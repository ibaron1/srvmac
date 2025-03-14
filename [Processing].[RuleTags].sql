CREATE VIEW [Processing].[RuleTags]
AS
SELECT S.Id AS RuleId 
, LTRIM(RTRIM(Tags.value)) AS Tag

, CASE WHEN CHARINDEX(':', Tags.value) <= 1 THEN
	0
WHEN LTRIM(RTRIM(LEFT(Tags.value, CHARINDEX(':', Tags.value) - 1))) 
						IN ( 'CFPB', 'FNMA', 'FHLMC'
							, 'GNMA', 'FHA', 'VA', 'USDA'
							, 'MMC', 'State' ) THEN
	1
ELSE
	0
END AS IsRegulatoryTag
, LTRIM(RTRIM(Utilities.GetItemFromDelimitedList(Tags.value,':', 1, 0))) AS TagSegment1
, LTRIM(RTRIM(Utilities.GetItemFromDelimitedList(Tags.value,':', 2, 0))) AS TagSegment2
, LTRIM(RTRIM(Utilities.GetItemFromDelimitedList(Tags.value,':', 3, 0))) AS TagSegment3
, LTRIM(RTRIM(Utilities.GetItemFromDelimitedList(Tags.value,':', 4, 0))) AS TagSegment4
, LTRIM(RTRIM(Utilities.GetItemFromDelimitedList(Tags.value,':', 5, 0))) AS TagSegment5
FROM Shared.DevOps.[Sentry360_2.0] AS S
CROSS APPLY STRING_SPLIT(S.Tags, ';') AS Tags
WHERE S.WorkItemType = 'Rule';
