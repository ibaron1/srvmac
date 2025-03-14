USE [ServiceMac]
GO

CREATE OR ALTER PROCEDURE [Utilities].[ClearSchemaObjects] @SchemaName VARCHAR(100)
AS
SET NOCOUNT ON;

DROP TABLE IF EXISTS #ObjectTypes;

CREATE TABLE #ObjectTypes
(ObjectType VARCHAR(2)
, ObjectTypeDescription VARCHAR(20)
, DropOrder INT);

INSERT INTO #ObjectTypes (ObjectType, ObjectTypeDescription, DropOrder)
VALUES
('V', 'VIEW', 1)
, ('FN', 'FUNCTION', 2)
, ('IF', 'FUNCTION', 3)
, ('TF', 'FUNCTION', 4)
, ('TF', 'FUNCTION', 4)
, ('P', 'PROCEDURE', 5)
, ('U', 'TABLE', 6);

DROP TABLE IF EXISTS #ObjectList;

SELECT		CONCAT('DROP ', OT.ObjectTypeDescription, ' ', QUOTENAME(SCHEMA_NAME(O.schema_id) ), '.', QUOTENAME(O.name) ) AS DropSQL
			, ROW_NUMBER() OVER (ORDER BY OT.DropOrder, O.name) AS Seq
INTO		#ObjectList
FROM		sys.objects AS O
INNER JOIN	#ObjectTypes AS OT ON
			OT.ObjectType = O.type COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE		SCHEMA_NAME(O.schema_id) =@SchemaName;

DECLARE @DropSeq INT = 1;
DECLARE @DropSQL VARCHAR(MAX);

WHILE @DropSeq <= (SELECT MAX(Seq)FROM #ObjectList)
BEGIN
	SELECT	@DropSQL = OL.DropSQL
	FROM	#ObjectList AS OL
	WHERE	OL.Seq = @DropSeq;

	EXEC (@DropSQL);

	SET @DropSeq = @DropSeq + 1;
END;

GO