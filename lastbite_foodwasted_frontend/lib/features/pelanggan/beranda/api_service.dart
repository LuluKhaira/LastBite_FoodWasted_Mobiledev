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
    try {
      await _kirim(http.post(Uri.parse('$baseUrl/logout'),
          headers: await _headers(auth: true)));
    } finally {
      // token lokal SELALU dihapus, walau server tidak terjangkau
      (await SharedPreferences.getInstance()).remove('token');
    }
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
      int produkId, int qty, String metode,
      {String? catatan}) async {
    final r = await _kirim(http.post(Uri.parse('$baseUrl/pesanan'),
        headers: await _headers(auth: true),
        body: jsonEncode({
          'produk_id': produkId,
          'qty': qty,
          'metode': metode,
          if (catatan != null && catatan.trim().isNotEmpty)
            'catatan': catatan.trim(),
        })));
    return Map<String, dynamic>.from(_handle(r)['data']);
  }

  /// Tandai pesanan sudah diambil (status menunggu -> selesai).
  static Future<void> selesaikanPesanan(String kode) async {
    final r = await _kirim(http.post(Uri.parse('$baseUrl/pesanan/$kode/selesai'),
        headers: await _headers(auth: true)));
    _handle(r);
  }

  /// Beri bintang 1-5 untuk pesanan yang sudah selesai.
  static Future<void> beriNilai(String kode, int rating) async {
    final r = await _kirim(http.post(Uri.parse('$baseUrl/pesanan/$kode/rating'),
        headers: await _headers(auth: true),
        body: jsonEncode({'rating': rating})));
    _handle(r);
  }

  // ---------- PROFIL ----------
  static Future<Map<String, dynamic>> getProfil() async {
    final d = _handle(await _kirim(
        http.get(Uri.parse('$baseUrl/profil'), headers: await _headers(auth: true))));
    return Map<String, dynamic>.from(d['data']);
  }

  static Future<Map<String, dynamic>> updateProfil({
    required String name,
    String? phone,
  }) async {
    final r = await _kirim(http.put(Uri.parse('$baseUrl/profil'),
        headers: await _headers(auth: true),
        body: jsonEncode({
          'name': name,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        })));
    return Map<String, dynamic>.from(_handle(r)['data']);
  }

  // ---------- AKUN / KEAMANAN ----------
  /// [lama] boleh null bila akun belum punya kata sandi (daftar via OTP).
  static Future<void> ubahPassword({String? lama, required String baru}) async {
    final r = await _kirim(http.put(Uri.parse('$baseUrl/akun/password'),
        headers: await _headers(auth: true),
        body: jsonEncode({
          if (lama != null && lama.isNotEmpty) 'password_lama': lama,
          'password_baru': baru,
        })));
    _handle(r);
  }

  /// Cabut semua token KECUALI perangkat ini.
  static Future<void> keluarPerangkatLain() async {
    final r = await _kirim(http.post(Uri.parse('$baseUrl/akun/logout-lainnya'),
        headers: await _headers(auth: true)));
    _handle(r);
  }

  // ---------- ALAMAT ----------
  static Future<List<Map<String, dynamic>>> getAlamat() async {
    final d = _handle(await _kirim(
        http.get(Uri.parse('$baseUrl/alamat'), headers: await _headers(auth: true))));
    return List<Map<String, dynamic>>.from(d['data']);
  }

  /// [id] null = tambah baru, ada = ubah.
  static Future<void> simpanAlamat(Map<String, dynamic> data, {int? id}) async {
    final uri = Uri.parse(id == null ? '$baseUrl/alamat' : '$baseUrl/alamat/$id');
    final h = await _headers(auth: true);
    final body = jsonEncode(data);
    final r = await _kirim(
        id == null ? http.post(uri, headers: h, body: body) : http.put(uri, headers: h, body: body));
    _handle(r);
  }

  static Future<void> hapusAlamat(int id) async {
    final r = await _kirim(http.delete(Uri.parse('$baseUrl/alamat/$id'),
        headers: await _headers(auth: true)));
    _handle(r);
  }

  static Future<void> jadikanAlamatUtama(int id) async {
    final r = await _kirim(http.post(Uri.parse('$baseUrl/alamat/$id/utama'),
        headers: await _headers(auth: true)));
    _handle(r);
  }

  // ---------- MITRA FAVORIT ----------
  static Future<List<Map<String, dynamic>>> getMitraFavorit() async {
    final d = _handle(await _kirim(http.get(Uri.parse('$baseUrl/mitra-favorit'),
        headers: await _headers(auth: true))));
    return List<Map<String, dynamic>>.from(d['data']);
  }

  /// Apakah mitra dari produk ini sudah difavoritkan?
  static Future<bool> statusMitraFavorit(int produkId) async {
    final uri = Uri.parse('$baseUrl/mitra-favorit/status')
        .replace(queryParameters: {'produk_id': '$produkId'});
    final d = _handle(await _kirim(http.get(uri, headers: await _headers(auth: true))));
    return d['favorit'] == true;
  }

  /// Tambah / hapus mitra dari favorit. Mengembalikan status terbaru.
  static Future<bool> toggleMitraFavorit(int produkId) async {
    final r = await _kirim(http.post(Uri.parse('$baseUrl/mitra-favorit/toggle'),
        headers: await _headers(auth: true),
        body: jsonEncode({'produk_id': produkId})));
    return _handle(r)['favorit'] == true;
  }

  static Future<void> hapusMitraFavorit(int idMitra) async {
    final r = await _kirim(http.delete(Uri.parse('$baseUrl/mitra-favorit/$idMitra'),
        headers: await _headers(auth: true)));
    _handle(r);
  }

  // ---------- BANTUAN ----------
  /// Mengembalikan { data: [faq], kategori: [..], kontak: {..} }
  static Future<Map<String, dynamic>> getFaq({String? q, String? kategori}) async {
    final params = <String, String>{
      if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
      if (kategori != null && kategori.isNotEmpty) 'kategori': kategori,
    };
    final uri = Uri.parse('$baseUrl/faq').replace(queryParameters: params.isEmpty ? null : params);
    return Map<String, dynamic>.from(
        _handle(await _kirim(http.get(uri, headers: await _headers()))));
  }

  /// Kirim pesan ke Live Chat CS (disimpan di database, dibalas tim CS).
  static Future<Map<String, dynamic>> kirimBantuan(String pesan,
      {String kanal = 'live'}) async {
    final r = await _kirim(http.post(Uri.parse('$baseUrl/bantuan/pesan'),
        headers: await _headers(auth: true),
        body: jsonEncode({'pesan': pesan, 'kanal': kanal})));
    return Map<String, dynamic>.from(_handle(r));
  }

  static Future<List<Map<String, dynamic>>> getPesanBantuan() async {
    final d = _handle(await _kirim(http.get(Uri.parse('$baseUrl/bantuan/pesan'),
        headers: await _headers(auth: true))));
    return List<Map<String, dynamic>>.from(d['data']);
  }
}