# Site özel scraper'ları
import re
import json
import requests
from bs4 import BeautifulSoup

def hepsiburada_fiyat_bul(url, headers):
    """Hepsiburada için özel fiyat bulma"""
    try:
        # Hepsiburada'nın product ID'sini URL'den çıkar
        # Örnek: HBC00007OJ2RK veya pm-HBC00007OJ2RK
        product_id_match = re.search(r'([A-Z0-9]+)(?:-pm-|$)', url.split('/')[-1])
        if not product_id_match:
            return None

        product_id = product_id_match.group(1)

        # Hepsiburada'nın internal API'sini dene
        api_url = f"https://www.hepsiburada.com/api/product/dynamic/{product_id}"

        response = requests.get(api_url, headers=headers, timeout=10, verify=False)

        if response.status_code == 200:
            try:
                data = response.json()
                # Farklı fiyat alanlarını kontrol et
                if 'product' in data:
                    product = data['product']
                    if 'listings' in product and product['listings']:
                        listing = product['listings'][0]
                        if 'priceInfo' in listing:
                            price_info = listing['priceInfo']
                            if 'price' in price_info:
                                return float(price_info['price'])
                            elif 'discountedPrice' in price_info:
                                return float(price_info['discountedPrice'])
                            elif 'originalPrice' in price_info:
                                return float(price_info['originalPrice'])

                # Alternatif yapılar
                if 'price' in data:
                    return float(data['price'])
            except:
                pass
    except:
        pass

    # API çalışmazsa normal HTML'den dene
    return None

def trendyol_fiyat_bul(html_content):
    """Trendyol için özel fiyat bulma"""
    soup = BeautifulSoup(html_content, 'html.parser')

    # Trendyol genelde prc-dsc veya prc-box class'larını kullanır
    price_elements = soup.find_all(class_=re.compile('prc-dsc|prc-box|price'))

    for elem in price_elements:
        text = elem.get_text(strip=True)
        # TL ve virgül içeren pattern
        match = re.search(r'([\d.]+,\d{2})\s*TL', text)
        if match:
            price_str = match.group(1).replace('.', '').replace(',', '.')
            try:
                return float(price_str)
            except:
                continue

    return None

def n11_fiyat_bul(html_content):
    """N11 için özel fiyat bulma"""
    soup = BeautifulSoup(html_content, 'html.parser')

    # N11 genelde newPrice veya price class'larını kullanır
    price_elem = soup.find(class_='newPrice') or soup.find(class_='price')

    if price_elem:
        # ins tag'i içinde fiyat olabilir
        ins_elem = price_elem.find('ins')
        if ins_elem:
            text = ins_elem.get_text(strip=True)
        else:
            text = price_elem.get_text(strip=True)

        # Fiyatı çıkar
        match = re.search(r'([\d.]+,\d{2})', text)
        if match:
            price_str = match.group(1).replace('.', '').replace(',', '.')
            try:
                return float(price_str)
            except:
                pass

    return None

def gittigidiyor_fiyat_bul(html_content):
    """GittiGidiyor için özel fiyat bulma"""
    soup = BeautifulSoup(html_content, 'html.parser')

    # GittiGidiyor genelde price-container veya product-price class'larını kullanır
    price_elem = soup.find(class_='price-container') or soup.find(class_='product-price')

    if price_elem:
        text = price_elem.get_text(strip=True)
        # TL içeren pattern
        match = re.search(r'([\d.]+,\d{2})\s*TL', text)
        if match:
            price_str = match.group(1).replace('.', '').replace(',', '.')
            try:
                return float(price_str)
            except:
                pass

    return None

def amazon_tr_fiyat_bul(html_content):
    """Amazon.com.tr için özel fiyat bulma"""
    soup = BeautifulSoup(html_content, 'html.parser')

    # Amazon farklı class'lar kullanabilir
    price_classes = [
        'a-price-whole',
        'a-price-range',
        'a-price',
        'price-large',
        'offer-price',
        'priceblock_dealprice',
        'priceblock_saleprice',
        'priceblock_ourprice'
    ]

    for class_name in price_classes:
        price_elem = soup.find(class_=class_name)
        if price_elem:
            text = price_elem.get_text(strip=True)
            # Virgül ve TL içeren pattern
            match = re.search(r'([\d.]+,\d{2})', text)
            if match:
                price_str = match.group(1).replace('.', '').replace(',', '.')
                try:
                    return float(price_str)
                except:
                    continue

    return None

def teknosa_fiyat_bul(html_content):
    """Teknosa için özel fiyat bulma"""
    soup = BeautifulSoup(html_content, 'html.parser')

    # Teknosa genelde prc veya price class'larını kullanır
    price_elem = soup.find(class_=re.compile('prc|price', re.I))

    if price_elem:
        # data-price attribute'u olabilir
        if price_elem.get('data-price'):
            try:
                return float(price_elem['data-price'].replace(',', '.'))
            except:
                pass

        text = price_elem.get_text(strip=True)
        match = re.search(r'([\d.]+,\d{2})', text)
        if match:
            price_str = match.group(1).replace('.', '').replace(',', '.')
            try:
                return float(price_str)
            except:
                pass

    return None

def site_ozel_fiyat_bul(url, html_content, headers):
    """Site özel fiyat bulma fonksiyonlarını çağır"""

    # URL'den site adını çıkar
    if 'hepsiburada.com' in url:
        price = hepsiburada_fiyat_bul(url, headers)
        if price:
            return price
    elif 'trendyol.com' in url:
        price = trendyol_fiyat_bul(html_content)
        if price:
            return price
    elif 'n11.com' in url:
        price = n11_fiyat_bul(html_content)
        if price:
            return price
    elif 'gittigidiyor.com' in url:
        price = gittigidiyor_fiyat_bul(html_content)
        if price:
            return price
    elif 'amazon.com.tr' in url:
        price = amazon_tr_fiyat_bul(html_content)
        if price:
            return price
    elif 'teknosa.com' in url:
        price = teknosa_fiyat_bul(html_content)
        if price:
            return price

    return None