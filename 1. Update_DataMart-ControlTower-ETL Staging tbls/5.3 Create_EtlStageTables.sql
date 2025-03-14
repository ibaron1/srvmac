CREATE PROCEDURE [Processing].[Create_EtlStageTables] @TableName VARCHAR(100) = NULL
AS
SET NOCOUNT ON;

/* All data elements */
DROP TABLE IF EXISTS #DataElements;

SELECT S.FileName AS TableName
, S.Title		 AS ColumnName
, CASE WHEN S.DataType = 'varchar' THEN
	CONCAT(S.DataType, '(', S.CharacterLength, ') ')
WHEN S.DataType = 'decimal' THEN
	CONCAT(S.DataType, '(', ISNULL(S.DecimalPrecision,38), ',', ISNULL(S.DecimalScale, 0), ')')
ELSE
	S.DataType
END	AS DataType
, S.PrimaryKeyIndex
, ROW_NUMBER() OVER (PARTITION BY S.FileName ORDER BY IIF(S.PrimaryKeyIndex IS NULL, 1, 0), S.PrimaryKeyIndex, S.Title) AS OrdinalPosition
INTO #DataElements
FROM DevOps.[Sentry360_2.0] AS S
WHERE S.WorkItemType = 'Data Element'
AND S.State = 'User Testing'
AND S.FileName NOT LIKE '%(Derived)%'
AND S.Title NOT IN ( 'RecordStartDate', 'RecordEndDate' )
AND (S.FileName = @TableName OR NULLIF(@TableName, '') IS NULL);













/* Add RecordStartDate/RecordEndDate */
INSERT INTO #DataElements (TableName, ColumnName, DataType, PrimaryKeyIndex, OrdinalPosition)
SELECT DISTINCT
DE.TableName
,'RecordStartDate' AS ColumnName
,'date' AS DataType
, NULL AS PrimaryKeyIndex
,-2 AS OrdinalPosition
FROM #DataElements AS DE;

INSERT INTO #DataElements (TableName, ColumnName, DataType, PrimaryKeyIndex, OrdinalPosition)
SELECT DISTINCT
DE.TableName
,'RecordEndDate' AS ColumnName
,'date' AS DataType
,NULL AS PrimaryKeyIndex
,-1 AS OrdinalPosition
FROM #DataElements AS DE;

/* Drop all tables in schema */
DECLARE @DropTableSQL VARCHAR(MAX);

SELECT @DropTableSQL = STRING_AGG(CONCAT('DROP TABLE IF EXISTS ', T.TABLE_SCHEMA, '.', T.TABLE_NAME), '; ')
FROM INFORMATION_SCHEMA.TABLES AS T
WHERE T.TABLE_SCHEMA = 'EtlStage'
AND T.TABLE_TYPE = 'BASE TABLE'
AND (T.TABLE_NAME = @TableName OR NULLIF(@TableName, '') IS NULL);

EXEC (@DropTableSQL);

/* Create tables */
-- Generate drop/create SQL
DROP TABLE IF EXISTS #CreateTableSql;

SELECT CONCAT (
'
CREATE TABLE EtlStage.'
, DE.TableName

, STRING_AGG(
		CONCAT(DE.ColumnName, ' ', DE.DataType, IIF(DE.PrimaryKeyIndex IS NULL, '', ' NOT NULL' ) ), ',')WITHIN GROUP(ORDER BY DE.OrdinalPosition)
		, ');
		') AS CreateTableSQL
, ROW_NUMBER() OVER (ORDER BY DE.TableName) AS Seq
INTO #CreateTableSql
FROM #DataElements AS DE
GROUP BY DE.TableName;

-- Loop through tables to drop/create
DECLARE @CreateTableSeq INT = 1;
DECLARE @CreateTableSQL VARCHAR(MAX);

WHILE @CreateTableSeq <= (SELECT MAX(Seq) FROM #CreateTableSql)
BEGIN
	SELECT @CreateTableSQL = CTS.CreateTableSQL
	FROM #CreateTableSql AS CTS
	WHERE CTS.Seq = @CreateTableSeq;

	EXEC (@CreateTableSQL);

	SET @CreateTableSeq = @CreateTableSeq + 1;
END;






