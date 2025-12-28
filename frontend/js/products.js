const API_URL = 'http://127.0.0.1:5000/api/products/top';
let allData = []; // Simpan semua data untuk search

function formatCurrency(value) {
    return new Intl.NumberFormat('id-ID', {
        style: 'currency',
        currency: 'IDR',
        minimumFractionDigits: 0
    }).format(value);
}

function formatNumber(value) {
    return new Intl.NumberFormat('id-ID').format(value);
}

function renderTable(data) {
    const container = document.getElementById('productTable');
    
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
                    <th style="width: 60px;">Rank</th>
                    <th>Nama Produk</th>
                    <th style="text-align: center;">Qty Terjual</th>
                    <th style="text-align: right;">Total Pendapatan</th>
                    <th style="text-align: right;">Total Laba</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    data.forEach((item, index) => {
        const rankBadge = index < 3 ? '🏆' : '';
        html += `
            <tr>
                <td style="font-weight: bold; color: #e91e63; text-align: center;">${rankBadge} #${index + 1}</td>
                <td style="font-weight: 600;">${item.namaProduk}</td>
                <td style="text-align: center;">${formatNumber(item.totalTerjual)}</td>
                <td style="text-align: right; color: #2e7d32;">${formatCurrency(item.totalPendapatan)}</td>
                <td style="text-align: right; color: #ad1457;">${formatCurrency(item.totalLaba)}</td>
            </tr>
        `;
    });
    
    html += '</tbody></table>';
    container.innerHTML = html;
}

function searchTable() {
    const searchValue = document.getElementById('searchInput').value.toLowerCase();
    const searchInfo = document.getElementById('searchInfo');
    
    if (searchValue === '') {
        renderTable(allData);
        searchInfo.textContent = `Menampilkan semua data (${allData.length} produk)`;
        return;
    }
    
    const filteredData = allData.filter(item => 
        item.namaProduk.toLowerCase().includes(searchValue)
    );
    
    renderTable(filteredData);
    searchInfo.textContent = `Ditemukan ${filteredData.length} produk dari ${allData.length} total produk`;
}

async function loadProducts() {
    try {
        const response = await fetch(API_URL);
        if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
        
        allData = await response.json();
        renderTable(allData);
        
        document.getElementById('searchInfo').textContent = 
            `Menampilkan semua data (${allData.length} produk)`;
    } catch (error) {
        console.error('Error:', error);
        document.getElementById('productTable').innerHTML = `
            <div class="error">❌ Gagal memuat data produk<br><small>${error.message}</small></div>
        `;
    }
}

document.addEventListener('DOMContentLoaded', loadProducts);