# Geliştirilmiş fiyat bulma modülü
import re
from bs4 import BeautifulSoup
import json
from site_scrapers import site_ozel_fiyat_bul

def fiyat_bul_gelismis(html_content):
    """Geliştirilmiş fiyat bulma algoritması"""
    soup = BeautifulSoup(html_content, 'html.parser')
    bulunan_fiyatlar = []

    # 1. JSON-LD Structured Data kontrolü
    scripts = soup.find_all('script', type='application/ld+json')
    for script in scripts:
        try:
            data = json.loads(script.string)
            if isinstance(data, dict):
                # Offers içinde price ara
                if 'offers' in data:
                    if isinstance(data['offers'], dict) and 'price' in data['offers']:
                        price = float(str(data['offers']['price']).replace(',', '.'))
                        if price > 0:
                            bulunan_fiyatlar.append(('json-ld', price))
                # Direkt price alanı
                if 'price' in data:
                    price = float(str(data['price']).replace(',', '.'))
                    if price > 0:
                        bulunan_fiyatlar.append(('json-ld', price))
        except:
            continue

    # 2. Data attribute kontrolü
    data_attrs = [
        'data-price', 'data-product-price', 'data-variant-price',
        'data-gtm-price', 'data-default-price', 'data-sale-price'
    ]

    for attr in data_attrs:
        elements = soup.find_all(attrs={attr: True})
        for element in elements:
            try:
                value = element[attr]
                # Sayısal değer çıkar
                price_str = re.sub(r'[^\d,.]', '', value)
                price_str = price_str.replace(',', '.')
                price = float(price_str)
                if 0 < price < 100000:
                    bulunan_fiyatlar.append((f'data-{attr}', price))
            except:
                continue

    # 3. Gratis için özel kontrol
    # Gratis genelde class="product-price" kullanır
    gratis_elements = soup.find_all(class_=re.compile('product.*price', re.I))
    for elem in gratis_elements:
        text = elem.get_text(strip=True)
        # TL işareti veya virgül içeren sayılar
        matches = re.findall(r'[\d.]+,\d{2}', text)
        for match in matches:
            try:
                price = float(match.replace('.', '').replace(',', '.'))
                if 0 < price < 100000:
                    bulunan_fiyatlar.append(('gratis-special', price))
            except:
                continue

    # 4. Meta tag kontrolü
    meta_props = [
        'product:price:amount', 'og:price:amount',
        'product:price', 'price'
    ]

    for prop in meta_props:
        meta = soup.find('meta', {'property': prop}) or \
               soup.find('meta', {'name': prop})
        if meta and meta.get('content'):
            try:
                price_str = re.sub(r'[^\d,.]', '', meta['content'])
                price_str = price_str.replace(',', '.')
                price = float(price_str)
                if 0 < price < 100000:
                    bulunan_fiyatlar.append((f'meta-{prop}', price))
            except:
                continue

    # 5. Genel class/id pattern araması
    price_patterns = [
        r'₺\s*([\d.,]+)',
        r'([\d.,]+)\s*₺',
        r'([\d.,]+)\s*TL',
        r'TL\s*([\d.,]+)',
        r'(\d{1,3}(?:\.\d{3})*,\d{2})',  # 1.234,56 formatı
        r'(\d+,\d{2})',  # 123,45 formatı
    ]

    # Fiyat içerebilecek class isimleri (genişletilmiş liste)
    price_classes = [
        'price', 'Price', 'PRICE',
        'fiyat', 'Fiyat', 'FIYAT',
        'tutar', 'amount', 'cost',
        'product-price', 'product_price', 'productPrice',
        'sale-price', 'sale_price', 'salePrice',
        'regular-price', 'regularPrice',
        'current-price', 'currentPrice',
        'new-price', 'newPrice',
        'price-now', 'priceNow',
        'price-box', 'priceBox',
        'price-tag', 'priceTag',
        'prd-price', 'prdPrice',
        'item-price', 'itemPrice',
        'price-value', 'priceValue',
        'product-card-price',
        'product-price-value'
    ]

    # Class ve ID'lerde ara
    for class_name in price_classes:
        # Class attribute'unda ara
        elements = soup.find_all(class_=re.compile(class_name, re.I))
        # ID attribute'unda ara
        elements += soup.find_all(id=re.compile(class_name, re.I))

        for elem in elements:
            text = elem.get_text(strip=True)
            # Çok uzun text'leri atla
            if len(text) > 100:
                continue

            for pattern in price_patterns:
                matches = re.findall(pattern, text)
                for match in matches:
                    try:
                        # Türkçe sayı formatını düzelt
                        price_str = match
                        if isinstance(match, tuple):
                            price_str = match[0]

                        # Binlik ayırıcı nokta, ondalık virgül
                        if '.' in price_str and ',' in price_str:
                            # 1.234,56 -> 1234.56
                            price_str = price_str.replace('.', '').replace(',', '.')
                        elif ',' in price_str:
                            # 123,45 -> 123.45
                            price_str = price_str.replace(',', '.')

                        price = float(price_str)
                        if 0 < price < 100000:
                            bulunan_fiyatlar.append((f'class-{class_name}', price))
                    except:
                        continue

    # 6. İçinde TL veya ₺ geçen tüm elementlerde ara (son çare)
    if not bulunan_fiyatlar:
        all_elements = soup.find_all(['span', 'div', 'p', 'strong', 'b'])
        for elem in all_elements[:200]:  # İlk 200 element
            text = elem.get_text(strip=True)
            if ('₺' in text or 'TL' in text) and len(text) < 50:
                for pattern in price_patterns:
                    matches = re.findall(pattern, text)
                    for match in matches:
                        try:
                            price_str = match
                            if isinstance(match, tuple):
                                price_str = match[0]

                            if '.' in price_str and ',' in price_str:
                                price_str = price_str.replace('.', '').replace(',', '.')
                            elif ',' in price_str:
                                price_str = price_str.replace(',', '.')

                            price = float(price_str)
                            if 0 < price < 100000:
                                bulunan_fiyatlar.append(('general-search', price))
                        except:
                            continue

    # En güvenilir fiyatı seç
    if bulunan_fiyatlar:
        # Öncelik sırasına göre sırala
        priority_order = ['json-ld', 'data-', 'meta-', 'gratis-special', 'class-', 'general-search']

        def get_priority(item):
            source = item[0]
            for i, prefix in enumerate(priority_order):
                if source.startswith(prefix):
                    return i
            return len(priority_order)

        bulunan_fiyatlar.sort(key=lambda x: get_priority(x))

        # En güvenilir fiyatı döndür
        selected_price = bulunan_fiyatlar[0][1]
        print(f"Fiyat bulundu: {selected_price} TL (Kaynak: {bulunan_fiyatlar[0][0]})")
        return selected_price

    print("Fiyat bulunamadı!")
    return None