use ServiceMac
GO

UPDATE Utilities.Launch_DataMartUpdate
SET LaunchDataMartUpdate = 1,
PreviousLaunchTime = LaunchTime;

UPDATE Utilities.Launch_DataMartUpdate
SET LaunchTime = GETDATE();

EXEC Processing.Update_DataMart;

select * from Utilities.Launch_DataMartUpdate;

/* select from temporal log table
SELECT *
FROM DataMart_Log.Update_DataMart_History_log
FOR SYSTEM_TIME BETWEEN '2025-01-04' AND '2025-01-17'
WHERE ProcedureName LIKE '%Update_DataMart_History_%' AND EndTime IS NOT NULL
ORDER BY ValidFrom DESC;
*/
