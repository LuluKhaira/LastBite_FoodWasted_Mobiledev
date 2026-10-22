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
  });

  factory Produk.fromJson(Map<String, dynamic> j) {
    int i(dynamic v) => int.tryParse('$v') ?? 0;
    double d(dynamic v) => double.tryParse('$v') ?? 0.0;
    
    // =======================================================================
    // PERHATIKAN BAGIAN INI:
    // - Kalau pakai Emulator Android, gunakan: http://10.0.2.2:8000
    // - Kalau pakai HP Fisik, gunakan IP Laptopmu (Cek di CMD -> ipconfig -> IPv4)
    //   Contoh: http://192.168.1.15:8000
    // =======================================================================
    const String baseUrlImage = 'http://10.0.2.2:8000'; // <--- GANTI DI SINI KALAU PERLU
    
    String? imgUrl;
    if (j['gambar'] != null && j['gambar'].toString().isNotEmpty) {
      final String gambarPath = j['gambar'].toString();
      
      if (gambarPath.startsWith('http')) {
        imgUrl = gambarPath; // Jika dari DB sudah full URL
      } else {
        // Gabungkan Base URL + storage + nama file
        imgUrl = '$baseUrlImage/storage/$gambarPath';
      }
    }

    return Produk(
      id: i(j['id']),
      nama: '${j['nama'] ?? '-'}',
      deskripsi: '${j['deskripsi'] ?? 'Kombinasi produk surplus berkualitas'}',
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
    );
  }

  StatusProduk get statusUI {
    if (!aktif) return StatusProduk.habis;
    if (stok == 0) return StatusProduk.habis;
    return StatusProduk.tayang; 
  }

  bool get adaDiskon => hargaAsli > harga && hargaAsli > 0;
  int get diskon => adaDiskon ? ((1 - harga / hargaAsli) * 100).round() : 0;
  double get rasio => kuota == 0 ? 0 : stok / kuota;
  int get persen => (rasio * 100).toInt();
  bool get cepatHabis => statusUI == StatusProduk.tayang && rasio <= 0.3;
  String get jamAmbil => '$waktuMulai - $waktuSelesai';
}