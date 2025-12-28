from flask import Flask, jsonify, request
from flask_cors import CORS
from db import get_connection

app = Flask(__name__)
CORS(app)

# ========================================
# ENDPOINT 1: KPI DASHBOARD
# ========================================
@app.route('/api/kpi', methods=['GET'])
def get_kpi():
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        query = """
        SELECT 
            COUNT(DISTINCT NoTransaksi) AS TotalTransaksi,
            SUM(Quantity) AS TotalItemTerjual,
            SUM(JumlahNetto) AS TotalPenjualan,
            SUM(LabaKotor) AS TotalLaba,
            CASE 
                WHEN SUM(JumlahNetto) > 0 
                THEN (SUM(LabaKotor) / SUM(JumlahNetto)) * 100 
                ELSE 0 
            END AS MarginLaba
        FROM FactPenjualan
        """
        
        cursor.execute(query)
        row = cursor.fetchone()
        conn.close()
        
        kpi_data = {
            "totalTransaksi": int(row[0]) if row and row[0] else 0,
            "totalItemTerjual": int(row[1]) if row and row[1] else 0,
            "totalPenjualan": float(row[2]) if row and row[2] else 0,
            "totalLaba": float(row[3]) if row and row[3] else 0,
            "marginLaba": float(row[4]) if row and row[4] else 0
        }
        
        return jsonify(kpi_data), 200
    except Exception as e:
        print(f"❌ Error KPI: {e}")
        return jsonify({"error": str(e)}), 500

# ========================================
# ENDPOINT 2: TREN BULANAN
# ========================================
@app.route('/api/sales/monthly', methods=['GET'])
def sales_monthly():
    try:
        year = request.args.get('year')
        conn = get_connection()
        cursor = conn.cursor()
        
        query = """
        SELECT 
            d.Bulan,
            d.NamaBulan,
            SUM(f.JumlahNetto) AS TotalPenjualan,
            COUNT(DISTINCT f.PenjualanKey) AS JumlahTransaksi,
            SUM(f.LabaKotor) AS TotalLaba
        FROM FactPenjualan f
        JOIN DimTanggal d ON f.TanggalKey = d.TanggalKey
        """

        params = []
        if year and year != 'all':
            query += " WHERE d.Tahun = %s "  # Ganti ? dengan %s
            params.append(year)

        query += """
        GROUP BY d.Bulan, d.NamaBulan
        ORDER BY d.Bulan
        """

        cursor.execute(query, tuple(params))
        rows = cursor.fetchall()
        conn.close()
        
        trend_data = [
            {
                "bulan": row[0],
                "namaBulan": row[1],
                "totalPenjualan": float(row[2]),
                "jumlahTransaksi": int(row[3]),
                "totalLaba": float(row[4])
            } for row in rows
        ]
        
        return jsonify(trend_data), 200
    except Exception as e:
        print(f"❌ Error Trend: {e}")
        return jsonify({"error": str(e)}), 500

# ========================================
# ENDPOINT 3: PER KATEGORI
# ========================================
@app.route('/api/sales/category', methods=['GET'])
def sales_by_category():
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        query = """
        SELECT 
            k.NamaKategori,
            SUM(f.JumlahNetto) AS TotalPenjualan,
            SUM(f.Quantity) AS TotalKuantitas,
            SUM(f.LabaKotor) AS TotalLaba
        FROM FactPenjualan f
        JOIN DimProduk p ON f.ProdukKey = p.ProdukKey
        JOIN DimSubKategori s ON p.SubKategoriKey = s.SubKategoriKey
        JOIN DimKategori k ON s.KategoriKey = k.KategoriKey
        GROUP BY k.NamaKategori
        ORDER BY SUM(f.JumlahNetto) DESC
        """
        
        cursor.execute(query)
        rows = cursor.fetchall()
        conn.close()
        
        category_data = [
            {
                "kategori": row[0],
                "totalPenjualan": float(row[1]),
                "totalKuantitas": int(row[2]),
                "totalLaba": float(row[3])
            } for row in rows
        ]
        return jsonify(category_data), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ========================================
# ENDPOINT 4: TOP PRODUK (Fix LIMIT & Query)
# ========================================
@app.route('/api/products/top', methods=['GET'])
def top_products():
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        # PERBAIKAN: Ganti TOP 10 dengan LIMIT 10 di akhir
        query = """
        SELECT 
            p.NamaProduk,
            SUM(f.Quantity) AS TotalTerjual,
            SUM(f.JumlahNetto) AS TotalPendapatan,
            SUM(f.LabaKotor) AS TotalLaba
        FROM FactPenjualan f
        JOIN DimProduk p ON f.ProdukKey = p.ProdukKey
        GROUP BY p.NamaProduk
        ORDER BY SUM(f.JumlahNetto) DESC
        LIMIT 10
        """
        
        cursor.execute(query)
        rows = cursor.fetchall()
        conn.close()
        
        products = [
            {
                "namaProduk": row[0],
                "totalTerjual": int(row[1]),
                "totalPendapatan": float(row[2]),
                "totalLaba": float(row[3])
            } for row in rows
        ]
        return jsonify(products), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ========================================
# ENDPOINT 5: PER LOKASI
# ========================================
@app.route('/api/sales/location', methods=['GET'])
def sales_by_location():
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        query = """
        SELECT 
            prov.NamaProvinsi,
            kota.NamaKota,
            SUM(f.JumlahNetto) AS TotalPenjualan,
            COUNT(DISTINCT f.PenjualanKey) AS JumlahTransaksi,
            SUM(f.LabaKotor) AS TotalLaba
        FROM FactPenjualan f
        JOIN DimLokasi l ON f.LokasiKey = l.LokasiKey
        JOIN DimKota kota ON l.KotaKey = kota.KotaKey
        JOIN DimProvinsi prov ON kota.ProvinsiKey = prov.ProvinsiKey
        GROUP BY prov.NamaProvinsi, kota.NamaKota
        ORDER BY SUM(f.JumlahNetto) DESC
        """
        
        cursor.execute(query)
        rows = cursor.fetchall()
        conn.close()
        
        location_data = [
            {
                "provinsi": row[0],
                "kota": row[1],
                "totalPenjualan": float(row[2]),
                "jumlahTransaksi": int(row[3]),
                "totalLaba": float(row[4])
            } for row in rows
        ]
        return jsonify(location_data), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ========================================
# ENDPOINT 6: PER PEGAWAI
# ========================================
@app.route('/api/sales/employee', methods=['GET'])
def sales_by_employee():
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        query = """
        SELECT 
            p.NamaPegawai,
            COUNT(DISTINCT f.PenjualanKey) AS JumlahTransaksi,
            SUM(f.JumlahNetto) AS TotalPenjualan,
            SUM(f.LabaKotor) AS TotalLaba,
            AVG(f.JumlahNetto) AS RataRataTransaksi
        FROM FactPenjualan f
        JOIN DimPegawai p ON f.PegawaiKey = p.PegawaiKey
        GROUP BY p.NamaPegawai
        ORDER BY SUM(f.JumlahNetto) DESC
        """
        
        cursor.execute(query)
        rows = cursor.fetchall()
        conn.close()
        
        employee_data = [
            {
                "namaPegawai": row[0],
                "jumlahTransaksi": int(row[1]),
                "totalPenjualan": float(row[2]),
                "totalLaba": float(row[3]),
                "rataRataTransaksi": float(row[4])
            } for row in rows
        ]
        return jsonify(employee_data), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, port=5000)