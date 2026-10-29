import 'package:lastbite_foodwasted_mobiledev/core/config/api_config.dart';

enum StatusProduk { tayang, terjadwal, habis, draf }

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
  final bool draf;
  final DateTime? kadaluarsa;
  final String? kategoriAsli;
  final DateTime? dialihkanPada;

  // Fitur Pengalihan Surprise Box ke Pakan / Kompos
  final bool bersediaDialihkan;
  final String? targetKategoriPengalihan;
  final double perkiraanBeratPerPaket;
  final String statusPengalihan; // tidak_dialihkan | menunggu | dialihkan | dibuang | selesai
  final double beratAktual;
  final double beratSisaKg;
  final int? produkSurplusId;
  final DateTime? dikonfirmasiPada;
  final String? catatanPengalihan;
  final double totalPerkiraanBerat;

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
    this.draf = false,
    this.kadaluarsa,
    this.kategoriAsli,
    this.dialihkanPada,
    this.bersediaDialihkan = false,
    this.targetKategoriPengalihan,
    this.perkiraanBeratPerPaket = 0.0,
    this.statusPengalihan = 'tidak_dialihkan',
    this.beratAktual = 0.0,
    this.beratSisaKg = 0.0,
    this.produkSurplusId,
    this.dikonfirmasiPada,
    this.catatanPengalihan,
    this.totalPerkiraanBerat = 0.0,
  });

  factory Produk.fromJson(Map<String, dynamic> j) {
    int i(dynamic v) => int.tryParse('$v') ?? 0;
    double d(dynamic v) => double.tryParse('$v') ?? 0.0;
    DateTime? t(dynamic v) {
      final s = v?.toString().trim() ?? '';
      return s.isEmpty ? null : DateTime.tryParse(s);
    }

    final resolvedUrl = ApiConfig.resolveImageUrl(j['gambar'] ?? j['image_url']);
    final String? imgUrl = resolvedUrl.isEmpty ? null : resolvedUrl;

    final int stokVal = i(j['stok']);
    final double perkiraanVal = d(j['perkiraan_berat_per_paket']);
    final double totalEst = j['total_perkiraan_berat'] != null
        ? d(j['total_perkiraan_berat'])
        : (stokVal * perkiraanVal);

    final bool isDraf = j['draf'] == true || j['draf'] == 1 || '${j['status']}' == 'draf';
    final double beratSisa = d(j['berat_sisa_kg'] ?? j['berat_aktual'] ?? j['berat_kg'] ?? totalEst);

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
      stok: stokVal,
      kuota: i(j['kuota']),
      waktuMulai: j['waktu_mulai'] != null && j['waktu_mulai'].toString().isNotEmpty
          ? (j['waktu_mulai'].toString().length >= 5
              ? j['waktu_mulai'].toString().substring(0, 5)
              : j['waktu_mulai'].toString())
          : '00:00',
      waktuSelesai: j['waktu_selesai'] != null && j['waktu_selesai'].toString().isNotEmpty
          ? (j['waktu_selesai'].toString().length >= 5
              ? j['waktu_selesai'].toString().substring(0, 5)
              : j['waktu_selesai'].toString())
          : (j['jam'] != null && j['jam'].toString().isNotEmpty && j['jam'] != '-'
              ? j['jam'].toString()
              : '00:00'),
      rating: d(j['rating']),
      aktif: j['aktif'] == true || j['aktif'] == 1,
      draf: isDraf,
      kadaluarsa: t(j['kadaluarsa']),
      kategoriAsli: j['kategori_asli']?.toString(),
      dialihkanPada: t(j['dialihkan_pada']),
      bersediaDialihkan: j['bersedia_dialihkan'] == true || j['bersedia_dialihkan'] == 1,
      targetKategoriPengalihan: j['target_kategori_pengalihan']?.toString(),
      perkiraanBeratPerPaket: perkiraanVal,
      statusPengalihan: j['status_pengalihan']?.toString() ?? 'tidak_dialihkan',
      beratAktual: d(j['berat_aktual']),
      beratSisaKg: beratSisa,
      produkSurplusId: j['produk_surplus_id'] != null ? i(j['produk_surplus_id']) : null,
      dikonfirmasiPada: t(j['dikonfirmasi_pada']),
      catatanPengalihan: j['catatan_pengalihan']?.toString(),
      totalPerkiraanBerat: totalEst,
    );
  }

  /// Menunggu konfirmasi penimbangan/pengalihan dari mitra
  bool get isMenungguKonfirmasi =>
      statusPengalihan == 'menunggu' || statusPengalihan == 'menunggu_konfirmasi';

  /// Sudah dialihkan ke kategori pakan/kompos setelah dikonfirmasi mitra
  bool get isSudahDialihkan =>
      statusPengalihan == 'dialihkan' || dialihkanPada != null;

  /// Dibuang / dinilai tidak layak oleh mitra
  bool get isDibuang => statusPengalihan == 'dibuang';

  /// Selesai (misal expired tapi stok habis)
  bool get isSelesai => statusPengalihan == 'selesai';

  /// Badge status untuk kategori Pakan/Kompos
  bool get tampilBadgePakan =>
      isSudahDialihkan || isMenungguKonfirmasi || isDibuang || bersediaDialihkan;

  String get labelBadgePakan {
    if (isMenungguKonfirmasi) return 'Menunggu Konfirmasi Pengalihan';
    if (isSudahDialihkan) return 'Dialihkan → Pakan/Kompos';
    if (isDibuang) return 'Tidak Layak (Dibuang)';
    if (bersediaDialihkan) {
      return 'Siap Dialihkan → ${targetKategoriPengalihan ?? "Pakan/Kompos"}';
    }
    return 'Pakan / Kompos';
  }

  StatusProduk get statusUI {
    if (draf) return StatusProduk.draf;
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
