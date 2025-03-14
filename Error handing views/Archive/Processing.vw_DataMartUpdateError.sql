DROP VIEW IF EXISTS Processing.vw_DataMartUpdateError
GO
CREATE VIEW Processing.vw_DataMartUpdateError WITH SCHEMABINDING
as
SELECT STRING_AGG(CONCAT(ProcName, ': ', Error, CHAR(13) ),'') AS Error FROM
(SELECT ProcName, Error FROM DataMart_Log.Update_DataMart_log
WHERE ISNULL(Error,'') <> ''
UNION ALL
SELECT ProcName, ERROR FROM DataMart_Log.Import_DataFromControlTowerToEtlStage_log
WHERE ISNULL(ERROR, ' ') <> ''
UNION ALL
SELECT TableName, Error FROM DataMart_Log.Import_DataMartTablesFromEtlStage_log
WHERE ISNULL(Error, '') <> ''
UNION ALL
SELECT ProcedureName, Error FROM DataMart_Log.Update_DataMart_History_log
WHERE ISNULL(Error,'') <> ''
UNION ALL
SELECT ProcedureName, Error FROM DataMart_Log.Update_DataMart_MonthEndHistory_log
WHERE ISNULL(Error,'') <> '') AS T;