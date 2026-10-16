import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static Future<bool> registerWhatsApp(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mitra/register-phone'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phoneNumber}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error: $e');
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
}