# import pyodbc

# def get_connection():
#     """
#     Koneksi ke SQL Server - Data Warehouse Penjualan
#     Sesuaikan dengan konfigurasi SQL Server kamu
#     """
#     try:
#         conn = pyodbc.connect(
#             "DRIVER={ODBC Driver 17 for SQL Server};"
#             "SERVER=localhost\\SQLEXPRESS;"  # atau localhost saja
#             "DATABASE=DW_Penjualan_Gudang;"
#             "Trusted_Connection=yes;"
#             "Encrypt=no;"  # Tambahkan ini untuk bypass SSL error
#         )
#         return conn
#     except Exception as e:
#         print(f"❌ Error koneksi database: {e}")
#         raise

import os
import psycopg2

def get_connection():
    try:
        # Kita ambil connection string dari Environment Variable bernama 'DATABASE_URL'
        # Jangan tulis link database di sini agar aman
        db_url = os.environ.get('DATABASE_URL')
        
        if not db_url:
            raise ValueError("DATABASE_URL tidak ditemukan di environment variable")

        conn = psycopg2.connect(db_url)
        return conn
    except Exception as e:
        print(f"❌ Error koneksi database: {e}")
        raise