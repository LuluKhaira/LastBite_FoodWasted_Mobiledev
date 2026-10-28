import 'model_bahan.dart';

class TokoGroup {
  final String nama;
  final String inisial;
  final String jarak;
  final String waktu;
  final String alamat;
  final String rating;
  final List<BahanItem> items;

  const TokoGroup({
    required this.nama,
    required this.inisial,
    required this.jarak,
    required this.waktu,
    required this.alamat,
    required this.rating,
    required this.items,
  });

  int get jumlahPaket => items.length;

  int get jumlahTersedia => items.where((e) => e.badge != 'Habis').length;

  static List<TokoGroup> kelompokkan(List<BahanItem> semua) {
    final peta = <String, List<BahanItem>>{};
    for (final it in semua) {
      final kunci = it.penjual.trim().isEmpty ? 'Toko' : it.penjual.trim();
      (peta[kunci] ??= []).add(it);
    }

    return peta.entries.map((e) {
      final p = e.value.first;
      final nilai = e.value
          .map((x) => double.tryParse(x.rating) ?? 0)
          .where((r) => r > 0)
          .toList();
      final rata =
          nilai.isEmpty ? 0.0 : nilai.reduce((a, b) => a + b) / nilai.length;

      return TokoGroup(
        nama: e.key,
        inisial: p.inisial,
        jarak: p.jarak,
        waktu: p.waktu,
        alamat: p.alamat,
        rating: rata.toStringAsFixed(1),
        items: e.value,
      );
    }).toList();
  }
}