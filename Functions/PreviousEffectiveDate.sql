
CREATE FUNCTION [DateReference].[PreviousEffectiveDate] ()
RETURNS DATE
AS

BEGIN
	DECLARE @PreviousEffectiveDate DATE = (SELECT TOP 1 ED.PreviousEffectiveDate FROM DataMart.EffectiveDates AS ED);

	RETURN @PreviousEffectiveDate;
END;
