# Veritabanını güncelleme scripti - Favori sütunu ekle
import sqlite3

def update_database():
    """Mevcut veritabanına favori sütununu ekle"""
    conn = sqlite3.connect('fiyat_takip.db')
    cursor = conn.cursor()

    try:
        # Önce favori sütunu var mı kontrol et
        cursor.execute("PRAGMA table_info(urunler)")
        columns = cursor.fetchall()
        column_names = [column[1] for column in columns]

        if 'favori' not in column_names:
            # Favori sütununu ekle
            cursor.execute("ALTER TABLE urunler ADD COLUMN favori INTEGER DEFAULT 0")
            conn.commit()
            print("Favori sutunu basariyla eklendi")
        else:
            print("Favori sutunu zaten mevcut")

    except Exception as e:
        print(f"Hata: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    update_database()