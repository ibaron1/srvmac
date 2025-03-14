CREATE OR ALTER PROCEDURE Processing.Update DataMart @ViewLogs INT = 0, @TargetSchema VARCHAR (100) = 'DataMart PreviousDay'
AS

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET DEADLOCK_PRIORITY 10;

DECLARE @EmailSubject NVARCHAR(255);
DECLARE @EmailBody NVARCHAR(MAX) = N'';
DECLARE @EmailPriority TINYINT;

IF

Utilities.Launch DataMartUpdate) = 1

LaunchDataMartUpdate = 0;

(

FROM
WHERE

BEGIN

AND ProcName

BEGIN TRY

(SELECT LaunchDataMartUpdate FROM
BEGIN

/* 1. Reset launch flag to be set by ControlTower */
UPDATE Utilities.Launch DataMartUpdate
SET

/* set up to exclude Update DataMart_PreviousDay schema from rerun */
IF EXISTS
SELECT 1
DataMart_Log.Update_DataMart_log
CAST(StartTime AS DATE) = CAST(GETDATE() AS DATE)
= 'Utilities.MoveSchema' )