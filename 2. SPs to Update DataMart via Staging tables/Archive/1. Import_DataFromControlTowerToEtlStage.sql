CREATE OR ALTER PROCEDURE Processing.Import_DataFromControlTowerToEtlStage @TableName VARCHAR(200) = NULL
AS
SET NOCOUNT ON;

DELETE DataMart_Log.Import_DataFromControlTowerToEtlStage_log;

INSERT DataMart_Log.Import_DataFromControlTowerToEtlStage_log (ProcName, StartTime)
SELECT 'Processing.Import_DataFromControlTowerToEtlStage'
, CURRENT_TIMESTAMP;

DECLARE @EtlStageTables TABLE (EtlStageTable VARCHAR(4000), ImportTable# INT);
DECLARE @EtlStageTable VARCHAR(200);
DECLARE @SQLStr VARCHAR(MAX);
DECLARE @EffectiveDate DATE;

/* Drop all EtlStage tables before refresh from ControlTower tables */
DECLARE @DropTableSQL VARCHAR(MAX);

SELECT @DropTableSQL = STRING_AGG(CONCAT('DROP TABLE IF EXISTS ', T.TABLE_SCHEMA, '.', T.TABLE_NAME), ' ; ' )
FROM INFORMATION_SCHEMA.TABLES AS T
WHERE T.TABLE_SCHEMA = 'EtlStage'
AND T.TABLE_TYPE = 'BASE TABLE'
AND (T.TABLE_NAME = @TableName OR @TableName IS NULL);

EXEC (@DropTableSQL);

/* Import ControlTower tables with data into EtlStage */
INSERT @EtlStageTables
SELECT T.TABLE_NAME
, ROW_NUMBER() OVER (ORDER BY T.TABLE_NAME) AS ImportTable#
--FROM [SM-SQLDEV.97600FBB54A7.DATABASE.WINDOWS.NET].ControlTower.INFORMATION_SCHEMA.TABLES AS T
FROM ControlTower.INFORMATION_SCHEMA.TABLES AS T
WHERE T.TABLE_SCHEMA = 'DataExport_Uat'
AND (T.TABLE_NAME = @TableName OR @TableName IS NULL)
AND EXISTS (SELECT 1 FROM Processing.DataElements WHERE TableName = T.TABLE_NAME);

DECLARE @import TABLE
(ColumnName VARCHAR(4000) NULL
, DataType VARCHAR(100) NULL
, IS_NULLABLE VARCHAR(3) NULL
, OrdinalPosition INT NULL);

SELECT @EffectiveDate = DateReference.EffectiveDate();

DECLARE @GenerateStaticProc NVARCHAR(MAX)
	= CONCAT(
			'CREATE OR ALTER PROCEDURE Processing.Import_DataFromControlTowerToEtlStage_static
AS
SET NOCOUNT ON;', CHAR(13));

DECLARE @ImportTable# INT = 1;

BEGIN TRY

	WHILE @ImportTable# <= (SELECT MAX(ImportTable#) FROM @EtlStageTables)
	BEGIN
		SELECT @EtlStageTable = EtlStageTable
		FROM @EtlStageTables
		WHERE ImportTable# = @ImportTable#;

		DELETE @import;

		INSERT @import
		SELECT		 C.COLUMN_NAME AS ColumnName
					,'varchar(4000)' AS DataType
					,C.IS_NULLABLE -- S.PrimaryKeyIndex
					,C.ORDINAL_POSITION
		FROM	ControlTower.INFORMATION_SCHEMA.TABLES AS T	
					--[SM-SQLDEV.97600FBB54A7.DATABASE.WINDOWS.NET].ControlTower.INFORMATION_SCHEMA.TABLES AS T
		INNER JOIN ControlTower.INFORMATION_SCHEMA.COLUMNS AS C ON
				--[SM-SQLDEV.97600FBB54A7.DATABASE.WINDOWS.NET].ControlTower.INFORMATION_SCHEMA.COLUMNS AS C ON
					T.TABLE_SCHEMA = C.TABLE_SCHEMA
					AND T.TABLE_NAME = C.TABLE_NAME
		WHERE T.TABLE_TYPE	= 'BASE TABLE'
		AND T.TABLE_NAME	= @EtlStageTable
		AND T.TABLE_SCHEMA	= 'DataExport_Uat'
		AND LTRIM(RTRIM(C.COLUMN_NAME) ) NOT IN ( 'RecordStartDate', 'RecordEndDate' )
		ORDER BY C.ORDINAL_POSITION;

		SELECT @SQLStr
		= CONCAT (
		'SELECT NULLIF (CAST('''
		, @EffectiveDate
		, ''' AS DATE), '''') AS RecordStartDate, CAST(NULL AS DATE) AS RecordEndDate, '
		, CHAR(13));

		SELECT @SQLStr += CONCAT(
						STRING_AGG(
							CASE WHEN IS_NULLABLE = 'YES' 
									THEN
										CAST (CONCAT(
												'NULLIF(CAST('
												, ColumnName
												, ' AS '
												, DataType
												,'), '''') AS '
												, ColumnName) AS VARCHAR(MAX))

								ELSE
									CAST (CONCAT(
												'CAST ('
												, ColumnName
												, ' AS '
												, DataType
												, ') AS '
												, ColumnName) AS VARCHAR(MAX))
							END
						, ',')
		, ' INTO EtlStage.'
		, @EtlStageTable
		,' FROM ControlTower.DataExport_Uat.'
		, @EtlStageTable
		, ';'
		, CHAR(13)
		, CHAR(13))
		FROM @import;

		SET @GenerateStaticProc += @SQLStr;

		SET @ImportTable# += 1;

	END;

	EXEC (@GenerateStaticProc);

	EXEC Processing.Import_DataFromControlTowerToEtlStage_static;

	/* Complete logging */

	UPDATE Import
	SET   Import.GeneratedProcDefinition = SqlText.text
		, Import.QueryPlan = QueryPlan.query_plan
		, Import.EndTime = CURRENT_TIMESTAMP
		, Import.RunTime_sec = DATEDIFF(ss, Import.StartTime, CURRENT_TIMESTAMP)
		, Import.RunTime = Utilities.ParseTime(DATEDIFF(ss, Import.StartTime, CURRENT_TIMESTAMP))
	FROM sys.dm_exec_cached_plans AS cp
	CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS SqlText
	CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS QueryPlan
	CROSS APPLY DataMart_Log.Import_DataFromControlTowerToEtlStage_log AS Import
	WHERE QueryPlan.dbid = DB_ID()
	AND QueryPlan.objectid = OBJECT_ID(Import.ProcName);
END TRY
BEGIN CATCH
	UPDATE Import
	SET   Import.GeneratedProcDefinition = SqlText.text
		, Import.QueryPlan = QueryPlan.query_plan
		, Import.EndTime = CURRENT_TIMESTAMP
		, Import.RunTime_sec = DATEDIFF(ss, Import.StartTime, CURRENT_TIMESTAMP)
		, Import.RunTime = Utilities.ParseTime(DATEDIFF(ss, Import.StartTime, CURRENT_TIMESTAMP) )
		, Import.Error = (SELECT ReturnedError FROM Processing.vw_ReturnedError)
	FROM sys.dm_exec_cached_plans AS cp
	CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS SqlText
	CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS QueryPlan
	CROSS APPLY DataMart_Log.Import_DataFromControlTowerToEtlStage_log AS Import
	WHERE QueryPlan.dbid = DB_ID()
	AND QueryPlan.objectid = OBJECT_ID(Import.ProcName);
END CATCH;








