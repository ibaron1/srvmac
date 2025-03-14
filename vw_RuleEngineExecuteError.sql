DROP VIEW IF EXISTS Processing.vw_RuleEngineExecuteError
GO
CREATE VIEW Processing.vw_RuleEngineExecuteError WITH SCHEMABINDING
AS
SELECT STRING_AGG(CAST(CONCAT(ProcName, ': ', Error, CHAR(13)) as VARCHAR(MAX)),'') AS Error FROM
(SELECT ProcName, Error FROM DataMart_Log.Rules_Engine_Processing_log
WHERE ISNULL(Error,'') <> ''
UNION ALL
SELECT RuleName, Error FROM DataMart_Log.Update_DailyResults_RuleResults_Log
WHERE Error <> ''
UNION ALL
SELECT RuleName, Error FROM DataMart_Log.Update_DailyRuleTables_log
WHERE ISNULL(Error, '') <> ''
UNION ALL
SELECT CONCAT('Rule_', RuleId), Error FROM DataMart_Log.Update_DailyRuleResults_log
WHERE ISNULL(Error,'') <> ''
UNION ALL
SELECT RuleName, Error FROM DataMart_Log.Update_DailyResults_ActiveResults_Log
WHERE Error <> '') AS T