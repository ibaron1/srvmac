CREATE OR ALTER PROCEDURE [Processing].[BuildTableIndexes_DataMart] @TableName VARCHAR(100) = NULL
AS
/* Loan */
BEGIN TRY
IF @TableName IS NULL
OR @TableName = 'Loan' AND OBJECT_ID('DataMart.Loan' ) IS NOT NULL
BEGIN
	IF INDEXPROPERTY (OBJECT_ID('DataMart.Loan' ) , 'IX_DataMart_Loan_CI' , 'IndexID' ) IS NULL
	CREATE CLUSTERED INDEX IX_DataMart_Loan_CI ON DataMart.Loan(LoanNumber) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY];
END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* Bankruptcy */
BEGIN TRY
IF @TableName IS NULL
OR @TableName = 'Bankruptcy' AND OBJECT_ID('DataMart.Bankruptcy' ) IS NOT NULL
BEGIN
	IF INDEXPROPERTY (OBJECT_ID('DataMart.Bankruptcy' ) , 'IX_DataMart_Bankruptcy_CI' , 'IndexID' ) IS NULL
	CREATE CLUSTERED INDEX IX_DataMart_Bankruptcy_CI ON DataMart.Bankruptcy(LoanNumber, BankruptcyId) WITH (DATA_COMPRESSION = PAGE)
END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* Escrow */
BEGIN TRY
IF @TableName IS NULL
OR @TableName = 'Escrow' AND OBJECT_ID('DataMart.Escrow' ) IS NOT NULL
BEGIN
	IF INDEXPROPERTY (OBJECT_ID('DataMart.Escrow' ) , 'IX_DataMart_Escrow_CI' , 'IndexID' ) IS NULL
	CREATE CLUSTERED INDEX IX_DataMart_Escrow_CI ON DataMart.Escrow(LoanNumber) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY];
END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* EventHistory */
BEGIN TRY
IF @TableName IS NULL
OR @TableName = 'EventHistory' AND OBJECT_ID( 'DataMart.EventHistory' ) IS NOT NULL
BEGIN
	IF INDEXPROPERTY (OBJECT_ID('DataMart.EventHistory' ) , 'IX_DataMart_EventHistory_CI' , 'IndexID' ) IS NULL
	CREATE CLUSTERED INDEX IX_DataMart_EventHistory_CI ON DataMart.EventHistory(LoanNumber, EventHistoryId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY];
END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* Foreclosure */
BEGIN TRY
IF @TableName IS NULL
OR @TableName = 'Foreclosure' AND OBJECT_ID('DataMart.Foreclosure' ) IS NOT NULL
BEGIN
	IF INDEXPROPERTY (OBJECT_ID('DataMart.Foreclosure' ) , 'IX_DataMart_Foreclosure_CI' , 'IndexID' ) IS NULL
	CREATE CLUSTERED INDEX IX_DataMart_Foreclosure_CI ON DataMart.Foreclosure(LoanNumber, ForeclosureId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY];
END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* LossMitigation */
BEGIN TRY
IF @TableName IS NULL
OR @TableName = 'LossMitigation' AND OBJECT_ID( 'DataMart.LossMitigation' ) IS NOT NULL
BEGIN
	IF INDEXPROPERTY (OBJECT_ID('DataMart.LossMitigation' ) , 'IX_DataMart_LossMitigation_CI' , 'IndexID' ) IS NULL
	CREATE CLUSTERED INDEX IX_DataMart_LossMitigation_CI ON DataMart.LossMitigation(LoanNumber, LossMitigationId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY];
END
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* PaymentChangeHistory */
BEGIN TRY
IF @TableName IS NULL
OR @TableName = 'PaymentChangeHistory' AND OBJECT_ID('DataMart.PaymentChangeHistory' ) IS NOT NULL
BEGIN
	IF INDEXPROPERTY (OBJECT_ID( 'DataMart.PaymentChangeHistory' ) , 'IX_DataMart_PaymentChangeHistory_CI' , 'IndexID' ) IS NULL
	CREATE CLUSTERED INDEX IX_DataMart_PaymentChangeHistory_CI ON DataMart.PaymentChangeHistory (LoanNumber, PaymentChangeHistoryId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY];
END
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* LetterHistory */
BEGIN TRY
IF @TableName IS NULL
OR @TableName = 'LetterHistory' AND OBJECT_ID('DataMart.LetterHistory' ) IS NOT NULL
BEGIN
	IF INDEXPROPERTY (OBJECT_ID( 'DataMart.LetterHistory' ) , 'IX_DataMart_LetterHistory_CI' , 'IndexID' ) IS NULL
	CREATE CLUSTERED INDEX IX_DataMart_LetterHistory_CI ON DataMart.LetterHistory(LoanNumber, LetterHistoryId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY];
END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* CycleDates */
BEGIN TRY
IF @TableName IS NULL
OR @TableName = 'CycleDates' AND OBJECT_ID( 'DataMart.CycleDates' ) IS NOT NULL
BEGIN
	IF INDEXPROPERTY (OBJECT_ID( 'DataMart.CycleDates' ) , 'IX_DataMart_CycleDates' , 'IndexID' ) IS NULL
	CREATE CLUSTERED INDEX IX_DataMart_CycleDates ON DataMart.CycleDates (CycleDate) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY];
END
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* BorrowerDoNotCallPreferences */
BEGIN TRY
IF @TableName IS NULL
OR @TableName = 'BorrowerDoNotCallPreferences' AND OBJECT_ID( 'DataMart.BorrowerDoNotCallPreferences' ) IS NOT NULL
BEGIN
	IF INDEXPROPERTY (OBJECT_ID( 'DataMart.BorrowerDoNotCallPreferences' ) , 'IX_DataMart_BorrowerDoNotCallPreferences' , 'IndexID' ) IS NULL
	CREATE CLUSTERED INDEX IX_DataMart_BorrowerDoNotCallPreferences ON DataMart.BorrowerDoNotCallPreferences(LoanNumber, BorrowerDoNotCallPreferencesID) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY];
END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* DisasterTracking */
BEGIN TRY
IF @TableName IS NULL
OR @TableName = 'DisasterTracking' AND OBJECT_ID( 'DataMart.DisasterTracking' ) IS NOT NULL
BEGIN
	IF INDEXPROPERTY (OBJECT_ID('DataMart.DisasterTracking' ) , 'IX_DataMart_DisasterTracking' , 'IndexID' ) IS NULL
	CREATE CLUSTERED INDEX IX_DataMart_DisasterTracking ON DataMart.DisasterTracking(LoanNumber, DisasterTrackingId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY];
END
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* DocumentImaging */
BEGIN TRY
IF @TableName IS NULL
OR @TableName = 'DocumentImaging' AND OBJECT_ID( 'DataMart.DocumentImaging' ) IS NOT NULL
BEGIN
	IF INDEXPROPERTY (OBJECT_ID('DataMart.DocumentImaging' ) , 'IX_DataMart_DocumentImaging' , 'IndexID' ) IS NULL
	CREATE CLUSTERED INDEX IX_DataMart_DocumentImaging ON DataMart.DocumentImaging (LoanNumber, DocumentImagingId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY];
END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* Valeri */
BEGIN TRY
IF @TableName IS NULL
OR @TableName = 'Valeri' AND OBJECT_ID('DataMart.Valeri' ) IS NOT NULL
BEGIN
	IF INDEXPROPERTY (OBJECT_ID( 'DataMart.Valeri' ) , 'IX_DataMart_Valeri' , 'IndexID' ) IS NULL
	CREATE CLUSTERED INDEX IX_DataMart_Valeri ON DataMart.Valeri(LoanNumber, ValeriId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY];
END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* ForbearancePlan */
BEGIN TRY
IF @TableName IS NULL
OR @TableName = 'ForbearancePlan' AND OBJECT_ID( 'DataMart.ForbearancePlan' ) IS NOT NULL
BEGIN
	IF INDEXPROPERTY (OBJECT_ID( 'DataMart.ForbearancePlan' ) , 'IX_DataMart_ForbearancePlan_CI' , 'IndexID' ) IS NULL
	CREATE CLUSTERED INDEX IX_DataMart_ForbearancePlan_CI ON DataMart.ForbearancePlan(LoanNumber) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY];
END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* CorporateAdvanceTransactions */
BEGIN TRY
IF @TableName IS NULL
OR @TableName = 'CorporateAdvanceTransactions' AND OBJECT_ID( 'DataMart.CorporateAdvanceTransactions' ) IS NOT NULL
BEGIN
	IF INDEXPROPERTY (OBJECT_ID('DataMart.CorporateAdvanceTransactions' ) , 'IX_DataMart_CorporateAdvanceTransactions_CI' , 'IndexID' ) IS NULL
	CREATE CLUSTERED INDEX IX_DataMart_CorporateAdvanceTransactions_CI ON DataMart.CorporateAdvanceTransactions (LoanNumber, CorporateAdvanceTransactionsId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY];
END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* CreditBureauReporting */
BEGIN TRY
IF @TableName IS NULL
OR @TableName = 'CreditBureauReporting' AND OBJECT_ID( 'DataMart.CreditBureauReporting' ) IS NOT NULL
BEGIN
	IF INDEXPROPERTY (OBJECT_ID( 'DataMart.CreditBureauReporting' ) , 'IX_DataMart_CreditBureauReporting_CI' , 'IndexID' ) IS NULL
	CREATE CLUSTERED INDEX IX_DataMart_CreditBureauReporting_CI ON DataMart.CreditBureauReporting(LoanNumber, CreditBureauReportingId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY];
END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* InvestorReportingExceptions */
BEGIN TRY
IF @TableName IS NULL
OR @TableName = 'InvestorReportingExceptions' AND OBJECT_ID( 'DataMart.InvestorReportingExceptions' ) IS NOT NULL
BEGIN
	IF INDEXPROPERTY (OBJECT_ID( 'DataMart.InvestorReportingExceptions' ) , 'IX_DataMart_InvestorReportingExceptions_CI' , 'IndexID' ) IS NULL
	CREATE CLUSTERED INDEX IX_DataMart_InvestorReportingExceptions_CI ON DataMart.InvestorReportingExceptions (LoanNumber, InvestorReportingExceptionsId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY];
END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* RealEstateOwned */
BEGIN TRY
IF @TableName IS NULL
OR @TableName = 'RealEstateOwned' AND OBJECT_ID( 'DataMart.RealEstateOwned' ) IS NOT NULL
BEGIN
	IF INDEXPROPERTY (OBJECT_ID( 'DataMart.RealEstateOwned' ) , 'IX_DataMart_RealEstateOwned_CI' , 'IndexID' ) IS NULL
	CREATE CLUSTERED INDEX IX_DataMart_RealEstateOwned_CI ON DataMart.RealEstateOwned(LoanNumber, RealEstateOwnedId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY];
END
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* ReportedStatusFha */
BEGIN TRY
IF @TableName IS NULL
OR @TableName = 'ReportedStatusFha' AND OBJECT_ID( 'DataMart.ReportedStatusFha' ) IS NOT NULL
BEGIN
	IF INDEXPROPERTY (OBJECT_ID( 'DataMart.ReportedStatusFha' ) , 'IX_DataMart_ReportedStatusFha_CI' , 'IndexID' ) IS NULL
	CREATE CLUSTERED INDEX IX_DataMart_ReportedStatusFha_CI ON DataMart.ReportedStatusFha(LoanNumber, ReportedStatusFhaId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY];
END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* InsuranceLines */
BEGIN TRY
IF @TableName IS NULL
OR @TableName = 'InsuranceLines' AND OBJECT_ID( 'DataMart.InsuranceLines' ) IS NOT NULL
BEGIN
	IF INDEXPROPERTY (OBJECT_ID( 'DataMart.InsuranceLines' ) , 'IX_DataMart_InsuranceLines_CI' , 'IndexID' ) IS NULL
	CREATE CLUSTERED INDEX IX_DataMart_InsuranceLines_CI ON DataMart.InsuranceLines(LoanNumber, InsuranceLinesId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY];
END
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* EffectiveDates */
BEGIN TRY
IF @TableName IS NULL
OR @TableName = 'EffectiveDates' AND OBJECT_ID( 'DataMart.EffectiveDates' ) IS NOT NULL
BEGIN
	IF INDEXPROPERTY (OBJECT_ID( 'DataMart.EffectiveDates' ) , 'IX_DataMart_EffectiveDates_CI' , 'IndexID' ) IS NULL
	CREATE CLUSTERED INDEX IX_DataMart_EffectiveDates_CI ON DataMart.EffectiveDates (EffectiveDate) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY];
END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

GO