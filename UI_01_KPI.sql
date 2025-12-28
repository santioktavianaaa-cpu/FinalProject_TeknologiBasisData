SELECT 
    COUNT(DISTINCT NoTransaksi) AS total_transaksi,
    SUM(Quantity) AS total_item_terjual,
    SUM(JumlahNetto) AS total_penjualan,
    SUM(LabaKotor) AS total_laba,
    ROUND(
        (SUM(LabaKotor) * 100.0 / NULLIF(SUM(JumlahNetto), 0)), 2
    ) AS margin_laba_persen
FROM FactPenjualan;
