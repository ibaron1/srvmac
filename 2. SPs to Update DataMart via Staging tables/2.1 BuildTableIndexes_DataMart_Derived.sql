CREATE PROCEDURE [Processing].[BuildTableIndexes_DataMart_Derived] @TableName VARCHAR(100) = NULL
AS
/* BusinessFields */
IF @TableName IS NULL
OR @TableName = 'BusinessFields'
	BEGIN
		IF NOT EXISTS
		(SELECT 1
		FROM sys.indexes
		WHERE object_id = OBJECT_ID('DataMart.BusinessFields')
		AND name = 'IX_DataMart_BusinessFields_CCI' )

		BEGIN
			CREATE CLUSTERED COLUMNSTORE INDEX IX_DataMart_BusinessFields_CCI ON DataMart.BusinessFields;
	END;

IF NOT EXISTS
(SELECT 1
FROM sys.indexes
WHERE object_id = OBJECT_ID('DataMart.BusinessFields')
AND name = 'PK_DataMart_BusinessFields' )
	BEGIN
		ALTER TABLE DataMart.BusinessFields
		ADD CONSTRAINT PK_DataMart_BusinessFields
		PRIMARY KEY NONCLUSTERED (LoanNumber);
	END;

END;