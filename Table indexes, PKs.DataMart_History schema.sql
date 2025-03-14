CREATE CLUSTERED INDEX IX_DataMart_History_Bankruptcy_CI ON DataMart_History.Bankruptcy (RecordEndDate, LoanNumber) WITH(DATA_COMPRESSION = PAGE ) ON ps_DateByMonthRight(RecordEndDate);
CREATE NONCLUSTERED INDEX IX_DataMart_History_Bankruptcy_LoanNumber_RecordStartDate ON DataMart_History.Bankruptcy(LoanNumber, RecordStartDate) WITH(DATA_COMPRESSION = PAGE )ON ps_DateByMonthRight(RecordEndDate);
CREATE CLUSTERED INDEX IX_DataMart_History_BorrowerDoNotCallPreferences_CI ON DataMart_History.BorrowerDoNotCallPreferences (RecordEndDate, LoanNumber, BorrowerDoNotCallPreferencesID) WITH(DATA_COMPRESSION = PAGE ) ON ps_DateByMonthRight(RecordEndDate);
CREATE CLUSTERED INDEX IX_DataMart_History_BusinessFields_CI ON DataMart_History.BusinessFields (RecordEndDate, LoanNumber) WITH(DATA_COMPRESSION = PAGE ) ON ps_DateByMonthRight (RecordEndDate);
CREATE CLUSTERED INDEX IX_DataMart_History_CorporateAdvanceTransactions_CI ON DataMart_History.CorporateAdvanceTransactions (RecordEndDate, LoanNumber, CorporateAdvanceTransactionsId) WITH(DATA_COMPRESSION = PAGE ) ON ps_DateByMonthRight(RecordEndDate);
CREATE CLUSTERED INDEX IX_DataMart_History_CreditBureauReporting_CI ON DataMart_History.CreditBureauReporting (RecordEndDate, LoanNumber, CreditBureauReportingId) WITH(DATA_COMPRESSION = PAGE ) ON ps_DateByMonthRight (RecordEndDate);
CREATE CLUSTERED INDEX IX_DataMart_History_CycleDates_CI ON DataMart_History.CycleDates (RecordEndDate, CycleDate) WITH(DATA_COMPRESSION = PAGE ) ON ps_DateByMonthRight(RecordEndDate);
CREATE CLUSTERED INDEX IX_DataMart_History_DisasterTracking_CI ON DataMart_History.DisasterTracking(RecordEndDate, LoanNumber, DisasterTrackingId) WITH(DATA_COMPRESSION = PAGE ) ON [PRIMARY];
CREATE CLUSTERED INDEX IX_DataMart_DocumentImaging_CI ON DataMart_History.DocumentImaging (RecordEndDate, LoanNumber, DocumentImagingId) WITH(DATA_COMPRESSION = PAGE ) ON [PRIMARY];
CREATE CLUSTERED INDEX IX_DataMart_History_EffectiveDates_CI ON DataMart_History.EffectiveDates (RecordEndDate, EffectiveDate) WITH(DATA_COMPRESSION = PAGE )ON ps_DateByMonthRight(RecordEndDate);
CREATE CLUSTERED INDEX IX_DataMart_History_Escrow_CI ON DataMart_History.Escrow(RecordEndDate, LoanNumber ) WITH(DATA_COMPRESSION = PAGE ) ON ps_DateByMonthRight(RecordEndDate);
CREATE CLUSTERED INDEX IX_DataMart_History_EventHistory_CI ON DataMart_History.EventHistory(RecordEndDate, LoanNumber) WITH(DATA_COMPRESSION = PAGE )ON ps_DateByMonthRight(RecordEndDate);
CREATE CLUSTERED INDEX IX_DataMart_History_ForbearancePlan_CI ON DataMart_History.ForbearancePlan(RecordEndDate, LoanNumber) WITH(DATA_COMPRESSION = PAGE )ON ps_DateByMonthRight (RecordEndDate);
CREATE CLUSTERED INDEX IX_DataMart_History_Foreclosure_CI ON DataMart_History.Foreclosure(RecordEndDate, LoanNumber, ForeclosureId) WITH(DATA_COMPRESSION = PAGE ) ON ps_DateByMonthRight (RecordEndDate);
CREATE CLUSTERED INDEX IX_DataMart_History_Insurancelines_CI ON DataMart_History.InsuranceLines (RecordEndDate, LoanNumber, InsuranceLinesId) WITH(DATA_COMPRESSION = PAGE )ON ps_DateByMonthRight (RecordEndDate);
CREATE CLUSTERED INDEX IX_DataMart_History_InvestorReportingExceptions_CI ON DataMart_History.InvestorReportingExceptions (RecordEndDate, LoanNumber, InvestorReportingExceptionsId) WITH(DATA_COMPRESSION = PAGE )ON ps_DateByMonthRight(RecordEndDate);
CREATE CLUSTERED INDEX IX_DataMart_History_LetterHistory_CI ON DataMart_History.LetterHistory(RecordEndDate, LoanNumber, LetterHistoryId) WITH(DATA_COMPRESSION = PAGE ) ON [PRIMARY];
CREATE CLUSTERED INDEX IX_DataMart_History_Loan_CI ON DataMart_History.Loan(RecordEndDate, LoanNumber ) WITH(DATA_COMPRESSION = PAGE ) ON ps_DateByMonthRight(RecordEndDate);
CREATE CLUSTERED INDEX IX_DataMart_History_LossMitigation_CI ON DataMart_History.LossMitigation(RecordEndDate, LoanNumber, LossMitigationId) WITH(DATA_COMPRESSION = PAGE ) ON ps_DateByMonthRight(RecordEndDate);
CREATE CLUSTERED INDEX IX_DataMart_History_PaymentChangeHistory_CI ON DataMart_History.PaymentChangeHistory(RecordEndDate, LoanNumber, PaymentChangeHistoryId) WITH(DATA_COMPRESSION = PAGE ) ON [PRIMARY];
CREATE CLUSTERED INDEX IX_DataMart_History_RealEstateOwned_CI ON DataMart_History.RealEstateOwned(RecordEndDate, LoanNumber, RealEstateOwnedId) WITH(DATA_COMPRESSION = PAGE ) ON ps_DateByMonthRight (RecordEndDate);
CREATE CLUSTERED INDEX IX_DataMart_History_ReportedStatusFha_CI ON DataMart_History.ReportedStatusFha (RecordEndDate, LoanNumber, ReportedStatusFhaId) WITH(DATA_COMPRESSION = PAGE ) ON [PRIMARY];
CREATE CLUSTERED INDEX IX_DataMart_History_Valeri_CI ON DataMart_History.Valeri(RecordEndDate, LoanNumber, ValeriId) WITH(DATA_COMPRESSION = PAGE ) ON [PRIMARY];

CREATE CLUSTERED INDEX [IX RuleId_RowHash_CI] ON [DailyResults]. [RuleResults] ([RuleId], [RowHash]) WITH (DATA_COMPRESSION = PAGE ) ON [PRIMARY];
CREATE NONCLUSTERED INDEX [IX_RuleId RecordId_CycleId ActionByDate] ON [DailyResults]. [RuleResults] ([RuleId], [RecordId]) INCLUDE ([ActionByDate], [CycleId]) WITH (DATA_COMPRESSION = PAGE ) ON [PRIMARY];

-- original not mine
CREATE CLUSTERED COLUMNSTORE INDEX [IX_DailyResults_ActiveResults_CCI] ON [DailyResults]. [ActiveResults] ON [PRIMARY];
ALTER TABLE [DailyResults]. [ActiveResults] ADD CONSTRAINT [PK_DailyResults_ActiveResults] PRIMARY KEY NONCLUSTERED ([CycleId]) ON [PRIMARY];
