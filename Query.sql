-- ============================================
-- QUERY ANALITIK DATA WAREHOUSE
-- SISTEM PENJUALAN GUDANG
-- Report Lengkap & Detail
-- ============================================

USE DW_Penjualan_Gudang;
GO

PRINT '============================================';
PRINT 'LAPORAN ANALITIK DATA WAREHOUSE';
PRINT 'Tanggal Generate: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '============================================';
PRINT '';
GO

-- ============================================
-- REPORT 1: RINGKASAN PENJUALAN KESELURUHAN
-- ============================================

PRINT '';
PRINT '============================================';
PRINT 'REPORT 1: RINGKASAN PENJUALAN KESELURUHAN';
PRINT '============================================';
GO

SELECT 
    COUNT(DISTINCT NoTransaksi) AS TotalTransaksi,
    COUNT(*) AS TotalItemTerjual,
    SUM(Quantity) AS TotalQuantity,
    FORMAT(SUM(JumlahBruto), 'N0') AS TotalPenjualanBruto,
    FORMAT(SUM(Diskon), 'N0') AS TotalDiskon,
    FORMAT(SUM(JumlahNetto), 'N0') AS TotalPenjualanNetto,
    FORMAT(SUM(LabaKotor), 'N0') AS TotalLabaKotor,
    FORMAT(AVG(JumlahNetto), 'N0') AS RataRataPenjualanPerItem,
    FORMAT(
        (SUM(LabaKotor) * 100.0 / NULLIF(SUM(JumlahNetto), 0)), 
        'N2'
    ) + '%' AS PersentaseMarginLaba
FROM FactPenjualan;
GO

-- ============================================
-- REPORT 2: PENJUALAN PER PERIODE (BULANAN)
-- ============================================

PRINT '';
PRINT '============================================';
PRINT 'REPORT 2: PENJUALAN PER BULAN';
PRINT '============================================';
GO

SELECT 
    t.Tahun,
    t.Bulan,
    t.NamaBulan,
    COUNT(DISTINCT f.NoTransaksi) AS JumlahTransaksi,
    SUM(f.Quantity) AS TotalQuantity,
    FORMAT(SUM(f.JumlahNetto), 'N0') AS TotalPenjualan,
    FORMAT(SUM(f.LabaKotor), 'N0') AS TotalLaba,
    FORMAT(AVG(f.JumlahNetto), 'N0') AS RataRataPenjualan,
    FORMAT(
        (SUM(f.LabaKotor) * 100.0 / NULLIF(SUM(f.JumlahNetto), 0)), 
        'N2'
    ) + '%' AS MarginLaba
FROM FactPenjualan f
INNER JOIN DimTanggal t ON f.TanggalKey = t.TanggalKey
GROUP BY t.Tahun, t.Bulan, t.NamaBulan
ORDER BY t.Tahun, t.Bulan;
GO

-- ============================================
-- REPORT 3: PENJUALAN PER HARI
-- ============================================

PRINT '';
PRINT '============================================';
PRINT 'REPORT 3: PENJUALAN PER HARI';
PRINT '============================================';
GO

SELECT 
    t.TanggalLengkap,
    t.NamaHari,
    COUNT(DISTINCT f.NoTransaksi) AS JumlahTransaksi,
    SUM(f.Quantity) AS TotalQuantity,
    FORMAT(SUM(f.JumlahNetto), 'N0') AS TotalPenjualan,
    FORMAT(SUM(f.LabaKotor), 'N0') AS TotalLaba
FROM FactPenjualan f
INNER JOIN DimTanggal t ON f.TanggalKey = t.TanggalKey
GROUP BY t.TanggalLengkap, t.NamaHari
ORDER BY t.TanggalLengkap;
GO

-- ============================================
-- REPORT 4: TOP 10 PRODUK TERLARIS
-- ============================================

PRINT '';
PRINT '============================================';
PRINT 'REPORT 4: TOP 10 PRODUK TERLARIS';
PRINT '============================================';
GO

SELECT TOP 10
    p.KodeProduk,
    p.NamaProduk,
    p.Merk,
    sk.NamaSubKategori,
    k.NamaKategori,
    COUNT(DISTINCT f.NoTransaksi) AS JumlahTransaksi,
    SUM(f.Quantity) AS TotalTerjual,
    FORMAT(SUM(f.JumlahNetto), 'N0') AS TotalPenjualan,
    FORMAT(SUM(f.LabaKotor), 'N0') AS TotalLaba,
    FORMAT(AVG(f.HargaSatuan), 'N0') AS HargaRataRata
FROM FactPenjualan f
INNER JOIN DimProduk p ON f.ProdukKey = p.ProdukKey
INNER JOIN DimSubKategori sk ON p.SubKategoriKey = sk.SubKategoriKey
INNER JOIN DimKategori k ON sk.KategoriKey = k.KategoriKey
GROUP BY p.KodeProduk, p.NamaProduk, p.Merk, sk.NamaSubKategori, k.NamaKategori
ORDER BY SUM(f.JumlahNetto) DESC;
GO

-- ============================================
-- REPORT 5: PENJUALAN PER KATEGORI PRODUK
-- ============================================

PRINT '';
PRINT '============================================';
PRINT 'REPORT 5: PENJUALAN PER KATEGORI PRODUK';
PRINT '============================================';
GO

SELECT 
    k.NamaKategori,
    COUNT(DISTINCT f.NoTransaksi) AS JumlahTransaksi,
    COUNT(DISTINCT p.ProdukKey) AS JumlahProdukTerjual,
    SUM(f.Quantity) AS TotalQuantity,
    FORMAT(SUM(f.JumlahNetto), 'N0') AS TotalPenjualan,
    FORMAT(SUM(f.LabaKotor), 'N0') AS TotalLaba,
    FORMAT(AVG(f.JumlahNetto), 'N0') AS RataRataPenjualan,
    FORMAT(
        (SUM(f.JumlahNetto) * 100.0 / 
        (SELECT SUM(JumlahNetto) FROM FactPenjualan)), 
        'N2'
    ) + '%' AS KontribusiPenjualan
FROM FactPenjualan f
INNER JOIN DimProduk p ON f.ProdukKey = p.ProdukKey
INNER JOIN DimSubKategori sk ON p.SubKategoriKey = sk.SubKategoriKey
INNER JOIN DimKategori k ON sk.KategoriKey = k.KategoriKey
GROUP BY k.NamaKategori
ORDER BY SUM(f.JumlahNetto) DESC;
GO

-- ============================================
-- REPORT 6: PENJUALAN PER SUB-KATEGORI
-- ============================================

PRINT '';
PRINT '============================================';
PRINT 'REPORT 6: PENJUALAN PER SUB-KATEGORI';
PRINT '============================================';
GO

SELECT 
    k.NamaKategori,
    sk.NamaSubKategori,
    COUNT(DISTINCT f.NoTransaksi) AS JumlahTransaksi,
    SUM(f.Quantity) AS TotalQuantity,
    FORMAT(SUM(f.JumlahNetto), 'N0') AS TotalPenjualan,
    FORMAT(SUM(f.LabaKotor), 'N0') AS TotalLaba,
    FORMAT(
        (SUM(f.LabaKotor) * 100.0 / NULLIF(SUM(f.JumlahNetto), 0)), 
        'N2'
    ) + '%' AS MarginLaba
FROM FactPenjualan f
INNER JOIN DimProduk p ON f.ProdukKey = p.ProdukKey
INNER JOIN DimSubKategori sk ON p.SubKategoriKey = sk.SubKategoriKey
INNER JOIN DimKategori k ON sk.KategoriKey = k.KategoriKey
GROUP BY k.NamaKategori, sk.NamaSubKategori
ORDER BY SUM(f.JumlahNetto) DESC;
GO

-- ============================================
-- REPORT 7: PENJUALAN PER LOKASI/GUDANG
-- ============================================

PRINT '';
PRINT '============================================';
PRINT 'REPORT 7: PENJUALAN PER GUDANG';
PRINT '============================================';
GO

SELECT 
    l.KodeGudang,
    l.NamaGudang,
    kt.NamaKota,
    pv.NamaProvinsi,
    COUNT(DISTINCT f.NoTransaksi) AS JumlahTransaksi,
    SUM(f.Quantity) AS TotalQuantity,
    FORMAT(SUM(f.JumlahNetto), 'N0') AS TotalPenjualan,
    FORMAT(SUM(f.LabaKotor), 'N0') AS TotalLaba,
    FORMAT(AVG(f.JumlahNetto), 'N0') AS RataRataPenjualan,
    FORMAT(
        (SUM(f.JumlahNetto) * 100.0 / 
        (SELECT SUM(JumlahNetto) FROM FactPenjualan)), 
        'N2'
    ) + '%' AS KontribusiPenjualan
FROM FactPenjualan f
INNER JOIN DimLokasi l ON f.LokasiKey = l.LokasiKey
INNER JOIN DimKota kt ON l.KotaKey = kt.KotaKey
INNER JOIN DimProvinsi pv ON kt.ProvinsiKey = pv.ProvinsiKey
GROUP BY l.KodeGudang, l.NamaGudang, kt.NamaKota, pv.NamaProvinsi
ORDER BY SUM(f.JumlahNetto) DESC;
GO

-- ============================================
-- REPORT 8: PENJUALAN PER KOTA
-- ============================================

PRINT '';
PRINT '============================================';
PRINT 'REPORT 8: PENJUALAN PER KOTA';
PRINT '============================================';
GO

SELECT 
    kt.NamaKota,
    pv.NamaProvinsi,
    COUNT(DISTINCT l.LokasiKey) AS JumlahGudang,
    COUNT(DISTINCT f.NoTransaksi) AS JumlahTransaksi,
    SUM(f.Quantity) AS TotalQuantity,
    FORMAT(SUM(f.JumlahNetto), 'N0') AS TotalPenjualan,
    FORMAT(SUM(f.LabaKotor), 'N0') AS TotalLaba
FROM FactPenjualan f
INNER JOIN DimLokasi l ON f.LokasiKey = l.LokasiKey
INNER JOIN DimKota kt ON l.KotaKey = kt.KotaKey
INNER JOIN DimProvinsi pv ON kt.ProvinsiKey = pv.ProvinsiKey
GROUP BY kt.NamaKota, pv.NamaProvinsi
ORDER BY SUM(f.JumlahNetto) DESC;
GO

-- ============================================
-- REPORT 9: PENJUALAN PER PROVINSI
-- ============================================

PRINT '';
PRINT '============================================';
PRINT 'REPORT 9: PENJUALAN PER PROVINSI';
PRINT '============================================';
GO

SELECT 
    pv.NamaProvinsi,
    COUNT(DISTINCT kt.KotaKey) AS JumlahKota,
    COUNT(DISTINCT l.LokasiKey) AS JumlahGudang,
    COUNT(DISTINCT f.NoTransaksi) AS JumlahTransaksi,
    SUM(f.Quantity) AS TotalQuantity,
    FORMAT(SUM(f.JumlahNetto), 'N0') AS TotalPenjualan,
    FORMAT(SUM(f.LabaKotor), 'N0') AS TotalLaba,
    FORMAT(
        (SUM(f.JumlahNetto) * 100.0 / 
        (SELECT SUM(JumlahNetto) FROM FactPenjualan)), 
        'N2'
    ) + '%' AS KontribusiPenjualan
FROM FactPenjualan f
INNER JOIN DimLokasi l ON f.LokasiKey = l.LokasiKey
INNER JOIN DimKota kt ON l.KotaKey = kt.KotaKey
INNER JOIN DimProvinsi pv ON kt.ProvinsiKey = pv.ProvinsiKey
GROUP BY pv.NamaProvinsi
ORDER BY SUM(f.JumlahNetto) DESC;
GO

-- ============================================
-- REPORT 10: PERFORMA PEGAWAI
-- ============================================

PRINT '';
PRINT '============================================';
PRINT 'REPORT 10: PERFORMA PEGAWAI (KASIR)';
PRINT '============================================';
GO

SELECT 
    pg.KodePegawai,
    pg.NamaPegawai,
    pg.Jabatan,
    pg.Departemen,
    COUNT(DISTINCT f.NoTransaksi) AS JumlahTransaksi,
    SUM(f.Quantity) AS TotalItemTerjual,
    FORMAT(SUM(f.JumlahNetto), 'N0') AS TotalPenjualan,
    FORMAT(SUM(f.LabaKotor), 'N0') AS TotalLaba,
    FORMAT(AVG(f.JumlahNetto), 'N0') AS RataRataPenjualanPerItem,
    FORMAT(
        SUM(f.JumlahNetto) * 1.0 / 
        NULLIF(COUNT(DISTINCT f.NoTransaksi), 0), 
        'N0'
    ) AS RataRataPenjualanPerTransaksi
FROM FactPenjualan f
INNER JOIN DimPegawai pg ON f.PegawaiKey = pg.PegawaiKey
GROUP BY pg.KodePegawai, pg.NamaPegawai, pg.Jabatan, pg.Departemen
ORDER BY SUM(f.JumlahNetto) DESC;
GO

-- ============================================
-- REPORT 11: ANALISIS PELANGGAN
-- ============================================

PRINT '';
PRINT '============================================';
PRINT 'REPORT 11: ANALISIS PELANGGAN';
PRINT '============================================';
GO

SELECT 
    pl.KodePelanggan,
    pl.NamaPelanggan,
    pl.TipePelanggan,
    pl.JenisKelamin,
    COUNT(DISTINCT f.NoTransaksi) AS JumlahTransaksi,
    SUM(f.Quantity) AS TotalItemDibeli,
    FORMAT(SUM(f.JumlahNetto), 'N0') AS TotalBelanja,
    FORMAT(AVG(f.JumlahNetto), 'N0') AS RataRataBelanjaPerItem,
    FORMAT(
        SUM(f.JumlahNetto) * 1.0 / 
        NULLIF(COUNT(DISTINCT f.NoTransaksi), 0), 
        'N0'
    ) AS RataRataBelanjaPerTransaksi
FROM FactPenjualan f
INNER JOIN DimPelanggan pl ON f.PelangganKey = pl.PelangganKey
GROUP BY pl.KodePelanggan, pl.NamaPelanggan, pl.TipePelanggan, pl.JenisKelamin
ORDER BY SUM(f.JumlahNetto) DESC;
GO

-- ============================================
-- REPORT 12: SEGMENTASI PELANGGAN (TIPE)
-- ============================================

PRINT '';
PRINT '============================================';
PRINT 'REPORT 12: SEGMENTASI PELANGGAN (TIPE)';
PRINT '============================================';
GO

SELECT 
    pl.TipePelanggan,
    COUNT(DISTINCT pl.PelangganKey) AS JumlahPelanggan,
    COUNT(DISTINCT f.NoTransaksi) AS JumlahTransaksi,
    SUM(f.Quantity) AS TotalQuantity,
    FORMAT(SUM(f.JumlahNetto), 'N0') AS TotalPenjualan,
    FORMAT(SUM(f.LabaKotor), 'N0') AS TotalLaba,
    FORMAT(AVG(f.JumlahNetto), 'N0') AS RataRataPenjualan,
    FORMAT(
        (SUM(f.JumlahNetto) * 100.0 / 
        (SELECT SUM(JumlahNetto) FROM FactPenjualan)), 
        'N2'
    ) + '%' AS KontribusiPenjualan
FROM FactPenjualan f
INNER JOIN DimPelanggan pl ON f.PelangganKey = pl.PelangganKey
GROUP BY pl.TipePelanggan
ORDER BY SUM(f.JumlahNetto) DESC;
GO

-- ============================================
-- REPORT 13: ANALISIS SUPPLIER
-- ============================================

PRINT '';
PRINT '============================================';
PRINT 'REPORT 13: PERFORMA SUPPLIER';
PRINT '============================================';
GO

SELECT 
    s.KodeSupplier,
    s.NamaSupplier,
    s.Kota,
    s.Provinsi,
    COUNT(DISTINCT p.ProdukKey) AS JumlahProduk,
    COUNT(DISTINCT f.NoTransaksi) AS JumlahTransaksi,
    SUM(f.Quantity) AS TotalQuantityTerjual,
    FORMAT(SUM(f.JumlahNetto), 'N0') AS TotalPenjualan,
    FORMAT(SUM(f.LabaKotor), 'N0') AS TotalLaba,
    FORMAT(
        (SUM(f.LabaKotor) * 100.0 / NULLIF(SUM(f.JumlahNetto), 0)), 
        'N2'
    ) + '%' AS MarginLaba
FROM FactPenjualan f
INNER JOIN DimSupplier s ON f.SupplierKey = s.SupplierKey
INNER JOIN DimProduk p ON f.ProdukKey = p.ProdukKey
GROUP BY s.KodeSupplier, s.NamaSupplier, s.Kota, s.Provinsi
ORDER BY SUM(f.JumlahNetto) DESC;
GO

-- ============================================
-- REPORT 14: ANALISIS DISKON
-- ============================================

PRINT '';
PRINT '============================================';
PRINT 'REPORT 14: ANALISIS DISKON';
PRINT '============================================';
GO

SELECT 
    CASE 
        WHEN f.Diskon = 0 THEN 'Tanpa Diskon'
        WHEN f.Diskon > 0 AND f.Diskon <= 50000 THEN 'Diskon Kecil (< 50K)'
        WHEN f.Diskon > 50000 AND f.Diskon <= 500000 THEN 'Diskon Sedang (50K-500K)'
        WHEN f.Diskon > 500000 THEN 'Diskon Besar (> 500K)'
    END AS KategoriDiskon,
    COUNT(*) AS JumlahItem,
    COUNT(DISTINCT f.NoTransaksi) AS JumlahTransaksi,
    FORMAT(SUM(f.Diskon), 'N0') AS TotalDiskon,
    FORMAT(SUM(f.JumlahBruto), 'N0') AS TotalPenjualanBruto,
    FORMAT(SUM(f.JumlahNetto), 'N0') AS TotalPenjualanNetto,
    FORMAT(
        (SUM(f.Diskon) * 100.0 / NULLIF(SUM(f.JumlahBruto), 0)), 
        'N2'
    ) + '%' AS PersentaseDiskon
FROM FactPenjualan f
GROUP BY 
    CASE 
        WHEN f.Diskon = 0 THEN 'Tanpa Diskon'
        WHEN f.Diskon > 0 AND f.Diskon <= 50000 THEN 'Diskon Kecil (< 50K)'
        WHEN f.Diskon > 50000 AND f.Diskon <= 500000 THEN 'Diskon Sedang (50K-500K)'
        WHEN f.Diskon > 500000 THEN 'Diskon Besar (> 500K)'
    END
ORDER BY SUM(f.Diskon) DESC;
GO

-- ============================================
-- REPORT 15: DETAIL TRANSAKSI LENGKAP
-- ============================================

PRINT '';
PRINT '============================================';
PRINT 'REPORT 15: DETAIL TRANSAKSI (TOP 20)';
PRINT '============================================';
GO

SELECT TOP 20
    f.NoTransaksi,
    t.TanggalLengkap,
    t.NamaHari,
    pg.NamaPegawai AS Kasir,
    pl.NamaPelanggan,
    pl.TipePelanggan,
    p.NamaProduk,
    p.Merk,
    sk.NamaSubKategori,
    k.NamaKategori,
    l.NamaGudang,
    kt.NamaKota,
    f.Quantity,
    FORMAT(f.HargaSatuan, 'N0') AS HargaSatuan,
    FORMAT(f.Diskon, 'N0') AS Diskon,
    FORMAT(f.JumlahBruto, 'N0') AS JumlahBruto,
    FORMAT(f.JumlahNetto, 'N0') AS JumlahNetto,
    FORMAT(f.LabaKotor, 'N0') AS LabaKotor
FROM FactPenjualan f
INNER JOIN DimTanggal t ON f.TanggalKey = t.TanggalKey
INNER JOIN DimProduk p ON f.ProdukKey = p.ProdukKey
INNER JOIN DimSubKategori sk ON p.SubKategoriKey = sk.SubKategoriKey
INNER JOIN DimKategori k ON sk.KategoriKey = k.KategoriKey
INNER JOIN DimLokasi l ON f.LokasiKey = l.LokasiKey
INNER JOIN DimKota kt ON l.KotaKey = kt.KotaKey
INNER JOIN DimPelanggan pl ON f.PelangganKey = pl.PelangganKey
INNER JOIN DimPegawai pg ON f.PegawaiKey = pg.PegawaiKey
ORDER BY t.TanggalLengkap DESC, f.JumlahNetto DESC;
GO

-- ============================================
-- REPORT 16: TREN PENJUALAN HARIAN
-- ============================================

PRINT '';
PRINT '============================================';
PRINT 'REPORT 16: TREN PENJUALAN HARIAN';
PRINT '============================================';
GO

SELECT 
    t.TanggalLengkap,
    t.NamaHari,
    COUNT(DISTINCT f.NoTransaksi) AS JumlahTransaksi,
    SUM(f.Quantity) AS TotalQuantity,
    FORMAT(SUM(f.JumlahNetto), 'N0') AS TotalPenjualan,
    FORMAT(SUM(f.LabaKotor), 'N0') AS TotalLaba,
    FORMAT(AVG(f.JumlahNetto), 'N0') AS RataRataPerItem
FROM FactPenjualan f
INNER JOIN DimTanggal t ON f.TanggalKey = t.TanggalKey
GROUP BY t.TanggalLengkap, t.NamaHari
ORDER BY t.TanggalLengkap;
GO

-- ============================================
-- REPORT 17: KOMBINASI PRODUK-LOKASI TERBAIK
-- ============================================

PRINT '';
PRINT '============================================';
PRINT 'REPORT 17: TOP 10 KOMBINASI PRODUK-LOKASI';
PRINT '============================================';
GO

SELECT TOP 10
    p.NamaProduk,
    p.Merk,
    l.NamaGudang,
    kt.NamaKota,
    COUNT(DISTINCT f.NoTransaksi) AS JumlahTransaksi,
    SUM(f.Quantity) AS TotalTerjual,
    FORMAT(SUM(f.JumlahNetto), 'N0') AS TotalPenjualan,
    FORMAT(SUM(f.LabaKotor), 'N0') AS TotalLaba
FROM FactPenjualan f
INNER JOIN DimProduk p ON f.ProdukKey = p.ProdukKey
INNER JOIN DimLokasi l ON f.LokasiKey = l.LokasiKey
INNER JOIN DimKota kt ON l.KotaKey = kt.KotaKey
GROUP BY p.NamaProduk, p.Merk, l.NamaGudang, kt.NamaKota
ORDER BY SUM(f.JumlahNetto) DESC;
GO

-- ============================================
-- REPORT 18: ANALISIS MARGIN LABA PER KATEGORI
-- ============================================

PRINT '';
PRINT '============================================';
PRINT 'REPORT 18: MARGIN LABA PER KATEGORI';
PRINT '============================================';
GO

SELECT 
    k.NamaKategori,
    FORMAT(SUM(f.JumlahBruto), 'N0') AS PenjualanBruto,
    FORMAT(SUM(f.Diskon), 'N0') AS TotalDiskon,
    FORMAT(SUM(f.JumlahNetto), 'N0') AS PenjualanNetto,
    FORMAT(SUM(f.LabaKotor), 'N0') AS LabaKotor,
    FORMAT(
        (SUM(f.LabaKotor) * 100.0 / NULLIF(SUM(f.JumlahNetto), 0)), 
        'N2'
    ) + '%' AS MarginLaba,
    FORMAT(
        (SUM(f.Diskon) * 100.0 / NULLIF(SUM(f.JumlahBruto), 0)), 
        'N2'
    ) + '%' AS PersentaseDiskon
FROM FactPenjualan f
INNER JOIN DimProduk p ON f.ProdukKey = p.ProdukKey
INNER JOIN DimSubKategori sk ON p.SubKategoriKey = sk.SubKategoriKey
INNER JOIN DimKategori k ON sk.KategoriKey = k.KategoriKey
GROUP BY k.NamaKategori
ORDER BY (SUM(f.LabaKotor) * 100.0 / NULLIF(SUM(f.JumlahNetto), 0)) DESC;
GO

-- ============================================
-- REPORT 19: PERBANDINGAN PENJUALAN ANTAR BULAN
-- ============================================

PRINT '';
PRINT '============================================';
PRINT 'REPORT 19: PERBANDINGAN GROWTH ANTAR BULAN';
PRINT '============================================';
GO

WITH MonthlyData AS (
    SELECT 
        t.Tahun,
        t.Bulan,
        t.NamaBulan,
        SUM(f.JumlahNetto) AS TotalPenjualan,
        SUM(f.LabaKotor) AS TotalLaba
    FROM FactPenjualan f
    INNER JOIN DimTanggal t ON f.TanggalKey = t.TanggalKey
    GROUP BY t.Tahun, t.Bulan, t.NamaBulan
)
SELECT 
    m.Tahun,
    m.Bulan,
    m.NamaBulan,
    FORMAT(m.TotalPenjualan, 'N0') AS TotalPenjualan,
    FORMAT(m.TotalLaba, 'N0') AS TotalLaba,
    FORMAT(
        LAG(m.TotalPenjualan) OVER (ORDER BY m.Tahun, m.Bulan), 
        'N0'
    ) AS PenjualanBulanSebelumnya,
    FORMAT(
        (m.TotalPenjualan - LAG(m.TotalPenjualan) OVER (ORDER BY m.Tahun, m.Bulan)) * 100.0 / 
        NULLIF(LAG(m.TotalPenjualan) OVER (ORDER BY m.Tahun, m.Bulan), 0),
        'N2'
    ) + '%' AS GrowthRate
FROM MonthlyData m
ORDER BY m.Tahun, m.Bulan;
GO

-- ============================================
-- REPORT 20: SUMMARY EKSEKUTIF
-- ============================================

PRINT '';
PRINT '============================================';
PRINT 'REPORT 20: SUMMARY EKSEKUTIF';
PRINT '============================================';
GO

SELECT 
    'Total Penjualan' AS Metrik,
    FORMAT(SUM(JumlahNetto), 'N0') AS Nilai
FROM FactPenjualan
UNION ALL
SELECT 'Total Laba Kotor', FORMAT(SUM(LabaKotor), 'N0')
FROM FactPenjualan
UNION ALL
SELECT 'Total Transaksi', FORMAT(COUNT(DISTINCT NoTransaksi), 'N0')
FROM FactPenjualan
UNION ALL
SELECT 'Total Item Terjual', FORMAT(SUM(Quantity), 'N0')
FROM FactPenjualan
UNION ALL
SELECT 'Jumlah Produk Aktif', FORMAT(COUNT(*), 'N0')
FROM DimProduk
UNION ALL
SELECT 'Jumlah Pelanggan', FORMAT(COUNT(*), 'N0')