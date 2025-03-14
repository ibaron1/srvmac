USE [ServiceMac]
GO

/****** Object:  StoredProcedure [Processing].[Update_DataMart]    Script Date: 12/27/2024 4:11:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER  PROCEDURE [Processing].[Update_DataMart] @ViewLogs INT = 0, @TargetSchema VARCHAR(100) = 'DataMart_PreviousDay'
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET DEADLOCK_PRIORITY 10; -- to lower deadlock priority

DECLARE @EmailSubject NVARCHAR(255);
DECLARE @EmailBody NVARCHAR(MAX) = N'';
DECLARE @EmailPriority  varchar(6); --Low, Normal (default), High

BEGIN TRY

	IF (SELECT LaunchDataMartUpdate FROM Utilities.Launch_DataMartUpdate) = 1
	BEGIN

		/* 1. Reset launch flag to be set by ControlTower */
		UPDATE Utilities.Launch_DataMartUpdate
		SET LaunchDataMartUpdate = 0;

		/* set up to exclude Update DataMart_PreviousDay schema from rerun */
		IF EXISTS
			(SELECT 1
			FROM DataMart_Log.Update_DataMart_log
			WHERE CAST(StartTime AS DATE) = CAST(GETDATE() AS DATE)
			AND ProcName = 'Utilities.MoveSchema' )	
		BEGIN
			DELETE DataMart_Log.Update_DataMart_log
			WHERE CAST(StartTime AS DATE) = CAST(GETDATE() AS DATE)
			AND ProcName <> 'Utilities.MoveSchema';

			UPDATE DataMart_Log.Update_DataMart_log
			SET	  Note = 'Rerun'
				, StartTime = CURRENT_TIMESTAMP
			WHERE CAST(StartTime AS DATE) = CAST(GETDATE() AS DATE)
			AND ProcName= 'Utilities.MoveSchema';
		END;
		ELSE 
			DELETE DataMart_Log.Update_DataMart_log;

		INSERT DataMart_Log.Update_DataMart_log (ProcName, StartTime, Note)
		SELECT 'Processing.Update_DataMart'
		, CURRENT_TIMESTAMP
		, 'Parent procedure cumulative time';

		/* 2. Update DataMart_PreviousDay schema */
		IF NOT EXISTS
			(SELECT 1
			FROM DataMart_Log.Update_DataMart_log AS UDM
			WHERE PreviousDayObjectsMovedToSchema = @TargetSchema
			AND UDM.ProcName = 'Utilities.MoveSchema' AND PreviousDayObjectsMovedToSchema = @TargetSchema)
		BEGIN
			INSERT DataMart_Log.Update_DataMart_log (ProcName, StartTime)

			VALUES ('Utilities.ClearSchemaObjects', CURRENT_TIMESTAMP);

			EXEC Utilities.ClearSchemaObjects @SchemaName = @TargetSchema;

			UPDATE DataMart_Log.Update_DataMart_log
			SET   EndTime = CURRENT_TIMESTAMP
				, RunTime_sec = DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP)
				, RunTime = Utilities.ParseTime(DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP))
			WHERE ProcName = 'Utilities.ClearSchemaObjects';

			INSERT DataMart_Log.Update_DataMart_log (ProcName, StartTime)
			VALUES
			('Utilities.MoveSchema', CURRENT_TIMESTAMP);

			EXEC Utilities.MoveSchema @SourceSchema = 'DataMart', @TargetSchema = @TargetSchema;

			UPDATE DataMart_Log.Update_DataMart_log
			SET   EndTime = CURRENT_TIMESTAMP
				, RunTime_sec = DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP)
				, RunTime = Utilities.ParseTime(DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP) )
				, PreviousDayObjectsMovedToSchema = @TargetSchema
			WHERE ProcName = 'Utilities.MoveSchema';

		END;

		/* 3. Copy tables to 2.0 instance Staging tables */
		BEGIN TRY
		INSERT DataMart_Log.Update_DataMart_log (ProcName, StartTime)
		VALUES
		('Processing.Import_DataFromControlTowerToEtlStage', CURRENT_TIMESTAMP);

		EXEC Processing.Import_DataFromControlTowerToEtlStage;

		UPDATE DataMart_Log.Update_DataMart_log
		SET   EndTime = CURRENT_TIMESTAMP
			, RunTime_sec = DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP)
			, RunTime = Utilities.ParseTime(DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP) )
		WHERE ProcName = 'Processing.Import_DataFromControlTowerToEtlStage';
		END TRY
		BEGIN CATCH
			UPDATE DataMart_Log.Update_DataMart_log
			SET   EndTime = CURRENT_TIMESTAMP
				, RunTime_sec = DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP)
				, RunTime = Utilities.ParseTime(DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP) )
				, Error = (SELECT ReturnedError FROM Processing.vw_ReturnedError)
			WHERE ProcName = 'Processing.Import_DataFromControlTowerToEtlStage';
		END CATCH;

		/* 4. EtlCopy tables from Staging to datamart tables mapping into DevOps column names and data types, create discrepancy report, build indexes
		Create derived tables and build indexes */
		BEGIN TRY
		INSERT DataMart_Log.Update_DataMart_log(ProcName, StartTime)
		VALUES
		('Processing.Import_DataMartTablesFromEtlStage', CURRENT_TIMESTAMP);

		EXEC Processing.Import_DataMartTablesFromEtlStage;

		UPDATE DataMart_Log.Update_DataMart_log
		SET EndTime = CURRENT_TIMESTAMP
		, RunTime_sec = DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP)
		, RunTime = Utilities.ParseTime(DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP) )
		WHERE ProcName = 'Processing.Import_DataMartTablesFromEtlStage';
		END TRY
		BEGIN CATCH
		UPDATE DataMart_Log.Update_DataMart_log
		SET EndTime = CURRENT_TIMESTAMP
		, RunTime_sec = DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP)
		, RunTime = Utilities.ParseTime(DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP))
		, Error = (SELECT ReturnedError FROM Processing.vw_ReturnedError)
		WHERE ProcName = 'Processing.Import_DataMartTablesFromEtlStage';
		END CATCH;

		/* 5.Update cycle date tables */
		BEGIN TRY
			DELETE DataMart_Log.Update_DataMart_log
			WHERE ProcName = 'Processing.Update_AllCycleDateTables';

			INSERT DataMart_Log.Update_DataMart_log (ProcName, StartTime)
			VALUES
			('Processing.Update_AllCycleDateTables', CURRENT_TIMESTAMP);

			EXEC Processing.Update_AllCycleDateTables;

			UPDATE DataMart_Log.Update_DataMart_log
			SET   EndTime = CURRENT_TIMESTAMP
				, RunTime_sec = DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP)
				, RunTime = Utilities.ParseTime(DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP) )
			WHERE ProcName = 'Processing.Update_AllCycleDateTables';
		END TRY
		BEGIN CATCH
			UPDATE DataMart_Log.Update_DataMart_log
			SET EndTime = CURRENT_TIMESTAMP
			, RunTime_sec = DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP)
			, RunTime = Utilities.ParseTime(DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP) )
			, Error = (SELECT ReturnedError FROM Processing.vw_ReturnedError)
			WHERE ProcName = 'Processing.Update_AllCycleDateTables';
		END CATCH;

		/* 6. Update DataMart_History tables */
		BEGIN TRY
			DELETE DataMart_Log.Update_DataMart_log
			WHERE ProcName = ' Processing.Update_DataMart_History';

			INSERT DataMart_Log.Update_DataMart_log (ProcName, StartTime)
			VALUES
			('Processing.Update_DataMart_History', CURRENT_TIMESTAMP);

			EXEC Processing.Update_DataMart_History;

			UPDATE DataMart_Log.Update_DataMart_log
			SET   EndTime = CURRENT_TIMESTAMP
				, RunTime_sec = DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP)
				, RunTime = Utilities.ParseTime(DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP) )
			WHERE ProcName = 'Processing.Update_DataMart_History';
		END TRY
		BEGIN CATCH
			UPDATE DataMart_Log.Update_DataMart_log
			SET   EndTime = CURRENT_TIMESTAMP
				, RunTime_sec = DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP)
				, RunTime = Utilities.ParseTime(DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP) )
				, Error = (SELECT ReturnedError FROM Processing.vw_ReturnedError)
			WHERE ProcName = ' Processing.Update_DataMart_History';
		END CATCH;

		/* 7. Update DataMart_Daily views */
		BEGIN TRY
			INSERT DataMart_Log.Update_DataMart_log (ProcName, StartTime)
			VALUES
			('Processing.Update_DataMart_Daily_Views', CURRENT_TIMESTAMP);

			EXEC Processing.Update_DataMart_Daily_Views;

			UPDATE DataMart_Log.Update_DataMart_log
			SET EndTime = CURRENT_TIMESTAMP
			, RunTime_sec = DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP)
			, RunTime = Utilities.ParseTime(DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP) )
			WHERE ProcName = 'Processing.Update_DataMart_Daily_Views';
		END TRY
		BEGIN CATCH
			UPDATE DataMart_Log.Update_DataMart_log
			SET EndTime = CURRENT_TIMESTAMP
			, RunTime_sec = DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP)
			, RunTime = Utilities.ParseTime(DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP) )
			, Error = (SELECT ReturnedError FROM Processing.vw_ReturnedError)
			WHERE ProcName = 'Processing.Update_DataMart_Daily_Views';
		END CATCH;

		/* 8. Update DataMart_MonthEnd and DataMart_MonthEndHistory schemas at month end */
		IF EXISTS
			(SELECT 1
			FROM DateReference.CycleDates AS CD
			WHERE CD.CycleDate = DateReference.EffectiveDate()
			AND CD.IsMonthEnd = 1)
		BEGIN
			BEGIN TRY
				INSERT DataMart_Log.Update_DataMart_log (ProcName, StartTime)
				VALUES
				('Utilities.ClearSchemaObjects', CURRENT_TIMESTAMP);

				EXEC Utilities.ClearSchemaObjects @SchemaName = 'DataMart_MonthEnd';

				UPDATE DataMart_Log.Update_DataMart_log
				SET EndTime = CURRENT_TIMESTAMP
					, RunTime_sec = DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP)
					, RunTime = Utilities.ParseTime(DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP) )
				WHERE ProcName = 'Utilities.ClearSchemaObjects';
			END TRY
			BEGIN CATCH
				UPDATE DataMart_Log.Update_DataMart_log
				SET EndTime = CURRENT_TIMESTAMP
				, RunTime_sec = DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP)
				, RunTime = Utilities.ParseTime(DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP) )
				, Error = (SELECT ReturnedError FROM Processing.vw_ReturnedError)
				WHERE ProcName = 'Utilities.ClearSchemaObjects';
			END CATCH;

			BEGIN TRY
				INSERT DataMart_Log.Update_DataMart_log (ProcName, StartTime)
				VALUES
				('Utilities.DuplicateSchema', CURRENT_TIMESTAMP);

				EXEC Utilities.DuplicateSchema @SourceSchema = 'DataMart', @TargetSchema = 'DataMart_MonthEnd';

				UPDATE DataMart_Log.Update_DataMart_log
				SET   EndTime = CURRENT_TIMESTAMP
					, RunTime_sec = DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP)
					, RunTime = Utilities.ParseTime(DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP) )
				WHERE ProcName = 'Utilities.DuplicateSchema';
			END TRY
			BEGIN CATCH
				UPDATE DataMart_Log.Update_DataMart_log
				SET   EndTime = CURRENT_TIMESTAMP
					, RunTime_sec = DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP)
					, RunTime = Utilities.ParseTime(DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP) )
					, Error = (SELECT ReturnedError FROM Processing.vw_ReturnedError)
				WHERE ProcName = 'Utilities.DuplicateSchema';
			END CATCH;

			BEGIN TRY
				INSERT DataMart_Log.Update_DataMart_log (ProcName, StartTime)
				VALUES
				('Processing.Update_DataMart_MonthEndHistory', CURRENT_TIMESTAMP);

				EXEC Processing.Update_DataMart_MonthEndHistory @TableName = NULL;

				UPDATE DataMart_Log.Update_DataMart_log
				SET   EndTime = CURRENT_TIMESTAMP
					, RunTime_sec = DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP)
					, RunTime = Utilities.ParseTime(DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP) )
					WHERE ProcName = 'Processing.Update_DataMart_MonthEndHistory';
			END TRY
			BEGIN CATCH
				UPDATE DataMart_Log.Update_DataMart_log
				SET   EndTime = CURRENT_TIMESTAMP
					, RunTime_sec = DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP)
					, RunTime = Utilities.ParseTime(DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP))
					, Error = (SELECT ReturnedError FROM Processing.vw_ReturnedError)
				WHERE ProcName = 'Processing.Update_DataMart_MonthEndHistory';
			END CATCH;
		END;

		UPDATE DataMart_Log.Update_DataMart_log
		SET   EndTime = CURRENT_TIMESTAMP
			, RunTime_sec = DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP)
			, RunTime = Utilities.ParseTime(DATEDIFF(ss, StartTime, CURRENT_TIMESTAMP) )
		WHERE ProcName = 'Processing.Update_DataMart';

		/* 9. Add query plan */
		UPDATE Upd
		SET QueryPlan = QueryPlan.query_plan
		FROM DataMart_Log.Update_DataMart_log AS Upd
		CROSS APPLY sys.dm_exec_cached_plans AS cp
		CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS QueryPlan
		WHERE QueryPlan.dbid = DB_ID()
		AND QueryPlan.objectid = OBJECT_ID(Upd.ProcName);

		/* Optionally view logs */
		IF @ViewLogs = 1
		BEGIN
			SELECT *
			FROM ServiceMac.DataMart_Log.Update_DataMart_log;
			SELECT *
			FROM ServiceMac.DataMart_Log.Import_DataFromControlTowerToEtlStage_log;
			SELECT *
			FROM ServiceMac.DataMart_Log.Import_DataMartTablesFromEtlStage_Log;
			SELECT *
			FROM ServiceMac.DataMart_Log.MissingOrIncorrectEtlStageColumns;
			SELECT *
			FROM ServiceMac.DataMart_Log.Update_DataMart_History_log;
			SELECT *
			FROM ServiceMac.DataMart_Log.Update_DataMart_MonthEndHistory_log;
		END;

		/* 10. Send summary results */
		SELECT @EmailSubject = CONCAT(Utilities.Env(), ' DataMart Update ')
		, @EmailPriority = 'Normal';

		IF NOT EXISTS (SELECT 1 FROM Processing.vw_DataMartUpdateError WHERE Error IS NOT NULL)
			SET @EmailSubject += N'Success, ';
		ELSE
			SELECT @EmailBody += CONCAT(@EmailBody, CHAR(13), 'Errors', CHAR(13), Error, CHAR(13))
			, @EmailSubject += N'completed with some errors,'
			, @EmailPriority = 'Normal'
			FROM Processing.vw_DataMartUpdateError;

		SELECT @EmailSubject += CONCAT(
									CONVERT(CHAR(20), MAX(EndTime), 20)
									, ', run time '
									, Utilities.ParseTime(DATEDIFF(ss, MIN(StartTime), MAX(EndTime))))
		FROM DataMart_Log.Update_DataMart_log;

		SELECT @EmailBody += CONCAT('Started ', CONVERT(CHAR(20), MIN(StartTime), 20))
		FROM DataMart_Log.Update_DataMart_log;

		SET @EmailBody += N'

	Procedure : RunTime
	--------------------------
	'				;

		SELECT @EmailBody += CONCAT(
								STUFF(ProcName, 1, CHARINDEX('.', ProcName), '')
							, ' : '
							, RunTime
							, ' '
							, Note
							, CHAR(13))
							FROM DataMart_Log.Update_DataMart_log;

		SET @EmailBody += N'
	DataMart Update Processing Logs
	------------------------------------------
	DataMart_Log.Update_DataMart_log						-- DataMart Cycle Dates update
	DataMart_Log.Import_DataFromControlTowerToEtlStage_log	-- Data copy from source to staging tables
	DataMart_Log.Import_DataMartTablesFromEtlStage_log		-- Data from ETL Staging tables is loaded into DataMart as per columns mapping
	DataMart_Log.MissingOrIncorrectEtlStageColumns			-- Missing/Incorrect ETL Staging table columns not defined in mapping
	DataMart_Log.Update_DataMart_History_log				-- DataMart History Update
	DataMart_Log.Update_DataMart_MonthEndHistory_log		DataMart Month End History Update';


		EXEC msdb.dbo.sp_send_dbmail 
				@profile_name = 'DbMail',
				@recipients = 'ibaron1@msn.com',
				@subject = @EmailSubject, --'testing dbmail',
				@body = @EmailBody,
				@importance = 'Normal', --@EmailPriority, --Low, Normal (default), High
				@body_format = 'TEXT'; -- TEXT(default) | HTML

						/* Service Mac wraparound, very few params, limited body size, no attachement param
						EXEC DBA.Utilities.SendEmail @Recipients = 'jim.crouse@servicemacusa.com;
										eli.baron@servicemacusa.com;'
										-- joseph.trinh@servicemacusa.com'
										, @Subject = @EmailSubject
										, @Body = @EmailBody
										, @Priority = 0;
						*/

		IF EXISTS (SELECT 1 FROM DataMart_Log.Update_DataMart_MonthEndHistory_log)
			DELETE FROM DataMart_Log.Update_DataMart_MonthEndHistory_log;

		IF EXISTS (SELECT 1 FROM DataMart_Log.MissingOrIncorrectEtlStageColumns)
		BEGIN
			SET @EmailBody = N'';

			SELECT @EmailSubject
				= CONCAT (
				  Utilities.Env()
				,' DataMart Update Missing/Incorrect ETL Staging Tables Column Mapping Report')
				, @EmailBody += CONCAT(
				 'Table : '
				, EtlStageTable
				, ' || '
				,'NotDefinedColumnNameFromEtlStage : '
				, NotDefinedColumnNameFromEtlStage
				, ' || '
				, 'Missing DevOps.Sentry360_2.0 Title/Column : '
				, [Missing DevOps.Sentry360_2.0 Title/Column]
				, CHAR(13))
			FROM DataMart_Log.MissingOrIncorrectEtlStageColumns;

select @EmailSubject as [Email subject], @EmailBody as [Email Body]

			EXEC msdb.dbo.sp_send_dbmail 
				@profile_name = 'DbMail',
				@recipients = 'ibaron1@msn.com',
				@subject = @EmailSubject, --'testing dbmail',
				@body = @EmailBody,
				@importance = 'Normal', --@EmailPriority, --Low, Normal (default), High
				@body_format = 'TEXT'; -- TEXT(default) | HTML
						/* Service Mac wraparound, very few params, limited body size, no attachement param
						EXEC DBA.Utilities.SendEmail @Recipients = 'jim.crouse@servicemacusa.com;
										eli.baron@servicemacusa.com;'
										-- joseph.trinh@servicemacusa.com'
										, @Subject = @EmailSubject
										, @Body = @EmailBody
										, @Priority = 0;
						*/
			END;

					/* 11.Set Rules Engine Execute launch */
					UPDATE Utilities.Launch_ExecuteRulesEngine
					SET LaunchExecuteRulesEngine = 1
					, LaunchTime = CURRENT_TIMESTAMP
					, ErrorTime = NULL
					, ErrorToLaunch = NULL;
	END;
END TRY
BEGIN CATCH
	/* 12.Launch failure, send summary results */
	UPDATE Utilities.Launch_DataMartUpdate
	SET	 ErrorToLaunch = (SELECT ReturnedError FROM Processing.vw_ReturnedError)
		,ErrorTime = CURRENT_TIMESTAMP;

	SELECT @EmailBody = ErrorToLaunch
			,@EmailSubject = CONCAT(Utilities.Env(), ' DataMart Update failed to complete, ', ErrorTime)
			,@EmailPriority = 'High'
	FROM Utilities.Launch_DataMartUpdate;

	EXEC msdb.dbo.sp_send_dbmail 
		@profile_name = 'DbMail',
		@recipients = 'ibaron1@msn.com',
		@subject = @EmailSubject, --'testing dbmail',
		@importance = @EmailPriority, --Low, Normal (default), High
		@body_format = 'TEXT'; -- TEXT(default) | HTML

	/*  DBA.Utilities.SendEmail is a wraparound proc calling msdb.dbo.sp_send_dbmail with limited functionality, i.e. only few parameters used, w very small @body size and no attachement
		EXEC DBA.Utilities.SendEmail @Recipients = 'jim.crouse@servicemacusa.com;
							eli.baron@servicemacusa.com'
								,@Subject = @EmailSubject
								,@Body = @EmailBody
								,@Priority = @EmailPriority;
	*/


END CATCH;


GO


