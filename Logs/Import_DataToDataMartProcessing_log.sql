CREATE TABLE DataMart_Log.Import_DataToDataMartProcessing_log
(ProcName VARCHAR(200) NOT NULL CONSTRAINT PK_Import_DataToDataMartProcessing_log PRIMARY KEY CLUSTERED,
StartTime DATETIME,
EndTime DATETIME NULL,
RunTime_sec INT NULL,
RunTime VARCHAR (20) NULL,
GeneratedProcDefinition VARCHAR(MAX) NULL,
QueryPlan XML NULL,
Error VARCHAR(1000) NOT NULL DEFAULT (''),
ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START,
ValidTo DATETIME2 GENERATED ALWAYS AS ROW END,
PERIOD FOR SYSTEM_TIME(ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON
(HISTORY_TABLE = DataMart_Log.Import_DataToDataMartProcessing_log_History,
HISTORY_RETENTION_PERIOD = 2 WEEKS)
);
GO

-- DROP temporal TABLE
/*
ALTER TABLE DataMart_Log.Import_DataToDataMartProcessing_log SET ( SYSTEM_VERSIONING = OFF )
GO
DROP TABLE DataMart_Log.Import_DataToDataMartProcessing_log
GO
DROP TABLE DataMart_Log.Import_DataToDataMartProcessing_log_History
*/