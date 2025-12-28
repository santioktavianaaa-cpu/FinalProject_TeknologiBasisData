SELECT 
    pv.NamaProvinsi,
    kt.NamaKota,
    SUM(f.JumlahNetto) AS total_penjualan
FROM FactPenjualan f
JOIN DimLokasi l ON f.LokasiKey = l.LokasiKey
JOIN DimKota kt ON l.KotaKey = kt.KotaKey
JOIN DimProvinsi pv ON kt.ProvinsiKey = pv.ProvinsiKey
GROUP BY pv.NamaProvinsi, kt.NamaKota
ORDER BY total_penjualan DESC;
