DROP VIEW IF EXISTS Processing.vw_ReturnedError
GO
CREATE VIEW Processing.vw_ReturnedError
AS
SELECT CONCAT('ErrorNumber: ', ERROR_NUMBER(),
' ErrorSeverity: ', ERROR_SEVERITY(),
' ErrorState: ', ERROR_STATE(),
' ErrorProcedure: ', ISNULL(ERROR_PROCEDURE(), 'Ad-Hoc Query' ),
' ErrorLine: ', ISNULL(ERROR_LINE(),0),
' ErrorMessage: ', ERROR_MESSAGE() ) as ReturnedError;

GO