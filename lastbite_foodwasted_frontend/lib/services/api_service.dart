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
        Uri.parse('$baseUrl/mitra/verify-otp'), // Pastikan ini tujuannya
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
      return {
        'ok': false,
        'message': _pesanError(response),
        'data': <Map<String, dynamic>>[],
      };
    } catch (e) {
      debugPrint('Error getMitraPesanan: $e');
      return {
        'ok': false,
        'message': 'Gagal terhubung ke server.',
        'data': <Map<String, dynamic>>[],
      };
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
      return {
        'ok': false,
        'message': 'Gagal verifikasi pengambilan ke server.',
      };
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
        return {
          'ok': true,
          'message': data['message'] ?? 'Pesanan berhasil ditolak.',
        };
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

  static Future<Map<String, dynamic>> setProdukAktif(
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
      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'ok': true,
          'message': body['message'] ?? 'Berhasil mengubah status produk',
        };
      }
      return {
        'ok': false,
        'message': body['message'] ?? _pesanError(response),
      };
    } catch (e) {
      debugPrint('Error setProdukAktif: $e');
      return {
        'ok': false,
        'message': 'Gagal terhubung ke server. Pastikan backend aktif.',
      };
    }
  }

  /// Jam operasional toko per hari (hari: 1 = Senin ... 7 = Minggu).
  /// Mengembalikan list kosong bila belum diatur, null bila gagal memuat.
  static Future<List<Map<String, dynamic>>?> getJamOperasional(
    String phoneNumber,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mitra/jam-buka'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phoneNumber}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final dynamic raw = decoded is Map ? decoded['data'] : null;
        if (raw is List) {
          return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
        return [];
      }
      return null;
    } catch (e) {
      debugPrint('Error getJamOperasional: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> simpanJamOperasional({
    required String phoneNumber,
    required List<Map<String, dynamic>> jam,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mitra/jam-buka/simpan'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phoneNumber, 'jam': jam}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final b = jsonDecode(response.body);
        return {'ok': true, 'message': '${b['message'] ?? 'Berhasil disimpan.'}'};
      }
      return {'ok': false, 'message': _pesanError(response)};
    } catch (e) {
      return {'ok': false, 'message': 'Tidak bisa terhubung ke server.'};
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
    required String kadaluarsa,
    required bool terbit,
    bool bersediaDialihkan = false,
    String? targetKategoriPengalihan,
    double? perkiraanBeratPerPaket,
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
        'kategori_asli': tipe == 'dimakan' ? 'Konsumsi Manusia' : 'Pakan / Kompos',
        'harga_asli': '$hargaAsli',
        'harga': '$harga',
        'stok': '$stok',
        'kuota': '$stok',
        'waktu_mulai': waktuMulai,
        'waktu_selesai': waktuSelesai,
        'kadaluarsa': kadaluarsa,
        'terbit': terbit ? '1' : '0',
        'bersedia_dialihkan': bersediaDialihkan ? '1' : '0',
      });

      if (bersediaDialihkan && targetKategoriPengalihan != null) {
        request.fields['target_kategori_pengalihan'] = targetKategoriPengalihan;
      }
      if (bersediaDialihkan && perkiraanBeratPerPaket != null) {
        request.fields['perkiraan_berat_per_paket'] =
            perkiraanBeratPerPaket.toString();
      }

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
    bool? bersediaDialihkan,
    String? targetKategoriPengalihan,
    double? perkiraanBeratPerPaket,
  }) async {
    try {
      final body = <String, dynamic>{
        'phone': phoneNumber,
        'id': idProduk,
        'nama': nama,
        'deskripsi': deskripsi,
        'harga_asli': hargaAsli,
        'harga': harga,
        'stok': stok,
      };

      if (bersediaDialihkan != null) {
        body['bersedia_dialihkan'] = bersediaDialihkan;
        body['target_kategori_pengalihan'] = targetKategoriPengalihan;
        body['perkiraan_berat_per_paket'] = perkiraanBeratPerPaket;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/mitra/produk/update'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return {'ok': true, 'message': 'Produk berhasil diperbarui'};
      }
      return {'ok': false, 'message': _pesanError(response)};
    } catch (e) {
      return {'ok': false, 'message': 'Tidak bisa terhubung ke server.'};
    }
  }

  /// Mengambil opsi kategori tujuan pengalihan pakan / kompos
  static Future<Map<String, dynamic>?> getOpsiPengalihan({String? kategori}) async {
    try {
      final uri = Uri.parse('$baseUrl/produk/opsi-pengalihan').replace(
        queryParameters: kategori != null && kategori.isNotEmpty
            ? {'kategori': kategori}
            : null,
      );
      final response = await http.get(uri, headers: {'Accept': 'application/json'});
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error getOpsiPengalihan: $e');
      return null;
    }
  }

  /// Konfirmasi pengalihan produk yang melewati batas penjualan oleh mitra
  static Future<Map<String, dynamic>> konfirmasiPengalihan({
    required String phoneNumber,
    required int idProduk,
    required String aksi, // 'alihkan' | 'buang'
    double? beratAktual,
    String? targetKategori,
    int? hargaPerKg,
    String? catatan,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mitra/produk/konfirmasi-pengalihan'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phoneNumber,
          'id': idProduk,
          'aksi': aksi,
          'berat_aktual': beratAktual,
          'target_kategori': targetKategori,
          if (hargaPerKg != null) 'harga_per_kg': hargaPerKg,
          'catatan': catatan,
        }),
      );

      final b = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'ok': true,
          'message': b['message'] ?? 'Berhasil diproses.',
          'data': b['data'],
        };
      }
      return {'ok': false, 'message': b['message'] ?? _pesanError(response)};
    } catch (e) {
      return {'ok': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // ---------- LOGIN MITRA / PELANGGAN ----------
  static Future<Map<String, dynamic>> loginMitra(
    String id,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/login-mitra',
        ), // Pastikan URL sesuai endpoint route Laravel (/login-mitra)
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'identifier': id, // Diubah dari 'login' menjadi 'identifier' sesuai validasi Laravel
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
      return {'ok': false, 'message': data['message'] ?? _pesanError(response)};
    } catch (e) {
      debugPrint('Error loginMitra: $e');
      return {
        'ok': false,
        'message': 'Gagal terhubung ke server. Pastikan backend aktif.',
      };
    }
  }

  // ---------- REGISTER / PENDAFTARAN AKUN ----------
  static Future<Map<String, dynamic>> register({
    required String name,
    required String identifier,
    required String password,
  }) async {
    try {
      final isEmail = identifier.contains('@');

      // Jika user menginput HP, buatkan format email sementara agar pass validasi Laravel
      final String emailValue = isEmail
          ? identifier
          : '${identifier.replaceAll(RegExp(r'\D'), '')}@lastbite.com';
      final String phoneValue = isEmail ? '' : identifier;

      final bodyData = {
        'name': name,
        'email': emailValue, // Memastikan field 'email' selalu terisi
        'phone': phoneValue,
        'password': password,
        'password_confirmation': password,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(bodyData),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'ok': true,
          'data': data,
          'message': data['message'] ?? 'Pendaftaran berhasil',
        };
      }
      return {'ok': false, 'message': data['message'] ?? _pesanError(response)};
    } catch (e) {
      debugPrint('Error register: $e');
      return {
        'ok': false,
        'message': 'Gagal terhubung ke server. Pastikan backend aktif.',
      };
    }
  }

  // ---------- VERIFIKASI OTP (MITRA / PELANGGAN) ----------
  static Future<bool> verifikasiOtp(
    String phoneNumber,
    String otp,
    String purpose,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/mitra/verify-otp',
        ), // Mengarah ke endpoint verifikasi OTP mitra yang benar
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phoneNumber,
          'otp': otp,
          'purpose': purpose,
        }),
      );

      debugPrint('<-- [${response.statusCode}] verify-otp: ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error verifikasiOtp: $e');
      return false;
    }
  }

  // ---------- KIRIM ULANG OTP ----------
  static Future<bool> kirimUlangOtp(String phoneNumber, String purpose) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/mitra/register-phone',
        ), // Memicu ulang pengiriman OTP via WhatsApp
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phoneNumber, 'purpose': purpose}),
      );

      debugPrint(
        '<-- [${response.statusCode}] kirimUlangOtp: ${response.body}',
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error kirimUlangOtp: $e');
      return false;
    }
  }

  // ======================================================================
  // AUTH PEMBELI (WhatsApp OTP) -> endpoint /auth/* (AuthController)
  // Terpisah dari alur mitra (/mitra/*) supaya data masuk ke tabel users.
  // ======================================================================
  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Kirim OTP pendaftaran pembeli. Akun dibuat di server SETELAH OTP benar.
  static Future<bool> registerPhonePembeli({
    required String name,
    required String phone,
    String? password,
  }) async {
    lastErrorMessage = null;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register-phone'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'name': name,
          'phone': phone,
          if (password != null && password.isNotEmpty) 'password': password,
        }),
      );
      debugPrint('<-- [${response.statusCode}] register-phone: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) return true;
      lastErrorMessage = _pesanError(response);
      return false;
    } catch (e) {
      debugPrint('Error registerPhonePembeli: $e');
      lastErrorMessage = 'Gagal terhubung ke server. Pastikan backend aktif.';
      return false;
    }
  }

  /// Verifikasi OTP pembeli. Mengembalikan {'ok': bool, 'message': String, 'data': ...}
  static Future<Map<String, dynamic>> verifikasiOtpPembeli(
    String phone,
    String code,
    String purpose,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: _jsonHeaders,
        body: jsonEncode({'phone': phone, 'code': code, 'purpose': purpose}),
      );
      debugPrint('<-- [${response.statusCode}] auth/verify-otp: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'ok': true,
          'data': data,
          'message': (data is Map ? data['message'] : null) ?? 'Berhasil',
        };
      }
      return {'ok': false, 'message': _pesanError(response)};
    } catch (e) {
      debugPrint('Error verifikasiOtpPembeli: $e');
      return {
        'ok': false,
        'message': 'Gagal terhubung ke server. Pastikan backend aktif.',
      };
    }
  }

  /// Kirim ulang OTP pembeli (purpose: 'register' atau 'login').
  static Future<bool> kirimUlangOtpPembeli(String phone, String purpose) async {
    lastErrorMessage = null;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/resend-otp'),
        headers: _jsonHeaders,
        body: jsonEncode({'phone': phone, 'purpose': purpose}),
      );
      debugPrint('<-- [${response.statusCode}] auth/resend-otp: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) return true;
      lastErrorMessage = _pesanError(response);
      return false;
    } catch (e) {
      debugPrint('Error kirimUlangOtpPembeli: $e');
      lastErrorMessage = 'Gagal terhubung ke server. Pastikan backend aktif.';
      return false;
    }
  }

  /// Login PEMBELI (nomor HP atau email + kata sandi) -> POST /login (tabel users).
  /// Mengembalikan {'ok': bool, 'message': String, 'data': {user, token}}
  static Future<Map<String, dynamic>> loginPembeli(
    String identifier,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _jsonHeaders,
        body: jsonEncode({'identifier': identifier, 'password': password}),
      );
      debugPrint('<-- [${response.statusCode}] login: ${response.body}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'ok': true, 'data': data, 'message': 'Login berhasil'};
      }
      return {'ok': false, 'message': _pesanError(response)};
    } catch (e) {
      debugPrint('Error loginPembeli: $e');
      return {
        'ok': false,
        'message': 'Gagal terhubung ke server. Pastikan backend aktif.',
      };
    }
  }
}