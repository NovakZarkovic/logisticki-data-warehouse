USE LogistikaDW;
GO

CREATE OR ALTER PROCEDURE usp_Ucitaj_Cinjenice
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Ociscen AS (
        SELECT
            LTRIM(RTRIM(BrojPosiljke)) AS Br,
            ISNULL(NULLIF(UPPER(LTRIM(RTRIM(Kupac))), ''), 'NEPOZNAT KUPAC') AS KupacC,
            LTRIM(RTRIM(GradPolaska)) AS Polazak,
            LTRIM(RTRIM(GradDolaska)) AS Dolazak,
            LTRIM(RTRIM(Prevoznik))   AS Prev,
            COALESCE(TRY_CONVERT(DATE, DatumPolaska, 23),     TRY_CONVERT(DATE, DatumPolaska, 104))     AS DatPol,
            COALESCE(TRY_CONVERT(DATE, PlaniranaDostava, 23), TRY_CONVERT(DATE, PlaniranaDostava, 104)) AS DatPlan,
            COALESCE(TRY_CONVERT(DATE, StvarnaDostava, 23),   TRY_CONVERT(DATE, StvarnaDostava, 104))   AS DatStv,
            TRY_CAST(TezinaKg     AS DECIMAL(10,2)) AS Kg,
            TRY_CAST(RastojanjeKm AS DECIMAL(10,2)) AS Km,
            TRY_CAST(Prihod       AS DECIMAL(10,2)) AS Prih,
            TRY_CAST(Trosak       AS DECIMAL(10,2)) AS Tros,
            ROW_NUMBER() OVER (PARTITION BY BrojPosiljke ORDER BY (SELECT NULL)) AS rn
        FROM stg_Posiljke
    )
    INSERT INTO fact_Posiljke
        (BrojPosiljke, KupacKey, RutaKey, PrevoznikKey, DatumPolaskaKey,
         PlaniranaDostava, StvarnaDostava, TezinaKg, RastojanjeKm, Prihod, Trosak, KasnjenjeDana)
    SELECT
        o.Br, k.KupacKey, r.RutaKey, p.PrevoznikKey, d.DatumKey,
        o.DatPlan, o.DatStv, o.Kg, o.Km, o.Prih, o.Tros,
        DATEDIFF(DAY, o.DatPlan, o.DatStv)
    FROM Ociscen o
    JOIN dim_Kupac     k ON k.NazivKupca      = o.KupacC
    JOIN dim_Ruta      r ON r.GradPolaska     = o.Polazak AND r.GradDolaska = o.Dolazak
    JOIN dim_Prevoznik p ON p.NazivPrevoznika = o.Prev
    JOIN dim_Datum     d ON d.Datum           = o.DatPol
    WHERE o.rn = 1
      AND NOT EXISTS (SELECT 1 FROM fact_Posiljke f WHERE f.BrojPosiljke = o.Br);
END;
GO

EXEC usp_Ucitaj_Cinjenice;
GO

-- provera
SELECT
    COUNT(*)                                                    AS UkupnoPosiljki,
    SUM(CASE WHEN Prihod IS NULL THEN 1 ELSE 0 END)             AS BezPrihoda,
    SUM(CASE WHEN KasnjenjeDana > 0 THEN 1 ELSE 0 END)          AS Kasne,
    CAST(100.0 * SUM(CASE WHEN KasnjenjeDana > 0 THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,1)) AS ProcenatKasnjenja
FROM fact_Posiljke;

SELECT k.NazivKupca, COUNT(*) AS BrojPosiljki
FROM fact_Posiljke f
JOIN dim_Kupac k ON k.KupacKey = f.KupacKey
GROUP BY k.NazivKupca
ORDER BY BrojPosiljki DESC;