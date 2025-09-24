// Modern Ana Sayfa Tasarımı
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/urun.dart';
import '../services/api_service.dart';
import 'urun_detay.dart';

class ModernAnaSayfa extends StatefulWidget {
  const ModernAnaSayfa({super.key});

  @override
  State<ModernAnaSayfa> createState() => _ModernAnaSayfaState();
}

class _ModernAnaSayfaState extends State<ModernAnaSayfa> {
  // State değişkenleri
  List<Urun> urunler = [];
  List<Urun> filtrelenmisUrunler = [];
  bool yukleniyor = true;
  bool yenileniyor = false;
  String aramaMetni = '';
  int secilenIndex = 0; // Bottom nav için

  @override
  void initState() {
    super.initState();
    urunleriYukle();
  }

  // API'den ürünleri çek
  Future<void> urunleriYukle() async {
    try {
      final yuklenenurunler = await ApiService.urunleriGetir();
      setState(() {
        urunler = yuklenenurunler;
        filtrelenmisUrunler = yuklenenurunler;
        yukleniyor = false;
      });
    } catch (e) {
      setState(() {
        yukleniyor = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ürünler yüklenemedi: $e')),
        );
      }
    }
  }

  // Arama fonksiyonu
  void aramaYap(String metin) {
    setState(() {
      aramaMetni = metin;
      if (metin.isEmpty) {
        filtrelenmisUrunler = urunler;
      } else {
        filtrelenmisUrunler = urunler
            .where((urun) =>
                (urun.isim ?? '').toLowerCase().contains(metin.toLowerCase()) ||
                urun.url.toLowerCase().contains(metin.toLowerCase()))
            .toList();
      }
    });
  }

  // Ürün ekleme dialogu
  void urunEkleDialog() {
    final TextEditingController urlController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Yeni Ürün Ekle',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Takip etmek istediğiniz ürünün linkini yapıştırın',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    labelText: 'Ürün Linki',
                    hintText: 'https://...',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.link),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.paste),
                      onPressed: () async {
                        ClipboardData? data =
                            await Clipboard.getData(Clipboard.kTextPlain);
                        if (data != null && data.text != null) {
                          urlController.text = data.text!;
                        }
                      },
                    ),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'İptal',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          final url = urlController.text.trim();
                          if (url.isNotEmpty) {
                            Navigator.of(context).pop();
                            await urunEkle(url);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF3B7D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Ekle',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // Yeni ürün ekle
  Future<void> urunEkle(String url) async {
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
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Ürün eklendi: ${sonuc['isim']} - ${sonuc['fiyat']} TL'),
          backgroundColor: Colors.green,
        ),
      );

      urunleriYukle();
    } catch (e) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Manuel fiyat kontrolü
  Future<void> fiyatKontroluBaslat() async {
    setState(() {
      yenileniyor = true;
    });

    final basarili = await ApiService.fiyatKontroluBaslat();

    if (basarili) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fiyat kontrolü başlatıldı'),
          backgroundColor: Color(0xFFFF3B7D),
        ),
      );

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
      backgroundColor: const Color(0xFFF5F5F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Üst bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fiyat Takip',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            onPressed: () {},
                          ),
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFFFF3B7D),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Arama çubuğu
                  TextField(
                    onChanged: aramaYap,
                    decoration: InputDecoration(
                      hintText: 'Ürün ara...',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey[400],
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ],
              ),
            ),

            // İstatistik kartları
          
            // Ürün listesi
            Expanded(
              child: yukleniyor
                  ? const Center(child: CircularProgressIndicator())
                  : filtrelenmisUrunler.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 100,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                aramaMetni.isNotEmpty
                                    ? 'Ürün bulunamadı'
                                    : 'Henüz ürün eklemediniz',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: urunleriYukle,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: filtrelenmisUrunler.length,
                            itemBuilder: (context, index) {
                              final urun = filtrelenmisUrunler[index];
                              return _buildModernProductCard(urun);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Ana Sayfa', 0, true),
                _buildNavItem(Icons.analytics_outlined, 'Analiz', 1, false),
                GestureDetector(
                  onTap: urunEkleDialog,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF3B7D),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                _buildNavItem(Icons.bookmark_outline, 'Favoriler', 2, false),
                _buildNavItem(Icons.settings_outlined, 'Ayarlar', 3, false),
              ],
            ),
          ),
        ),
      ),

      // Yenileme butonu
      floatingActionButton: yenileniyor
          ? null
          : FloatingActionButton.small(
              onPressed: fiyatKontroluBaslat,
              backgroundColor: Colors.white,
              elevation: 4,
              child: Icon(
                Icons.refresh,
                color: yenileniyor ? Colors.grey : const Color(0xFFFF3B7D),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }

  // İstatistik kartı widget'ı
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 140,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Modern ürün kartı
  Widget _buildModernProductCard(Urun urun) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UrunDetay(urunId: urun.id!),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
        child: Row(
          children: [
            // Ürün görseli placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.shopping_bag,
                color: Colors.grey[400],
                size: 40,
              ),
            ),
            const SizedBox(width: 16),

            // Ürün bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    urun.isim ?? 'Ürün ${urun.id}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${urun.sonFiyat?.toStringAsFixed(2) ?? "-"} TL',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF3B7D),
                        ),
                      ),
                      if (urun.oncekiFiyat != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${urun.oncekiFiyat!.toStringAsFixed(2)} TL',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (urun.getFiyatDegisimi() != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: urun.fiyatDustuMu()
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            urun.fiyatDustuMu()
                                ? Icons.trending_down
                                : Icons.trending_up,
                            size: 14,
                            color: urun.fiyatDustuMu()
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${urun.getFiyatDegisimi()!.abs().toStringAsFixed(1)}%',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: urun.fiyatDustuMu()
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Menü butonu
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'sil',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Sil'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 'sil') {
                  final onay = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Ürünü Sil'),
                      content: const Text('Bu ürünü takipten çıkarmak istediğinize emin misiniz?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('İptal'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
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
          ],
        ),
      ),
    );
  }

  // Bottom nav item
  Widget _buildNavItem(IconData icon, String label, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          secilenIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFFF3B7D) : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isSelected ? const Color(0xFFFF3B7D) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

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