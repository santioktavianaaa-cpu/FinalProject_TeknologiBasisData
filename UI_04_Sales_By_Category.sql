SELECT 
    k.NamaKategori,
    SUM(f.JumlahNetto) AS total_penjualan
FROM FactPenjualan f
JOIN DimProduk p ON f.ProdukKey = p.ProdukKey
JOIN DimSubKategori sk ON p.SubKategoriKey = sk.SubKategoriKey
JOIN DimKategori k ON sk.KategoriKey = k.KategoriKey
GROUP BY k.NamaKategori
ORDER BY total_penjualan DESC;
