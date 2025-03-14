CREATE FUNCTION [Utilities].[GetItemFromDelimitedList]
(@InputString VARCHAR(MAX)
, @Delimiter VARCHAR(MAX)
, @PositionToGet INT
, @RightToLeft BIT = 0)
RETURNS VARCHAR (MAX)
AS

BEGIN
	DECLARE @Result VARCHAR(MAX);
	DECLARE @PositionGot INT = 1;
	SELECT @PositionToGet = COALESCE(@PositionToGet, 0);

	IF (@RightToLeft = 1) SELECT @InputString = REVERSE(@InputString);

	IF @PositionToGet <= 0
		BEGIN
			SELECT @Result = NULL;
		END;
	ELSE
		BEGIN
			WHILE (@PositionGot < @PositionToGet)
			BEGIN
				SELECT @InputString
					= SUBSTRING(@InputString, CHARINDEX(@Delimiter, @InputString +@Delimiter) + 1, 999);
				SELECT @PositionGot = @PositionGot + 1;
			END;

			SELECT @Result
				= NULLIF(SUBSTRING(@InputString, 1, CHARINDEX(@Delimiter, @InputString + @Delimiter) - 1), '');
		END;

	IF (@RightToLeft = 1) 
		SELECT @Result = REVERSE(@Result);

	RETURN @Result;
END;





GO