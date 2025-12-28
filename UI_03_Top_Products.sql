SELECT TOP 10
    p.NamaProduk,
    p.Merk,
    SUM(f.Quantity) AS total_terjual,
    SUM(f.JumlahNetto) AS total_penjualan
FROM FactPenjualan f
JOIN DimProduk p ON f.ProdukKey = p.ProdukKey
GROUP BY p.NamaProduk, p.Merk
ORDER BY total_penjualan DESC;
