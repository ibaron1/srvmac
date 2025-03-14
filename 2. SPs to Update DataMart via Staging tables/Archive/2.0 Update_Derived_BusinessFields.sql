CREATE OR ALTER PROCEDURE Processing.Update_Derived_BusinessFields
AS

DECLARE @EffectiveDate DATE = DateReference.EffectiveDate();

DROP TABLE IF EXISTS DataMart.BusinessFields;

SELECT L.RowHash
, L.RecordStartDate
, L.RecordEndDate
, L.LoanNumber
, CASE WHEN IsActiveLoan = 0 THEN
	0
WHEN L.NextPaymentDueDate > @EffectiveDate THEN
	0
ELSE
	DATEDIFF(DAY, L.NextPaymentDueDate, @EffectiveDate) + 1
END AS DelinquentDayCount
, CASE WHEN IsActiveLoan = 0 THEN
	0
WHEN L.NextPaymentDueDate > @EffectiveDate THEN
	0
WHEN DAY(L.NextPaymentDueDate) > 1
	AND DAY(L.NextPaymentDueDate) > DAY(@EffectiveDate) THEN
DATEDIFF(MONTH, L.NextPaymentDueDate, @EffectiveDate)
ELSE
	DATEDIFF(MONTH, L.NextPaymentDueDate, @EffectiveDate) + 1
END AS DelinquentPaymentCount
INTO DataMart.BusinessFields
FROM DataMart.Loan AS L;




