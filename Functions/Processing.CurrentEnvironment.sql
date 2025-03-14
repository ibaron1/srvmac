CREATE OR ALTER FUNCTION Processing.CurrentEnvironment()
RETURNS VARCHAR (20)
AS
	BEGIN
		DECLARE @CurrentEnvironment VARCHAR(20) = CASE WHEN DB_NAME() LIKE '%Dev' THEN
													'Development'
													WHEN @@SERVERNAME LIKE '%dev%' THEN
													'Test'
													WHEN @@SERVERNAME NOT LIKE '%dev%' THEN
													'Production'
													ELSE
													'Unknown '
												END;

		RETURN @CurrentEnvironment;
	END;

GO