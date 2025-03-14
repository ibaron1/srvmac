use ServiceMac
go
CREATE FUNCTION [Processing].[DevOpsCurrentEnv]()
RETURNS VARCHAR(20)
AS
BEGIN
DECLARE @DevOpsCurrentEnv VARCHAR(20) = CASE WHEN DB_NAME() LIKE '%Dev' THEN
'New'
WHEN @@SERVERNAME LIKE '%dev%' THEN
'User Testing'
WHEN @@SERVERNAME NOT LIKE '%dev%' THEN
'Production'
ELSE
'Unknown'
END;
RETURN @DevOpsCurrentEnv;
END;