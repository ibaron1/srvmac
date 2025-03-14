DROP TABLE IF EXISTS DataMart_Log.Update_DataMart_MonthEndHistory_log;
CREATE TABLE DataMart_Log.Update_DataMart_MonthEndHistory_log
(ProcedureName VARCHAR(200),
StartTime DATETIME,
EndTime DATETIME NULL,
RunTime_sec INT NULL,
RunTime VARCHAR (20) NULL,
RecordsAdded INT NULL,
GeneratedProcDefinition VARCHAR(MAX) NULL,
QueryPlan XML NULL,
Error VARCHAR(1000) NULL);

CREATE UNIQUE CLUSTERED INDEX CI_StartTime ON DataMart_Log.Update_DataMart_MonthEndHistory_log(StartTime DESC);

CREATE UNIQUE INDEX NCI_ProcedureName_StartTime ON DataMart_Log.Update_DataMart_MonthEndHistory_log(ProcedureName, StartTime DESC);

CREATE INDEX NCI_RunTime_Sec ON DataMart_Log.Update_DataMart_MonthEndHistory_log(RunTime_sec DESC);