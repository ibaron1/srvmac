DROP PROC IF EXISTS Processing.BuildTableIndexes_DataMart_History
GO
CREATE PROCEDURE Processing.BuildTableIndexes_DataMart_History @TableName VARCHAR(100) = NULL
AS

/* 1.Loan */
BEGIN TRY
	IF @TableName IS NULL
	OR @TableName = 'Loan' AND OBJECT_ID('DataMart_History.Loan' ) IS NOT NULL
	BEGIN
		IF INDEXPROPERTY (OBJECT_ID('DataMart_History.Loan' ) , 'IX_DataMart_History_Loan_CI' , 'IndexID' ) IS NULL
		CREATE CLUSTERED INDEX IX_DataMart_History_Loan_CI ON DataMart_History.Loan(RecordEndDate, LoanNumber) WITH (DATA_COMPRESSION = PAGE) ON [Primary] -- ps_DateByMonthRight(RecordEndDate);
	END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* 2.Bankruptcy */
BEGIN TRY
	IF @TableName IS NULL
	OR @TableName = 'Bankruptcy' AND OBJECT_ID('DataMart_History.Bankruptcy' ) IS NOT NULL
	BEGIN
		IF INDEXPROPERTY (OBJECT_ID('DataMart_History.Bankruptcy' ) , 'IX_DataMart_History_Bankruptcy_CI' , 'IndexID' ) IS NULL
		CREATE CLUSTERED INDEX IX_DataMart_History_Bankruptcy_CI ON DataMart_History.Bankruptcy(RecordEndDate, LoanNumber) WITH (DATA_COMPRESSION = PAGE) ON ps_DateByMonthRight(RecordEndDate);
	END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* 3.BorrowerDoNotCallPreferences */
BEGIN TRY
	IF @TableName IS NULL
	OR @TableName = 'BorrowerDoNotCallPreferences' AND OBJECT_ID('DataMart_History.BorrowerDoNotCallPreferences' ) IS NOT NULL
	BEGIN
	IF INDEXPROPERTY (OBJECT_ID('DataMart_History.BorrowerDoNotCallPreferences') , 'IX_DataMart_History_BorrowerDoNotCallPreferences_CI' , 'IndexID' ) IS NULL
	CREATE CLUSTERED INDEX IX_DataMart_History_BorrowerDoNotCallPreferences_CI ON DataMart_History.BorrowerDoNotCallPreferences(RecordEndDate, LoanNumber, BorrowerDoNotCallPreferencesID) WITH (DATA_COMPRESSION = PAGE) ON [Primary];
	END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* 4.Valeri */
BEGIN TRY
	IF @TableName IS NULL
	OR @TableName = 'Valeri' AND OBJECT_ID('DataMart_History.Valeri' ) IS NOT NULL
		BEGIN
			IF INDEXPROPERTY (OBJECT_ID('DataMart_History.Valeri' ) , 'IX_DataMart_History_Valeri_CI' , 'IndexID' ) IS NULL
			CREATE CLUSTERED INDEX IX_DataMart_History_Valeri_CI ON DataMart_History.Valeri(RecordEndDate, LoanNumber, ValeriId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY];
		END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* 5.Escrow */
BEGIN TRY
IF @TableName IS NULL
OR @TableName = 'Escrow' AND OBJECT_ID('DataMart_History.Escrow' ) IS NOT NULL
	BEGIN
		IF INDEXPROPERTY (OBJECT_ID('DataMart_History.Escrow' ) , 'IX_DataMart_History_Escrow_CI' , 'IndexID' ) IS NULL
		CREATE CLUSTERED INDEX IX_DataMart_History_Escrow_CI ON DataMart_History.Escrow(RecordEndDate, LoanNumber) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY] -- ps_DateByMonthRight(RecordEndDate);
END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* 6.EventHistory */
BEGIN TRY
	IF @TableName IS NULL
	OR @TableName = 'EventHistory' AND OBJECT_ID('DataMart_History.EventHistory' ) IS NOT NULL
		BEGIN
		IF INDEXPROPERTY (OBJECT_ID('DataMart_History.EventHistory' ) , 'IX_DataMart_History_EventHistory_CI' , 'IndexID' ) IS NULL
		CREATE CLUSTERED INDEX IX_DataMart_History_EventHistory_CI ON DataMart_History.EventHistory(RecordEndDate, LoanNumber) WITH (DATA_COMPRESSION = PAGE) ON ps_DateByMonthRight(RecordEndDate);
		END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* 7.ForbearancePlan */
BEGIN TRY
	IF @TableName IS NULL
	OR @TableName = 'ForbearancePlan' AND OBJECT_ID('DataMart_History.ForbearancePlan' ) IS NOT NULL
		BEGIN
		IF INDEXPROPERTY (OBJECT_ID('DataMart_History.ForbearancePlan' ) , 'IX_DataMart_History_ForbearancePlan_CI' , 'IndexID' ) IS NULL
		CREATE CLUSTERED INDEX IX_DataMart_History_ForbearancePlan_CI ON DataMart_History.ForbearancePlan(RecordEndDate, LoanNumber) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY] -- ps_DateByMonthRight(RecordEndDate);
		END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* 8.Foreclosure */
BEGIN TRY
	IF @TableName IS NULL
	OR @TableName = 'Foreclosure' AND OBJECT_ID('DataMart_History.Foreclosure') IS NOT NULL
		BEGIN
			IF INDEXPROPERTY (OBJECT_ID('DataMart_History.Foreclosure' ) , 'IX_DataMart_History_Foreclosure_CI' , 'IndexID' ) IS NULL
			CREATE CLUSTERED INDEX IX_DataMart_History_Foreclosure_CI ON DataMart_History.Foreclosure(RecordEndDate, LoanNumber, ForeclosureId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY] -- ps_DateByMonthRight(RecordEndDate);
		END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* 9.InsuranceLines */
BEGIN TRY
	IF @TableName IS NULL
	OR @TableName = 'InsuranceLines' AND OBJECT_ID('DataMart_History.InsuranceLines' ) IS NOT NULL
		BEGIN
		IF INDEXPROPERTY (OBJECT_ID('DataMart_History.InsuranceLines') , 'IX_DataMart_History_InsuranceLines_CI' , 'IndexID' ) IS NULL
		CREATE CLUSTERED INDEX IX_DataMart_History_InsuranceLines_CI ON DataMart_History.InsuranceLines(RecordEndDate, LoanNumber, InsuranceLinesId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY] -- ps_DateByMonthRight(RecordEndDate);
		END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* 10.InvestorReportingExceptions */
BEGIN TRY
	IF @TableName IS NULL
	OR @TableName = 'InvestorReportingExceptions' AND OBJECT_ID('DataMart_History.InvestorReportingExceptions' ) IS NOT NULL
		BEGIN
		IF INDEXPROPERTY (OBJECT_ID('DataMart_History.InvestorReportingExceptions' ) , 'IX_DataMart_History_InvestorReportingExceptions_CI' , 'IndexID' ) IS NULL
		CREATE CLUSTERED INDEX IX_DataMart_History_InvestorReportingExceptions_CI ON DataMart_History.InvestorReportingExceptions(RecordEndDate, LoanNumber, InvestorReportingExceptionsId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY]
		END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* 11.LetterHistory */
BEGIN TRY
	IF @TableName IS NULL
	OR @TableName = 'LetterHistory' AND OBJECT_ID('DataMart_History.LetterHistory' ) IS NOT NULL
		BEGIN
		IF INDEXPROPERTY (OBJECT_ID('DataMart_History.LetterHistory' ) , 'IX_DataMart_History_LetterHistory_CI' , 'IndexID' ) IS NULL
		CREATE CLUSTERED INDEX IX_DataMart_History_LetterHistory_CI ON DataMart_History.LetterHistory(RecordEndDate, LoanNumber, LetterHistoryId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY] -- ps_DateByMonthRight(RecordEndDate);
		END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* 12.LossMitigation */
BEGIN TRY
	IF @TableName IS NULL
	OR @TableName = 'LossMitigation' AND OBJECT_ID('DataMart_History.LossMitigation' ) IS NOT NULL
		BEGIN
		IF INDEXPROPERTY (OBJECT_ID('DataMart_History.LossMitigation' ) , 'IX_DataMart_History_LossMitigation_CI' , 'IndexID' ) IS NULL
		CREATE CLUSTERED INDEX IX_DataMart_History_LossMitigation_CI ON DataMart_History.LossMitigation(RecordEndDate, LoanNumber, LossMitigationId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY] -- ps_DateByMonthRight(RecordEndDate);
		END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* 13.PaymentChangeHistory */
BEGIN TRY
	IF @TableName IS NULL
	OR @TableName = 'PaymentChangeHistory' AND OBJECT_ID('DataMart_History.PaymentChangeHistory' ) IS NOT NULL
		BEGIN
		IF INDEXPROPERTY (OBJECT_ID('DataMart_History.PaymentChangeHistory' ) , 'IX_DataMart_History_PaymentChangeHistory_CI' , 'IndexID' ) IS NULL
		CREATE CLUSTERED INDEX IX_DataMart_History_PaymentChangeHistory_CI ON DataMart_History.PaymentChangeHistory(RecordEndDate, LoanNumber, PaymentChangeHistoryId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY] -- ps_DateByMonthRight(RecordEndDate);
		END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH

/* 14.RealEstateOwned */
BEGIN TRY
	IF @TableName IS NULL
	OR @TableName = 'RealEstateOwned' AND OBJECT_ID('DataMart_History.RealEstateOwned' ) IS NOT NULL
		BEGIN
		IF INDEXPROPERTY (OBJECT_ID('DataMart_History.RealEstateOwned' ) , 'IX_DataMart_History_RealEstateOwned_CI' , 'IndexID' ) IS NULL
		CREATE CLUSTERED INDEX IX_DataMart_History_RealEstateOwned_CI ON DataMart_History.RealEstateOwned(RecordEndDate, LoanNumber, RealEstateOwnedId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY] -- ps_DateByMonthRight(RecordEndDate);
		END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* 15.CorporateAdvanceTransactions */
BEGIN TRY
	IF @TableName IS NULL
	OR @TableName = 'CorporateAdvanceTransactions' AND OBJECT_ID('DataMart_History.CorporateAdvanceTransactions') IS NOT NULL
		BEGIN
		IF INDEXPROPERTY (OBJECT_ID('DataMart_History.CorporateAdvanceTransactions' ) , 'IX_DataMart_History_CorporateAdvanceTransactions_CI' , 'IndexID' ) IS NULL
		CREATE CLUSTERED INDEX IX_DataMart_History_CorporateAdvanceTransactions_CI ON DataMart_History.CorporateAdvanceTransactions(RecordEndDate, LoanNumber, CorporateAdvanceTransactionsId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY]
		END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* 16.CreditBureauReporting */
BEGIN TRY
	IF @TableName IS NULL
	OR @TableName = 'CreditBureauReporting' AND OBJECT_ID('DataMart_History.CreditBureauReporting' ) IS NOT NULL
		BEGIN
		IF INDEXPROPERTY (OBJECT_ID('DataMart_History.CreditBureauReporting' ) , 'IX_DataMart_History_CreditBureauReporting_CI' , 'IndexID' ) IS NULL
		CREATE CLUSTERED INDEX IX_DataMart_History_CreditBureauReporting_CI ON DataMart_History.CreditBureauReporting(RecordEndDate, LoanNumber, CreditBureauReportingId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY] -- ps
		END;
END TRY
BEGIN CATCH
SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* 17.CycleDates */
BEGIN TRY
	IF @TableName IS NULL
	OR @TableName = 'CycleDates' AND OBJECT_ID('DataMart_History.CycleDates' ) IS NOT NULL
		BEGIN
		IF INDEXPROPERTY (OBJECT_ID('DataMart_History.CycleDates' ) , 'IX_DataMart_History_CycleDates_CI' , 'IndexID' ) IS NULL
		CREATE CLUSTERED INDEX IX_DataMart_History_CycleDates_CI ON DataMart_History.CycleDates(RecordEndDate, CycleDate) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY] -- ps_DateByMonthRight(RecordEndDate);
		END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* 18.DisasterTracking */
BEGIN TRY
	IF @TableName IS NULL
	OR @TableName = 'DisasterTracking' AND OBJECT_ID('DataMart_History.DisasterTracking' ) IS NOT NULL
		BEGIN
		IF INDEXPROPERTY (OBJECT_ID('DataMart_History.DisasterTracking' ) , 'IX_DataMart_History_DisasterTracking_CI' , 'IndexID' ) IS NULL
		CREATE CLUSTERED INDEX IX_DataMart_History_DisasterTracking_CI ON DataMart_History.DisasterTracking(RecordEndDate, LoanNumber, DisasterTrackingId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY]; -- ps_DateByMonthRight(RecordEndDate) (RecordEndDate)
		END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* 19.ReportedStatusFha */
BEGIN TRY
	IF @TableName IS NULL
	OR @TableName = 'ReportedStatusFha' AND OBJECT_ID('DataMart_History.ReportedStatusFha' ) IS NOT NULL
		BEGIN
		IF INDEXPROPERTY (OBJECT_ID('DataMart_History.ReportedStatusFha' ) , 'IX_DataMart_History_ReportedStatusFha_CI' , 'IndexID' ) IS NULL
		CREATE CLUSTERED INDEX IX_DataMart_History_ReportedStatusFha_CI ON DataMart_History.ReportedStatusFha(RecordEndDate, LoanNumber, ReportedStatusFhaId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY];
		END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* 20.EffectiveDates */
BEGIN TRY
	IF @TableName IS NULL
	OR @TableName = 'EffectiveDates' AND OBJECT_ID('DataMart_History.EffectiveDates' ) IS NOT NULL
		BEGIN
		IF INDEXPROPERTY (OBJECT_ID('DataMart_History.EffectiveDates' ) , 'IX_DataMart_History_EffectiveDates_CI' , 'IndexID' ) IS NULL
		CREATE CLUSTERED INDEX IX_DataMart_History_EffectiveDates_CI ON DataMart_History.EffectiveDates(RecordEndDate, EffectiveDate) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY]; -- ps_DateByMonthRight(RecordEndDate);
		END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* 21.DocumentImaging */
BEGIN TRY
	IF @TableName IS NULL
	OR @TableName = 'DocumentImaging' AND OBJECT_ID('DataMart_History.DocumentImaging' ) IS NOT NULL
		BEGIN
		IF INDEXPROPERTY (OBJECT_ID('DataMart_History.DocumentImaging' ) , 'IX_DataMart_DocumentImaging_CI' , 'IndexID' ) IS NULL
		CREATE CLUSTERED INDEX IX_DataMart_DocumentImaging_CI ON DataMart_History.DocumentImaging(RecordEndDate, LoanNumber, DocumentImagingId) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY];
		END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;

/* 22.BusinessFields */
BEGIN TRY
	IF @TableName IS NULL
	OR @TableName = 'Loan' AND OBJECT_ID('DataMart_History.BusinessFields' ) IS NOT NULL
		BEGIN
		IF INDEXPROPERTY (OBJECT_ID('DataMart_History.BusinessFields') , 'IX_DataMart_History_BusinessFields_CI' , 'IndexID' ) IS NULL
		CREATE CLUSTERED INDEX IX_DataMart_History_BusinessFields_CI ON DataMart_History.BusinessFields(RecordEndDate, LoanNumber) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY];
		END;
END TRY
BEGIN CATCH
	SELECT * FROM Processing.vw_ReturnedError;
END CATCH;
