USE ServiceMac;
GO
DROP PROC IF EXISTS Processing.Update_History_Data_Static_Proc_Generator_NP;
GO
CREATE PROCEDURE Processing.Update_History_Data_Static_Proc_Generator_NP
@DeltaProcName VARCHAR(200)
,@DeltaTableName VARCHAR(100)
,@ColumnList_RowHash VARCHAR(MAX)
,@ColumnList_RowHashCount INT
,@PrimaryKeyCondition VARCHAR(200)
,@PrimaryKey1_ColumnName VARCHAR(100)
,@ColumnList_Full VARCHAR(MAX)
AS
SET NOCOUNT ON;

DECLARE @DropProc VARCHAR(220) = CONCAT('DROP PROC IF EXISTS ', @DeltaProcName);
EXEC (@DropProc);

DECLARE @GenerateStaticProc VARCHAR(MAX)
= CONCAT('CREATE PROCEDURE ', @DeltaProcName, CHAR(13), 'AS
SET NOCOUNT ON;', CHAR(13));

DECLARE @columnlist VARCHAR(MAX);
DECLARE @RowHash VARCHAR(MAX);

SELECT @RowHash =
	CONCAT('CONVERT(BIGINT, HASHBYTES(''SHA1',',', CONCAT((SELECT STRING_AGG(CAST(CONCAT('CAST(',value,' AS VARCHAR(100))+'' |''') AS VARCHAR(MAX)), '+') FROM STRING_SPLIT(@ColumnList_RowHash,',')),'))'));

SET @GenerateStaticProc += CONCAT('							
	/* Variables */
	DECLARE @EffectiveDate DATE = DateReference.EffectiveDate();

	DECLARE @ProcedureName VARCHAR(200) = CONCAT(OBJECT_SCHEMA_NAME(@@PROCID),''.'', OBJECT_NAME(@@PROCID)),
	@StartTime DATETIME = CURRENT_TIMESTAMP;

	INSERT DataMart_Log.Update_DataMart_History_log(ProcedureName, StartTime)
	VALUES(@ProcedureName, @StartTime)

	BEGIN TRY

	/* Reset RecordStartDate/RecordEndDate (for reruns) */
	UPDATE L
	SET RecordEndDate = NULL
	FROM DataMart_History.'
			,@DeltaTableName
			,' AS L -- WITH (FORCESEEK) -- execution time error that cannot use this hint
	WHERE L.RecordEndDate = @EffectiveDate;

	DELETE L
	FROM DataMart_History.'
					,@DeltaTableName
					,' AS L
	WHERE RecordStartDate = @EffectiveDate;

	/* Identify delta records */
	DROP TABLE IF EXISTS #Deltas;

	DECLARE @RecordEndDate DATE = NULL;

	SELECT Today .*
	INTO #Deltas
	FROM DataMart.'
		,@DeltaTableName
		,' AS Today
	LEFT OUTER JOIN DataMart_History.'
						,@DeltaTableName
						,' AS History -- WITH (FORCESEEK)
	ON '
						, REPLACE(REPLACE(@PrimaryKeyCondition, 'Table1', 'Today' ), 'Table2', 'History' )
						,'
	AND Today.RowHash = History.RowHash
	AND History.RecordEndDate IS NULL
	WHERE History.RowHash IS NULL;

	/* End date changing records */
	UPDATE History
	SET History.RecordEndDate = @EffectiveDate
	FROM #Deltas AS D
	INNER JOIN DataMart_History.'
							,@DeltaTableName
							,' AS History -- WITH (FORCESEEK)
	ON '
	, REPLACE (REPLACE(@PrimaryKeyCondition, 'Table1', 'History'), 'Table2', 'D')
	, ' AND History.RecordEndDate IS NULL

	/* End date deleted records */
	UPDATE History
	SET History.RecordEndDate = @EffectiveDate
	FROM DataMart_History.'
					, @DeltaTableName
					,' AS History -- WITH (FORCESEEK)
	LEFT OUTER JOIN DataMart.'
						, @DeltaTableName
						, ' AS Today ON 
									'
						, REPLACE(REPLACE(@PrimaryKeyCondition, 'Table1', 'History' ), 'Table2', 'Today')
						, '
	WHERE History.RecordEndDate IS NULL
	AND Today.'
	,@PrimaryKey1_ColumnName
	, 'IS NULL;

	/* insert new records */
	INSERT INTO DataMart_History.'
				, @DeltaTableName
				, ' ('
				, REPLACE(@ColumnList_Full,'RowHash,' ,'')
				, ')
		SELECT '
	, REPLACE(@ColumnList_Full,'RowHash,' ,' ' )
	, '
		FROM #Deltas AS D;

	UPDATE DataMart_Log.Update_DataMart_History_log
	SET EndTime = CURRENT_TIMESTAMP,
		RunTime_sec = DATEDIFF(ss, @StartTime, CURRENT_TIMESTAMP),
		RunTime = Utilities.ParseTime(DATEDIFF(ss, @StartTime, CURRENT_TIMESTAMP)),
		RecordsAdded = @@ROWCOUNT
	WHERE ProcedureName = @ProcedureName AND StartTime = @StartTime;
	
	END TRY
	BEGIN CATCH
		UPDATE DataMart_Log.Update_DataMart_History_log
		SET EndTime = CURRENT_TIMESTAMP,
			RunTime_sec = DATEDIFF(ss, @StartTime, CURRENT_TIMESTAMP),
			RunTime = Utilities.ParseTime(DATEDIFF(ss, @StartTime, CURRENT_TIMESTAMP)),
			Error = (SELECT ReturnedError FROM Processing.vw_ReturnedError)
		WHERE ProcedureName = @ProcedureName AND StartTime = @StartTime;
	END CATCH;
	');

-- compile proc
EXEC (@GenerateStaticProc);
