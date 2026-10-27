import 'package:lastbite_foodwasted_mobiledev/core/config/api_config.dart';

enum StatusProduk { tayang, terjadwal, habis }

class Produk {
  final int id;
  final String nama;
  final String deskripsi;
  final String tipe;
  final String kategori;
  final String? gambar;
  final int harga;
  final int hargaAsli;
  final String satuan;
  final int stok;
  final int kuota;
  final String waktuMulai;
  final String waktuSelesai;
  final double rating;
  final bool aktif;
  final DateTime? kadaluarsa;
  final String? kategoriAsli;
  final DateTime? dialihkanPada;

  Produk({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.tipe,
    required this.kategori,
    this.gambar,
    required this.harga,
    required this.hargaAsli,
    required this.satuan,
    required this.stok,
    required this.kuota,
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.rating,
    required this.aktif,
    this.kadaluarsa,
    this.kategoriAsli,
    this.dialihkanPada,
  });

  factory Produk.fromJson(Map<String, dynamic> j) {
    int i(dynamic v) => int.tryParse('$v') ?? 0;
    double d(dynamic v) => double.tryParse('$v') ?? 0.0;
    DateTime? t(dynamic v) {
      final s = v?.toString().trim() ?? '';
      return s.isEmpty ? null : DateTime.tryParse(s);
    }

    // Mengambil alamat server dari konfigurasi API.
    // Contoh HP fisik: http://192.168.1.203:8000
    final String baseUrlImage = ApiConfig.baseUrl.replaceFirst(
      RegExp(r'/api/?$'),
      '',
    );

    // Menggunakan gambar atau image_url dari respons API.
    final dynamic nilaiGambar = j['gambar'] ?? j['image_url'];
    final String rawImage = nilaiGambar?.toString().trim() ?? '';

    String? imgUrl;

    if (rawImage.isNotEmpty && rawImage != 'null') {
      final uri = Uri.tryParse(rawImage);

      if (uri != null && uri.hasScheme && uri.hasAuthority) {
        // URL dari Laravel mungkin masih memakai localhost,
        // 127.0.0.1, atau alamat emulator 10.0.2.2.
        if (uri.host == '127.0.0.1' ||
            uri.host == 'localhost' ||
            uri.host == '10.0.2.2') {
          final apiUri = Uri.parse(baseUrlImage);

          imgUrl = uri.replace(
            scheme: apiUri.scheme,
            host: apiUri.host,
            port: apiUri.port,
          ).toString();
        } else {
          // Jika URL sudah memakai host yang benar, gunakan langsung.
          imgUrl = rawImage;
        }
      } else {
        // Jika API hanya mengirim nama atau path gambar.
        String path = rawImage;

        if (path.startsWith('/')) {
          path = path.substring(1);
        }

        if (!path.startsWith('storage/')) {
          path = 'storage/$path';
        }

        imgUrl = '$baseUrlImage/$path';
      }
    }

    return Produk(
      id: i(j['id']),
      nama: '${j['nama'] ?? '-'}',
      deskripsi:
          '${j['deskripsi'] ?? 'Kombinasi produk surplus berkualitas'}',
      tipe: '${j['tipe'] ?? 'dimakan'}',
      kategori: '${j['kategori'] ?? 'Umum'}',
      gambar: imgUrl,
      harga: i(j['harga']),
      hargaAsli: i(j['harga_asli']),
      satuan: '${j['satuan'] ?? '/paket'}',
      stok: i(j['stok']),
      kuota: i(j['kuota']),
      waktuMulai: '${j['waktu_mulai'] ?? '00:00'}',
      waktuSelesai: '${j['waktu_selesai'] ?? '00:00'}',
      rating: d(j['rating']),
      aktif: j['aktif'] == true || j['aktif'] == 1,
      kadaluarsa: t(j['kadaluarsa']),
      kategoriAsli: j['kategori_asli']?.toString(),
      dialihkanPada: t(j['dialihkan_pada']),
    );
  }

  /// Sudah dialihkan otomatis ke kategori pakan oleh scheduler.
  bool get sudahDialihkan => dialihkanPada != null;

  /// Sudah lewat kadaluarsa tapi scheduler belum sempat mengalihkan.
  bool get kadaluarsaBelumDialihkan =>
      !sudahDialihkan &&
      tipe == 'dimakan' &&
      kadaluarsa != null &&
      DateTime.now().isAfter(kadaluarsa!);

  bool get tampilBadgePakan => sudahDialihkan || kadaluarsaBelumDialihkan;

  String get labelBadgePakan =>
      sudahDialihkan ? 'Expired → Pakan' : 'Kadaluarsa • segera jadi pakan';

  StatusProduk get statusUI {
    if (!aktif) return StatusProduk.habis;
    if (stok == 0) return StatusProduk.habis;
    return StatusProduk.tayang;
  }

  bool get adaDiskon => hargaAsli > harga && hargaAsli > 0;

  int get diskon =>
      adaDiskon ? ((1 - harga / hargaAsli) * 100).round() : 0;

  double get rasio => kuota == 0 ? 0 : stok / kuota;

  int get persen => (rasio * 100).toInt();

  bool get cepatHabis =>
      statusUI == StatusProduk.tayang && rasio <= 0.3;

  String get jamAmbil => '$waktuMulai - $waktuSelesai';
}