import 'package:flutter/material.dart';
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

  const BahanItem({
    this.id,
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

    final tipe = (j['tipe'] ?? 'dimakan').toString();
    final harga = (j['harga'] as num?)?.toInt() ?? 0;
    final asli = (j['harga_asli'] as num?)?.toInt();
    final stok = (j['stok'] as num?)?.toInt() ?? 0;
    final berat = (j['berat_kg'] as num?)?.toDouble() ?? 0;
    final jarak = (j['jarak_km'] as num?)?.toDouble();
    final penjual = (j['penjual'] ?? '').toString();
    final inisial = (j['inisial'] ?? '').toString();

    return BahanItem(
      id: (j['id'] as num?)?.toInt(),
      nama: (j['nama'] ?? '').toString(),
      penjual: penjual,
      inisial: inisial.isNotEmpty
          ? inisial
          : (penjual.isNotEmpty ? penjual.substring(0, 1).toUpperCase() : '?'),
      waktu: (j['waktu'] ?? '-').toString(),
      jarak: jarak == null ? '-' : '${fmt(jarak)} km',
      kategori: (j['kategori'] ?? '').toString(),
      gambar: (j['gambar'] ?? '').toString(),
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

  bool get gratis => harga == 'Rp0';

  bool get untukTernak =>
      kategori == 'Pakan Ternak' || kategori == 'Bahan Pupuk';
}

class LbKategori {
  final String label;
  final IconData icon;
  const LbKategori(this.label, this.icon);
}
