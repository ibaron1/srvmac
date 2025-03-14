create schema DataMart

CREATE TABLE [DataMart].[CycleDates](
[RowHash] [bigint] NULL,
[RecordStartDate] [date] NULL,
[RecordEndDate] [date] NULL,
[CycleDate] [date] NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO

CREATE TABLE DateReference.CycleDates(
[CycleDate] [DATE] NOT NULL,
[CycleNumber] [INT] NULL,
[CycleNumberWithinYear] [SMALLINT] NULL,
[CycleNumberWithinMonth] [SMALLINT] NULL,
[IsMonthEnd] [BIT] NULL,
CONSTRAINT [PK_DateReference_CycleDates] PRIMARY KEY CLUSTERED
([CycleDate] ASC)WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY]
) ON [PRIMARY]

GO