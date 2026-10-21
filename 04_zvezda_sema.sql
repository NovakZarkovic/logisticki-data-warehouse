USE LogistikaDW;
GO

-- brisanje redom: prvo tabela činjenica, pa dimenzije (zbog stranih ključeva)
IF OBJECT_ID('fact_Posiljke') IS NOT NULL DROP TABLE fact_Posiljke;
IF OBJECT_ID('dim_Kupac')     IS NOT NULL DROP TABLE dim_Kupac;
IF OBJECT_ID('dim_Ruta')      IS NOT NULL DROP TABLE dim_Ruta;
IF OBJECT_ID('dim_Prevoznik') IS NOT NULL DROP TABLE dim_Prevoznik;
IF OBJECT_ID('dim_Datum')     IS NOT NULL DROP TABLE dim_Datum;
GO

CREATE TABLE dim_Kupac (
    KupacKey    INT IDENTITY(1,1) PRIMARY KEY,
    NazivKupca  VARCHAR(100) NOT NULL
);

CREATE TABLE dim_Ruta (
    RutaKey      INT IDENTITY(1,1) PRIMARY KEY,
    GradPolaska  VARCHAR(100) NOT NULL,
    GradDolaska  VARCHAR(100) NOT NULL,
    NazivRute    VARCHAR(210) NOT NULL
);

CREATE TABLE dim_Prevoznik (
    PrevoznikKey   INT IDENTITY(1,1) PRIMARY KEY,
    NazivPrevoznika VARCHAR(100) NOT NULL
);

CREATE TABLE dim_Datum (
    DatumKey     INT PRIMARY KEY,        -- npr. 20250124
    Datum        DATE NOT NULL,
    Godina       INT NOT NULL,
    Kvartal      INT NOT NULL,
    Mesec        INT NOT NULL,
    NazivMeseca  VARCHAR(20) NOT NULL,
    Dan          INT NOT NULL,
    NazivDana    VARCHAR(20) NOT NULL
);

CREATE TABLE fact_Posiljke (
    PosiljkaKey      INT IDENTITY(1,1) PRIMARY KEY,
    BrojPosiljke     VARCHAR(50) NOT NULL,
    KupacKey         INT NOT NULL REFERENCES dim_Kupac(KupacKey),
    RutaKey          INT NOT NULL REFERENCES dim_Ruta(RutaKey),
    PrevoznikKey     INT NOT NULL REFERENCES dim_Prevoznik(PrevoznikKey),
    DatumPolaskaKey  INT NOT NULL REFERENCES dim_Datum(DatumKey),
    PlaniranaDostava DATE NULL,
    StvarnaDostava   DATE NULL,
    TezinaKg         DECIMAL(10,2) NULL,
    RastojanjeKm     DECIMAL(10,2) NULL,
    Prihod           DECIMAL(10,2) NULL,   -- NULL ako je u izvoru bilo "N/A"
    Trosak           DECIMAL(10,2) NULL,
    KasnjenjeDana    INT NULL
);
GO

-- provera: treba da vidiš 6 tabela
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES ORDER BY TABLE_NAME;