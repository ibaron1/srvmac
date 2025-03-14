CREATE or alter FUNCTION [Utilities].[Env]()
RETURNS VARCHAR(7)
AS
BEGIN
	RETURN CASE Processing. CurrentEnvironment()
		WHEN 'Development'
		THEN 'DEV'
		WHEN 'Test'
		THEN 'UAT'
		WHEN 'Production'
		THEN 'PROD'
		ELSE 'UserEnv'	
	END;
END;