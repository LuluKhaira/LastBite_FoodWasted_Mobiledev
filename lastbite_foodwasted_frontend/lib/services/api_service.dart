import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;
  static String? lastErrorMessage;

  static Future<bool> registerWhatsApp(String phoneNumber) async {
    lastErrorMessage = null;
    final url = Uri.parse('$baseUrl/mitra/register-phone');
    debugPrint('--> POST $url (phone: $phoneNumber)');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phoneNumber}),
      ).timeout(const Duration(seconds: 15));

      debugPrint('<-- [${response.statusCode}] $url: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        try {
          final data = jsonDecode(response.body);
          lastErrorMessage = data['message'] ?? 'Server error [${response.statusCode}]';
        } catch (_) {
          lastErrorMessage = 'Server error [${response.statusCode}]: ${response.body}';
        }
        return false;
      }
    } catch (e, stack) {
      debugPrint('Error registerWhatsApp: $e\n$stack');
      lastErrorMessage = 'Gagal terhubung ($e). Pastikan server aktif di $baseUrl';
      return false;
    }
  }

  static Future<bool> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mitra/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phoneNumber, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
  }

  static Future<bool> setPassword(String phoneNumber, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mitra/set-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phoneNumber, 'password': password}),
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error Set Password: $e');
      return false;
    }
  }

  static Future<bool> setBusinessCategory(
    String phoneNumber,
    String kategori,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mitra/set-business'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phoneNumber, 'kategori_usaha': kategori}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error Set Business: $e');
      return false;
    }
  }

  static Future<bool> setAddress(
    String phoneNumber,
    String namaUsaha,
    String alamat,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mitra/set-address'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phoneNumber,
          'nama_usaha': namaUsaha,
          'alamat': alamat,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error Set Address: $e');
      return false;
    }
  }

  // Membaca file dari path (mobile/desktop) atau blob URL (web) sebagai bytes,
  // sehingga aman dipakai di semua platform.
  static Future<http.MultipartFile> _filePart(String field, String path) async {
    final xfile = XFile(path);
    final bytes = await xfile.readAsBytes();

    var name = xfile.name;
    if (!name.contains('.')) {
      name = '$field.jpg';
    }

    return http.MultipartFile.fromBytes(field, bytes, filename: name);
  }

  static Future<bool> setDocuments({
    required String phoneNumber,
    required String ktpPath,
    String? npwpPath,
    String? halalPath,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/mitra/set-documents'),
      );

      request.headers['Accept'] = 'application/json';
      request.fields['phone'] = phoneNumber;

      // Lampirkan file KTP (Wajib)
      if (ktpPath.isNotEmpty) {
        request.files.add(await _filePart('foto_ktp', ktpPath));
      }

      // Lampirkan file NPWP (Opsional)
      if (npwpPath != null && npwpPath.isNotEmpty) {
        request.files.add(await _filePart('foto_npwp', npwpPath));
      }

      // Lampirkan file Sertifikat Halal (Opsional)
      if (halalPath != null && halalPath.isNotEmpty) {
        request.files.add(await _filePart('sertifikat_halal', halalPath));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error Set Documents: $e');
      return false;
    }
  }

  // Membaca status verifikasi mitra yang diputuskan admin di dashboard Laravel
  static Future<Map<String, dynamic>?> checkStatus(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mitra/check-status'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phoneNumber}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return Map<String, dynamic>.from(body['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Error Check Status: $e');
      return null;
    }
  }

  // Mengambil data dashboard mitra (info toko, status buka, jumlah pesanan, dll)
  // Rute Laravel-nya POST, jadi harus dipanggil dengan http.post (bukan get).
  static Future<Map<String, dynamic>?> getMitraDashboard(
    String phoneNumber,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mitra/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phoneNumber}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final data = jsonResponse['data'];
        if (data is Map) return Map<String, dynamic>.from(data);
        return null;
      }

      debugPrint(
        'getMitraDashboard gagal: ${response.statusCode} ${response.body}',
      );
      return null;
    } catch (e) {
      debugPrint('Error getMitraDashboard: $e');
      return null;
    }
  }

  // Mengambil pesan error pertama dari respons Laravel (422/403/dll)
  static String _pesanError(http.Response r) {
    try {
      final b = jsonDecode(r.body);
      if (b is Map) {
        final e = b['errors'];
        if (e is Map && e.isNotEmpty) {
          final f = e.values.first;
          if (f is List && f.isNotEmpty) return '${f.first}';
        }
        if (b['message'] != null) return '${b['message']}';
      }
    } catch (_) {}
    return 'Terjadi kesalahan (kode ${r.statusCode}).';
  }

  // Menyimpan produk baru. terbit=true -> tayang, terbit=false -> draf.
  // Mengembalikan {'ok': bool, 'message': String}
  static Future<Map<String, dynamic>> tambahProduk({
    required String phoneNumber,
    required String nama,
    required String kategori,
    required int hargaAsli,
    required int harga,
    required int stok,
    required String waktuSelesai, // format "HH:mm"
    required bool terbit,
    Uint8List? fotoBytes,
    String? fotoNama,
    String? gambarLama,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/mitra/produk'),
      );
      request.headers['Accept'] = 'application/json';
      request.fields.addAll({
        'phone': phoneNumber,
        'nama': nama,
        'kategori': kategori,
        'harga_asli': '$hargaAsli',
        'harga': '$harga',
        'stok': '$stok',
        'waktu_selesai': waktuSelesai,
        'terbit': terbit ? '1' : '0',
      });
      if (gambarLama != null && gambarLama.isNotEmpty) {
        request.fields['gambar_lama'] = gambarLama;
      }
      if (fotoBytes != null) {
        var namaFile = (fotoNama == null || fotoNama.isEmpty) ? 'foto.jpg' : fotoNama;
        if (!namaFile.contains('.')) namaFile = '$namaFile.jpg';
        request.files.add(
          http.MultipartFile.fromBytes('foto', fotoBytes, filename: namaFile),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final b = jsonDecode(response.body);
        return {'ok': true, 'message': '${b['message'] ?? 'Berhasil disimpan.'}'};
      }
      debugPrint('tambahProduk gagal: ${response.statusCode} ${response.body}');
      return {'ok': false, 'message': _pesanError(response)};
    } catch (e) {
      debugPrint('Error tambahProduk: $e');
      return {'ok': false, 'message': 'Tidak bisa terhubung ke server.'};
    }
  }

  // Produk terakhir mitra, dipakai untuk fitur "Salin dari" di form produk
  static Future<Map<String, dynamic>?> getTemplateProduk(
    String phoneNumber,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mitra/produk/template'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phoneNumber}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        if (data is Map) return Map<String, dynamic>.from(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getTemplateProduk: $e');
      return null;
    }
  }

  // Menyimpan status toko (buka/tutup) dari tombol di dashboard
  static Future<bool> setTokoStatus(String phoneNumber, bool buka) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mitra/toko-status'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phoneNumber, 'buka': buka}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error Set Status Toko: $e');
      return false;
    }
  }

  // Daftar semua produk milik mitra (untuk layar Produk Saya)
  static Future<List<Map<String, dynamic>>?> getMitraProduk(
    String phoneNumber,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mitra/produk/list'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phoneNumber}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final dynamic raw = decoded is Map ? (decoded['data'] ?? decoded) : decoded;
        if (raw is List) {
          return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
        return [];
      }

      debugPrint('getMitraProduk gagal: ${response.statusCode} ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Error getMitraProduk: $e');
      return null;
    }
  }

  // Mengubah sisa stok produk
  static Future<bool> updateStokProduk(
    String phoneNumber,
    int idProduk,
    int stok,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mitra/produk/stok'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phoneNumber, 'id': idProduk, 'stok': stok}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updateStokProduk: $e');
      return false;
    }
  }

  // Mengaktifkan / menonaktifkan produk
  static Future<bool> setProdukAktif(
    String phoneNumber,
    int idProduk,
    bool aktif,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mitra/produk/aktif'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phoneNumber, 'id': idProduk, 'aktif': aktif}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error setProdukAktif: $e');
      return false;
    }
  }
}