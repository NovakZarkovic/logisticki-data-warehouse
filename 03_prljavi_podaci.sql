USE LogistikaDW;
GO

-- 1) prazan kupac (15 nasumičnih redova)
UPDATE stg_Posiljke
SET Kupac = NULL
WHERE BrojPosiljke IN (SELECT TOP 15 BrojPosiljke FROM stg_Posiljke ORDER BY NEWID());

-- 2) kupac velikim slovima i sa razmakom ispred (20 redova)
UPDATE stg_Posiljke
SET Kupac = '  ' + UPPER(Kupac)
WHERE BrojPosiljke IN (SELECT TOP 20 BrojPosiljke FROM stg_Posiljke ORDER BY NEWID());

-- 3) datum polaska u formatu dd.mm.gggg (30 redova)
UPDATE stg_Posiljke
SET DatumPolaska = CONVERT(VARCHAR(10), CAST(DatumPolaska AS DATE), 104)
WHERE BrojPosiljke IN (SELECT TOP 30 BrojPosiljke FROM stg_Posiljke ORDER BY NEWID());

-- 4) prihod "N/A" (10 redova)
UPDATE stg_Posiljke
SET Prihod = 'N/A'
WHERE BrojPosiljke IN (SELECT TOP 10 BrojPosiljke FROM stg_Posiljke ORDER BY NEWID());

-- 5) duplikati: 20 nasumičnih redova se kopira još jednom
INSERT INTO stg_Posiljke
SELECT TOP 20 * FROM stg_Posiljke ORDER BY NEWID();
GO

-- provera
SELECT
    COUNT(*)                                          AS UkupnoRedova,
    COUNT(DISTINCT BrojPosiljke)                      AS RazlicitihPosiljki,
    SUM(CASE WHEN Kupac IS NULL THEN 1 ELSE 0 END)    AS BezKupca,
    SUM(CASE WHEN DatumPolaska LIKE '%.%' THEN 1 ELSE 0 END) AS DatumSaTackama,
    SUM(CASE WHEN Prihod = 'N/A' THEN 1 ELSE 0 END)   AS PrihodNA
FROM stg_Posiljke;