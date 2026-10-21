USE LogistikaDW;
GO

CREATE OR ALTER PROCEDURE usp_Ucitaj_Dimenzije
AS
BEGIN
    SET NOCOUNT ON;

    -- 1) dim_Datum: kalendar 2025-2026
    ;WITH Dani AS (
        SELECT CAST('2025-01-01' AS DATE) AS Datum
        UNION ALL
        SELECT DATEADD(DAY, 1, Datum) FROM Dani WHERE Datum < '2026-12-31'
    )
    INSERT INTO dim_Datum (DatumKey, Datum, Godina, Kvartal, Mesec, NazivMeseca, Dan, NazivDana)
    SELECT
        CONVERT(INT, CONVERT(CHAR(8), d.Datum, 112)),
        d.Datum,
        YEAR(d.Datum),
        DATEPART(QUARTER, d.Datum),
        MONTH(d.Datum),
        DATENAME(MONTH, d.Datum),
        DAY(d.Datum),
        DATENAME(WEEKDAY, d.Datum)
    FROM Dani d
    WHERE NOT EXISTS (SELECT 1 FROM dim_Datum x WHERE x.Datum = d.Datum)
    OPTION (MAXRECURSION 1000);

    -- 2) dim_Kupac: čišćenje naziva
    INSERT INTO dim_Kupac (NazivKupca)
    SELECT DISTINCT s.Kupac
    FROM (
        SELECT ISNULL(NULLIF(UPPER(LTRIM(RTRIM(Kupac))), ''), 'NEPOZNAT KUPAC') AS Kupac
        FROM stg_Posiljke
    ) s
    WHERE NOT EXISTS (SELECT 1 FROM dim_Kupac k WHERE k.NazivKupca = s.Kupac);

    -- 3) dim_Ruta
    INSERT INTO dim_Ruta (GradPolaska, GradDolaska, NazivRute)
    SELECT DISTINCT
        LTRIM(RTRIM(s.GradPolaska)),
        LTRIM(RTRIM(s.GradDolaska)),
        LTRIM(RTRIM(s.GradPolaska)) + ' - ' + LTRIM(RTRIM(s.GradDolaska))
    FROM stg_Posiljke s
    WHERE NOT EXISTS (
        SELECT 1 FROM dim_Ruta r
        WHERE r.GradPolaska = LTRIM(RTRIM(s.GradPolaska))
          AND r.GradDolaska = LTRIM(RTRIM(s.GradDolaska))
    );

    -- 4) dim_Prevoznik
    INSERT INTO dim_Prevoznik (NazivPrevoznika)
    SELECT DISTINCT LTRIM(RTRIM(s.Prevoznik))
    FROM stg_Posiljke s
    WHERE NOT EXISTS (
        SELECT 1 FROM dim_Prevoznik p WHERE p.NazivPrevoznika = LTRIM(RTRIM(s.Prevoznik))
    );
END;
GO

-- pokretanje procedure
EXEC usp_Ucitaj_Dimenzije;
GO

-- provera
SELECT 'dim_Datum' AS Tabela, COUNT(*) AS BrojRedova FROM dim_Datum
UNION ALL SELECT 'dim_Kupac',     COUNT(*) FROM dim_Kupac
UNION ALL SELECT 'dim_Ruta',      COUNT(*) FROM dim_Ruta
UNION ALL SELECT 'dim_Prevoznik', COUNT(*) FROM dim_Prevoznik;

SELECT * FROM dim_Kupac;