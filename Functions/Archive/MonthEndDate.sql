CREATE FUNCTION [DateReference].[MonthEndDate] (@InputDate DATE = NULL)
RETURNS DATE
AS
	BEGIN
	IF (@InputDate IS NULL) SELECT @InputDate = DateReference.EffectiveDate();
		RETURN
		(SELECT CD.CycleDate
		FROM DateReference.CycleDates AS CD
		WHERE CD.IsMonthEnd = 1
		AND DATEDIFF(MONTH, @InputDate, CD.CycleDate) = 0);
	END;