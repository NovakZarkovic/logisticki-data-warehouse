USE LogistikaDW;
GO

-- 1) Rute sa najvećim procentom kašnjenja
SELECT TOP 5
    r.NazivRute,
    COUNT(*) AS BrojPosiljki,
    SUM(CASE WHEN f.KasnjenjeDana > 0 THEN 1 ELSE 0 END) AS Kasne,
    CAST(100.0 * SUM(CASE WHEN f.KasnjenjeDana > 0 THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,1)) AS ProcenatKasnjenja
FROM fact_Posiljke f
JOIN dim_Ruta r ON r.RutaKey = f.RutaKey
GROUP BY r.NazivRute
HAVING COUNT(*) >= 10
ORDER BY ProcenatKasnjenja DESC;

-- 2) Dobit po kupcu (samo pošiljke koje imaju prihod)
SELECT
    k.NazivKupca,
    SUM(f.Prihod) AS Prihod,
    SUM(f.Trosak) AS Trosak,
    SUM(f.Prihod) - SUM(f.Trosak) AS Dobit
FROM fact_Posiljke f
JOIN dim_Kupac k ON k.KupacKey = f.KupacKey
WHERE f.Prihod IS NOT NULL
GROUP BY k.NazivKupca
ORDER BY Dobit DESC;

-- 3) Mesečni trošak po kilometru
SELECT
    d.Godina,
    d.Mesec,
    d.NazivMeseca,
    CAST(SUM(f.Trosak) / SUM(f.RastojanjeKm) AS DECIMAL(10,2)) AS TrosakPoKm
FROM fact_Posiljke f
JOIN dim_Datum d ON d.DatumKey = f.DatumPolaskaKey
GROUP BY d.Godina, d.Mesec, d.NazivMeseca
ORDER BY d.Godina, d.Mesec;

-- 4) Rang prevoznika po dobiti (window funkcija RANK)
SELECT
    p.NazivPrevoznika,
    SUM(f.Prihod) - SUM(f.Trosak) AS Dobit,
    RANK() OVER (ORDER BY SUM(f.Prihod) - SUM(f.Trosak) DESC) AS Rang
FROM fact_Posiljke f
JOIN dim_Prevoznik p ON p.PrevoznikKey = f.PrevoznikKey
WHERE f.Prihod IS NOT NULL
GROUP BY p.NazivPrevoznika;