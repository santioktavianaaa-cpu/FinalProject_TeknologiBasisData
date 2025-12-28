const API_URL = "/api/sales/location";
let allData = [];

function formatCurrency(value) {
  return new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency: "IDR",
    minimumFractionDigits: 0,
  }).format(value);
}

function formatNumber(value) {
  return new Intl.NumberFormat("id-ID").format(value);
}

function renderTable(data) {
  const container = document.getElementById("locationTable");

  if (data.length === 0) {
    container.innerHTML = `
            <div style="text-align: center; padding: 40px; color: #ad1457;">
                ❌ Tidak ada data yang cocok dengan pencarian
            </div>
        `;
    return;
  }

  let html = `
        <table>
            <thead>
                <tr>
                    <th>Provinsi</th>
                    <th>Kota</th>
                    <th style="text-align: center;">Transaksi</th>
                    <th style="text-align: right;">Total Penjualan</th>
                    <th style="text-align: right;">Total Laba</th>
                </tr>
            </thead>
            <tbody>
    `;

  data.forEach((item) => {
    html += `
            <tr>
                <td style="font-weight: 600;">${item.provinsi}</td>
                <td>${item.kota}</td>
                <td style="text-align: center;">${formatNumber(
                  item.jumlahTransaksi
                )}</td>
                <td style="text-align: right; color: #2e7d32;">${formatCurrency(
                  item.totalPenjualan
                )}</td>
                <td style="text-align: right; color: #ad1457;">${formatCurrency(
                  item.totalLaba
                )}</td>
            </tr>
        `;
  });

  html += "</tbody></table>";
  container.innerHTML = html;
}

function searchTable() {
  const searchValue = document
    .getElementById("searchInput")
    .value.toLowerCase();
  const searchInfo = document.getElementById("searchInfo");

  if (searchValue === "") {
    renderTable(allData);
    searchInfo.textContent = `Menampilkan semua data (${allData.length} lokasi)`;
    return;
  }

  const filteredData = allData.filter(
    (item) =>
      item.provinsi.toLowerCase().includes(searchValue) ||
      item.kota.toLowerCase().includes(searchValue)
  );

  renderTable(filteredData);
  searchInfo.textContent = `Ditemukan ${filteredData.length} lokasi dari ${allData.length} total lokasi`;
}

async function loadLocation() {
  try {
    const response = await fetch(API_URL);
    if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);

    allData = await response.json();
    renderTable(allData);

    document.getElementById(
      "searchInfo"
    ).textContent = `Menampilkan semua data (${allData.length} lokasi)`;
  } catch (error) {
    console.error("Error:", error);
    document.getElementById("locationTable").innerHTML = `
            <div class="error">❌ Gagal memuat data lokasi<br><small>${error.message}</small></div>
        `;
  }
}

document.addEventListener("DOMContentLoaded", loadLocation);
