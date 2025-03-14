USE [ServiceMac]
GO

CREATE OR ALTER PROCEDURE Processing.Update_RuleResults_Views @RuleId INT = NULL
AS
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @TableName VARCHAR(50);
DECLARE @RuleId_ INT;
DECLARE @ColumnList VARCHAR(MAX);
DECLARE @EndTime DATETIME2;

DELETE DataMart_Log.Update_RuleResults_Views_Log
WHERE ViewName = ISNULL(CONCAT('Rule_',@RuleId), ViewName);

/* List of rules */
DROP TABLE IF EXISTS #Rules;

SELECT T.TABLE_SCHEMA
	, T.TABLE_NAME
	, REPLACE(T.TABLE_NAME, 'Rule_', '' ) AS RuleId
INTO #Rules
FROM INFORMATION_SCHEMA.TABLES AS T
INNER JOIN Processing.RuleStates AS RS ON
	RS.TableName = T.TABLE_NAME
WHERE  T.TABLE_SCHEMA = 'DailyResults'
AND (@RuleId IS NULL OR @RuleId = RS.RuleId)
AND ((RS.IsInDevelopment = 1 AND Processing.CurrentEnvironment() = 'Development')
	 OR (RS.IsInUat = 1 AND Processing.CurrentEnvironment() = 'Test')
	 OR(RS.IsInProduction = 1 AND Processing.CurrentEnvironment() = 'Production'));

/* Identify rules to update (if column list does not change, view will not be updated) */
DROP TABLE IF EXISTS #ViewsToUpdate;

WITH SourceColumn AS
	(SELECT R.TABLE_NAME
	, C.COLUMN_NAME
	, CONCAT(
			C.DATA_TYPE
			, CASE WHEN C.DATA_TYPE LIKE '%char' THEN
						'(' + CONVERT(VARCHAR(5), C.CHARACTER_MAXIMUM_LENGTH) + ')'
					WHEN C.DATA_TYPE IN ( 'decimal', 'numeric' ) THEN
						'(' + CONVERT(VARCHAR(5), C.NUMERIC_PRECISION) + ','
						+ CONVERT(VARCHAR(5), C.NUMERIC_SCALE) + ')'
					ELSE
						''
			END) AS DataType
			, 0  AS IsJsonColumn
			, C.ORDINAL_POSITION
	FROM INFORMATION_SCHEMA.COLUMNS AS C
	CROSS JOIN #Rules AS R
	WHERE C.TABLE_SCHEMA = 'Results'
	AND C.TABLE_NAME = 'RuleResults'
	AND C.COLUMN_NAME <> 'ResultDetail'
	UNION
	SELECT RuleTable.TABLE_NAME
		 , RuleTable.COLUMN_NAME
		 , CONCAT(
				RuleTable.DATA_TYPE
				, CASE WHEN RuleTable.DATA_TYPE LIKE '%char' THEN
							'(' + CONVERT(VARCHAR(5), RuleTable.CHARACTER_MAXIMUM_LENGTH) + ')'
						WHEN RuleTable.DATA_TYPE IN ( 'decimal', 'numeric' ) THEN
							'(' + CONVERT(VARCHAR(5), RuleTable.NUMERIC_PRECISION) + +','
							+ CONVERT(VARCHAR(5), RuleTable.NUMERIC_SCALE) + ')'
				ELSE
					''
				END) AS DataType
		 , 1 AS IsJsonColumn
		 , RuleTable.ORDINAL_POSITION
	FROM INFORMATION_SCHEMA.COLUMNS AS RuleTable
	LEFT OUTER JOIN INFORMATION_SCHEMA.COLUMNS AS Base ON
		Base.TABLE_SCHEMA = 'Results'
		AND Base.TABLE_NAME = 'RuleResults'
		AND Base.COLUMN_NAME = RuleTable.COLUMN_NAME
	WHERE RuleTable.TABLE_SCHEMA = 'DailyResults'
	AND RuleTable.TABLE_NAME LIKE 'Rule[_]_____'
	AND RuleTable.COLUMN_NAME NOT IN ( 'EffectiveDate')
	AND Base.COLUMN_NAME IS NULL)
SELECT SourceColumn.TABLE_NAME
, SourceColumn.COLUMN_NAME
, SourceColumn.DataType
, SourceColumn.IsJsonColumn
, SourceColumn.ORDINAL_POSITION
INTO #ViewsToUpdate
FROM SourceColumn AS SourceColumn
WHERE EXISTS
(	SELECT 1
	FROM SourceColumn AS SC
	FULL OUTER JOIN
		( SELECT T.TABLE_NAME
			, C.COLUMN_NAME
		FROM INFORMATION_SCHEMA.TABLES AS T
		INNER JOIN INFORMATION_SCHEMA.COLUMNS AS C ON
			C.TABLE_SCHEMA = T.TABLE_SCHEMA
			AND C.TABLE_NAME = T.TABLE_NAME
		WHERE T.TABLE_TYPE = 'VIEW'
		AND T.TABLE_SCHEMA = 'Results') AS ViewStructure ON
			ViewStructure.TABLE_NAME = SC.TABLE_NAME
			AND ViewStructure.COLUMN_NAME = SC.COLUMN_NAME
		WHERE (SC.COLUMN_NAME IS NULL OR ViewStructure.COLUMN_NAME IS NULL) -- only include views that have a change
			  AND SC.TABLE_NAME = SourceColumn.TABLE_NAME)
		ORDER BY SourceColumn.TABLE_NAME
		, SourceColumn.ORDINAL_POSITION;

/* Column list for each rule with JSON extraction */
DROP TABLE IF EXISTS #RuleColumnList;

SELECT R.RuleId
, R.TABLE_NAME
, CAST(STRING_AGG(
			CASE WHEN VTU.IsJsonColumn = 0 THEN
					CONCAT('RR.', QUOTENAME(VTU.COLUMN_NAME) )
				ELSE
					CONCAT(
						'CONVERT('
						, VTU.DataType
						, ', JSON_VALUE(RR.[ResultDetail], ''$."'
						, VTU.COLUMN_NAME
						, '"'')) AS '
						, QUOTENAME (VTU.COLUMN_NAME) )
			END
		,',') WITHIN GROUP (ORDER BY VTU.IsJsonColumn
								   , VTU.ORDINAL_POSITION) AS VARCHAR(MAX)) AS ColumnList
			, ROW_NUMBER() OVER (ORDER BY R.RuleId) AS Seq
INTO #RuleColumnList
FROM #ViewsToUpdate AS VTU
INNER JOIN #Rules AS R ON
	R.TABLE_NAME = VTU.TABLE_NAME
GROUP BY R.RuleId
		, R.TABLE_NAME

/* Update views */
DECLARE @Seq INT = 1;
DECLARE @ViewSQL NVARCHAR(MAX);

WHILE @Seq <= (SELECT MAX(Seq) FROM #RuleColumnList)
BEGIN
	SELECT @TableName = RCL.TABLE_NAME
		, @RuleId_ = RuleId
		, @ColumnList = ColumnList
	FROM #RuleColumnList AS RCL
	WHERE RCL.Seq = @Seq;

	INSERT DataMart_Log.Update_RuleResults_Views_Log(ViewName, StartTime)
	VALUES(@TableName,SYSDATETIME());

	BEGIN TRY
		SET @ViewSQL = CONCAT('DROP VIEW IF EXISTS Results.', @TableName, ';');

		EXEC (@ViewSQL);

		SET @ViewSQL
		= CONCAT('CREATE VIEW Results.', @TableName
					,'AS
					SELECT	', @ColumnList
					,' 
					FROM Results.RuleResults AS RR
					WHERE RR.RuleId = ', @RuleId_,';');

		EXEC (@ViewSQL);

	END TRY
	BEGIN CATCH
		UPDATE DataMart_Log.Update_RuleResults_Views_Log
		SET Error = (SELECT ReturnedError FROM Processing.vw_ReturnedError)
		WHERE ViewName = @TableName;
	END CATCH;

	SET @Seq += 1;

	SET @EndTime = SYSDATETIME();

	UPDATE DataMart_Log.Update_RuleResults_Views_Log
	SET EndTime = @EndTime,
		RunTime_sec = CAST(DATEDIFF(mcs, StartTime, @EndTime)/1000000.0 AS DECIMAL(38,6)),
		ViewDefinition = @ViewSQL
	WHERE ViewName = @TableName;

END;