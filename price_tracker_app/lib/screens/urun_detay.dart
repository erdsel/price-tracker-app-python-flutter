// Ürün Detay Sayfası - Fiyat geçmişi ve detaylı bilgiler

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../models/urun.dart';
import 'widgets/custom_app_bar.dart';

class UrunDetay extends StatefulWidget {
  final int urunId;

  const UrunDetay({super.key, required this.urunId});

  @override
  State<UrunDetay> createState() => _UrunDetayState();
}

class _UrunDetayState extends State<UrunDetay> {
  Urun? urun;
  List<dynamic> fiyatGecmisi = [];
  bool yukleniyor = true;

  @override
  void initState() {
    super.initState();
    detaylariYukle();
  }

  // Ürün detaylarını ve fiyat geçmişini yükle
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernSearchAppBar(
        title: 'Ürün Detayları',
        hintText: 'Ürün ara...',
        onMenuPressed: () {
          Navigator.pop(context);
        },
        onBellPressed: () {
          if (urun != null) {
            // URL'yi panoya kopyala
            Clipboard.setData(ClipboardData(text: urun!.url));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Link panoya kopyalandı'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      ),
      body: yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : urun == null
              ? const Center(child: Text('Ürün bulunamadı'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ürün başlığı
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                urun!.isim ?? 'Ürün ${urun!.id}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // URL
                              Row(
                                children: [
                                  const Icon(Icons.link,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      urun!.url,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Fiyat bilgileri
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Fiyat Bilgileri',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Güncel fiyat
                              if (urun!.sonFiyat != null)
                                _fiyatSatiri(
                                  'Güncel Fiyat:',
                                  '${urun!.sonFiyat!.toStringAsFixed(2)} TL',
                                  urun!.fiyatDustuMu()
                                      ? Colors.green
                                      : Colors.black87,
                                ),
                              // Önceki fiyat
                              if (urun!.oncekiFiyat != null)
                                _fiyatSatiri(
                                  'Önceki Fiyat:',
                                  '${urun!.oncekiFiyat!.toStringAsFixed(2)} TL',
                                  Colors.grey,
                                ),
                              // Fiyat değişimi
                              if (urun!.getFiyatDegisimi() != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: urun!.fiyatDustuMu()
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        urun!.fiyatDustuMu()
                                            ? Icons.arrow_downward
                                            : Icons.arrow_upward,
                                        size: 16,
                                        color: urun!.fiyatDustuMu()
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${urun!.getFiyatDegisimi()!.abs().toStringAsFixed(1)}% ${urun!.fiyatDustuMu() ? "düştü" : "arttı"}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: urun!.fiyatDustuMu()
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              // Son kontrol
                              if (urun!.sonKontrol != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'Son kontrol: ${_formatTarih(urun!.sonKontrol!)}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Fiyat geçmişi
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Fiyat Geçmişi',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (fiyatGecmisi.isEmpty)
                                const Text(
                                  'Henüz fiyat geçmişi yok',
                                  style: TextStyle(color: Colors.grey),
                                )
                              else
                                // Basit grafik gösterimi
                                Container(
                                  height: 200,
                                  child: CustomPaint(
                                    painter: FiyatGrafigi(fiyatGecmisi),
                                    child: Container(),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              // Fiyat listesi
                              if (fiyatGecmisi.isNotEmpty) ...[
                                const Divider(),
                                const Text(
                                  'Son Fiyat Değişimleri',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...fiyatGecmisi.take(10).map((gecmis) {
                                  final tarih =
                                      DateTime.parse(gecmis['tarih']);
                                  final fiyat = gecmis['fiyat'].toDouble();
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatTarih(tarih),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        Text(
                                          '${fiyat.toStringAsFixed(2)} TL',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _fiyatSatiri(String baslik, String deger, Color renk) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            baslik,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            deger,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: renk,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTarih(DateTime tarih) {
    // Tarih formatlama
    final simdi = DateTime.now();
    final fark = simdi.difference(tarih);

    if (fark.inDays == 0) {
      // Bugün
      return 'Bugün ${tarih.hour.toString().padLeft(2, '0')}:${tarih.minute.toString().padLeft(2, '0')}';
    } else if (fark.inDays == 1) {
      // Dün
      return 'Dün ${tarih.hour.toString().padLeft(2, '0')}:${tarih.minute.toString().padLeft(2, '0')}';
    } else if (fark.inDays < 7) {
      // Bu hafta
      return '${fark.inDays} gün önce';
    } else {
      // Eski tarih
      return '${tarih.day}.${tarih.month}.${tarih.year}';
    }
  }
}

// Basit fiyat grafiği çizimi
class FiyatGrafigi extends CustomPainter {
  final List<dynamic> fiyatlar;

  FiyatGrafigi(this.fiyatlar);

  @override
  void paint(Canvas canvas, Size size) {
    if (fiyatlar.isEmpty) return;

    // Fiyatları tersine çevir (eskiden yeniye)
    final tersiFiyatlar = fiyatlar.reversed.toList();

    // Min ve max fiyatları bul
    double minFiyat = double.infinity;
    double maxFiyat = double.negativeInfinity;

    for (var item in tersiFiyatlar) {
      final fiyat = item['fiyat'].toDouble();
      if (fiyat < minFiyat) minFiyat = fiyat;
      if (fiyat > maxFiyat) maxFiyat = fiyat;
    }

    // Grafik aralığını biraz genişlet
    final aralik = maxFiyat - minFiyat;
    if (aralik > 0) {
      minFiyat -= aralik * 0.1;
      maxFiyat += aralik * 0.1;
    } else {
      minFiyat -= 10;
      maxFiyat += 10;
    }

    // Çizim için paint nesneleri
    final linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // Grid çizgileri için
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    // Yatay grid çizgileri çiz
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
      final y = size.height -
          ((fiyat - minFiyat) / (maxFiyat - minFiyat)) * size.height;

      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Çizgiyi çiz
    canvas.drawPath(path, linePaint);

    // Noktaları çiz
    for (var point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }

    // Son fiyat etiketini çiz
    if (tersiFiyatlar.isNotEmpty) {
      final sonFiyat = tersiFiyatlar.last['fiyat'].toDouble();
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${sonFiyat.toStringAsFixed(2)} TL',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final lastPoint = points.last;
      textPainter.paint(
        canvas,
        Offset(
          lastPoint.dx - textPainter.width - 5,
          lastPoint.dy - textPainter.height - 5,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}