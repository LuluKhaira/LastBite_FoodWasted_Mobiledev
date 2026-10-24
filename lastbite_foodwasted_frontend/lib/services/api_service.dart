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
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'phone': phoneNumber}),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('<-- [${response.statusCode}] $url: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        try {
          final data = jsonDecode(response.body);
          lastErrorMessage =
              data['message'] ?? 'Server error [${response.statusCode}]';
        } catch (_) {
          lastErrorMessage =
              'Server error [${response.statusCode}]: ${response.body}';
        }
        return false;
      }
    } catch (e, stack) {
      debugPrint('Error registerWhatsApp: $e\n$stack');
      lastErrorMessage =
          'Gagal terhubung ($e). Pastikan server aktif di $baseUrl';
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

  // Membaca file dari path (mobile/desktop) atau blob URL (web) sebagai bytes
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

      if (ktpPath.isNotEmpty) {
        request.files.add(await _filePart('foto_ktp', ktpPath));
      }
      if (npwpPath != null && npwpPath.isNotEmpty) {
        request.files.add(await _filePart('foto_npwp', npwpPath));
      }
      if (halalPath != null && halalPath.isNotEmpty) {
        request.files.add(await _filePart('sertifikat_halal', halalPath));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error Set Documents: $e');
      return false;
    }
  }

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
      return null;
    } catch (e) {
      debugPrint('Error getMitraDashboard: $e');
      return null;
    }
  }

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

  // ---------- MANAJEMEN PESANAN MITRA ----------
  static Future<Map<String, dynamic>> getMitraPesanan(
    String phoneNumber, {
    String tab = 'baru',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mitra/pesanan'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phoneNumber, 'tab': tab}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'ok': true,
          'tab': data['tab'] ?? tab,
          'mitra': data['mitra'] ?? {},
          'data': List<Map<String, dynamic>>.from(data['data'] ?? []),
        };
      }
      return {'ok': false, 'message': _pesanError(response), 'data': <Map<String, dynamic>>[]};
    } catch (e) {
      debugPrint('Error getMitraPesanan: $e');
      return {'ok': false, 'message': 'Gagal terhubung ke server.', 'data': <Map<String, dynamic>>[]};
    }
  }

  static Future<Map<String, dynamic>> tandaiPesananSiap(
    String phoneNumber,
    String kode,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mitra/pesanan/$kode/siap'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phoneNumber}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'ok': true,
          'message': data['message'] ?? 'Pesanan siap diambil.',
          'kode_ambil': data['kode_ambil'],
          'data': data['data'],
        };
      }
      return {'ok': false, 'message': data['message'] ?? _pesanError(response)};
    } catch (e) {
      debugPrint('Error tandaiPesananSiap: $e');
      return {'ok': false, 'message': 'Gagal menghubungi server.'};
    }
  }

  static Future<Map<String, dynamic>> verifikasiPengambilan(
    String phoneNumber,
    String pickupCode, {
    String? kode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mitra/pesanan/verify-pickup'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phoneNumber,
          'pickup_code': pickupCode,
          if (kode != null && kode.isNotEmpty) 'kode': kode,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'ok': true,
          'message': data['message'] ?? 'Pengambilan berhasil diverifikasi.',
          'pendapatan': data['pendapatan'] ?? 0,
          'saldo_terbaru': data['saldo_terbaru'],
          'data': data['data'],
        };
      }
      return {'ok': false, 'message': data['message'] ?? _pesanError(response)};
    } catch (e) {
      debugPrint('Error verifikasiPengambilan: $e');
      return {'ok': false, 'message': 'Gagal verifikasi pengambilan ke server.'};
    }
  }

  static Future<Map<String, dynamic>> tolakPesanan(
    String phoneNumber,
    String kode,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mitra/pesanan/$kode/tolak'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phoneNumber}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'ok': true, 'message': data['message'] ?? 'Pesanan berhasil ditolak.'};
      }
      return {'ok': false, 'message': data['message'] ?? _pesanError(response)};
    } catch (e) {
      debugPrint('Error tolakPesanan: $e');
      return {'ok': false, 'message': 'Gagal menolak pesanan.'};
    }
  }

  // ---------- MANAJEMEN PRODUK MITRA ----------
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
        final dynamic raw = decoded is Map
            ? (decoded['data'] ?? decoded)
            : decoded;
        if (raw is List) {
          return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
        return [];
      }
      return null;
    } catch (e) {
      debugPrint('Error getMitraProduk: $e');
      return null;
    }
  }

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
        body: jsonEncode({
          'phone': phoneNumber,
          'id': idProduk,
          'aktif': aktif,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error setProdukAktif: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> tambahProdukLengkap({
    required String phoneNumber,
    required String nama,
    required String deskripsi,
    required String tipe,
    required String kategori,
    required int hargaAsli,
    required int harga,
    required int stok,
    required String waktuMulai,
    required String waktuSelesai,
    required bool terbit,
    Uint8List? fotoBytes,
    String? fotoNama,
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
        'deskripsi': deskripsi,
        'tipe': tipe,
        'kategori': kategori,
        'harga_asli': '$hargaAsli',
        'harga': '$harga',
        'stok': '$stok',
        'kuota': '$stok',
        'waktu_mulai': waktuMulai,
        'waktu_selesai': waktuSelesai,
        'terbit': terbit ? '1' : '0',
      });

      if (fotoBytes != null) {
        var namaFile = (fotoNama == null || fotoNama.isEmpty)
            ? 'foto.jpg'
            : fotoNama;
        if (!namaFile.contains('.')) namaFile = '$namaFile.jpg';
        request.files.add(
          http.MultipartFile.fromBytes('foto', fotoBytes, filename: namaFile),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final b = jsonDecode(response.body);
        return {
          'ok': true,
          'message': '${b['message'] ?? 'Berhasil disimpan.'}',
        };
      }
      return {'ok': false, 'message': _pesanError(response)};
    } catch (e) {
      return {'ok': false, 'message': 'Tidak bisa terhubung ke server.'};
    }
  }

  static Future<Map<String, dynamic>> updateProdukLengkap({
    required String phoneNumber,
    required int idProduk,
    required String nama,
    required String deskripsi,
    required int hargaAsli,
    required int harga,
    required int stok,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mitra/produk/update'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phoneNumber,
          'id': idProduk,
          'nama': nama,
          'deskripsi': deskripsi,
          'harga_asli': hargaAsli,
          'harga': harga,
          'stok': stok,
        }),
      );

      if (response.statusCode == 200) {
        return {'ok': true, 'message': 'Produk berhasil diperbarui'};
      }
      return {'ok': false, 'message': _pesanError(response)};
    } catch (e) {
      return {'ok': false, 'message': 'Tidak bisa terhubung ke server.'};
    }
  }
  // ---------- LOGIN MITRA / PELANGGAN ----------
  static Future<Map<String, dynamic>> loginMitra(String id, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login-mitra'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'login': id, // Bisa berupa email atau nomor HP sesuai input form
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'ok': true,
          'data': data,
          'message': data['message'] ?? 'Login berhasil',
        };
      }
      return {
        'ok': false,
        'message': data['message'] ?? _pesanError(response),
      };
    } catch (e) {
      debugPrint('Error loginMitra: $e');
      return {
        'ok': false,
        'message': 'Gagal terhubung ke server. Pastikan backend aktif.',
      };
    }
  }
}