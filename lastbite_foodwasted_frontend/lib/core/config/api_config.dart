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
}

