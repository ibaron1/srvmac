CREATE or alter FUNCTION [DateReference].[EffectiveDate] ()
RETURNS DATE
AS
BEGIN
	RETURN (SELECT TOP 1 EffectiveDate FROM DataMart.EffectiveDates);
END;
GO
--SELECT DateReference.EffectiveDate()