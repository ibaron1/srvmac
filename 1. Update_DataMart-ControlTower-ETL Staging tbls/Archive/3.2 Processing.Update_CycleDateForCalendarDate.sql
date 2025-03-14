CREATE PROCEDURE [Processing].[Update_CycleDateForCalendarDate]
AS

/* Table of all calendar dates */
DECLARE @CalendarStartDate DATE = (SELECT MIN(CD.CycleDate)FROM DateReference.CycleDates AS CD);
DECLARE @CalendarEndDate DATE = (SELECT MAX(CD.CycleDate) FROM DateReference.CycleDates AS CD);


DROP TABLE IF EXISTS #CalendarDates;

WITH CalendarDates AS
(SELECT @CalendarStartDate AS CalendarDate
UNION ALL
SELECT DATEADD(DAY, 1, CD.CalendarDate) AS CalendarDate
FROM CalendarDates AS CD
WHERE DATEADD(DAY, 1, CD.CalendarDate) <= @CalendarEndDate)
SELECT *
INTO #CalendarDates
FROM CalendarDates
OPTION (MAXRECURSION 0);

/* Update CycleDateForCalendarDate */
TRUNCATE TABLE DateReference.CycleDateForCalendarDate;

INSERT INTO DateReference.CycleDateForCalendarDate
(CalendarDate
, WeekdayNumber
, FirstCycleDateOnOrAfter
, LastCycleDateOnOrBefore
, FirstCycleDateAfter
, LastCycleDateBefore)
SELECT CalendarDates.CalendarDate
, DATEPART(dw, CalendarDates.CalendarDate)		AS WeekDayNumber
, (SELECT MIN(CD.CycleDate) FROM DateReference.CycleDates AS CD WHERE CD.CycleDate >= CalendarDates.CalendarDate) AS FirstCycleDateOnOrAfter
, (SELECT MAX(CD.CycleDate) FROM DateReference.CycleDates AS CD WHERE CD.CycleDate <= CalendarDates.CalendarDate) AS LastCycleDateOnOrBefore
, (SELECT MIN(CD.CycleDate)FROM DateReference.CycleDates AS CD WHERE CD.CycleDate > CalendarDates.CalendarDate) AS FirstCycleDateAfter
, (SELECT MAX(CD.CycleDate)FROM DateReference.CycleDates AS CD WHERE CD.CycleDate < CalendarDates.CalendarDate) AS LastCycleDateOnBefore
FROM #CalendarDates AS CalendarDates
INNER JOIN DateReference.CycleDates AS CD2 ON
CD2.CycleDate =
(SELECT MIN(CD.CycleDate) FROM DateReference.CycleDates AS CD WHERE CD.CycleDate >= CalendarDates.CalendarDate);

