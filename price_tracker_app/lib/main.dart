// Fiyat Takip Uygulaması - Ana Dosya
// Öğrenci Projesi - 2024

import 'package:flutter/material.dart';
import 'screens/ana_sayfa.dart';

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
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const AnaSayfa(),
    );
  }
}
