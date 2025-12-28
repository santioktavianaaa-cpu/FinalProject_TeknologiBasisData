-- ============================================
-- DATABASE OLTP - SISTEM KASIR GUDANG
-- Nama: OLTP_Transaksi
-- Terpisah dari Data Warehouse
-- Struktur: 5 Tabel
-- ============================================

-- Hapus database jika sudah ada
USE master;
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'OLTP_Transaksi')
BEGIN
    ALTER DATABASE OLTP_Transaksi SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE OLTP_Transaksi;
END
GO

-- Buat Database OLTP
CREATE DATABASE OLTP_Transaksi;
GO
USE OLTP_Transaksi;
GO

-- ============================================
-- TABEL 1: MASTER PEGAWAI
-- Menyimpan data pegawai yang mengakses sistem
-- ============================================

CREATE TABLE MasterPegawai (
    KodePegawai VARCHAR(20) PRIMARY KEY,
    NamaPegawai VARCHAR(100) NOT NULL,
    JenisKelamin VARCHAR(10),
    Jabatan VARCHAR(50) NOT NULL,
    Departemen VARCHAR(50),
    NoTelp VARCHAR(20),
    Email VARCHAR(100),
    Alamat VARCHAR(200),
    TanggalMasuk DATE NOT NULL,
    Status VARCHAR(20) DEFAULT 'Aktif'
);
GO

-- ============================================
-- TABEL 2: MASTER SUPPLIER
-- Menyimpan data supplier/pemasok produk
-- ============================================

CREATE TABLE MasterSupplier (
    KodeSupplier VARCHAR(20) PRIMARY KEY,
    NamaSupplier VARCHAR(100) NOT NULL,
    NamaKontak VARCHAR(100),
    NoTelp VARCHAR(20),
    Email VARCHAR(100),
    Alamat VARCHAR(200),
    Kota VARCHAR(50),
    Provinsi VARCHAR(50),
    Status VARCHAR(20) DEFAULT 'Aktif'
);
GO

-- ============================================
-- TABEL 3: MASTER PRODUK
-- Menyimpan data master produk yang dijual
-- ============================================

CREATE TABLE MasterProduk (
    KodeProduk VARCHAR(20) PRIMARY KEY,
    NamaProduk VARCHAR(100) NOT NULL,
    Merk VARCHAR(50),
    NamaSubKategori VARCHAR(50) NOT NULL,
    NamaKategori VARCHAR(50) NOT NULL,
    HargaPokok DECIMAL(18,2) NOT NULL,
    HargaJual DECIMAL(18,2) NOT NULL,
    KodeSupplier VARCHAR(20) NOT NULL,
    CONSTRAINT FK_Produk_Supplier 
        FOREIGN KEY (KodeSupplier) REFERENCES MasterSupplier(KodeSupplier)
);
GO

-- ============================================
-- TABEL 4: TRANSAKSI HEADER
-- Menyimpan informasi utama transaksi
-- ============================================

CREATE TABLE TransaksiHeader (
    NoTransaksi VARCHAR(30) PRIMARY KEY,
    TanggalTransaksi DATE NOT NULL,
    KodePegawai VARCHAR(20) NOT NULL,
    KodePelanggan VARCHAR(20) NOT NULL,
    NamaPelanggan VARCHAR(100) NOT NULL,
    JenisKelamin VARCHAR(10),
    AlamatPelanggan VARCHAR(200),
    NoTelpPelanggan VARCHAR(20),
    EmailPelanggan VARCHAR(100),
    TipePelanggan VARCHAR(20),
    KodeGudang VARCHAR(20) NOT NULL,
    NamaGudang VARCHAR(100) NOT NULL,
    AlamatGudang VARCHAR(200),
    NamaKota VARCHAR(50) NOT NULL,
    NamaProvinsi VARCHAR(50) NOT NULL,
    CONSTRAINT FK_Header_Pegawai 
        FOREIGN KEY (KodePegawai) REFERENCES MasterPegawai(KodePegawai)
);
GO

-- ============================================
-- TABEL 5: TRANSAKSI DETAIL
-- Menyimpan detail item per transaksi
-- ============================================

CREATE TABLE TransaksiDetail (
    DetailID INT IDENTITY(1,1) PRIMARY KEY,
    NoTransaksi VARCHAR(30) NOT NULL,
    KodeProduk VARCHAR(20) NOT NULL,
    Quantity INT NOT NULL,
    HargaJual DECIMAL(18,2) NOT NULL,
    Diskon DECIMAL(18,2) DEFAULT 0,
    CONSTRAINT FK_Detail_Header 
        FOREIGN KEY (NoTransaksi) REFERENCES TransaksiHeader(NoTransaksi),
    CONSTRAINT FK_Detail_Produk 
        FOREIGN KEY (KodeProduk) REFERENCES MasterProduk(KodeProduk)
);
GO

-- Index untuk performa
CREATE INDEX IX_Header_Pegawai ON TransaksiHeader(KodePegawai);
CREATE INDEX IX_Produk_Supplier ON MasterProduk(KodeSupplier);
CREATE INDEX IX_Detail_NoTransaksi ON TransaksiDetail(NoTransaksi);
CREATE INDEX IX_Detail_KodeProduk ON TransaksiDetail(KodeProduk);
GO

-- ============================================
-- ISI DATA MASTER PEGAWAI (8 Pegawai)
-- ============================================

INSERT INTO MasterPegawai (KodePegawai, NamaPegawai, JenisKelamin, Jabatan, Departemen, NoTelp, Email, Alamat, TanggalMasuk, Status)
VALUES
('PGW-001', 'Andi Pratama', 'Pria', 'Kasir', 'Operasional', '0812-1111-0001', 'andi.pratama@warehouse.com', 'Jl. Merdeka No. 10, Surabaya', '2022-01-15', 'Aktif'),
('PGW-002', 'Sari Dewi', 'Wanita', 'Kasir', 'Operasional', '0812-1111-0002', 'sari.dewi@warehouse.com', 'Jl. Pahlawan No. 25, Surabaya', '2022-03-01', 'Aktif'),
('PGW-003', 'Budi Setiawan', 'Pria', 'Kasir', 'Operasional', '0812-1111-0003', 'budi.setiawan@warehouse.com', 'Jl. Diponegoro No. 5, Malang', '2022-06-10', 'Aktif'),
('PGW-004', 'Rina Wulandari', 'Wanita', 'Supervisor', 'Operasional', '0812-1111-0004', 'rina.wulandari@warehouse.com', 'Jl. Sudirman No. 100, Jakarta', '2021-02-01', 'Aktif'),
('PGW-005', 'Doni Kurniawan', 'Pria', 'Kasir', 'Operasional', '0812-1111-0005', 'doni.kurniawan@warehouse.com', 'Jl. Asia Afrika No. 50, Bandung', '2023-01-05', 'Aktif'),
('PGW-006', 'Maya Sari', 'Wanita', 'Admin', 'Administrasi', '0812-1111-0006', 'maya.sari@warehouse.com', 'Jl. Pemuda No. 30, Semarang', '2021-08-15', 'Aktif'),
('PGW-007', 'Hendra Wijaya', 'Pria', 'Manager', 'Manajemen', '0812-1111-0007', 'hendra.wijaya@warehouse.com', 'Jl. Gatot Subroto No. 88, Jakarta', '2020-05-01', 'Aktif'),
('PGW-008', 'Linda Permata', 'Wanita', 'Kasir', 'Operasional', '0812-1111-0008', 'linda.permata@warehouse.com', 'Jl. Braga No. 15, Bandung', '2023-06-20', 'Aktif');
GO

-- ============================================
-- ISI DATA MASTER SUPPLIER (10 Supplier)
-- ============================================

INSERT INTO MasterSupplier (KodeSupplier, NamaSupplier, NamaKontak, NoTelp, Email, Alamat, Kota, Provinsi, Status)
VALUES
('SUP-001', 'PT Samsung Electronics Indonesia', 'Kevin Lee', '021-5551001', 'samsung.id@supplier.com', 'Jl. Jend. Sudirman Kav. 52-53', 'Jakarta Selatan', 'DKI Jakarta', 'Aktif'),
('SUP-002', 'PT Apple Indonesia', 'Michael Chen', '021-5551002', 'apple.id@supplier.com', 'Jl. MH Thamrin No. 28-30', 'Jakarta Pusat', 'DKI Jakarta', 'Aktif'),
('SUP-003', 'PT Indofood Sukses Makmur Tbk', 'Bambang Susilo', '021-5551003', 'indofood@supplier.com', 'Jl. Ancol Barat VIII No. 155', 'Jakarta Utara', 'DKI Jakarta', 'Aktif'),
('SUP-004', 'PT Asus Indonesia', 'Tony Huang', '021-5551004', 'asus.id@supplier.com', 'Jl. Puri Kencana No. 1', 'Jakarta Barat', 'DKI Jakarta', 'Aktif'),
('SUP-005', 'PT Sinar Sosro', 'Widya Hartono', '021-5551005', 'sosro@supplier.com', 'Jl. Raya Sultan Agung Km. 28', 'Bekasi', 'Jawa Barat', 'Aktif'),
('SUP-006', 'PT Fast Retailing Indonesia (Uniqlo)', 'Yuki Tanaka', '021-5551006', 'uniqlo.id@supplier.com', 'Jl. Jend. Sudirman No. 1', 'Jakarta Selatan', 'DKI Jakarta', 'Aktif'),
('SUP-007', 'PT Levi Strauss Indonesia', 'David Smith', '021-5551007', 'levis.id@supplier.com', 'Jl. TB Simatupang No. 41', 'Jakarta Selatan', 'DKI Jakarta', 'Aktif'),
('SUP-008', 'PT Maxim Houseware Indonesia', 'Suryanto', '021-5551008', 'maxim@supplier.com', 'Jl. Raya Bogor Km. 29', 'Depok', 'Jawa Barat', 'Aktif'),
('SUP-009', 'PT Pilot Pen Indonesia', 'Hiroshi Yamamoto', '021-5551009', 'pilot.id@supplier.com', 'Jl. Industri Raya Blok A No. 12', 'Tangerang', 'Banten', 'Aktif'),
('SUP-010', 'PT Lion Star Indonesia', 'Herman Wijaya', '021-5551010', 'lionstar@supplier.com', 'Jl. Raya Narogong Km. 12', 'Bekasi', 'Jawa Barat', 'Aktif');
GO

-- ============================================
-- ISI DATA MASTER PRODUK (14 Produk)
-- ============================================

INSERT INTO MasterProduk (KodeProduk, NamaProduk, Merk, NamaSubKategori, NamaKategori, HargaPokok, HargaJual, KodeSupplier)
VALUES
('PRD-001', 'Samsung Galaxy A54', 'Samsung', 'Smartphone', 'Elektronik', 4000000, 5000000, 'SUP-001'),
('PRD-002', 'iPhone 15 Pro', 'Apple', 'Smartphone', 'Elektronik', 15000000, 18000000, 'SUP-002'),
('PRD-003', 'Indomie Goreng', 'Indomie', 'Makanan Instan', 'Makanan & Minuman', 2500, 3500, 'SUP-003'),
('PRD-004', 'Chitato Lite 68g', 'Chitato', 'Snack', 'Makanan & Minuman', 8000, 12000, 'SUP-003'),
('PRD-005', 'ASUS ROG Strix', 'ASUS', 'Laptop', 'Elektronik', 18000000, 22000000, 'SUP-004'),
('PRD-006', 'Teh Botol Sosro 450ml', 'Sosro', 'Minuman', 'Makanan & Minuman', 4000, 6000, 'SUP-005'),
('PRD-007', 'Kaos Polos Pria', 'Uniqlo', 'Baju Pria', 'Pakaian', 80000, 120000, 'SUP-006'),
('PRD-008', 'Celana Jeans Slim', 'Levis', 'Celana', 'Pakaian', 300000, 450000, 'SUP-007'),
('PRD-009', 'Panci Set Stainless', 'Maxim', 'Peralatan Dapur', 'Peralatan Rumah Tangga', 250000, 350000, 'SUP-008'),
('PRD-010', 'Pulpen Pilot G2', 'Pilot', 'Alat Tulis', 'Alat Tulis Kantor', 12000, 15000, 'SUP-009'),
('PRD-011', 'Aqua 600ml', 'Aqua', 'Minuman', 'Makanan & Minuman', 3000, 5000, 'SUP-005'),
('PRD-012', 'MacBook Air M3', 'Apple', 'Laptop', 'Elektronik', 18000000, 22000000, 'SUP-002'),
('PRD-013', 'Blouse Wanita', 'Zara', 'Baju Wanita', 'Pakaian', 200000, 300000, 'SUP-006'),
('PRD-014', 'Sapu Pengki Set', 'Lion Star', 'Peralatan Kebersihan', 'Peralatan Rumah Tangga', 35000, 50000, 'SUP-010');
GO

-- ============================================
-- ISI DATA TRANSAKSI HEADER (25 Transaksi)
-- ============================================

INSERT INTO TransaksiHeader (
    NoTransaksi, TanggalTransaksi, KodePegawai,
    KodePelanggan, NamaPelanggan, JenisKelamin, AlamatPelanggan, NoTelpPelanggan, EmailPelanggan, TipePelanggan,
    KodeGudang, NamaGudang, AlamatGudang, NamaKota, NamaProvinsi
) VALUES
('TRX-2024-001', '2024-11-01', 'PGW-001', 'PLG-001', 'PT Maju Jaya', NULL, 'Jl. Tunjungan No. 10', '031-5551234', 'majujaya@email.com', 'Grosir', 'GDG-SBY', 'Gudang Surabaya', 'Jl. Rungkut Industri No. 10', 'Surabaya', 'Jawa Timur'),
('TRX-2024-002', '2024-11-02', 'PGW-002', 'PLG-002', 'Budi Santoso', 'Pria', 'Jl. Darmo No. 25', '0812-1111-2222', 'budi@email.com', 'Member', 'GDG-SBY', 'Gudang Surabaya', 'Jl. Rungkut Industri No. 10', 'Surabaya', 'Jawa Timur'),
('TRX-2024-003', '2024-11-03', 'PGW-003', 'PLG-003', 'Warung Bu Tini', NULL, 'Jl. Pasar Besar No. 5', '0341-123456', 'warungtini@email.com', 'Retail', 'GDG-MLG', 'Gudang Malang', 'Jl. Soekarno Hatta No. 100', 'Malang', 'Jawa Timur'),
('TRX-2024-004', '2024-11-04', 'PGW-001', 'PLG-004', 'Siti Rahayu', 'Wanita', 'Jl. Sudirman No. 100', '0813-3333-4444', 'siti@email.com', 'Member', 'GDG-SBY', 'Gudang Surabaya', 'Jl. Rungkut Industri No. 10', 'Surabaya', 'Jawa Timur'),
('TRX-2024-005', '2024-11-05', 'PGW-004', 'PLG-005', 'PT Teknologi Maju', NULL, 'Jl. Sudirman Kav. 10', '021-7891234', 'teknomaju@email.com', 'Grosir', 'GDG-JKT', 'Gudang Jakarta', 'Jl. Mangga Dua No. 88', 'Jakarta Pusat', 'DKI Jakarta'),
('TRX-2024-006', '2024-11-06', 'PGW-002', 'PLG-002', 'Budi Santoso', 'Pria', 'Jl. Darmo No. 25', '0812-1111-2222', 'budi@email.com', 'Member', 'GDG-SBY', 'Gudang Surabaya', 'Jl. Rungkut Industri No. 10', 'Surabaya', 'Jawa Timur'),
('TRX-2024-007', '2024-11-07', 'PGW-005', 'PLG-006', 'Fashion Store ID', NULL, 'Jl. Dago No. 50', '022-4567890', 'fashionstore@email.com', 'Grosir', 'GDG-BDG', 'Gudang Bandung', 'Jl. Soekarno Hatta No. 500', 'Bandung', 'Jawa Barat'),
('TRX-2024-008', '2024-11-08', 'PGW-005', 'PLG-007', 'Rudi Hartono', 'Pria', 'Jl. Pasteur No. 30', '0878-9876-5432', 'rudi@email.com', 'Retail', 'GDG-BDG', 'Gudang Bandung', 'Jl. Soekarno Hatta No. 500', 'Bandung', 'Jawa Barat'),
('TRX-2024-009', '2024-11-09', 'PGW-006', 'PLG-008', 'Dewi Lestari', 'Wanita', 'Jl. Pandanaran No. 20', '0857-7777-8888', 'dewi@email.com', 'Member', 'GDG-SMG', 'Gudang Semarang', 'Jl. Kaligawe No. 150', 'Semarang', 'Jawa Tengah'),
('TRX-2024-010', '2024-11-10', 'PGW-006', 'PLG-009', 'Toko ATK Sentosa', NULL, 'Jl. MT Haryono No. 100', '024-3456789', 'atksentosa@email.com', 'Retail', 'GDG-SMG', 'Gudang Semarang', 'Jl. Kaligawe No. 150', 'Semarang', 'Jawa Tengah'),
('TRX-2024-011', '2024-11-11', 'PGW-004', 'PLG-010', 'Ahmad Hidayat', 'Pria', 'Jl. Gatot Subroto No. 50', '0821-5555-6666', 'ahmad@email.com', 'Member', 'GDG-JKT', 'Gudang Jakarta', 'Jl. Mangga Dua No. 88', 'Jakarta Pusat', 'DKI Jakarta'),
('TRX-2024-012', '2024-11-12', 'PGW-001', 'PLG-003', 'Warung Bu Tini', NULL, 'Jl. Pasar Besar No. 5', '0341-123456', 'warungtini@email.com', 'Retail', 'GDG-SBY', 'Gudang Surabaya', 'Jl. Rungkut Industri No. 10', 'Surabaya', 'Jawa Timur'),
('TRX-2024-013', '2024-11-13', 'PGW-004', 'PLG-005', 'PT Teknologi Maju', NULL, 'Jl. Sudirman Kav. 10', '021-7891234', 'teknomaju@email.com', 'Grosir', 'GDG-JKT', 'Gudang Jakarta', 'Jl. Mangga Dua No. 88', 'Jakarta Pusat', 'DKI Jakarta'),
('TRX-2024-014', '2024-11-14', 'PGW-005', 'PLG-011', 'Rina Cantik Store', NULL, 'Jl. Braga No. 60', '022-5678901', 'rinacantik@email.com', 'Retail', 'GDG-BDG', 'Gudang Bandung', 'Jl. Soekarno Hatta No. 500', 'Bandung', 'Jawa Barat'),
('TRX-2024-015', '2024-11-15', 'PGW-003', 'PLG-008', 'Dewi Lestari', 'Wanita', 'Jl. Pandanaran No. 20', '0857-7777-8888', 'dewi@email.com', 'Member', 'GDG-MLG', 'Gudang Malang', 'Jl. Soekarno Hatta No. 100', 'Malang', 'Jawa Timur'),
('TRX-2024-016', '2024-12-01', 'PGW-001', 'PLG-001', 'PT Maju Jaya', NULL, 'Jl. Tunjungan No. 10', '031-5551234', 'majujaya@email.com', 'Grosir', 'GDG-SBY', 'Gudang Surabaya', 'Jl. Rungkut Industri No. 10', 'Surabaya', 'Jawa Timur'),
('TRX-2024-017', '2024-12-02', 'PGW-002', 'PLG-004', 'Siti Rahayu', 'Wanita', 'Jl. Sudirman No. 100', '0813-3333-4444', 'siti@email.com', 'Member', 'GDG-SBY', 'Gudang Surabaya', 'Jl. Rungkut Industri No. 10', 'Surabaya', 'Jawa Timur'),
('TRX-2024-018', '2024-12-03', 'PGW-005', 'PLG-012', 'CV Komputer Jaya', NULL, 'Jl. ABC No. 123', '022-9876543', 'kompjaya@email.com', 'Grosir', 'GDG-BDG', 'Gudang Bandung', 'Jl. Soekarno Hatta No. 500', 'Bandung', 'Jawa Barat'),
('TRX-2024-019', '2024-12-04', 'PGW-004', 'PLG-010', 'Ahmad Hidayat', 'Pria', 'Jl. Gatot Subroto No. 50', '0821-5555-6666', 'ahmad@email.com', 'Member', 'GDG-JKT', 'Gudang Jakarta', 'Jl. Mangga Dua No. 88', 'Jakarta Pusat', 'DKI Jakarta'),
('TRX-2024-020', '2024-12-05', 'PGW-003', 'PLG-003', 'Warung Bu Tini', NULL, 'Jl. Pasar Besar No. 5', '0341-123456', 'warungtini@email.com', 'Retail', 'GDG-MLG', 'Gudang Malang', 'Jl. Soekarno Hatta No. 100', 'Malang', 'Jawa Timur'),
('TRX-2024-021', '2024-12-06', 'PGW-004', 'PLG-002', 'Budi Santoso', 'Pria', 'Jl. Darmo No. 25', '0812-1111-2222', 'budi@email.com', 'Member', 'GDG-JKT', 'Gudang Jakarta', 'Jl. Mangga Dua No. 88', 'Jakarta Pusat', 'DKI Jakarta'),
('TRX-2024-022', '2024-12-07', 'PGW-001', 'PLG-007', 'Rudi Hartono', 'Pria', 'Jl. Pasteur No. 30', '0878-9876-5432', 'rudi@email.com', 'Retail', 'GDG-SBY', 'Gudang Surabaya', 'Jl. Rungkut Industri No. 10', 'Surabaya', 'Jawa Timur'),
('TRX-2024-023', '2024-12-08', 'PGW-008', 'PLG-011', 'Rina Cantik Store', NULL, 'Jl. Braga No. 60', '022-5678901', 'rinacantik@email.com', 'Retail', 'GDG-BDG', 'Gudang Bandung', 'Jl. Soekarno Hatta No. 500', 'Bandung', 'Jawa Barat'),
('TRX-2024-024', '2024-12-09', 'PGW-004', 'PLG-009', 'Toko ATK Sentosa', NULL, 'Jl. MT Haryono No. 100', '024-3456789', 'atksentosa@email.com', 'Retail', 'GDG-JKT', 'Gudang Jakarta', 'Jl. Mangga Dua No. 88', 'Jakarta Pusat', 'DKI Jakarta'),
('TRX-2024-025', '2024-12-10', 'PGW-006', 'PLG-013', 'Handphone Center', NULL, 'Jl. Simpang Lima No. 1', '024-1234567', 'hpcenter@email.com', 'Grosir', 'GDG-SMG', 'Gudang Semarang', 'Jl. Kaligawe No. 150', 'Semarang', 'Jawa Tengah');
GO

-- ============================================
-- ISI DATA TRANSAKSI DETAIL (25 Detail)
-- ============================================

INSERT INTO TransaksiDetail (NoTransaksi, KodeProduk, Quantity, HargaJual, Diskon)
VALUES
('TRX-2024-001', 'PRD-001', 10, 5000000, 200000),
('TRX-2024-002', 'PRD-002', 2, 18000000, 500000),
('TRX-2024-003', 'PRD-003', 100, 3500, 0),
('TRX-2024-004', 'PRD-004', 20, 12000, 10000),
('TRX-2024-005', 'PRD-005', 5, 22000000, 1000000),
('TRX-2024-006', 'PRD-006', 30, 6000, 5000),
('TRX-2024-007', 'PRD-007', 50, 120000, 100000),
('TRX-2024-008', 'PRD-008', 5, 450000, 50000),
('TRX-2024-009', 'PRD-009', 3, 350000, 25000),
('TRX-2024-010', 'PRD-010', 100, 15000, 50000),
('TRX-2024-011', 'PRD-001', 3, 5000000, 150000),
('TRX-2024-012', 'PRD-011', 50, 5000, 0),
('TRX-2024-013', 'PRD-012', 3, 22000000, 1500000),
('TRX-2024-014', 'PRD-013', 10, 300000, 50000),
('TRX-2024-015', 'PRD-014', 5, 50000, 10000),
('TRX-2024-016', 'PRD-002', 5, 18000000, 1000000),
('TRX-2024-017', 'PRD-003', 200, 3500, 20000),
('TRX-2024-018', 'PRD-005', 3, 22000000, 500000),
('TRX-2024-019', 'PRD-007', 10, 120000, 20000),
('TRX-2024-020', 'PRD-004', 50, 12000, 15000),
('TRX-2024-021', 'PRD-006', 40, 6000, 10000),
('TRX-2024-022', 'PRD-008', 8, 450000, 80000),
('TRX-2024-023', 'PRD-009', 4, 350000, 30000),
('TRX-2024-024', 'PRD-010', 150, 15000, 75000),
('TRX-2024-025', 'PRD-001', 15, 5000000, 300000);
GO

-- ============================================
-- VERIFIKASI DATA
-- ============================================

SELECT 'MasterPegawai' AS Tabel, COUNT(*) AS JumlahData FROM MasterPegawai
UNION ALL SELECT 'MasterSupplier', COUNT(*) FROM MasterSupplier
UNION ALL SELECT 'MasterProduk', COUNT(*) FROM MasterProduk
UNION ALL SELECT 'TransaksiHeader', COUNT(*) FROM TransaksiHeader
UNION ALL SELECT 'TransaksiDetail', COUNT(*) FROM TransaksiDetail;
GO

-- Lihat semua data
SELECT * FROM MasterPegawai;
SELECT * FROM MasterSupplier;
SELECT * FROM MasterProduk;
SELECT * FROM TransaksiHeader;
SELECT * FROM TransaksiDetail;
GO