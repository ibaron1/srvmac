use ServiceMac
go

CREATE OR ALTER PROCEDURE [Utilities].[DuplicateSchema] @SourceSchema VARCHAR(100),@TargetSchema VARCHAR(100)
AS

/*****
This procedure will duplicate all tables, views, procedures, function and indexes from one schema on a database to another.
If the target schema does not already exist, it will be created.
*******/

/* Create schema if it does not already exist */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = @TargetSchema)
BEGIN
	DECLARE @CreateSchemaSQL VARCHAR(MAX) = CONCAT('CREATE SCHEMA ', QUOTENAME(@TargetSchema));
	EXEC (@CreateSchemaSQL);
END;

/* Copy tables */
DROP TABLE IF EXISTS #TableList;

SELECT T.TABLE_NAME	AS TableName
, ROW_NUMBER() OVER (ORDER BY T.TABLE_NAME) AS Seq
INTO #TableList
FROM INFORMATION_SCHEMA.TABLES AS T
LEFT OUTER JOIN INFORMATION_SCHEMA.TABLES AS TTarget ON
	TTarget.TABLE_NAME = T.TABLE_NAME
	AND TTarget.TABLE_SCHEMA = @TargetSchema
WHERE T.TABLE_TYPE = 'BASE TABLE'
AND T.TABLE_SCHEMA = @SourceSchema
AND TTarget.TABLE_NAME IS NULL; -- Only include objects that do not already exist

DECLARE @TableSeq INT = 1;
DECLARE @TableSQL VARCHAR (MAX);

WHILE @TableSeq <= (SELECT MAX(Seq)FROM #TableList)
BEGIN
	SELECT @TableSQL = CONCAT('
SELECT *
INTO  ', QUOTENAME(@TargetSchema), '.', QUOTENAME(TL.TableName), '
FROM  ', QUOTENAME (@SourceSchema),'.', QUOTENAME(TL.TableName), ';
'  )
	FROM #TableList AS TL
	WHERE TL.Seq = @TableSeq;

	EXEC (@TableSQL);

	SET @TableSeq = @TableSeq + 1;
END;

/* Copy views */
DROP TABLE IF EXISTS #ViewList;

SELECT REPLACE(
			REPLACE(V.VIEW_DEFINITION, CONCAT(@SourceSchema, '.'), CONCAT(@TargetSchema, '.'))
			, CONCAT (QUOTENAME (@SourceSchema), '.')
			, CONCAT (QUOTENAME (@TargetSchema), '.') ) AS ViewSQL
			, ROW_NUMBER() OVER (ORDER BY V.TABLE_NAME) AS Seq
		, V.TABLE_NAME	AS SourceTable
		, VTarget.TABLE_NAME AS TargetTable	
INTO #ViewList
FROM INFORMATION_SCHEMA.VIEWS AS V
LEFT OUTER JOIN INFORMATION_SCHEMA.VIEWS AS VTarget ON
	VTarget.TABLE_NAME = V.TABLE_NAME
	AND VTarget.TABLE_SCHEMA = @TargetSchema
WHERE V.TABLE_SCHEMA = @SourceSchema
	AND VTarget.TABLE_NAME IS NULL; -- Only include objects that do not already exist

DECLARE @ViewSeq INT = 1;
DECLARE @ViewSQL VARCHAR(MAX);

WHILE @ViewSeq <= (SELECT MAX(Seq)FROM #ViewList)
BEGIN
	SELECT @ViewSQL = VL.ViewSQL
	FROM #ViewList AS VL
	WHERE VL.Seq = @ViewSeq;

	EXEC (@ViewSQL);

	SET @ViewSeq = @ViewSeq + 1;
END;

/* Copy procedures and functions */
DROP TABLE IF EXISTS #ProcedureList;

SELECT REPLACE (
			REPLACE(R.ROUTINE_DEFINITION, CONCAT(@SourceSchema, '.'), CONCAT(@TargetSchema, '.'))
			, CONCAT (QUOTENAME (@SourceSchema), '.')
			, CONCAT (QUOTENAME (@TargetSchema), '.')) AS ProcedureSQL
			, ROW_NUMBER() OVER (ORDER BY R.ROUTINE_NAME) AS Seq
INTO #ProcedureList
FROM INFORMATION_SCHEMA.ROUTINES AS R
LEFT OUTER JOIN INFORMATION_SCHEMA.ROUTINES AS RTarget ON
	RTarget.ROUTINE_NAME = R.ROUTINE_NAME
	AND RTarget.ROUTINE_SCHEMA = @TargetSchema
WHERE R.ROUTINE_SCHEMA = @SourceSchema
	AND RTarget.ROUTINE_NAME IS NULL;

-- Only include objects that do not already exist

DECLARE @ProcedureSeq INT = 1;
DECLARE @ProcedureSQL VARCHAR(MAX);

WHILE @ProcedureSeq <= (SELECT MAX(Seq) FROM #ProcedureList)
BEGIN
	SELECT @ProcedureSQL = PL.ProcedureSQL
	FROM #ProcedureList AS PL
	WHERE PL.Seq = @ProcedureSeq;

	EXEC (@ProcedureSQL);

	SET @ProcedureSeq = @ProcedureSeq + 1;
END;

/* Create indexes */
DROP TABLE IF EXISTS #IndexList;



/* Create indexes */
DROP TABLE IF EXISTS #IndexList;

SELECT
	REPLACE (
		REPLACE(TI.CreateIndexSQL, CONCAT(@SourceSchema, '.'), CONCAT(@TargetSchema, '.'))
		, CONCAT (QUOTENAME (@SourceSchema), '.')
		, CONCAT (QUOTENAME (@TargetSchema), '.')) AS IndexSQL
		, ROW_NUMBER() OVER (ORDER BY TI.TableName, TI.IndexName) AS Seq
INTO #IndexList
FROM Utilities.TableIndexes AS TI
LEFT OUTER JOIN Utilities.TableIndexes AS TITarget ON
TITarget.IndexName = TI.IndexName
AND TITarget.SchemaName = @TargetSchema
WHERE TI.SchemaName = @SourceSchema
AND TITarget.IndexName IS NULL; -- Only include objects that do not already exist

DECLARE @IndexSeq INT = 1;
DECLARE @IndexSQL VARCHAR(MAX);

WHILE @IndexSeq <= (SELECT MAX(Seq)FROM #IndexList)
BEGIN
	SELECT @IndexSQL = IL.IndexSQL
	FROM #IndexList AS IL
	WHERE IL.Seq = @IndexSeq;

	EXEC (@IndexSQL);

	SET @IndexSeq = @IndexSeq + 1;
END;

GO
















