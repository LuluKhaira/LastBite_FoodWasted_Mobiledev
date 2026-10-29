import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Ubah ke `true` jika kamu mengetes menggunakan Android Emulator (AVD) dan ingin memakai 10.0.2.2.
  /// Biarkan `false` jika kamu mengetes menggunakan HP asli (fisik) lewat Wi-Fi LAN / IP Laptop.
  /// Catatan: IP LAN (192.168.1.203) juga bisa diakses oleh Emulator selama Laravel dijalankan dengan --host=0.0.0.0.
  static const bool isEmulator = false;

  /// IP LAN laptop tempat backend Laravel aktif
  static const String lanIp = '192.168.1.203';
  static const String port = '8000';

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:$port/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (isEmulator) {
        return 'http://10.0.2.2:$port/api';
      }
      return 'http://$lanIp:$port/api';
    }
    return 'http://$lanIp:$port/api';
  }

  /// Mengambil base root server (contoh: 'http://192.168.1.203:8000' atau 'http://10.0.2.2:8000')
  /// tanpa akhiran '/api'
  static String get serverRoot {
    final base = baseUrl;
    final uri = Uri.parse(base);
    return '${uri.scheme}://${uri.host}:${uri.port}';
  }

  /// Mengubah path atau URL gambar dari API Laravel menjadi URL lengkap yang valid
  /// dan dapat diakses oleh Image.network() di HP fisik maupun Emulator Android.
  ///
  /// Menangani:
  /// - Path relatif (contoh: "produk/foto.jpg" atau "storage/produk/foto.jpg")
  /// - Host "localhost" atau "127.0.0.1" dari respon API (diganti ke IP/host server aktif)
  /// - Redirect dari path "/storage/..." ke endpoint API streaming "/api/foto/..."
  /// - Fallback aman bila string kosong/null
  static String resolveImageUrl(dynamic raw) {
    if (raw == null) return '';
    final str = raw.toString().trim();
    if (str.isEmpty || str == 'null') return '';

    // Jika merupakan aset lokal aplikasi
    if (str.startsWith('assets/')) return str;

    // Jika sudah berupa URL http/https lengkap
    if (str.startsWith('http://') || str.startsWith('https://')) {
      final uri = Uri.tryParse(str);
      if (uri != null && uri.hasAuthority) {
        Uri targetUri = uri;
        // Jika host dari backend adalah localhost, 127.0.0.1, atau 10.0.2.2,
        // ubah ke host & port server saat ini agar HP fisik / emulator dapat menjangkaunya
        if (uri.host == 'localhost' ||
            uri.host == '127.0.0.1' ||
            uri.host == '10.0.2.2') {
          final serverUri = Uri.parse(serverRoot);
          targetUri = uri.replace(
            scheme: serverUri.scheme,
            host: serverUri.host,
            port: serverUri.port,
          );
        }

        // Jika URL mengarah ke /storage/, alihkan ke endpoint API streaming /api/foto/
        // agar file dapat ditampilkan langsung tanpa bergantung pada symlink web server di Windows/Laragon
        if (targetUri.path.startsWith('/storage/')) {
          final subPath = targetUri.path.substring(9);
          targetUri = targetUri.replace(path: '/api/foto/$subPath');
        }

        return targetUri.toString();
      }
      return str;
    }

    // Jika berupa relative path dari penyimpanan Laravel
    var path = str;
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    if (path.startsWith('api/foto/')) {
      return '$serverRoot/$path';
    }
    if (path.startsWith('api/produk/')) {
      return '$serverRoot/$path';
    }
    if (path.startsWith('storage/')) {
      return '$serverRoot/api/foto/${path.substring(8)}';
    }

    return '$serverRoot/api/foto/$path';
  }
}
