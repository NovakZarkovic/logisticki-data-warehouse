USE LogistikaDW;
GO

CREATE OR ALTER PROCEDURE usp_Pokreni_ETL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
            EXEC usp_Ucitaj_Dimenzije;
            EXEC usp_Ucitaj_Cinjenice;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;   -- prosledi originalnu grešku dalje
    END CATCH;
END;
GO

-- TEST 1: ponovno pokretanje bez ikakvih promena
EXEC usp_Pokreni_ETL;
SELECT COUNT(*) AS PosiljkiPosleDrugogPokretanja FROM fact_Posiljke;

-- TEST 2: obrišemo celu tabelu činjenica i učitamo iznova
DELETE FROM fact_Posiljke;
EXEC usp_Pokreni_ETL;
SELECT COUNT(*) AS PosiljkiPosleUcitavanjaOdNule FROM fact_Posiljke;