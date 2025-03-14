CREATE TABLE DataMart_Log.Import_DataMartTablesFromEtlStage_Log
(TableName VARCHAR(200) NOT NULL CONSTRAINT PK_Import_DataMartTablesFromEt1Stage_Log PRIMARY KEY CLUSTERED,
StartTime DATETIME,
EndTime DATETIME NULL,
RunTime_sec INT NULL,
RunTime VARCHAR (20) NULL,
TableDefinition VARCHAR(MAX) NULL,
Error VARCHAR(1000) NOT NULL DEFAULT (''),
ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START,
ValidTo DATETIME2 GENERATED ALWAYS AS ROW END,
PERIOD FOR SYSTEM_TIME(ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON
(HISTORY_TABLE = DataMart_Log.Import_DataMartTablesFromEtlStage_Log_History,
HISTORY_RETENTION_PERIOD = 2 WEEKS)
);
GO

-- DROP temporal TABLE
/*
ALTER TABLE DataMart_Log.Import_DataMartTablesFromEt1Stage_Log SET ( SYSTEM_VERSIONING = OFF )
GO
DROP TABLE DataMart_Log.Import_DataMartTablesFromEt1Stage_Log
GO
DROP TABLE DataMart_Log.Import_DataMartTablesFromEtlStage_Log_History
*/