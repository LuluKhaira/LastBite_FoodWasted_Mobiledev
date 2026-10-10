import 'package:flutter/material.dart';
import 'beranda_widgets.dart';
import 'detail_paket.dart';
import 'halaman_beranda.dart';
import 'filter_preferensi.dart';

class BerandaUntukTernakScreen extends StatefulWidget {
  const BerandaUntukTernakScreen({super.key});
  @override
  State<BerandaUntukTernakScreen> createState() => _BerandaUntukTernakScreenState();
}

class _BerandaUntukTernakScreenState extends State<BerandaUntukTernakScreen> {
  int _kategori = 0;
  String _query = '';
  Map<String, dynamic> _filter = {};

  static const List<LbKategori> _kategoriList = [
    LbKategori('Semua', Icons.apps_rounded),
    LbKategori('Pakan Ternak', Icons.agriculture_rounded),
    LbKategori('Bahan Pupuk', Icons.eco_rounded),
  ];
  static const List<BahanItem> _semuaItem = [
    BahanItem(nama: 'Sisa Roti untuk Pakan Ternak', penjual: 'Holland Bakery - Batam Center', inisial: 'HB', alamat: 'Jl. Engku Putri No. 8, Batam Center', waktu: '08:00 - 10:00 WIB', jarak: '1,8 km', kategori: 'Pakan Ternak', gambar: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&q=80', badge: '20 kg', rating: '4.9', tag: 'Pakan Ternak', harga: 'Rp0', satuan: 'Gratis'),
    BahanItem(nama: 'Sisa Makanan Organik', penjual: 'Batam Bakery Central', inisial: 'RS', waktu: '19:00 - 20:00 WIB', jarak: '2,5 km', kategori: 'Pakan Ternak', gambar: 'https://images.unsplash.com/photo-1547592180-85f173990554?w=600&q=80', badge: '5 kg', rating: '4.8', tag: 'Pakan Ternak', harga: 'Rp15.000', satuan: '/paket'),
    BahanItem(nama: 'Sisa Sayur & Batang Jagung', penjual: 'Kios Sayur Segar Pasar Mitra', inisial: 'GM', waktu: '17:00 - 18:00 WIB', jarak: '2,1 km', kategori: 'Bahan Pupuk', gambar: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600&q=80', badge: '15 kg', rating: '4.7', tag: 'Bahan Pupuk', harga: 'Rp0', satuan: 'Gratis'),
    BahanItem(nama: 'Kebun Barokah - Batam Center', penjual: 'Kompos & Sisa Organik Siap Olah (Karung 5kg)', inisial: 'KB', waktu: '16:00 - 18:00 WIB', jarak: '2,3 km', kategori: 'Bahan Pupuk', gambar: 'https://images.unsplash.com/photo-1591857177580-dc82b9ac4e1e?w=600&q=80', badge: '5 kg', rating: '4.9', tag: 'Bahan Pupuk', harga: 'Rp12.500', satuan: '/karung'),
    BahanItem(nama: 'Sisa Sayur & Buah Organik', penjual: 'Toko Tani Lestari', inisial: 'TL', waktu: '15:00 - 17:00 WIB', jarak: '2,8 km', kategori: 'Bahan Pupuk', gambar: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600&q=80', badge: '10 kg', rating: '4.6', tag: 'Bahan Pupuk', harga: 'Rp8.000', satuan: '/paket'),
  ];

  double _angka(String teks) {
    final bersih = teks.replaceAll('.', '').replaceAll(',', '.');
    final match = RegExp(r'\d+(?:\.\d+)?').firstMatch(bersih);
    return match == null ? 0 : (double.tryParse(match.group(0)!) ?? 0);
  }

  Future<void> _bukaFilter() async {
    final hasil = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const FilterPreferensiScreen(isTernak: true)),
    );
    if (!mounted || hasil == null) return;
    setState(() => _filter = hasil);
  }

  List<BahanItem> get _items {
    final q = _query.trim().toLowerCase();
    final kategoriFilter = (_filter['kategori'] as List?)?.cast<String>() ?? <String>[];
    final jarakMaks = (_filter['jarak'] as num?)?.toDouble() ?? 10.0;
    final hargaFilter = _filter['harga'] as String? ?? 'Semua Harga';
    final hanyaTersedia = _filter['tersedia'] == true;
    final hasil = _semuaItem.where((e) {
      final kategoriAktif = _kategori == 0 || e.kategori == _kategoriList[_kategori].label;
      final kategoriPreferensi = kategoriFilter.isEmpty || kategoriFilter.contains(e.kategori);
      final cocokCari = q.isEmpty || e.nama.toLowerCase().contains(q) || e.penjual.toLowerCase().contains(q);
      final cocokJarak = _angka(e.jarak) <= jarakMaks;
      final hargaProduk = _angka(e.harga);
      final cocokHarga = switch (hargaFilter) {
        'Di bawah Rp25.000' => hargaProduk < 25000,
        'Rp25.000–Rp50.000' => hargaProduk >= 25000 && hargaProduk <= 50000,
        'Di atas Rp50.000' => hargaProduk > 50000,
        _ => true,
      };
      final cocokTersedia = !hanyaTersedia || e.badge.toLowerCase().contains('tersisa');
      return kategoriAktif && kategoriPreferensi && cocokCari && cocokJarak && cocokHarga && cocokTersedia;
    }).toList();
    switch (_filter['urutan']) {
      case 'Jarak Terdekat': hasil.sort((a, b) => _angka(a.jarak).compareTo(_angka(b.jarak))); break;
      case 'Harga Terendah': hasil.sort((a, b) => _angka(a.harga).compareTo(_angka(b.harga))); break;
    }
    return hasil;
  }

  @override
  Widget build(BuildContext context) => BerandaLayout(
    isTernak: true,
    kategori: _kategoriList,
    selectedKategori: _kategori,
    onKategori: (i) => setState(() => _kategori = i),
    onSearch: (v) => setState(() => _query = v),
    onFilterTap: _bukaFilter,
    sectionTitle: 'Pasokan Bahan Organik Terdekat',
    items: _items,
    onItemTap: (item) => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPaketScreen(item: item))),
    onSwitch: (keTernak) {
      if (!keTernak) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BerandaScreen()));
    },
  );
}
