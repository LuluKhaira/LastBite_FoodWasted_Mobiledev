/// Data satu toko (mitra) yang disimpan pelanggan sebagai favorit.
/// Dibuat dari JSON `GET /api/mitra-favorit`. Semua field aman terhadap null.
class TokoFavorit {
  final int idMitra;
  final String nama;
  final String alamat;
  final String gambar;
  final String waktu;
  final double? jarakKm;
  final int? produkId;
  final String namaProduk;
  final int harga;
  final int? hargaAsli;
  final int stok;

  const TokoFavorit({
    required this.idMitra,
    required this.nama,
    required this.alamat,
    required this.gambar,
    required this.waktu,
    required this.jarakKm,
    required this.produkId,
    required this.namaProduk,
    required this.harga,
    required this.hargaAsli,
    required this.stok,
  });

  factory TokoFavorit.dariJson(Map<String, dynamic> j) {
    int? angka(dynamic v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}');
    double? desimal(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('${v ?? ''}');
    String teks(dynamic v) => (v ?? '').toString().trim();

    return TokoFavorit(
      idMitra: angka(j['id_mitra']) ?? 0,
      nama: teks(j['nama']).isEmpty ? 'Mitra LastBite' : teks(j['nama']),
      alamat: teks(j['alamat']),
      gambar: teks(j['gambar']),
      waktu: teks(j['waktu']),
      jarakKm: desimal(j['jarak_km']),
      produkId: angka(j['produk_id']),
      namaProduk: teks(j['nama_produk']),
      harga: angka(j['harga']) ?? 0,
      hargaAsli: angka(j['harga_asli']),
      stok: angka(j['stok']) ?? 0,
    );
  }

  /// Ada produk yang masih bisa dipesan.
  bool get tersedia => produkId != null && stok > 0;

  /// Ada produk yang pernah dijual (untuk tombol "Ingatkan").
  bool get adaProduk => produkId != null;

  bool get adaHargaCoret => hargaAsli != null && hargaAsli! > harga;

  /// "0,8 km • Batam Center" — bagian yang kosong dilewati.
  String get infoLokasi {
    final bagian = <String>[];
    if (jarakKm != null) {
      bagian.add('${jarakKm!.toStringAsFixed(1).replaceAll('.', ',')} km');
    }
    if (alamat.isNotEmpty) bagian.add(alamat);
    return bagian.join(' • ');
  }
}