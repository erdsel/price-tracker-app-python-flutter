// Responsive Ana Sayfa - Her ekran boyutuna uyumlu
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/urun.dart';
import '../services/api_service.dart';
import 'urun_detay.dart';
import 'favoriler_sayfasi.dart';

class ResponsiveAnaSayfa extends StatefulWidget {
  const ResponsiveAnaSayfa({super.key});

  @override
  State<ResponsiveAnaSayfa> createState() => _ResponsiveAnaSayfaState();
}

class _ResponsiveAnaSayfaState extends State<ResponsiveAnaSayfa> {
  // State değişkenleri
  List<Urun> urunler = [];
  List<Urun> filtrelenmisUrunler = [];
  bool yukleniyor = true;
  bool yenileniyor = false;
  String aramaMetni = '';
  int secilenIndex = 0;

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
    // MediaQuery ile ekran boyutlarını al
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header - Responsive
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05, // %5 padding
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Üst bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Fiyat Takip',
                          style: GoogleFonts.poppins(
                            fontSize: width * 0.07, // Responsive font
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Arama çubuğu
                  SizedBox(
                    height: 48,
                    child: TextField(
                      onChanged: aramaYap,
                      decoration: InputDecoration(
                        hintText: 'Ürün ara...',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // İstatistik kartları - Yatay scroll
      

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
                                size: width * 0.2,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                aramaMetni.isNotEmpty
                                    ? 'Ürün bulunamadı'
                                    : 'Henüz ürün eklemediniz',
                                style: GoogleFonts.poppins(
                                  fontSize: width * 0.045,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: urunleriYukle,
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.05,
                              vertical: 8,
                            ),
                            itemCount: filtrelenmisUrunler.length,
                            itemBuilder: (context, index) {
                              final urun = filtrelenmisUrunler[index];
                              return _buildModernProductCard(urun, width);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar - Sadece 3 item
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
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Ana Sayfa
                _buildNavItem(Icons.home, 'Ana Sayfa', 0, true),

                // Yenileme butonu
                GestureDetector(
                  onTap: yenileniyor ? null : fiyatKontroluBaslat,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: yenileniyor ? Colors.grey : const Color(0xFFFF3B7D),
                      shape: BoxShape.circle,
                    ),
                    child: yenileniyor
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 24,
                          ),
                  ),
                ),

                // Ekleme butonu
                GestureDetector(
                  onTap: urunEkleDialog,
                  child: Container(
                    width: 48,
                    height: 48,
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

                // Favoriler
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FavorilerSayfasi(),
                      ),
                    ).then((_) => urunleriYukle());
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_outline,
                        color: Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Favoriler',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // İstatistik kartı - Responsive
  Widget _buildStatCard(String title, String value, IconData icon, Color color, double screenWidth) {
    return Container(
      width: screenWidth * 0.35, // Ekran genişliğinin %35'i
      padding: const EdgeInsets.all(12),
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
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Modern ürün kartı - Responsive
  Widget _buildModernProductCard(Urun urun, double screenWidth) {
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
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
              width: screenWidth * 0.18,
              height: screenWidth * 0.18,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.shopping_bag,
                color: Colors.grey[400],
                size: screenWidth * 0.08,
              ),
            ),
            const SizedBox(width: 12),

            // Ürün bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    urun.isim ?? 'Ürün ${urun.id}',
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.038,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${urun.sonFiyat?.toStringAsFixed(2) ?? "-"} TL',
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFF3B7D),
                            ),
                          ),
                        ),
                      ),
                      if (urun.oncekiFiyat != null) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${urun.oncekiFiyat!.toStringAsFixed(2)} TL',
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.032,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (urun.getFiyatDegisimi() != null)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
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
                            size: 12,
                            color: urun.fiyatDustuMu()
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${urun.getFiyatDegisimi()!.abs().toStringAsFixed(1)}%',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
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

            // Favori ve menü butonları
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    urun.favori ? Icons.favorite : Icons.favorite_border,
                    color: urun.favori ? const Color(0xFFFF3B7D) : Colors.grey,
                    size: 22,
                  ),
                  onPressed: () async {
                    final yeniFavoriDurumu = await ApiService.favoriToggle(urun.id!);
                    setState(() {
                      urun.favori = yeniFavoriDurumu;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          yeniFavoriDurumu
                              ? 'Favorilere eklendi'
                              : 'Favorilerden çıkarıldı',
                        ),
                        backgroundColor: yeniFavoriDurumu ? Colors.green : Colors.orange,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: Colors.grey, size: 20),
                  itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'sil',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text('Sil', style: TextStyle(fontSize: 14)),
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
        mainAxisAlignment: MainAxisAlignment.center,
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
              fontSize: 11,
              color: isSelected ? const Color(0xFFFF3B7D) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}