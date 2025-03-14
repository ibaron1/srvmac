CREATE PROCEDURE [Processing].[Update_CycleDateForCycleDifference]
AS

TRUNCATE TABLE DateReference.CycleDateForCycleDifference;

INSERT INTO DateReference.CycleDateForCycleDifference (CalendarDate, CycleDifference, CycleDateForDifference)
SELECT	  CDFCD.CalendarDate
		, CD.CycleNumber - CDFPOA.CycleNumber AS CycleDifference
		, CD.CycleDate  AS CycleDateForDifference
FROM DateReference.CycleDateForCalendarDate AS CDFCD
INNER JOIN DateReference.CycleDates AS CDFPOA ON
			CDFPOA.CycleDate = CDFCD.FirstCycleDateOnOrAfter
INNER JOIN DateReference.CycleDates AS CD ON
ABS(CDFPOA.CycleNumber - CD.CycleNumber) <= 100;

GO
