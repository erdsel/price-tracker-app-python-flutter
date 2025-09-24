// Modern Ürün Detay Sayfası - Ana tema ile uyumlu
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/urun.dart';

class ModernUrunDetay extends StatefulWidget {
  final int urunId;

  const ModernUrunDetay({super.key, required this.urunId});

  @override
  State<ModernUrunDetay> createState() => _ModernUrunDetayState();
}

class _ModernUrunDetayState extends State<ModernUrunDetay> {
  Urun? urun;
  List<dynamic> fiyatGecmisi = [];
  bool yukleniyor = true;

  @override
  void initState() {
    super.initState();
    detaylariYukle();
  }

  Future<void> detaylariYukle() async {
    try {
      final detaylar = await ApiService.urunDetayGetir(widget.urunId);
      setState(() {
        urun = Urun.fromJson(detaylar['urun']);
        fiyatGecmisi = detaylar['fiyat_gecmisi'] ?? [];
        yukleniyor = false;
      });
    } catch (e) {
      setState(() {
        yukleniyor = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Detaylar yüklenemedi: $e')),
        );
      }
    }
  }

  Future<void> favoriToggle() async {
    if (urun != null) {
      final yeniFavoriDurumu = await ApiService.favoriToggle(urun!.id!);
      setState(() {
        urun!.favori = yeniFavoriDurumu;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            yeniFavoriDurumu ? 'Favorilere eklendi' : 'Favorilerden çıkarıldı',
          ),
          backgroundColor: yeniFavoriDurumu ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      body: yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : urun == null
              ? const Center(child: Text('Ürün bulunamadı'))
              : SafeArea(
                  child: Column(
                    children: [
                      // Beyaz AppBar - Ana sayfa gibi
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.05,
                          vertical: 16,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.black87,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                Expanded(
                                  child: Text(
                                    'Ürün Detayları',
                                    style: GoogleFonts.poppins(
                                      fontSize: width * 0.055,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    urun!.favori ? Icons.favorite : Icons.favorite_border,
                                    color: urun!.favori ? const Color(0xFFFF3B7D) : Colors.grey,
                                  ),
                                  onPressed: favoriToggle,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Arama çubuğu yerine ürün adı
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.shopping_bag, color: Colors.grey, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      urun!.isim ?? 'Ürün ${urun!.id}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // İçerik
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(width * 0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ürün Bilgi Kartı
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Ürün başlığı ve link
                                    Row(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.shopping_bag,
                                            color: Colors.grey[400],
                                            size: 30,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                urun!.isim ?? 'Ürün ${urun!.id}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: width * 0.04,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              GestureDetector(
                                                onTap: () {
                                                  Clipboard.setData(ClipboardData(text: urun!.url));
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Link kopyalandı'),
                                                      duration: Duration(seconds: 1),
                                                    ),
                                                  );
                                                },
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.link, size: 14, color: Colors.grey[600]),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        urun!.url,
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 11,
                                                          color: Colors.grey[600],
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Fiyat Bilgileri Kartı
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Fiyat Bilgileri',
                                      style: GoogleFonts.poppins(
                                        fontSize: width * 0.045,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Güncel Fiyat:',
                                          style: GoogleFonts.poppins(
                                            fontSize: width * 0.035,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          '${urun!.sonFiyat?.toStringAsFixed(2) ?? "-"} TL',
                                          style: GoogleFonts.poppins(
                                            fontSize: width * 0.05,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFFFF3B7D),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (urun!.oncekiFiyat != null) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Önceki Fiyat:',
                                            style: GoogleFonts.poppins(
                                              fontSize: width * 0.035,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            '${urun!.oncekiFiyat!.toStringAsFixed(2)} TL',
                                            style: GoogleFonts.poppins(
                                              fontSize: width * 0.035,
                                              color: Colors.grey[600],
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      if (urun!.getFiyatDegisimi() != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: urun!.fiyatDustuMu()
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                urun!.fiyatDustuMu()
                                                    ? Icons.trending_down
                                                    : Icons.trending_up,
                                                size: 16,
                                                color: urun!.fiyatDustuMu()
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '% ${urun!.getFiyatDegisimi()!.abs().toStringAsFixed(1)} ${urun!.fiyatDustuMu() ? "düştü" : "arttı"}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: width * 0.032,
                                                  fontWeight: FontWeight.w500,
                                                  color: urun!.fiyatDustuMu()
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                    if (urun!.sonKontrol != null) ...[
                                      const Divider(height: 24),
                                      Row(
                                        children: [
                                          Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Son kontrol: ${_formatTarih(urun!.sonKontrol!)}',
                                            style: GoogleFonts.poppins(
                                              fontSize: width * 0.03,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Fiyat Geçmişi Kartı
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Fiyat Geçmişi',
                                          style: GoogleFonts.poppins(
                                            fontSize: width * 0.045,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        if (fiyatGecmisi.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFF3B7D).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${fiyatGecmisi.length} Kayıt',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFFFF3B7D),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    if (fiyatGecmisi.isEmpty)
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 32),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.show_chart,
                                                size: 50,
                                                color: Colors.grey[300],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Henüz fiyat geçmişi yok',
                                                style: GoogleFonts.poppins(
                                                  fontSize: width * 0.035,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    else ...[
                                      // Basit grafik
                                      SizedBox(
                                        height: 180,
                                        child: CustomPaint(
                                          painter: SimpleFiyatGrafigi(
                                            fiyatGecmisi,
                                            primaryColor: const Color(0xFFFF3B7D),
                                          ),
                                          child: Container(),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  String _formatTarih(DateTime tarih) {
    final simdi = DateTime.now();
    final fark = simdi.difference(tarih);

    if (fark.inDays == 0) {
      if (fark.inHours == 0) {
        if (fark.inMinutes == 0) {
          return 'Az önce';
        }
        return '${fark.inMinutes} dk önce';
      }
      return 'Bugün ${tarih.hour.toString().padLeft(2, '0')}:${tarih.minute.toString().padLeft(2, '0')}';
    } else if (fark.inDays == 1) {
      return 'Dün';
    } else if (fark.inDays < 7) {
      return '${fark.inDays} gün önce';
    } else {
      return '${tarih.day}.${tarih.month}.${tarih.year}';
    }
  }
}

// Basit fiyat grafiği
class SimpleFiyatGrafigi extends CustomPainter {
  final List<dynamic> fiyatlar;
  final Color primaryColor;

  SimpleFiyatGrafigi(this.fiyatlar, {this.primaryColor = const Color(0xFFFF3B7D)});

  @override
  void paint(Canvas canvas, Size size) {
    if (fiyatlar.isEmpty) return;

    final tersiFiyatlar = fiyatlar.reversed.toList();

    double minFiyat = double.infinity;
    double maxFiyat = double.negativeInfinity;

    for (var item in tersiFiyatlar) {
      final fiyat = item['fiyat'].toDouble();
      if (fiyat < minFiyat) minFiyat = fiyat;
      if (fiyat > maxFiyat) maxFiyat = fiyat;
    }

    final aralik = maxFiyat - minFiyat;
    if (aralik > 0) {
      minFiyat -= aralik * 0.1;
      maxFiyat += aralik * 0.1;
    } else {
      minFiyat -= 10;
      maxFiyat += 10;
    }

    // Çizgi için paint
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Nokta için paint
    final pointPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    // Grid için paint
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 1;

    // Yatay grid çizgileri
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Noktaları hesapla ve çiz
    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < tersiFiyatlar.length; i++) {
      final fiyat = tersiFiyatlar[i]['fiyat'].toDouble();
      final x = (i / (tersiFiyatlar.length - 1)) * size.width;
      final y = size.height - ((fiyat - minFiyat) / (maxFiyat - minFiyat)) * size.height;

      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Ana çizgi
    canvas.drawPath(path, linePaint);

    // Noktalar
    for (var point in points) {
      canvas.drawCircle(point, 4, Paint()..color = Colors.white);
      canvas.drawCircle(point, 4, pointPaint..style = PaintingStyle.stroke..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}