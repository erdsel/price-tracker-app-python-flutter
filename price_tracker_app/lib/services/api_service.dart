// API Servisi - Backend ile iletişimi yönetir

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/urun.dart';

class ApiService {
  // Backend API URL'i (emülatör için 10.0.2.2, gerçek cihaz için bilgisayarın IP'si)
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // Tüm ürünleri getir
  static Future<List<Urun>> urunleriGetir() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/urunler'));

      if (response.statusCode == 200) {
        // JSON'u decode et ve Urun listesine çevir
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Urun.fromJson(json)).toList();
      } else {
        throw Exception('Ürünler yüklenemedi');
      }
    } catch (e) {
      print('API Hatası: $e');
      throw Exception('Sunucuya bağlanılamadı');
    }
  }

  // Yeni ürün ekle
  static Future<Map<String, dynamic>> urunEkle(String url) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/urun/ekle'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'url': url}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['hata'] ?? 'Ürün eklenemedi');
      }
    } catch (e) {
      print('API Hatası: $e');
      throw Exception('Ürün eklenemedi: $e');
    }
  }

  // Ürün detaylarını getir (fiyat geçmişi dahil)
  static Future<Map<String, dynamic>> urunDetayGetir(int urunId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/urun/$urunId'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Ürün detayları yüklenemedi');
      }
    } catch (e) {
      print('API Hatası: $e');
      throw Exception('Sunucuya bağlanılamadı');
    }
  }

  // Ürünü sil
  static Future<bool> urunSil(int urunId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/urun/$urunId'));

      return response.statusCode == 200;
    } catch (e) {
      print('API Hatası: $e');
      return false;
    }
  }

  // Manuel fiyat kontrolü başlat
  static Future<bool> fiyatKontroluBaslat() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/kontrol/baslat'),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('API Hatası: $e');
      return false;
    }
  }

  // Favori durumunu değiştir
  static Future<bool> favoriToggle(int urunId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/urun/$urunId/favori'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['favori'] == 1;
      }
      return false;
    } catch (e) {
      print('API Hatası: $e');
      return false;
    }
  }

  // Favori ürünleri getir
  static Future<List<Urun>> favorileriGetir() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/favoriler'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Urun.fromJson(json)).toList();
      } else {
        throw Exception('Favoriler yüklenemedi');
      }
    } catch (e) {
      print('API Hatası: $e');
      throw Exception('Sunucuya bağlanılamadı');
    }
  }
}