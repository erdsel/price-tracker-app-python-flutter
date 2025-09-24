# Fiyat Takip Uygulaması - Backend API
# Öğrenci Projesi - 2024

from flask import Flask, jsonify, request
from flask_cors import CORS
import sqlite3
import requests
from bs4 import BeautifulSoup
import re
from datetime import datetime
import threading
import time
from apscheduler.schedulers.background import BackgroundScheduler
import urllib3
from improved_scraper import fiyat_bul_gelismis
from site_scrapers import site_ozel_fiyat_bul

# SSL sertifika doğrulaması uyarılarını kapat (öğrenci projesi için)
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Flask uygulamasını başlat
app = Flask(__name__)
CORS(app)  # Flutter'dan gelen istekleri kabul etmek için

# Veritabanı bağlantısı oluştur
def get_db():
    """SQLite veritabanına bağlan"""
    conn = sqlite3.connect('fiyat_takip.db')
    conn.row_factory = sqlite3.Row  # Sonuçları dictionary olarak al
    return conn

# Veritabanı tablolarını oluştur
def init_db():
    """Başlangıçta veritabanı tablolarını oluştur"""
    conn = get_db()
    cursor = conn.cursor()

    # Ürünler tablosu
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS urunler (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            url TEXT NOT NULL UNIQUE,
            isim TEXT,
            son_fiyat REAL,
            onceki_fiyat REAL,
            son_kontrol TIMESTAMP,
            aktif INTEGER DEFAULT 1
        )
    ''')

    # Fiyat geçmişi tablosu
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS fiyat_gecmisi (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            urun_id INTEGER,
            fiyat REAL,
            tarih TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (urun_id) REFERENCES urunler(id)
        )
    ''')

    conn.commit()
    conn.close()

def fiyat_bul(html_content):
    """HTML içeriğinden fiyat bilgisini bulmaya çalış - gelişmiş versiyon kullanıyor"""
    # Yeni gelişmiş fonksiyonu kullan
    return fiyat_bul_gelismis(html_content)

def urun_fiyatini_kontrol_et(urun_id):
    """Belirli bir ürünün fiyatını kontrol et"""
    conn = get_db()
    cursor = conn.cursor()

    # Ürün bilgilerini al
    cursor.execute('SELECT * FROM urunler WHERE id = ?', (urun_id,))
    urun = cursor.fetchone()

    if not urun:
        conn.close()
        return

    try:
        # Web sayfasını indir
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'tr-TR,tr;q=0.8,en-US;q=0.5,en;q=0.3',
            'Accept-Encoding': 'gzip, deflate',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1'
        }
        response = requests.get(urun['url'], headers=headers, timeout=10, verify=False)

        # Önce site özel scraper'ı dene
        yeni_fiyat = site_ozel_fiyat_bul(urun['url'], response.text, headers)

        # Site özel scraper başarısızsa genel scraper'ı kullan
        if not yeni_fiyat:
            yeni_fiyat = fiyat_bul(response.text)

        if yeni_fiyat:
            # Önceki fiyatı kaydet
            onceki_fiyat = urun['son_fiyat']

            # Yeni fiyatı güncelle
            cursor.execute('''
                UPDATE urunler
                SET son_fiyat = ?, onceki_fiyat = ?, son_kontrol = ?
                WHERE id = ?
            ''', (yeni_fiyat, onceki_fiyat, datetime.now(), urun_id))

            # Fiyat geçmişine ekle
            cursor.execute('''
                INSERT INTO fiyat_gecmisi (urun_id, fiyat)
                VALUES (?, ?)
            ''', (urun_id, yeni_fiyat))

            conn.commit()

            # Fiyat düştüyse bildirim gönder (ileride eklenecek)
            if onceki_fiyat and yeni_fiyat < onceki_fiyat:
                print(f"FIYAT DÜŞTÜ! {urun['isim']}: {onceki_fiyat} TL -> {yeni_fiyat} TL")

    except Exception as e:
        print(f"Hata oluştu: {e}")

    finally:
        conn.close()

def tum_urunleri_kontrol_et():
    """Tüm aktif ürünlerin fiyatlarını kontrol et"""
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute('SELECT id FROM urunler WHERE aktif = 1')
    urunler = cursor.fetchall()
    conn.close()

    # Her ürünü sırayla kontrol et
    for urun in urunler:
        urun_fiyatini_kontrol_et(urun['id'])
        time.sleep(2)  # Siteler banlamasın diye 2 saniye bekle

# API Endpoint'leri

@app.route('/api/urun/ekle', methods=['POST'])
def urun_ekle():
    """Yeni ürün ekle veya mevcut ürünü güncelle"""
    data = request.json
    url = data.get('url')

    if not url:
        return jsonify({'hata': 'URL gerekli'}), 400

    conn = get_db()
    cursor = conn.cursor()

    try:
        # Önce URL'nin zaten var olup olmadığını kontrol et
        cursor.execute('SELECT * FROM urunler WHERE url = ?', (url,))
        mevcut_urun = cursor.fetchone()

        # İlk fiyat kontrolü yap
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'tr-TR,tr;q=0.8,en-US;q=0.5,en;q=0.3',
            'Accept-Encoding': 'gzip, deflate',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1'
        }
        response = requests.get(url, headers=headers, timeout=10, verify=False)

        # Önce site özel scraper'ı dene
        fiyat = site_ozel_fiyat_bul(url, response.text, headers)

        # Site özel scraper başarısızsa genel scraper'ı kullan
        if not fiyat:
            fiyat = fiyat_bul(response.text)

        # Ürün ismini bulmaya çalış (title tag'inden)
        soup = BeautifulSoup(response.text, 'html.parser')
        isim = soup.title.string if soup.title else url[:50]

        if mevcut_urun:
            # Ürün zaten var, güncelle
            urun_id = mevcut_urun['id']
            onceki_fiyat = mevcut_urun['son_fiyat']

            # Eğer pasifse tekrar aktif et
            cursor.execute('''
                UPDATE urunler
                SET son_fiyat = ?, onceki_fiyat = ?, son_kontrol = ?, aktif = 1, isim = ?
                WHERE id = ?
            ''', (fiyat, onceki_fiyat, datetime.now(), isim, urun_id))

            # Yeni fiyatı geçmişe ekle
            if fiyat:
                cursor.execute('''
                    INSERT INTO fiyat_gecmisi (urun_id, fiyat)
                    VALUES (?, ?)
                ''', (urun_id, fiyat))

            conn.commit()
            conn.close()

            return jsonify({
                'basarili': True,
                'urun_id': urun_id,
                'isim': isim,
                'fiyat': fiyat,
                'mesaj': 'Ürün zaten takipte, fiyat güncellendi'
            })

        else:
            # Yeni ürün ekle
            cursor.execute('''
                INSERT INTO urunler (url, isim, son_fiyat, son_kontrol)
                VALUES (?, ?, ?, ?)
            ''', (url, isim, fiyat, datetime.now()))

            urun_id = cursor.lastrowid

            # İlk fiyatı geçmişe ekle
            if fiyat:
                cursor.execute('''
                    INSERT INTO fiyat_gecmisi (urun_id, fiyat)
                    VALUES (?, ?)
                ''', (urun_id, fiyat))

            conn.commit()
            conn.close()

            return jsonify({
                'basarili': True,
                'urun_id': urun_id,
                'isim': isim,
                'fiyat': fiyat,
                'mesaj': 'Yeni ürün eklendi'
            })

    except Exception as e:
        conn.close()
        return jsonify({'hata': str(e)}), 500

@app.route('/api/urunler', methods=['GET'])
def urunleri_listele():
    """Tüm ürünleri listele"""
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM urunler WHERE aktif = 1 ORDER BY id DESC')
    urunler = [dict(row) for row in cursor.fetchall()]
    conn.close()

    return jsonify(urunler)

@app.route('/api/urun/<int:urun_id>', methods=['GET'])
def urun_detay(urun_id):
    """Ürün detaylarını ve fiyat geçmişini getir"""
    conn = get_db()
    cursor = conn.cursor()

    # Ürün bilgileri
    cursor.execute('SELECT * FROM urunler WHERE id = ?', (urun_id,))
    urun_row = cursor.fetchone()
    urun = dict(urun_row) if urun_row else None

    if not urun:
        conn.close()
        return jsonify({'hata': 'Ürün bulunamadı'}), 404

    # Fiyat geçmişi
    cursor.execute('''
        SELECT fiyat, tarih
        FROM fiyat_gecmisi
        WHERE urun_id = ?
        ORDER BY tarih DESC
        LIMIT 30
    ''', (urun_id,))

    gecmis = [dict(row) for row in cursor.fetchall()]
    conn.close()

    return jsonify({
        'urun': urun,
        'fiyat_gecmisi': gecmis
    })

@app.route('/api/urun/<int:urun_id>', methods=['DELETE'])
def urun_sil(urun_id):
    """Ürünü pasif yap (soft delete)"""
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute('UPDATE urunler SET aktif = 0 WHERE id = ?', (urun_id,))
    conn.commit()
    conn.close()

    return jsonify({'basarili': True})

@app.route('/api/kontrol/baslat', methods=['POST'])
def kontrol_baslat():
    """Manuel fiyat kontrolü başlat"""
    # Arkaplan thread'inde kontrol başlat
    thread = threading.Thread(target=tum_urunleri_kontrol_et)
    thread.start()

    return jsonify({'mesaj': 'Fiyat kontrolü başlatıldı'})

# Uygulama başlatıldığında
if __name__ == '__main__':
    # Veritabanını başlat
    init_db()

    # Otomatik fiyat kontrolü için scheduler başlat
    scheduler = BackgroundScheduler()
    # Her 30 dakikada bir kontrol et
    scheduler.add_job(func=tum_urunleri_kontrol_et, trigger="interval", minutes=30)
    scheduler.start()

    print("Fiyat Takip API başlatıldı...")
    print("Otomatik kontrol: Her 30 dakikada bir")

    # Flask uygulamasını başlat
    app.run(debug=True, host='0.0.0.0', port=5000)