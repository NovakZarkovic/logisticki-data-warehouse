USE LogistikaDW;
GO

TRUNCATE TABLE stg_Posiljke;
GO

DECLARE @Kupci TABLE (Naziv VARCHAR(100));
INSERT INTO @Kupci VALUES
 ('Delta Trade'), ('Nova Pharma'), ('Agro Plus'), ('Metal Servis'),
 ('Tekstil Group'), ('Auto Delovi Srbija'), ('Mlekara Sumadija'), ('Elektro Market');

DECLARE @Gradovi TABLE (Naziv VARCHAR(100));
INSERT INTO @Gradovi VALUES
 ('Beograd'), ('Novi Sad'), ('Nis'), ('Kragujevac'),
 ('Subotica'), ('Kraljevo'), ('Zrenjanin'), ('Smederevo');

DECLARE @Prevoznici TABLE (Naziv VARCHAR(100));
INSERT INTO @Prevoznici VALUES
 ('Balkan Trans'), ('Moravac Prevoz'), ('Dunav Logistik'), ('Sumadija Cargo');

DECLARE @i INT = 1;
DECLARE @kupac VARCHAR(100), @polazak VARCHAR(100), @dolazak VARCHAR(100), @prevoznik VARCHAR(100);
DECLARE @datum DATE, @planirano DATE, @stvarno DATE;
DECLARE @km INT, @kg INT, @r INT, @kasnjenje INT;
DECLARE @trosak DECIMAL(10,2), @prihod DECIMAL(10,2);

WHILE @i <= 1000
BEGIN
    SELECT TOP 1 @kupac = Naziv FROM @Kupci ORDER BY NEWID();
    SELECT TOP 1 @polazak = Naziv FROM @Gradovi ORDER BY NEWID();
    SELECT TOP 1 @dolazak = Naziv FROM @Gradovi WHERE Naziv <> @polazak ORDER BY NEWID();
    SELECT TOP 1 @prevoznik = Naziv FROM @Prevoznici ORDER BY NEWID();

    SET @datum     = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 365, '2025-01-01');
    SET @planirano = DATEADD(DAY, 1 + ABS(CHECKSUM(NEWID())) % 3, @datum);

    -- oko 70% pošiljki stiže na vreme, ostale kasne 1-4 dana
    SET @r = ABS(CHECKSUM(NEWID())) % 100;
    SET @kasnjenje = CASE WHEN @r < 70 THEN 0 ELSE 1 + ABS(CHECKSUM(NEWID())) % 4 END;
    SET @stvarno = DATEADD(DAY, @kasnjenje, @planirano);

    SET @km = 100 + ABS(CHECKSUM(NEWID())) % 500;
    SET @kg = 100 + ABS(CHECKSUM(NEWID())) % 9900;
    SET @trosak = @km * (0.6 + (ABS(CHECKSUM(NEWID())) % 40) / 100.0);
    SET @prihod = @trosak * (0.9 + (ABS(CHECKSUM(NEWID())) % 50) / 100.0);

    INSERT INTO stg_Posiljke
    VALUES (
        'PO' + RIGHT('00000' + CAST(@i AS VARCHAR(5)), 5),
        @kupac, @polazak, @dolazak, @prevoznik,
        CONVERT(VARCHAR(10), @datum, 23),
        CONVERT(VARCHAR(10), @planirano, 23),
        CONVERT(VARCHAR(10), @stvarno, 23),
        CAST(@kg AS VARCHAR(50)),
        CAST(@km AS VARCHAR(50)),
        CAST(@prihod AS VARCHAR(50)),
        CAST(@trosak AS VARCHAR(50))
    );

    SET @i = @i + 1;
END;
GO

SELECT COUNT(*) AS BrojRedova FROM stg_Posiljke;
SELECT TOP 10 * FROM stg_Posiljke;