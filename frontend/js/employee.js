const API_URL = "/api/kpi/employee";
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
  const container = document.getElementById("employeeTable");

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
                    <th>Nama Pegawai</th>
                    <th style="text-align: center;">Transaksi</th>
                    <th style="text-align: right;">Total Penjualan</th>
                    <th style="text-align: right;">Total Laba</th>
                    <th style="text-align: right;">Avg/Transaksi</th>
                </tr>
            </thead>
            <tbody>
    `;

  data.forEach((item) => {
    html += `
            <tr>
                <td style="font-weight: 600;">${item.namaPegawai}</td>
                <td style="text-align: center;">${formatNumber(
                  item.jumlahTransaksi
                )}</td>
                <td style="text-align: right; color: #2e7d32;">${formatCurrency(
                  item.totalPenjualan
                )}</td>
                <td style="text-align: right; color: #ad1457;">${formatCurrency(
                  item.totalLaba
                )}</td>
                <td style="text-align: right;">${formatCurrency(
                  item.rataRataTransaksi
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
    searchInfo.textContent = `Menampilkan semua data (${allData.length} pegawai)`;
    return;
  }

  const filteredData = allData.filter((item) =>
    item.namaPegawai.toLowerCase().includes(searchValue)
  );

  renderTable(filteredData);
  searchInfo.textContent = `Ditemukan ${filteredData.length} pegawai dari ${allData.length} total pegawai`;
}

async function loadEmployee() {
  try {
    const response = await fetch(API_URL);
    if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);

    allData = await response.json();
    renderTable(allData);

    document.getElementById(
      "searchInfo"
    ).textContent = `Menampilkan semua data (${allData.length} pegawai)`;
  } catch (error) {
    console.error("Error:", error);
    document.getElementById("employeeTable").innerHTML = `
            <div class="error">❌ Gagal memuat data pegawai<br><small>${error.message}</small></div>
        `;
  }
}

document.addEventListener("DOMContentLoaded", loadEmployee);
