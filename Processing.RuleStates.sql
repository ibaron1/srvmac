CREATE OR ALTER VIEW Processing.RuleStates
AS

SELECT		S.Id  AS RuleId
		, COALESCE(RT.IsActiveRule, 0) AS IsActiveRule
		, CONCAT('Populate_Rule_', S.Id) AS ProcedureName
		, CONCAT ('Rule_', S.Id) AS TableName
		, CASE WHEN S.State = 'Development' THEN 1 ELSE 0 END AS IsInDevelopment
		, CASE WHEN S.State IN ( 'User Testing' ) THEN 1 ELSE 0 END AS IsInUat
		, CASE WHEN S.State = 'Deployed' THEN 1 ELSE 0 END AS IsInProduction
		, CONVERT(BIT, COALESCE(Regulatory.IsRegulatory, 0)) AS IsRegulatory
		, S.Tags
FROM Shared.DevOps.[Sentry360_2.0] AS S
LEFT OUTER JOIN ApplicationData.RuleTiers AS RT ON
	RT.RuleId = S.Id
LEFT OUTER JOIN
(SELECT		RT.RuleId
		, MAX(RT.IsRegulatoryTag) AS IsRegulatory
 FROM Processing.RuleTags AS RT
 GROUP BY RT.RuleId) AS Regulatory ON
	Regulatory.RuleId = S.Id
WHERE S.WorkItemType = 'Rule';

GO