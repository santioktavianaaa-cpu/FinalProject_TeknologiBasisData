-- ============================================
-- SCRIPT LENGKAP OPTIMIZED: CREATE DW + ETL
-- Versi dengan DimTanggal minimal (hanya tanggal transaksi)
-- ============================================

PRINT '============================================';
PRINT 'MEMULAI PROSES PEMBUATAN DATA WAREHOUSE';
PRINT 'Waktu Mulai: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '============================================';
GO

-- ============================================
-- BAGIAN 1: HAPUS DAN BUAT DATABASE DW
-- ============================================

USE master;
GO

PRINT '';
PRINT 'BAGIAN 1: Membuat Database Data Warehouse...';
PRINT '--------------------------------------------';

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'DW_Penjualan_Gudang')
BEGIN
    PRINT 'Database DW_Penjualan_Gudang sudah ada, akan dihapus...';
    ALTER DATABASE DW_Penjualan_Gudang SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DW_Penjualan_Gudang;
    PRINT 'Database lama berhasil dihapus.';
END

CREATE DATABASE DW_Penjualan_Gudang;
PRINT 'Database DW_Penjualan_Gudang berhasil dibuat!';
GO

USE DW_Penjualan_Gudang;
GO

PRINT 'Sekarang menggunakan database: DW_Penjualan_Gudang';
PRINT '';

-- ============================================
-- BAGIAN 2: BUAT SEMUA TABEL DIMENSI & FACT
-- ============================================

PRINT 'BAGIAN 2: Membuat Struktur Tabel (Snowflake Schema)...';
PRINT '--------------------------------------------';

PRINT 'Membuat tabel Dimensi Produk (Snowflake)...';

CREATE TABLE DimKategori (
    KategoriKey INT IDENTITY(1,1) PRIMARY KEY,
    NamaKategori VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE DimSubKategori (
    SubKategoriKey INT IDENTITY(1,1) PRIMARY KEY,
    NamaSubKategori VARCHAR(50) NOT NULL,
    KategoriKey INT NOT NULL,
    CONSTRAINT FK_SubKategori_Kategori 
        FOREIGN KEY (KategoriKey) REFERENCES DimKategori(KategoriKey)
);

CREATE TABLE DimProduk (
    ProdukKey INT IDENTITY(1,1) PRIMARY KEY,
    KodeProduk VARCHAR(20) NOT NULL UNIQUE,
    NamaProduk VARCHAR(100) NOT NULL,
    Merk VARCHAR(50),
    SubKategoriKey INT NOT NULL,
    HargaPokok DECIMAL(18,2) NOT NULL,
    HargaJual DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_Produk_SubKategori 
        FOREIGN KEY (SubKategoriKey) REFERENCES DimSubKategori(SubKategoriKey)
);

PRINT '  ✓ DimKategori, DimSubKategori, DimProduk berhasil dibuat';

PRINT 'Membuat tabel Dimensi Lokasi (Snowflake)...';

CREATE TABLE DimProvinsi (
    ProvinsiKey INT IDENTITY(1,1) PRIMARY KEY,
    NamaProvinsi VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE DimKota (
    KotaKey INT IDENTITY(1,1) PRIMARY KEY,
    NamaKota VARCHAR(50) NOT NULL,
    ProvinsiKey INT NOT NULL,
    CONSTRAINT FK_Kota_Provinsi 
        FOREIGN KEY (ProvinsiKey) REFERENCES DimProvinsi(ProvinsiKey)
);

CREATE TABLE DimLokasi (
    LokasiKey INT IDENTITY(1,1) PRIMARY KEY,
    KodeGudang VARCHAR(20) NOT NULL UNIQUE,
    NamaGudang VARCHAR(100) NOT NULL,
    AlamatGudang VARCHAR(200),
    KotaKey INT NOT NULL,
    CONSTRAINT FK_Lokasi_Kota 
        FOREIGN KEY (KotaKey) REFERENCES DimKota(KotaKey)
);

PRINT '  ✓ DimProvinsi, DimKota, DimLokasi berhasil dibuat';

PRINT 'Membuat tabel DimTanggal...';

CREATE TABLE DimTanggal (
    TanggalKey INT PRIMARY KEY,
    TanggalLengkap DATE NOT NULL UNIQUE,
    Hari INT NOT NULL,
    Bulan INT NOT NULL,
    Tahun INT NOT NULL,
    NamaBulan VARCHAR(20) NOT NULL,
    Kuartal INT NOT NULL,
    NamaHari VARCHAR(20) NOT NULL
);

PRINT '  ✓ DimTanggal berhasil dibuat';

PRINT 'Membuat tabel DimPelanggan...';

CREATE TABLE DimPelanggan (
    PelangganKey INT IDENTITY(1,1) PRIMARY KEY,
    KodePelanggan VARCHAR(20) NOT NULL UNIQUE,
    NamaPelanggan VARCHAR(100) NOT NULL,
    JenisKelamin VARCHAR(10),
    TipePelanggan VARCHAR(20) NOT NULL,
    AlamatPelanggan VARCHAR(200),
    NoTelpPelanggan VARCHAR(20),
    EmailPelanggan VARCHAR(100)
);

PRINT '  ✓ DimPelanggan berhasil dibuat';

PRINT 'Membuat tabel DimPegawai...';

CREATE TABLE DimPegawai (
    PegawaiKey INT IDENTITY(1,1) PRIMARY KEY,
    KodePegawai VARCHAR(20) NOT NULL UNIQUE,
    NamaPegawai VARCHAR(100) NOT NULL,
    JenisKelamin VARCHAR(10),
    Jabatan VARCHAR(50) NOT NULL,
    Departemen VARCHAR(50)
);

PRINT '  ✓ DimPegawai berhasil dibuat';

PRINT 'Membuat tabel DimSupplier...';

CREATE TABLE DimSupplier (
    SupplierKey INT IDENTITY(1,1) PRIMARY KEY,
    KodeSupplier VARCHAR(20) NOT NULL UNIQUE,
    NamaSupplier VARCHAR(100) NOT NULL,
    Kota VARCHAR(50),
    Provinsi VARCHAR(50)
);

PRINT '  ✓ DimSupplier berhasil dibuat';

PRINT 'Membuat tabel FactPenjualan...';

CREATE TABLE FactPenjualan (
    PenjualanKey INT IDENTITY(1,1) PRIMARY KEY,
    TanggalKey INT NOT NULL,
    ProdukKey INT NOT NULL,
    LokasiKey INT NOT NULL,
    PelangganKey INT NOT NULL,
    PegawaiKey INT NOT NULL,
    SupplierKey INT NOT NULL,
    Quantity INT NOT NULL,
    HargaSatuan DECIMAL(18,2) NOT NULL,
    Diskon DECIMAL(18,2) DEFAULT 0,
    JumlahBruto DECIMAL(18,2) NOT NULL,
    JumlahNetto DECIMAL(18,2) NOT NULL,
    LabaKotor DECIMAL(18,2) NOT NULL,
    NoTransaksi VARCHAR(30) NOT NULL,
    CONSTRAINT FK_Fact_Tanggal FOREIGN KEY (TanggalKey) REFERENCES DimTanggal(TanggalKey),
    CONSTRAINT FK_Fact_Produk FOREIGN KEY (ProdukKey) REFERENCES DimProduk(ProdukKey),
    CONSTRAINT FK_Fact_Lokasi FOREIGN KEY (LokasiKey) REFERENCES DimLokasi(LokasiKey),
    CONSTRAINT FK_Fact_Pelanggan FOREIGN KEY (PelangganKey) REFERENCES DimPelanggan(PelangganKey),
    CONSTRAINT FK_Fact_Pegawai FOREIGN KEY (PegawaiKey) REFERENCES DimPegawai(PegawaiKey),
    CONSTRAINT FK_Fact_Supplier FOREIGN KEY (SupplierKey) REFERENCES DimSupplier(SupplierKey)
);

PRINT '  ✓ FactPenjualan berhasil dibuat';

PRINT 'Membuat tabel kontrol ETL...';

CREATE TABLE ETL_Control (
    ControlID INT IDENTITY(1,1) PRIMARY KEY,
    TabelTarget VARCHAR(50) NOT NULL,
    TanggalETL DATETIME NOT NULL DEFAULT GETDATE(),
    JumlahRecordDiproses INT NOT NULL,
    Status VARCHAR(20) NOT NULL,
    Keterangan VARCHAR(500)
);

CREATE TABLE ETL_TransaksiLoaded (
    NoTransaksi VARCHAR(30) PRIMARY KEY,
    TanggalLoad DATETIME NOT NULL DEFAULT GETDATE()
);

PRINT '  ✓ Tabel kontrol ETL berhasil dibuat';
PRINT '';

PRINT 'Membuat index untuk performa...';

CREATE INDEX IX_Fact_TanggalKey ON FactPenjualan(TanggalKey);
CREATE INDEX IX_Fact_ProdukKey ON FactPenjualan(ProdukKey);
CREATE INDEX IX_Fact_LokasiKey ON FactPenjualan(LokasiKey);
CREATE INDEX IX_Fact_PelangganKey ON FactPenjualan(PelangganKey);
CREATE INDEX IX_Fact_PegawaiKey ON FactPenjualan(PegawaiKey);
CREATE INDEX IX_Fact_NoTransaksi ON FactPenjualan(NoTransaksi);
CREATE INDEX IX_SubKategori_KategoriKey ON DimSubKategori(KategoriKey);
CREATE INDEX IX_Produk_SubKategoriKey ON DimProduk(SubKategoriKey);
CREATE INDEX IX_Kota_ProvinsiKey ON DimKota(ProvinsiKey);
CREATE INDEX IX_Lokasi_KotaKey ON DimLokasi(KotaKey);

PRINT '  ✓ Index berhasil dibuat';
PRINT '';
PRINT 'BAGIAN 2: SELESAI - Semua tabel berhasil dibuat!';
PRINT '';
GO

-- ============================================
-- BAGIAN 3: PROSES ETL
-- ============================================

PRINT '============================================';
PRINT 'BAGIAN 3: MEMULAI PROSES ETL';
PRINT '============================================';
PRINT '';
GO

-- STEP 1: LOAD DIMENSI PRODUK --
BEGIN TRANSACTION;
BEGIN TRY
    PRINT 'STEP 1: Loading Dimensi Produk (Snowflake)...';
    
    INSERT INTO DimKategori (NamaKategori)
    SELECT DISTINCT NamaKategori
    FROM OLTP_Transaksi.dbo.MasterProduk
    WHERE NamaKategori NOT IN (SELECT NamaKategori FROM DimKategori);
    PRINT '  ✓ DimKategori: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' record';
    
    INSERT INTO DimSubKategori (NamaSubKategori, KategoriKey)
    SELECT DISTINCT p.NamaSubKategori, k.KategoriKey
    FROM OLTP_Transaksi.dbo.MasterProduk p
    INNER JOIN DimKategori k ON p.NamaKategori = k.NamaKategori
    WHERE NOT EXISTS (
        SELECT 1 FROM DimSubKategori sk 
        WHERE sk.NamaSubKategori = p.NamaSubKategori 
        AND sk.KategoriKey = k.KategoriKey
    );
    PRINT '  ✓ DimSubKategori: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' record';
    
    INSERT INTO DimProduk (KodeProduk, NamaProduk, Merk, SubKategoriKey, HargaPokok, HargaJual)
    SELECT p.KodeProduk, p.NamaProduk, p.Merk, sk.SubKategoriKey, p.HargaPokok, p.HargaJual
    FROM OLTP_Transaksi.dbo.MasterProduk p
    INNER JOIN DimKategori k ON p.NamaKategori = k.NamaKategori
    INNER JOIN DimSubKategori sk ON p.NamaSubKategori = sk.NamaSubKategori 
        AND sk.KategoriKey = k.KategoriKey
    WHERE p.KodeProduk NOT IN (SELECT KodeProduk FROM DimProduk);
    PRINT '  ✓ DimProduk: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' record';
    
    COMMIT TRANSACTION;
    PRINT 'STEP 1: BERHASIL';
    PRINT '';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'ERROR STEP 1: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO

-- STEP 2: LOAD DIMENSI LOKASI --
BEGIN TRANSACTION;
BEGIN TRY
    PRINT 'STEP 2: Loading Dimensi Lokasi (Snowflake)...';
    
    INSERT INTO DimProvinsi (NamaProvinsi)
    SELECT DISTINCT NamaProvinsi
    FROM OLTP_Transaksi.dbo.TransaksiHeader
    WHERE NamaProvinsi NOT IN (SELECT NamaProvinsi FROM DimProvinsi);
    PRINT '  ✓ DimProvinsi: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' record';
    
    INSERT INTO DimKota (NamaKota, ProvinsiKey)
    SELECT DISTINCT t.NamaKota, p.ProvinsiKey
    FROM OLTP_Transaksi.dbo.TransaksiHeader t
    INNER JOIN DimProvinsi p ON t.NamaProvinsi = p.NamaProvinsi
    WHERE NOT EXISTS (
        SELECT 1 FROM DimKota k 
        WHERE k.NamaKota = t.NamaKota 
        AND k.ProvinsiKey = p.ProvinsiKey
    );
    PRINT '  ✓ DimKota: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' record';
    
    INSERT INTO DimLokasi (KodeGudang, NamaGudang, AlamatGudang, KotaKey)
    SELECT DISTINCT t.KodeGudang, t.NamaGudang, t.AlamatGudang, k.KotaKey
    FROM OLTP_Transaksi.dbo.TransaksiHeader t
    INNER JOIN DimProvinsi p ON t.NamaProvinsi = p.NamaProvinsi
    INNER JOIN DimKota k ON t.NamaKota = k.NamaKota AND k.ProvinsiKey = p.ProvinsiKey
    WHERE t.KodeGudang NOT IN (SELECT KodeGudang FROM DimLokasi);
    PRINT '  ✓ DimLokasi: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' record';
    
    COMMIT TRANSACTION;
    PRINT 'STEP 2: BERHASIL';
    PRINT '';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'ERROR STEP 2: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO

-- STEP 3: LOAD DIMENSI TANGGAL (HANYA TANGGAL TRANSAKSI) --
BEGIN TRANSACTION;
BEGIN TRY
    PRINT 'STEP 3: Loading Dimensi Tanggal (Hanya tanggal transaksi)...';
    
    -- Hanya insert tanggal yang ada di transaksi
    INSERT INTO DimTanggal (TanggalKey, TanggalLengkap, Hari, Bulan, Tahun, NamaBulan, Kuartal, NamaHari)
    SELECT DISTINCT
        CONVERT(INT, FORMAT(TanggalTransaksi, 'yyyyMMdd')) AS TanggalKey,
        TanggalTransaksi AS TanggalLengkap,
        DAY(TanggalTransaksi) AS Hari,
        MONTH(TanggalTransaksi) AS Bulan,
        YEAR(TanggalTransaksi) AS Tahun,
        DATENAME(MONTH, TanggalTransaksi) AS NamaBulan,
        DATEPART(QUARTER, TanggalTransaksi) AS Kuartal,
        DATENAME(WEEKDAY, TanggalTransaksi) AS NamaHari
    FROM OLTP_Transaksi.dbo.TransaksiHeader
    WHERE CONVERT(INT, FORMAT(TanggalTransaksi, 'yyyyMMdd')) NOT IN (SELECT TanggalKey FROM DimTanggal);
    
    PRINT '  ✓ DimTanggal: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' record (tanggal unique dari transaksi)';
    COMMIT TRANSACTION;
    PRINT 'STEP 3: BERHASIL';
    PRINT '';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'ERROR STEP 3: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO

-- STEP 4: LOAD DIMENSI PELANGGAN --
BEGIN TRANSACTION;
BEGIN TRY
    PRINT 'STEP 4: Loading Dimensi Pelanggan...';
    
    INSERT INTO DimPelanggan (
        KodePelanggan, NamaPelanggan, JenisKelamin, 
        TipePelanggan, AlamatPelanggan, NoTelpPelanggan, EmailPelanggan
    )
    SELECT DISTINCT
        KodePelanggan, NamaPelanggan, JenisKelamin,
        TipePelanggan, AlamatPelanggan, NoTelpPelanggan, EmailPelanggan
    FROM OLTP_Transaksi.dbo.TransaksiHeader
    WHERE KodePelanggan NOT IN (SELECT KodePelanggan FROM DimPelanggan);
    
    PRINT '  ✓ DimPelanggan: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' record';
    COMMIT TRANSACTION;
    PRINT 'STEP 4: BERHASIL';
    PRINT '';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'ERROR STEP 4: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO

-- STEP 5: LOAD DIMENSI PEGAWAI --
BEGIN TRANSACTION;
BEGIN TRY
    PRINT 'STEP 5: Loading Dimensi Pegawai...';
    
    INSERT INTO DimPegawai (KodePegawai, NamaPegawai, JenisKelamin, Jabatan, Departemen)
    SELECT KodePegawai, NamaPegawai, JenisKelamin, Jabatan, Departemen
    FROM OLTP_Transaksi.dbo.MasterPegawai
    WHERE KodePegawai NOT IN (SELECT KodePegawai FROM DimPegawai);
    
    PRINT '  ✓ DimPegawai: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' record';
    COMMIT TRANSACTION;
    PRINT 'STEP 5: BERHASIL';
    PRINT '';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'ERROR STEP 5: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO

-- STEP 6: LOAD DIMENSI SUPPLIER --
BEGIN TRANSACTION;
BEGIN TRY
    PRINT 'STEP 6: Loading Dimensi Supplier...';
    
    INSERT INTO DimSupplier (KodeSupplier, NamaSupplier, Kota, Provinsi)
    SELECT KodeSupplier, NamaSupplier, Kota, Provinsi
    FROM OLTP_Transaksi.dbo.MasterSupplier
    WHERE KodeSupplier NOT IN (SELECT KodeSupplier FROM DimSupplier);
    
    PRINT '  ✓ DimSupplier: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' record';
    COMMIT TRANSACTION;
    PRINT 'STEP 6: BERHASIL';
    PRINT '';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'ERROR STEP 6: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO

-- STEP 7: LOAD FACT PENJUALAN (DENGAN ANTI-DUPLIKASI) --
BEGIN TRANSACTION;
BEGIN TRY
    PRINT 'STEP 7: Loading FactPenjualan (ANTI-DUPLIKASI)...';
    
    INSERT INTO FactPenjualan (
        TanggalKey, ProdukKey, LokasiKey, PelangganKey, PegawaiKey, SupplierKey,
        Quantity, HargaSatuan, Diskon, JumlahBruto, JumlahNetto, LabaKotor, NoTransaksi
    )
    SELECT 
        CONVERT(INT, FORMAT(h.TanggalTransaksi, 'yyyyMMdd')) AS TanggalKey,
        dp.ProdukKey, dl.LokasiKey, dpl.PelangganKey, dpg.PegawaiKey, ds.SupplierKey,
        d.Quantity, d.HargaJual, d.Diskon,
        (d.Quantity * d.HargaJual) AS JumlahBruto,
        ((d.Quantity * d.HargaJual) - d.Diskon) AS JumlahNetto,
        (((d.Quantity * d.HargaJual) - d.Diskon) - (d.Quantity * mp.HargaPokok)) AS LabaKotor,
        h.NoTransaksi
    FROM OLTP_Transaksi.dbo.TransaksiDetail d
    INNER JOIN OLTP_Transaksi.dbo.TransaksiHeader h ON d.NoTransaksi = h.NoTransaksi
    INNER JOIN OLTP_Transaksi.dbo.MasterProduk mp ON d.KodeProduk = mp.KodeProduk
    INNER JOIN DimProduk dp ON d.KodeProduk = dp.KodeProduk
    INNER JOIN DimLokasi dl ON h.KodeGudang = dl.KodeGudang
    INNER JOIN DimPelanggan dpl ON h.KodePelanggan = dpl.KodePelanggan
    INNER JOIN DimPegawai dpg ON h.KodePegawai = dpg.KodePegawai
    INNER JOIN DimSupplier ds ON mp.KodeSupplier = ds.KodeSupplier
    WHERE h.NoTransaksi NOT IN (SELECT NoTransaksi FROM ETL_TransaksiLoaded);
    
    DECLARE @RowsAffected INT = @@ROWCOUNT;
    PRINT '  ✓ FactPenjualan: ' + CAST(@RowsAffected AS VARCHAR) + ' record';
    
    INSERT INTO ETL_TransaksiLoaded (NoTransaksi)
    SELECT DISTINCT NoTransaksi
    FROM OLTP_Transaksi.dbo.TransaksiHeader
    WHERE NoTransaksi NOT IN (SELECT NoTransaksi FROM ETL_TransaksiLoaded);
    PRINT '  ✓ Transaksi dicatat: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' transaksi';
    
    INSERT INTO ETL_Control (TabelTarget, JumlahRecordDiproses, Status, Keterangan)
    VALUES ('FactPenjualan', @RowsAffected, 'Success', 'ETL pertama berhasil dengan anti-duplikasi');
    
    COMMIT TRANSACTION;
    PRINT 'STEP 7: BERHASIL';
    PRINT '';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    INSERT INTO ETL_Control (TabelTarget, JumlahRecordDiproses, Status, Keterangan)
    VALUES ('FactPenjualan', 0, 'Failed', ERROR_MESSAGE());
    PRINT 'ERROR STEP 7: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO

-- ============================================
-- BAGIAN 4: SUMMARY & VERIFIKASI
-- ============================================

PRINT '============================================';
PRINT 'PROSES ETL SELESAI!';
PRINT 'Waktu Selesai: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '============================================';
PRINT '';
PRINT 'SUMMARY DATA WAREHOUSE:';
PRINT '--------------------------------------------';
GO

SELECT 
    'DimKategori' AS Tabel, COUNT(*) AS JumlahRecord FROM DimKategori
UNION ALL SELECT 'DimSubKategori', COUNT(*) FROM DimSubKategori
UNION ALL SELECT 'DimProduk', COUNT(*) FROM DimProduk
UNION ALL SELECT 'DimProvinsi', COUNT(*) FROM DimProvinsi
UNION ALL SELECT 'DimKota', COUNT(*) FROM DimKota
UNION ALL SELECT 'DimLokasi', COUNT(*) FROM DimLokasi
UNION ALL SELECT 'DimTanggal', COUNT(*) FROM DimTanggal
UNION ALL SELECT 'DimPelanggan', COUNT(*) FROM DimPelanggan
UNION ALL SELECT 'DimPegawai', COUNT(*) FROM DimPegawai
UNION ALL SELECT 'DimSupplier', COUNT(*) FROM DimSupplier
UNION ALL SELECT 'FactPenjualan', COUNT(*) FROM FactPenjualan;
GO

PRINT '';
PRINT 'Detail DimTanggal:';
PRINT '--------------------------------------------';
SELECT TanggalKey, TanggalLengkap, NamaHari, NamaBulan, Tahun
FROM DimTanggal
ORDER BY TanggalKey;
GO

PRINT '';
PRINT 'Log ETL:';
PRINT '--------------------------------------------';
SELECT * FROM ETL_Control ORDER BY TanggalETL DESC;
GO

PRINT '';
PRINT '============================================';
PRINT '✓✓✓ SEMUA PROSES BERHASIL! ✓✓✓';
PRINT '============================================';
PRINT '';
PRINT 'Data Warehouse siap digunakan!';
PRINT 'DimTanggal sekarang hanya berisi tanggal transaksi.';
PRINT 'Anda sekarang bisa menjalankan query analitik.';
PRINT '';
GO