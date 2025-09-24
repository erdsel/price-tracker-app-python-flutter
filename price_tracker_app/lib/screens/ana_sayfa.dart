// Ana Sayfa - Ürün listesi ve yönetimi

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/urun.dart';
import '../services/api_service.dart';
import 'urun_detay.dart';
import 'widgets/custom_app_bar.dart';

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  // Ürün listesi
  List<Urun> urunler = [];
  bool yukleniyor = true;
  bool yenileniyor = false;

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında ürünleri yükle
    urunleriYukle();
  }

  // API'den ürünleri çek
  Future<void> urunleriYukle() async {
    try {
      final yuklenenurunler = await ApiService.urunleriGetir();
      setState(() {
        urunler = yuklenenurunler;
        yukleniyor = false;
      });
    } catch (e) {
      setState(() {
        yukleniyor = false;
      });
      // Hata mesajı göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ürünler yüklenemedi: $e')),
        );
      }
    }
  }

  // Ürün ekleme dialogu göster
  void urunEkleDialog() {
    final TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Yeni Ürün Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Takip etmek istediğiniz ürünün linkini yapıştırın:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'Ürün Linki',
                  hintText: 'https://...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 8),
              // Panoya yapıştır butonu
              TextButton.icon(
                onPressed: () async {
                  // Panodan metni al
                  ClipboardData? data =
                      await Clipboard.getData(Clipboard.kTextPlain);
                  if (data != null && data.text != null) {
                    urlController.text = data.text!;
                  }
                },
                icon: const Icon(Icons.paste),
                label: const Text('Panodan Yapıştır'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final url = urlController.text.trim();
                if (url.isNotEmpty) {
                  Navigator.of(context).pop();
                  // Ürünü ekle
                  await urunEkle(url);
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  // Yeni ürün ekle
  Future<void> urunEkle(String url) async {
    // Yükleniyor göstergesi
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Ürün ekleniyor...'),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      final sonuc = await ApiService.urunEkle(url);
      Navigator.of(context).pop(); // Yükleniyor dialogunu kapat

      // Başarı mesajı
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Ürün eklendi: ${sonuc['isim']} - ${sonuc['fiyat']} TL'),
          backgroundColor: Colors.green,
        ),
      );

      // Listeyi yenile
      urunleriYukle();
    } catch (e) {
      Navigator.of(context).pop(); // Yükleniyor dialogunu kapat

      // Hata mesajı
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Manuel fiyat kontrolü başlat
  Future<void> fiyatKontroluBaslat() async {
    setState(() {
      yenileniyor = true;
    });

    final basarili = await ApiService.fiyatKontroluBaslat();

    if (basarili) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fiyat kontrolü başlatıldı'),
          backgroundColor: Colors.blue,
        ),
      );

      // 5 saniye bekle ve listeyi yenile
      await Future.delayed(const Duration(seconds: 5));
      await urunleriYukle();
    }

    setState(() {
      yenileniyor = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernSearchAppBar(
        title: 'Fiyat Takip',
        hintText: 'Ürün ara...',
        onMenuPressed: () {
          // Menü işlemleri
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menü')),
          );
        },
        onSearchPressed: () {
          // Arama işlemleri
          // Mevcut ürünler arasında arama yapılabilir
        },
        onBellPressed: () {
          // Bildirimler
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bildirimler')),
          );
        },
        onChanged: (query) {
          // Arama metni değiştiğinde
          // İleride ürünleri filtrelemek için kullanılabilir
        },
      ),
      body: yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : urunler.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_cart_outlined,
                        size: 100,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Henüz ürün eklemediniz',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: urunEkleDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('İlk Ürünü Ekle'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: urunleriYukle,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: urunler.length,
                    itemBuilder: (context, index) {
                      final urun = urunler[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: urun.fiyatDustuMu()
                                ? Colors.green
                                : Colors.blue,
                            child: Icon(
                              urun.fiyatDustuMu()
                                  ? Icons.arrow_downward
                                  : Icons.shopping_bag,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            urun.isim ?? 'Ürün ${urun.id}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Fiyat bilgisi
                              if (urun.sonFiyat != null)
                                Row(
                                  children: [
                                    Text(
                                      '${urun.sonFiyat!.toStringAsFixed(2)} TL',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: urun.fiyatDustuMu()
                                            ? Colors.green
                                            : Colors.black87,
                                      ),
                                    ),
                                    if (urun.oncekiFiyat != null) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '${urun.oncekiFiyat!.toStringAsFixed(2)} TL',
                                        style: const TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                    if (urun.getFiyatDegisimi() != null) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '${urun.getFiyatDegisimi()!.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: urun.fiyatDustuMu()
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ],
                                )
                              else
                                const Text(
                                  'Fiyat bilgisi yok',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              // Son kontrol zamanı
                              if (urun.sonKontrol != null)
                                Text(
                                  'Son kontrol: ${_formatZaman(urun.sonKontrol!)}',
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'detay',
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline),
                                    SizedBox(width: 8),
                                    Text('Detaylar'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'sil',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Sil',
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) async {
                              if (value == 'detay') {
                                // Detay sayfasına git
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UrunDetay(urunId: urun.id!),
                                  ),
                                );
                              } else if (value == 'sil') {
                                // Silme onayı al
                                final onay = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Ürünü Sil'),
                                    content: const Text(
                                        'Bu ürünü takipten çıkarmak istediğinize emin misiniz?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('İptal'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red),
                                        child: const Text('Sil'),
                                      ),
                                    ],
                                  ),
                                );

                                if (onay == true) {
                                  await ApiService.urunSil(urun.id!);
                                  urunleriYukle();
                                }
                              }
                            },
                          ),
                          onTap: () {
                            // Detay sayfasına git
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UrunDetay(urunId: urun.id!),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Fiyat kontrolü butonu
          FloatingActionButton.small(
            heroTag: 'refresh',
            onPressed: yenileniyor ? null : fiyatKontroluBaslat,
            tooltip: 'Fiyatları Kontrol Et',
            backgroundColor: yenileniyor ? Colors.grey : Colors.pink.shade300,
            child: yenileniyor
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.refresh, size: 20),
          ),
          const SizedBox(height: 12),
          // Ürün ekleme butonu
          FloatingActionButton(
            heroTag: 'add',
            onPressed: urunEkleDialog,
            tooltip: 'Ürün Ekle',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  // Zamanı formatla
  String _formatZaman(DateTime zaman) {
    final simdi = DateTime.now();
    final fark = simdi.difference(zaman);

    if (fark.inMinutes < 1) {
      return 'Az önce';
    } else if (fark.inMinutes < 60) {
      return '${fark.inMinutes} dakika önce';
    } else if (fark.inHours < 24) {
      return '${fark.inHours} saat önce';
    } else {
      return '${fark.inDays} gün önce';
    }
  }
}