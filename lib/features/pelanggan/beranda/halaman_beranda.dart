import 'package:flutter/material.dart';
import 'beranda_widgets.dart';
import 'detail_paket.dart';
import 'beranda_untukternak.dart';
import 'filter_preferensi.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});
  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  int _kategori = 0;
  String _query = '';
  Map<String, dynamic> _filter = {};

  static const List<LbKategori> _kategoriList = [
    LbKategori('Semua', Icons.apps_rounded),
    LbKategori('Roti & Bakery', Icons.bakery_dining_rounded),
    LbKategori('Makanan Siap Saji', Icons.lunch_dining_rounded),
    LbKategori('Sayur & Buah', Icons.eco_rounded),
  ];

  static const List<BahanItem> _semuaItem = [
    BahanItem(nama: 'Paket Kejutan Roti Manis & Pastry', penjual: 'Holland Bakery - Batam Center', inisial: 'HB', alamat: 'Jl. Engku Putri No. 8, Batam Center', waktu: '19:00 - 20:00 WIB', jarak: '1,2 km', kategori: 'Roti & Bakery', gambar: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&q=80', badge: '3 tersisa', rating: '4.9', tag: 'Harga Spesial', tagIcon: Icons.local_offer_outlined, harga: 'Rp15.000', hargaAsli: 'Rp30.000', satuan: '/paket'),
    BahanItem(nama: 'Paket Kejutan Nasi Box Spesial', penjual: 'Resto Sederhana - Nagoya', inisial: 'RS', waktu: '21:00 - 22:00 WIB', jarak: '0,8 km', kategori: 'Makanan Siap Saji', gambar: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80', badge: '1 tersisa', rating: '4.5', tag: 'Harga Dinamis', tagIcon: Icons.local_offer_outlined, harga: 'Rp12.000', hargaAsli: 'Rp36.000', satuan: '/paket'),
    BahanItem(nama: 'Paket Kejutan Sayur & Buah Segar', penjual: 'Kios Sayur Segar Pasar Mitra', inisial: 'KS', waktu: '17:00 - 18:00 WIB', jarak: '2,1 km', kategori: 'Sayur & Buah', gambar: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600&q=80', badge: '5 tersisa', rating: '4.7', tag: 'Harga Spesial', tagIcon: Icons.local_offer_outlined, harga: 'Rp10.000', hargaAsli: 'Rp25.000', satuan: '/paket'),
  ];

  double _angka(String teks) {
    final bersih = teks.replaceAll('.', '').replaceAll(',', '.');
    final match = RegExp(r'\d+(?:\.\d+)?').firstMatch(bersih);
    return match == null ? 0 : (double.tryParse(match.group(0)!) ?? 0);
  }

  Future<void> _bukaFilter() async {
    final hasil = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const FilterPreferensiScreen(isTernak: false)),
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
      final jarakProduk = _angka(e.jarak);
      final hargaProduk = _angka(e.harga);
      final cocokJarak = jarakProduk <= jarakMaks;
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
    isTernak: false,
    kategori: _kategoriList,
    selectedKategori: _kategori,
    onKategori: (i) => setState(() => _kategori = i),
    onSearch: (v) => setState(() => _query = v),
    onFilterTap: _bukaFilter,
    sectionTitle: 'Paket Kejutan di Sekitarmu',
    items: _items,
    onItemTap: (item) => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPaketScreen(item: item))),
    onSwitch: (keTernak) {
      if (keTernak) Navigator.push(context, MaterialPageRoute(builder: (_) => const BerandaUntukTernakScreen()));
    },
  );
}
