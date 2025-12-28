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