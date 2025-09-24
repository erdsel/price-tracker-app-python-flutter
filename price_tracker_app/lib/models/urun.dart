// Ürün modeli - API'den gelen ürün verisini temsil eder

class Urun {
  final int? id;
  final String url;
  final String? isim;
  final double? sonFiyat;
  final double? oncekiFiyat;
  final DateTime? sonKontrol;
  final bool aktif;
  bool favori;

  Urun({
    this.id,
    required this.url,
    this.isim,
    this.sonFiyat,
    this.oncekiFiyat,
    this.sonKontrol,
    this.aktif = true,
    this.favori = false,
  });

  // JSON'dan Urun objesi oluştur
  factory Urun.fromJson(Map<String, dynamic> json) {
    return Urun(
      id: json['id'],
      url: json['url'],
      isim: json['isim'],
      sonFiyat: json['son_fiyat']?.toDouble(),
      oncekiFiyat: json['onceki_fiyat']?.toDouble(),
      sonKontrol: json['son_kontrol'] != null
          ? DateTime.parse(json['son_kontrol'])
          : null,
      aktif: json['aktif'] == 1,
      favori: (json['favori'] ?? 0) == 1,
    );
  }

  // Urun objesini JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'isim': isim,
      'son_fiyat': sonFiyat,
      'onceki_fiyat': oncekiFiyat,
      'son_kontrol': sonKontrol?.toIso8601String(),
      'aktif': aktif ? 1 : 0,
    };
  }

  // Fiyat değişimini hesapla (yüzde olarak)
  double? getFiyatDegisimi() {
    if (sonFiyat != null && oncekiFiyat != null && oncekiFiyat! > 0) {
      return ((sonFiyat! - oncekiFiyat!) / oncekiFiyat!) * 100;
    }
    return null;
  }

  // Fiyat düştü mü kontrol et
  bool fiyatDustuMu() {
    if (sonFiyat != null && oncekiFiyat != null) {
      return sonFiyat! < oncekiFiyat!;
    }
    return false;
  }
}