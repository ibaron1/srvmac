CREATE PROCEDURE [Processing]. [Update_CycleDates]
AS

TRUNCATE TABLE DateReference.CycleDates;

INSERT INTO DateReference.CycleDates
(CycleDate
, CycleNumber
, CycleNumberWithinYear
, CycleNumberWithinMonth
, IsMonthEnd)
SELECT CD.CycleDate
, ROW_NUMBER() OVER (ORDER BY CD.CycleDate)														AS CycleNumber
, ROW_NUMBER() OVER (PARTITION BY YEAR(CD.CycleDate)ORDER BY CD.CycleDate)						AS CycleNumberWithinYear
, ROW_NUMBER() OVER (PARTITION BY YEAR(CD.CycleDate), MONTH(CD.CycleDate)ORDER BY CD.CycleDate) AS CycleNumberWithinMonth
, IIF(
CD.CycleDate = MAX(CD.CycleDate) OVER (PARTITION BY YEAR(CD.CycleDate), MONTH(CD.CycleDate))
, 1
, 0)																							AS IsMonthEnd
FROM DataMart.CycleDates AS CD;

GO