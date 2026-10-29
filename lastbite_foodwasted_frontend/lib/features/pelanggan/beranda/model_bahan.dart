import 'package:flutter/material.dart';
import '../../../core/config/api_config.dart';
import '../pesanan/pesanan_model.dart' show lbRp;
import 'model_toko.dart';

// ============================================================
// MODEL DATA
// ============================================================
class BahanItem {
  final int? id; // id produk di database (dari API)
  final String nama;
  final String penjual;
  final String inisial;
  final String waktu;
  final String jarak;
  final String kategori;
  final String gambar;
  final String badge; // contoh: "20 kg" / "3 tersisa"
  final String rating;
  final String tag;
  final IconData tagIcon;
  final String harga;
  final String satuan; // "Gratis" / "/paket" / "/karung"
  final String? hargaAsli; // harga coret (opsional)
  final String alamat;
  final String tipe; // 'dimakan' / 'ternak' (kategori utama produk)
  final String skemaHarga; // 'diskon' / 'sedekah'
  final bool sudahDialihkan; // produk dimakan yang kedaluwarsa -> dialihkan

  const BahanItem({
    this.id,
    this.sudahDialihkan = false,
    this.tipe = 'dimakan',
    this.skemaHarga = 'diskon',
    required this.nama,
    required this.penjual,
    required this.inisial,
    required this.waktu,
    required this.jarak,
    required this.kategori,
    required this.gambar,
    required this.badge,
    required this.rating,
    required this.tag,
    required this.harga,
    required this.satuan,
    this.tagIcon = Icons.eco_rounded,
    this.hargaAsli,
    this.alamat = 'Batam Center, Kepulauan Riau',
  });

  /// Bentuk data dari API Laravel (GET /api/produk).
  factory BahanItem.fromJson(Map<String, dynamic> j) {
    String fmt(double v) => v == v.roundToDouble()
        ? v.toInt().toString()
        : v.toStringAsFixed(1).replaceAll('.', ',');

    // Backend memakai 'dimakan' / 'pakan' / 'kompos'; di aplikasi pakan &
    // kompos digabung menjadi satu jenis: 'ternak'.
    final tipeRaw = (j['tipe'] ?? 'dimakan').toString();
    final tipe =
        (tipeRaw == 'pakan' || tipeRaw == 'kompos') ? 'ternak' : tipeRaw;
    final harga = (j['harga'] as num?)?.toInt() ?? 0;
    final asli = (j['harga_asli'] as num?)?.toInt();
    final stok = (j['stok'] as num?)?.toInt() ?? 0;
    final berat = (j['berat_kg'] as num?)?.toDouble() ?? 0;
    final jarak = (j['jarak_km'] as num?)?.toDouble();
    final penjual = (j['penjual'] ?? '').toString();
    final inisial = (j['inisial'] ?? '').toString();

    return BahanItem(
      id: (j['id'] as num?)?.toInt(),
      tipe: tipe,
      skemaHarga: (j['skema_harga'] ?? (harga == 0 ? 'sedekah' : 'diskon')).toString(),
      sudahDialihkan: j['sudah_dialihkan'] == true,
      nama: (j['nama'] ?? '').toString(),
      penjual: penjual,
      inisial: inisial.isNotEmpty
          ? inisial
          : (penjual.isNotEmpty ? penjual.substring(0, 1).toUpperCase() : '?'),
      waktu: (j['waktu'] ?? '-').toString(),
      jarak: jarak == null ? '-' : '${fmt(jarak)} km',
      kategori: (j['kategori'] ?? '').toString(),
      gambar: ApiConfig.resolveImageUrl(j['gambar'] ?? j['image_url']),
      badge: stok <= 0
          ? 'Habis'
          : (tipe == 'ternak' ? '${fmt(berat)} kg' : '$stok tersisa'),
      rating: ((j['rating'] as num?)?.toDouble() ?? 0).toStringAsFixed(1),
      tag: (j['tag'] ?? j['kategori'] ?? '').toString(),
      tagIcon: tipe == 'ternak' ? Icons.eco_rounded : Icons.local_offer_outlined,
      harga: lbRp(harga),
      satuan: harga == 0 ? 'Gratis' : (j['satuan'] ?? '/paket').toString(),
      hargaAsli: (asli != null && asli > harga) ? lbRp(asli) : null,
      alamat: (j['alamat'] ?? 'Batam Center, Kepulauan Riau').toString(),
    );
  }

  bool get gratis => harga == 'Rp0' || harga == 'Rp 0' || harga == '0';

  /// Menandakan apakah produk ini merupakan skema sedekah (makanan surplus gratis)
  bool get isSedekah => skemaHarga == 'sedekah' || gratis;

  /// Ditentukan dari kategori utama (tipe), bukan nama kategori,
  /// karena nama kategori dikelola admin dan bisa berubah.
  bool get untukTernak => tipe == 'ternak';
}

class LbKategori {
  final String label;
  final IconData icon;
  const LbKategori(this.label, this.icon);
}