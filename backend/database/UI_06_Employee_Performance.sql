SELECT 
    pg.NamaPegawai,
    pg.Jabatan,
    COUNT(DISTINCT f.NoTransaksi) AS jumlah_transaksi,
    SUM(f.JumlahNetto) AS total_penjualan
FROM FactPenjualan f
JOIN DimPegawai pg ON f.PegawaiKey = pg.PegawaiKey
GROUP BY pg.NamaPegawai, pg.Jabatan
ORDER BY total_penjualan DESC;
