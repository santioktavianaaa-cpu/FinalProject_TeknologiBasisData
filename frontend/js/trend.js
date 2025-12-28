const API_URL = "http://127.0.0.1:5000/api/sales/monthly";

function renderChart(data) {
  const ctx = document.getElementById("salesChart").getContext("2d");

  new Chart(ctx, {
    type: "line",
    data: {
      labels: data.map((d) => d.namaBulan || `Bulan ${d.bulan}`),
      datasets: [
        {
          label: "💰 Total Penjualan (Rp)",
          data: data.map((d) => d.totalPenjualan),
          borderColor: "#e91e63",
          backgroundColor: "rgba(233, 30, 99, 0.1)",
          borderWidth: 3,
          fill: true,
          tension: 0.4,
          pointRadius: 5,
          pointBackgroundColor: "#ad1457",
          pointBorderColor: "#fff",
          pointBorderWidth: 2,
        },
        {
          label: "🛒 Jumlah Transaksi",
          data: data.map((d) => d.jumlahTransaksi),
          borderColor: "#7b1fa2",
          backgroundColor: "rgba(123, 31, 162, 0.1)",
          borderWidth: 3,
          fill: true,
          tension: 0.4,
          yAxisID: "y1",
          pointRadius: 5,
          pointBackgroundColor: "#4a148c",
          pointBorderColor: "#fff",
          pointBorderWidth: 2,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: true,
      interaction: {
        mode: "index",
        intersect: false,
      },
      plugins: {
        title: {
          display: true,
          text: "Tren Penjualan & Transaksi per Bulan",
          font: { size: 16, weight: "bold", family: "Inter" },
          color: "#ad1457",
          padding: { top: 10, bottom: 30 },
        },
        legend: {
          display: true,
          position: "top",
          labels: {
            font: { size: 12, weight: "600", family: "Inter" },
            color: "#424242",
            padding: 15,
            usePointStyle: true,
          },
        },
        tooltip: {
          backgroundColor: "rgba(255, 255, 255, 0.95)",
          titleColor: "#ad1457",
          bodyColor: "#424242",
          borderColor: "#e91e63",
          borderWidth: 2,
          padding: 12,
          titleFont: { size: 13, weight: "bold" },
          bodyFont: { size: 12 },
          callbacks: {
            label: function (context) {
              let label = context.dataset.label || "";
              if (label) label += ": ";
              if (context.parsed.y !== null) {
                if (context.datasetIndex === 0) {
                  label += new Intl.NumberFormat("id-ID", {
                    style: "currency",
                    currency: "IDR",
                    minimumFractionDigits: 0,
                  }).format(context.parsed.y);
                } else {
                  label += context.parsed.y + " transaksi";
                }
              }
              return label;
            },
          },
        },
      },
      scales: {
        y: {
          type: "linear",
          display: true,
          position: "left",
          title: {
            display: true,
            text: "💰 Total Penjualan (Rupiah)",
            font: { size: 12, weight: "bold", family: "Inter" },
            color: "#e91e63",
          },
          ticks: {
            callback: function (value) {
              return "Rp " + value.toLocaleString("id-ID");
            },
            font: { size: 10, family: "Inter" },
            color: "#616161",
          },
          grid: {
            color: "rgba(233, 30, 99, 0.08)",
            drawBorder: false,
          },
        },
        y1: {
          type: "linear",
          display: true,
          position: "right",
          title: {
            display: true,
            text: "🛒 Jumlah Transaksi",
            font: { size: 12, weight: "bold", family: "Inter" },
            color: "#7b1fa2",
          },
          ticks: {
            font: { size: 10, family: "Inter" },
            color: "#616161",
          },
          grid: {
            drawOnChartArea: false,
            drawBorder: false,
          },
        },
        x: {
          ticks: {
            font: { size: 11, weight: "600", family: "Inter" },
            color: "#424242",
          },
          grid: {
            color: "rgba(233, 30, 99, 0.05)",
            drawBorder: false,
          },
        },
      },
    },
  });
}

async function loadTrend() {
  try {
    const response = await fetch(API_URL);
    if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
    const data = await response.json();
    if (data.length === 0) throw new Error("Tidak ada data tren yang tersedia");
    renderChart(data);
  } catch (error) {
    console.error("Error:", error);
    document.querySelector(".chart-container").innerHTML = `
            <div class="error">
                ❌ Gagal memuat data tren penjualan<br>
                <small>${error.message}</small><br>
                <small style="margin-top: 10px; display: block;">
                    Pastikan backend berjalan di http://127.0.0.1:5000
                </small>
            </div>
        `;
  }
}

function applyFilter() {
  const year = document.getElementById("yearFilter").value;
  const url = year === "all" ? API_URL : `${API_URL}?year=${year}`;
  fetch(url)
    .then((res) => res.json())
    .then(renderChart);
}

document.addEventListener("DOMContentLoaded", loadTrend);
