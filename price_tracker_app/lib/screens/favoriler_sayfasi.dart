// Favoriler Sayfası
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/urun.dart';
import '../services/api_service.dart';
import 'urun_detay_modern.dart';

class FavorilerSayfasi extends StatefulWidget {
  const FavorilerSayfasi({super.key});

  @override
  State<FavorilerSayfasi> createState() => _FavorilerSayfasiState();
}

class _FavorilerSayfasiState extends State<FavorilerSayfasi> {
  List<Urun> favoriler = [];
  bool yukleniyor = true;

  @override
  void initState() {
    super.initState();
    favorileriYukle();
  }

  Future<void> favorileriYukle() async {
    try {
      final yuklenenFavoriler = await ApiService.favorileriGetir();
      setState(() {
        favoriler = yuklenenFavoriler;
        yukleniyor = false;
      });
    } catch (e) {
      setState(() {
        yukleniyor = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Favoriler yüklenemedi: $e')),
        );
      }
    }
  }

  Future<void> favoriyiKaldir(Urun urun) async {
    final basarili = await ApiService.favoriToggle(urun.id!);
    if (!basarili) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Favorilerden çıkarıldı'),
          backgroundColor: Colors.orange,
        ),
      );
      favorileriYukle();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Favorilerim',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : favoriler.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_outline,
                        size: width * 0.25,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz favori ürün yok',
                        style: GoogleFonts.poppins(
                          fontSize: width * 0.045,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Beğendiğiniz ürünleri favorilere ekleyin',
                        style: GoogleFonts.poppins(
                          fontSize: width * 0.035,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: favorileriYukle,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.05,
                      vertical: 16,
                    ),
                    itemCount: favoriler.length,
                    itemBuilder: (context, index) {
                      final urun = favoriler[index];
                      return _buildFavoriCard(urun, width);
                    },
                  ),
                ),
    );
  }

  Widget _buildFavoriCard(Urun urun, double screenWidth) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ModernUrunDetay(urunId: urun.id!),
          ),
        ).then((_) => favorileriYukle());
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
                color: const Color(0xFFFF3B7D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.favorite,
                color: Color(0xFFFF3B7D),
                size: 30,
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

            // Favoriden çıkar butonu
            IconButton(
              icon: const Icon(
                Icons.favorite,
                color: Color(0xFFFF3B7D),
              ),
              onPressed: () async {
                await favoriyiKaldir(urun);
              },
            ),
          ],
        ),
      ),
    );
  }
}