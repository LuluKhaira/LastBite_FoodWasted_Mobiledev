// pubspec.yaml: http: ^1.2.0   shared_preferences: ^2.2.0
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  /// Otomatis: Chrome/iOS/desktop -> 127.0.0.1 | Emulator Android -> 10.0.2.2
  /// HP fisik: ganti manual ke IP laptop, mis. 'http://192.168.1.10:8000/api'
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  static const _timeout = Duration(seconds: 12);

  static Future<String?> _token() async =>
      (await SharedPreferences.getInstance()).getString('token');

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final h = {'Accept': 'application/json', 'Content-Type': 'application/json'};
    if (auth) {
      final t = await _token();
      if (t != null) h['Authorization'] = 'Bearer $t';
    }
    return h;
  }

  static dynamic _handle(http.Response r) {
    final body = r.body.isEmpty ? {} : jsonDecode(r.body);
    if (r.statusCode >= 200 && r.statusCode < 300) return body;

    var msg = 'Terjadi kesalahan';
    if (body is Map) {
      // Error validasi Laravel (422): ambil pesan field pertama
      final errs = body['errors'];
      if (errs is Map && errs.isNotEmpty && errs.values.first is List && (errs.values.first as List).isNotEmpty) {
        msg = (errs.values.first as List).first.toString();
      } else if (body['message'] != null) {
        msg = body['message'].toString();
      }
    }
    throw Exception(msg);
  }

  static Future<http.Response> _kirim(Future<http.Response> req) async {
    try {
      return await req.timeout(_timeout);
    } on Exception {
      throw Exception(
          'Tidak bisa terhubung ke server. Pastikan "php artisan serve" menyala.');
    }
  }

  // ---------- AUTH (email + sandi) ----------
  static Future<void> register(String name, String email, String password) async {
    final r = await _kirim(http.post(Uri.parse('$baseUrl/register'),
        headers: await _headers(),
        body: jsonEncode({'name': name, 'email': email, 'password': password})));
    final d = _handle(r);
    (await SharedPreferences.getInstance()).setString('token', d['token']);
  }

  static Future<void> login(String email, String password) async {
    final r = await _kirim(http.post(Uri.parse('$baseUrl/login'),
        headers: await _headers(),
        body: jsonEncode({'email': email, 'password': password})));
    final d = _handle(r);
    (await SharedPreferences.getInstance()).setString('token', d['token']);
  }

  static Future<void> logout() async {
    await _kirim(http.post(Uri.parse('$baseUrl/logout'),
        headers: await _headers(auth: true)));
    (await SharedPreferences.getInstance()).remove('token');
  }

  // ---------- AUTH (WhatsApp OTP via Fonnte) ----------
  /// Kirim OTP pendaftaran. Akun baru dibuat di server setelah OTP benar.
  static Future<void> daftarOtp({
    required String name,
    required String phone, // format 62812xxxx
    String? email,
    String? password,
  }) async {
    final r = await _kirim(http.post(Uri.parse('$baseUrl/auth/register-phone'),
        headers: await _headers(),
        body: jsonEncode({
          'name': name,
          'phone': phone,
          if (email != null && email.isNotEmpty) 'email': email,
          if (password != null && password.isNotEmpty) 'password': password,
        })));
    _handle(r);
  }

  /// Kirim OTP untuk masuk (nomor harus sudah terdaftar).
  static Future<void> masukOtp(String phone) async {
    final r = await _kirim(http.post(Uri.parse('$baseUrl/auth/login-phone'),
        headers: await _headers(), body: jsonEncode({'phone': phone})));
    _handle(r);
  }

  static Future<void> kirimUlangOtp(String phone, String purpose) async {
    final r = await _kirim(http.post(Uri.parse('$baseUrl/auth/resend-otp'),
        headers: await _headers(),
        body: jsonEncode({'phone': phone, 'purpose': purpose})));
    _handle(r);
  }

  /// purpose: 'register' | 'login'. Jika benar, token disimpan.
  static Future<void> verifikasiOtp(String phone, String code, String purpose) async {
    final r = await _kirim(http.post(Uri.parse('$baseUrl/auth/verify-otp'),
        headers: await _headers(),
        body: jsonEncode({'phone': phone, 'code': code, 'purpose': purpose})));
    final d = _handle(r);
    (await SharedPreferences.getInstance()).setString('token', d['token']);
  }

  // ---------- PRODUK ----------
  /// Rentang harga dari label di FilterPreferensiScreen -> (min, max)
  static (int?, int?) _rentangHarga(String? label) {
    switch (label) {
      case 'Di bawah Rp25.000':
        return (null, 24999);
      case 'Rp25.000–Rp50.000':
        return (25000, 50000);
      case 'Di atas Rp50.000':
        return (50001, null);
      default:
        return (null, null);
    }
  }

  /// tipe: 'dimakan' atau 'ternak'.
  /// [filter] = hasil Navigator.pop dari FilterPreferensiScreen.
  static Future<List<Map<String, dynamic>>> getProduk({
    required String tipe,
    List<String>? kategori,
    String? q,
    Map<String, dynamic>? filter,
    double? lat,
    double? lng,
  }) async {
    final params = <String, dynamic>{'tipe': tipe};

    if (kategori != null && kategori.isNotEmpty) params['kategori[]'] = kategori;
    if (q != null && q.trim().isNotEmpty) params['q'] = q.trim();
    if (lat != null && lng != null) {
      params['lat'] = '$lat';
      params['lng'] = '$lng';
    }

    if (filter != null) {
      params['urutan'] = '${filter['urutan'] ?? 'Rekomendasi'}';
      if (lat != null && lng != null) {
        params['jarak'] = '${(filter['jarak'] as num?)?.toInt() ?? 10}';
      }
      if (filter['tersedia'] == true) params['tersedia'] = '1';
      final (hMin, hMax) = _rentangHarga(filter['harga'] as String?);
      if (hMin != null) params['harga_min'] = '$hMin';
      if (hMax != null) params['harga_max'] = '$hMax';
    }

    final uri = Uri.parse('$baseUrl/produk').replace(queryParameters: params);
    final d = _handle(await _kirim(http.get(uri, headers: await _headers())));
    return List<Map<String, dynamic>>.from(d['data']);
  }

  // ---------- PESANAN ----------
  static Future<List<Map<String, dynamic>>> getPesanan() async {
    final d = _handle(await _kirim(
        http.get(Uri.parse('$baseUrl/pesanan'), headers: await _headers(auth: true))));
    return List<Map<String, dynamic>>.from(d['data']);
  }

  static Future<Map<String, dynamic>> buatPesanan(
      int produkId, int qty, String metode) async {
    final r = await _kirim(http.post(Uri.parse('$baseUrl/pesanan'),
        headers: await _headers(auth: true),
        body: jsonEncode({'produk_id': produkId, 'qty': qty, 'metode': metode})));
    return Map<String, dynamic>.from(_handle(r)['data']);
  }
}
