use ServiceMac
GO
CREATE OR ALTER PROCEDURE [Utilities].[MoveSchema]
 @SourceSchema VARCHAR(100)
, @TargetSchema VARCHAR(100)
AS

/***************************************
This procedure will move all tables, views, procedures, function and indexes from one schema on a database to another.
If the target schema does not already exist, it will be created.
******************************/

/* Create schema if it is not exist */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = @TargetSchema)
BEGIN
	DECLARE @CreateSchemaSQL VARCHAR(MAX) = CONCAT('CREATE SCHEMA ', QUOTENAME(@TargetSchema));
	EXEC (@CreateSchemaSQL);
END;

/* Get list of all objects to move */
DROP TABLE IF EXISTS #MoveObjects;

SELECT	CONCAT(
			'ALTER SCHEMA '
			, QUOTENAME (@TargetSchema)
			,' TRANSFER '
			, QUOTENAME (@SourceSchema)
			, '.'
			, QUOTENAME (O.name)
			, ';')					MoveObjectSQL
			, ROW_NUMBER() OVER (ORDER BY O.name) AS Seq
INTO	#MoveObjects
FROM sys.objects AS O
WHERE SCHEMA_NAME(O.schema_id) = @SourceSchema
AND O.type IN ( 'U', 'V', 'P', 'FN', 'IF', 'TF' );

/* Move objects */
DECLARE @Seq INT = 1;
DECLARE @MoveObjectSQL NVARCHAR(MAX);

WHILE @Seq <= (SELECT MAX(Seq) FROM #MoveObjects)
BEGIN
	SELECT @MoveObjectSQL = MO.MoveObjectSQL
	FROM #MoveObjects AS MO
	WHERE MO.Seq = @Seq;

	EXEC sp_executesql @MoveObjectSQL;

	SET @Seq = @Seq + 1;
END;

declare @copyback varchar(1000) = 
	CONCAT('SELECT * INTO ',QUOTENAME (@SourceSchema),'.','EffectiveDates FROM ',QUOTENAME (@TargetSchema),'.','EffectiveDates;'
	       ,'CREATE CLUSTERED INDEX IX_DataMart_EffectiveDates_CI ON ',QUOTENAME (@SourceSchema),'.','EffectiveDates(EffectiveDate)')

exec (@copyback);

GO
