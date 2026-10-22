import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lastbite_foodwasted_mobiledev/core/config/api_config.dart';

class MitraPesananApi {
  static const _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  static dynamic _handle(http.Response r) {
    final body = r.body.isEmpty ? {} : jsonDecode(r.body);
    if (r.statusCode >= 200 && r.statusCode < 300) return body;
    final msg = (body is Map && body['message'] != null)
        ? body['message'].toString()
        : 'Terjadi kesalahan (${r.statusCode})';
    throw Exception(msg);
  }

  static Future<List<Map<String, dynamic>>> daftar(String phone) async {
    final r = await http
        .post(Uri.parse('${ApiConfig.baseUrl}/mitra/pesanan'),
            headers: _headers,
            body: jsonEncode({'phone': phone, 'tab': 'semua'}))
        .timeout(const Duration(seconds: 12));
    return List<Map<String, dynamic>>.from(_handle(r)['data']);
  }

  static Future<void> aksi(String phone, String kode, String aksi,
      {String? kodeAmbil}) async {
    final r = await http
        .post(Uri.parse('${ApiConfig.baseUrl}/mitra/pesanan/$kode/$aksi'),
            headers: _headers,
            body: jsonEncode({
              'phone': phone,
              if (kodeAmbil != null) 'kode_ambil': kodeAmbil,
            }))
        .timeout(const Duration(seconds: 12));
    _handle(r);
  }
}