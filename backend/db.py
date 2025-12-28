import pyodbc

def get_connection():
    """
    Koneksi ke SQL Server - Data Warehouse Penjualan
    Sesuaikan dengan konfigurasi SQL Server kamu
    """
    try:
        conn = pyodbc.connect(
            "DRIVER={ODBC Driver 17 for SQL Server};"
            "SERVER=localhost\\SQLEXPRESS;"  # atau localhost saja
            "DATABASE=DW_Penjualan_Gudang;"
            "Trusted_Connection=yes;"
            "Encrypt=no;"  # Tambahkan ini untuk bypass SSL error
        )
        return conn
    except Exception as e:
        print(f"❌ Error koneksi database: {e}")
        raise