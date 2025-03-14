CREATE FUNCTION [Utilities].[RemoveHtmlTags] (@InputString VARCHAR(MAX))
RETURNS VARCHAR (MAX)
AS
BEGIN
	SELECT @InputString = REPLACE(REPLACE(@InputString, '<br>', CHAR(10)), '<p', CONCAT(CHAR(10), '<p'));
	WHILE (@InputString LIKE '%<%>%')
	BEGIN
		SELECT @InputString
			= STUFF(
				  @InputString
				, CHARINDEX('<', @InputString)
				, CHARINDEX('>', @InputString) + 1 - CHARINDEX('<', @InputString)
				, '');
	END;

WHILE (@InputString LIKE CONCAT(CHAR(10), '%'))
BEGIN
	SELECT @InputString = SUBSTRING(@InputString, 2, 99999);
END;

RETURN REPLACE(
			REPLACE(
				REPLACE(REPLACE(REPLACE(@InputString, '&lt;', '<' ), '&gt;', ' >' ) , '&nbsp; ', ' '), '&quot;', '"' )
			, '&amp;'
			, '&');

END;

GO