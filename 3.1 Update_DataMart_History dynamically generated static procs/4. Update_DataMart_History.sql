USE [ServiceMac]
GO

/****** Object:  StoredProcedure [Processing].[Update_DataMart_History]    Script Date: 12/19/2024 4:38:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [Processing].[Update_DataMart_History] @TableName VARCHAR(100) = NULL
AS
SET NOCOUNT ON;

DECLARE @ProcedureName VARCHAR(200) = CONCAT(OBJECT_SCHEMA_NAME(@@PROCID),'.', OBJECT_NAME(@@PROCID)),
@StartTime DATETIME = CURRENT_TIMESTAMP;

DELETE DataMart_Log.Update_DataMart_History_log;

INSERT DataMart_Log.Update_DataMart_History_log(ProcedureName, StartTime)
VALUES(@ProcedureName, @StartTime);

BEGIN TRY

	DROP PROC IF EXISTS Processing.Update_DataMart_History_Static;
	DECLARE @GenerateStaticProc NVARCHAR(MAX) =
	CONCAT('CREATE OR ALTER PROCEDURE Processing.Update_DataMart_History_Static @TableName VARCHAR(100) =',IIF(@TableName IS NULL,'NULL',CONCAT('''',@TableName,'''')),CHAR(13),'AS',CHAR(13),'SET NOCOUNT ON;',CHAR(13));

	/* Create and execute procedure to create missing History tables */
	DROP PROC IF EXISTS Processing.Create_Missing_History_Tables;
	EXEC Processing.Generate_Missing_History_Tables_Procedure @TableName = @TableName;
	EXEC Processing.Create_Missing_History_Tables;

	WAITFOR DELAY '00:00:01';

	/* Create and execute procedure to add missing columns */
	DROP PROC IF EXISTS Processing.Add_Missing_History_Tables_Columns;
	EXEC Processing.Generate_Missing_Columns_Procedure @TableName = @TableName
	EXEC Processing.Add_Missing_History_Tables_Columns;

	/* Columns to exclude from populating in daily history TABLE_*/
	DROP TABLE IF EXISTS #TableColumnsToIgnore;

	CREATE TABLE #TableColumnsToIgnore (TableName VARCHAR(100), ColumnName VARCHAR(100));
	INSERT INTO #TableColumnsToIgnore (TableName, ColumnName)
	VALUES
	('BusinessFields', 'DelinquentDayCount');

	DROP TABLE IF EXISTS #ColumnsToIgnore;

	CREATE TABLE #ColumnsToIgnore (ColumnName VARCHAR(100));
	INSERT INTO #ColumnsToIgnore (ColumnName)
	VALUES
	('RecordStartDate' )
	, ('RecordEndDate' )
	, ('RowHash' );

	/* Primary keys for tables */
	DROP TABLE IF EXISTS #PrimaryKeys;

	SELECT DISTINCT REPLACE(DE.TableName, ' (Derived)', '') AS TableName
				,DE.PrimaryKeyIndex
				,DE.ColumnName
	INTO #PrimaryKeys
	FROM Processing.DataElements AS DE
	WHERE DE.PrimaryKeyIndex IS NOT NULL
	ORDER BY TableName, PrimaryKeyIndex

	/* List of tables to store historically */
	DROP TABLE IF EXISTS #HistoryTables;

	SELECT	QUOTENAME (C.TABLE_NAME)																										 AS TableName
			, CONCAT('RowHash,', STRING_AGG(CAST(QUOTENAME(C.COLUMN_NAME) AS VARCHAR(MAX)), ', ') WITHIN GROUP(ORDER BY C.ORDINAL_POSITION)) AS ColumnList_Full
			, STRING_AGG(CAST(QUOTENAME(IIF(GREATEST(TCTI.ColumnName, CTI.ColumnName) IS NULL, C.COLUMN_NAME, NULL) ) AS VARCHAR(MAX) ), ',') WITHIN GROUP(ORDER BY C.ORDINAL_POSITION) AS ColumnList_RowHash
			, COUNT(IIF(GREATEST(TCTI.ColumnName, CTI.ColumnName) IS NULL, C.COLUMN_NAME, NULL))											AS ColumnList_RowHashCount
			, MAX(PK.PrimaryKey1_ColumnName)																								AS PrimaryKey1_ColumnName
			, MAX(PK.PrimaryKeyCondition)																									AS PrimaryKeyCondition
			, ROW_NUMBER() OVER (ORDER BY QUOTENAME(C.TABLE_NAME))																			AS Seq
	INTO #HistoryTables
	FROM INFORMATION_SCHEMA.COLUMNS AS C
	INNER JOIN INFORMATION_SCHEMA.TABLES AS T ON
		T.TABLE_SCHEMA		= C.TABLE_SCHEMA
		AND T.TABLE_NAME	= C.TABLE_NAME
	LEFT OUTER JOIN #TableColumnsToIgnore AS TCTI ON
		TCTI.TableName		= C.TABLE_NAME
		AND TCTI.ColumnName = C.COLUMN_NAME
	LEFT OUTER JOIN #ColumnsToIgnore AS CTI ON
		CTI.ColumnName		= C.COLUMN_NAME
	INNER JOIN
	(SELECT	PK.TableName								AS PrimaryKey1_ColumnName
			, MAX(IIF(PK.PrimaryKeyIndex = 1, QUOTENAME(PK.ColumnName), NULL) )
			, STRING_AGG(
				 CAST(CONCAT('Table1.', QUOTENAME(PK.ColumnName), ' = Table2.', QUOTENAME(PK.ColumnName)) AS VARCHAR(MAX)), ' AND ') WITHIN GROUP(ORDER BY PK.PrimaryKeyIndex) AS PrimaryKeyCondition
	FROM #PrimaryKeys AS PK
	GROUP BY PK.TableName) AS PK ON
	PK.TableName = C.TABLE_NAME
	WHERE C.TABLE_SCHEMA = 'DataMart'
		AND T.TABLE_TYPE = 'BASE TABLE'
		AND (T.TABLE_NAME = @TableName OR @TableName IS NULL)
		AND EXISTS (SELECT 1 FROM #PrimaryKeys AS PK WHERE PK.TableName = C.TABLE_NAME)
	GROUP BY C.TABLE_NAME;

	/* Identify and store historical records */
	DECLARE @DeltaTableSeq INT = 1;
	DECLARE @DeltaTableName VARCHAR(100);
	DECLARE @ColumnList_Full VARCHAR(MAX);
	DECLARE @ColumnList_RowHash VARCHAR(MAX);
	DECLARE @ColumnList_RowHashCount INT;
	DECLARE @PrimaryKey1_ColumnName VARCHAR(100);
	DECLARE @PrimaryKeyCondition VARCHAR(200);
	DECLARE @HistoryTableSQL VARCHAR(MAX);
	DECLARE @DeltaProcName VARCHAR(200);
	DECLARE @DropStaticProc VARCHAR(220);

	WHILE @DeltaTableSeq <= (SELECT MAX(Seq) FROM #HistoryTables)
	BEGIN
		SELECT @DeltaTableName			= HT.TableName
			, @ColumnList_Full			= HT.ColumnList_Full
			, @ColumnList_RowHash		= HT.ColumnList_RowHash
			, @ColumnList_RowHashCount	= HT.ColumnList_RowHashCount
			, @PrimaryKey1_ColumnName	= HT.PrimaryKey1_ColumnName
			, @PrimaryKeyCondition		= HT.PrimaryKeyCondition
		FROM #HistoryTables AS HT
		WHERE HT.Seq = @DeltaTableSeq;

		--Generate static proc for history update
		SET @DeltaProcName = CONCAT('Processing.Update_DataMart_History_', REPLACE(REPLACE(@DeltaTableName,'[' ,' ' ) , ']' , ' ' ) )

		IF (SELECT Processing.partitionsCount(CONCAT('DataMart_History.',@DeltaTableName))) > 1
		-- table is partitioned
		EXEC Processing.Update_History_Data_Static_Proc_Generator
			@DeltaProcName,
			@DeltaTableName,
			@ColumnList_RowHash,
			@ColumnList_RowHashCount,
			@PrimaryKeyCondition,
			@PrimaryKey1_ColumnName,
			@ColumnList_Full;
		ELSE
		-- table is not partitioned
		EXEC Processing.Update_History_Data_Static_Proc_Generator_NP
			@DeltaProcName,
			@DeltaTableName,
			@ColumnList_RowHash,
			@ColumnList_RowHashCount,
			@PrimaryKeyCondition,
			@PrimaryKey1_ColumnName,
			@ColumnList_Full;

		SET @GenerateStaticProc += CONCAT('EXEC ',@DeltaProcName,';',CHAR(13));

		SET @DeltaTableSeq += 1;
	END;

	-- Compile static proc
	EXEC (@GenerateStaticProc);

	-- Execute static proc
	EXEC Processing.Update_DataMart_History_Static;
	
	UPDATE DataMart_Log.Update_DataMart_History_log
	SET EndTime = CURRENT_TIMESTAMP,
		RunTime_sec = DATEDIFF(ss, @StartTime, CURRENT_TIMESTAMP),
		RunTime = Utilities.ParseTime(DATEDIFF(ss, @StartTime, CURRENT_TIMESTAMP))
	WHERE ProcedureName = @ProcedureName AND StartTime = @StartTime;

	SELECT * FROM DataMart_Log.Update_DataMart_History_log
	WHERE Error IS NOT NULL;
END TRY	
BEGIN CATCH
	UPDATE DataMart_Log.Update_DataMart_History_log
	SET EndTime = CURRENT_TIMESTAMP,
	RunTime_sec = DATEDIFF(ss, @StartTime, CURRENT_TIMESTAMP),
	RunTime = Utilities.ParseTime(DATEDIFF(ss, @StartTime, CURRENT_TIMESTAMP)),
	Error = (SELECT ReturnedError FROM Processing.vw_ReturnedError)
	WHERE ProcedureName = @ProcedureName AND StartTime = @StartTime;

	SELECT * FROM DataMart_Log.Update_DataMart_History_log
	WHERE Error IS NOT NULL;
END CATCH;


	
















GO


