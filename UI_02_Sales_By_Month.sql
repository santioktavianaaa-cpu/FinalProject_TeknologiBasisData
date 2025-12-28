SELECT 
    t.Tahun,
    t.Bulan,
    t.NamaBulan,
    SUM(f.JumlahNetto) AS total_penjualan,
    SUM(f.LabaKotor) AS total_laba
FROM FactPenjualan f
JOIN DimTanggal t ON f.TanggalKey = t.TanggalKey
GROUP BY t.Tahun, t.Bulan, t.NamaBulan
ORDER BY t.Tahun, t.Bulan;
