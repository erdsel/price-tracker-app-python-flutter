// Fiyat Takip Uygulaması - Ana Dosya
// Öğrenci Projesi - 2024

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/ana_sayfa_responsive.dart';

void main() {
  runApp(const FiyatTakipApp());
}

class FiyatTakipApp extends StatelessWidget {
  const FiyatTakipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fiyat Takip',
      debugShowCheckedModeBanner: false, // Debug bandını kaldır
      theme: ThemeData(
        // Tema ayarları
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Poppins fontunu tüm uygulamada kullan
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
          elevation: 2,
          // AppBar için de Poppins font
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      home: const ResponsiveAnaSayfa(),
    );
  }
}
