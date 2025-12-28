const API_URL = 'http://127.0.0.1:5000/api/kpi';

function formatCurrency(value) {
    return new Intl.NumberFormat('id-ID', {
        style: 'currency',
        currency: 'IDR',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
    }).format(value);
}

function formatNumber(value) {
    return new Intl.NumberFormat('id-ID').format(value);
}

function renderKPI(data) {
    const container = document.getElementById('kpiContainer');
    
    container.innerHTML = `
        <div class="kpi-card">
            <h3>Total Transaksi</h3>
            <div class="value">${formatNumber(data.totalTransaksi)}</div>
            <div class="source">COUNT(DISTINCT PenjualanKey)</div>
        </div>

        <div class="kpi-card">
            <h3>Total Item Terjual</h3>
            <div class="value">${formatNumber(data.totalItemTerjual)}</div>
            <div class="source">SUM(Quantity)</div>
        </div>

        <div class="kpi-card">
            <h3>Total Penjualan</h3>
            <div class="value">${formatCurrency(data.totalPenjualan)}</div>
            <div class="source">SUM(JumlahNetto)</div>
        </div>

        <div class="kpi-card">
            <h3>Total Laba</h3>
            <div class="value">${formatCurrency(data.totalLaba)}</div>
            <div class="source">SUM(LabaKotor)</div>
        </div>

        <div class="kpi-card">
            <h3>Margin Laba (%)</h3>
            <div class="value">${data.marginLaba.toFixed(2)}%</div>
            <div class="source">(Laba / Penjualan) × 100</div>
        </div>
    `;
}

async function loadKPI() {
    try {
        const response = await fetch(API_URL);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const data = await response.json();
        renderKPI(data);
        
    } catch (error) {
        console.error('Error:', error);
        document.getElementById('kpiContainer').innerHTML = `
            <div class="error">
                ❌ Gagal memuat data KPI<br>
                <small>${error.message}</small>
            </div>
        `;
    }
}

document.addEventListener('DOMContentLoaded', loadKPI);
