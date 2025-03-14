/*
-- Get tables volume after Hist Update run, and perf stats from log table
select SCHEMA_NAME(o.schema_id)+'.'+o.name as tbl, format(rows,'N0') as rows
from sysindexes as i
join sys.objects as o
on i.id = o.object_id and indid in (0,1)
where o.type='U' AND SCHEMA_NAME(o.schema_id) in ('DataMart','DataMart_History' )
AND o.name NOT LIKE '%_old'
order by o.name, o.schema_id

select * from DataMart_Log.Update_DataMart_History_log

-------drop test procs for testing
DECLARE @dropProc VARCHAR(MAX) = (SELECT STRING_AGG(CONCAT('drop proc ',SCHEMA_NAME(schema_id),'.',name), CHAR(13))
FROM sys.objects AS 0
WHERE type='P' AND SCHEMA_NAME(schema_id) = 'test' -- 'DataMart_History'
)
SELECT @dropProc
EXEC (@dropProc)
--------drop test tables for testing
DECLARE @dropTbl VARCHAR(MAX) = (SELECT STRING_AGG(CONCAT('drop table',SCHEMA_NAME(schema_id),'.',name),CHAR(13))
FROM sys.objects AS 0
WHERE type='U' AND SCHEMA_NAME(schema_id) = 'test_history' -- 'DataMart_History'
)
SELECT @dropTbl
EXEC (@dropTbl)

RENAME TABLES BEFORE
DECLARE @renameTbl VARCHAR(MAX) =
(SELECT STRING_AGG(CONCAT('exec sp_rename ','''', SCHEMA_NAME(o.schema_id),'.',o.name,''' ',' ,','''',o.name,'_old' ,''' ','; '), CHAR(13))
FROM sys.objects AS 0
WHERE type='U' AND SCHEMA_NAME(schema_id) = 'DataMart_History' AND o.name NOT LIKE '%_old' )

EXEC (@renameTbl)
*/

-- RUN History Update with created static procedures

EXEC Processing.Update_DataMart_History

