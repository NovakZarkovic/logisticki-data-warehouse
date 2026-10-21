SELECT @@VERSION;

CREATE DATABASE LogistikaDW;
GO

USE LogistikaDW;
GO

SELECT DB_NAME() AS TrenutnaBaza;

USE LogistikaDW;
GO

CREATE TABLE stg_Posiljke (
    BrojPosiljke     VARCHAR(50),
    Kupac            VARCHAR(100),
    GradPolaska      VARCHAR(100),
    GradDolaska      VARCHAR(100),
    Prevoznik        VARCHAR(100),
    DatumPolaska     VARCHAR(50),
    PlaniranaDostava VARCHAR(50),
    StvarnaDostava   VARCHAR(50),
    TezinaKg         VARCHAR(50),
    RastojanjeKm     VARCHAR(50),
    Prihod           VARCHAR(50),
    Trosak           VARCHAR(50)
);
GO

SELECT COUNT(*) AS BrojRedova FROM stg_Posiljke;