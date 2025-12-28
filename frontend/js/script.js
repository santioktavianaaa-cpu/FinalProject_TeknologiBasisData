fetch("/kpi/")
  .then((res) => res.json())
  .then((data) => {
    document.getElementById("totalTransaksi").innerText = data.total_transaksi;
    document.getElementById("totalItem").innerText = data.total_item;
    document.getElementById("totalPenjualan").innerText =
      "Rp " + data.total_penjualan.toLocaleString("id-ID");
    document.getElementById("totalLaba").innerText =
      "Rp " + data.total_laba.toLocaleString("id-ID");
    document.getElementById("marginLaba").innerText = data.margin_laba + " %";
  })
  .catch((err) => console.error(err));
