import 'package:flutter/material.dart';
import 'beranda_widgets.dart';
import 'detail_paket.dart';
import 'lb_nav.dart';
import 'halaman_beranda.dart';

class BerandaUntukTernakScreen extends StatefulWidget {
  const BerandaUntukTernakScreen({super.key});

  @override
  State<BerandaUntukTernakScreen> createState() =>
      _BerandaUntukTernakScreenState();
}

class _BerandaUntukTernakScreenState extends State<BerandaUntukTernakScreen> {
  int _kategori = 0;
  String _query = '';

  static const List<LbKategori> _kategoriList = [
    LbKategori('Semua', Icons.apps_rounded),
    LbKategori('Pakan Ternak', Icons.agriculture_rounded),
    LbKategori('Bahan Pupuk', Icons.eco_rounded),
  ];

  static const List<BahanItem> _semuaItem = [
    BahanItem(
      nama: 'Sisa Roti untuk Pakan Ternak',
      penjual: 'Holland Bakery - Batam Center',
      inisial: 'HB',
      alamat: 'Jl. Engku Putri No. 8, Batam Center',
      waktu: '08:00 - 10:00 WIB',
      jarak: '1,8 km',
      kategori: 'Pakan Ternak',
      gambar:
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&q=80',
      badge: '20 kg',
      rating: '4.9',
      tag: 'Pakan Ternak',
      harga: 'Rp0',
      satuan: 'Gratis',
    ),
    BahanItem(
      nama: 'Sisa Makanan Organik',
      penjual: 'Batam Bakery Central',
      inisial: 'RS',
      waktu: '19:00 - 20:00 WIB',
      jarak: '2,5 km',
      kategori: 'Pakan Ternak',
      gambar:
          'https://images.unsplash.com/photo-1547592180-85f173990554?w=600&q=80',
      badge: '5 kg',
      rating: '4.8',
      tag: 'Pakan Ternak',
      harga: 'Rp15.000',
      satuan: '/paket',
    ),
    BahanItem(
      nama: 'Sisa Sayur & Batang Jagung',
      penjual: 'Kios Sayur Segar Pasar Mitra',
      inisial: 'GM',
      waktu: '17:00 - 18:00 WIB',
      jarak: '2,1 km',
      kategori: 'Bahan Pupuk',
      gambar:
          'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600&q=80',
      badge: '15 kg',
      rating: '4.7',
      tag: 'Bahan Pupuk',
      harga: 'Rp0',
      satuan: 'Gratis',
    ),
    BahanItem(
      nama: 'Kebun Barokah - Batam Center',
      penjual: 'Kompos & Sisa Organik Siap Olah (Karung 5kg)',
      inisial: 'KB',
      waktu: '16:00 - 18:00 WIB',
      jarak: '2,3 km',
      kategori: 'Bahan Pupuk',
      gambar:
          'https://images.unsplash.com/photo-1591857177580-dc82b9ac4e1e?w=600&q=80',
      badge: '5 kg',
      rating: '4.9',
      tag: 'Bahan Pupuk',
      harga: 'Rp12.500',
      satuan: '/karung',
    ),
    BahanItem(
      nama: 'Sisa Sayur & Buah Organik',
      penjual: 'Toko Tani Lestari',
      inisial: 'TL',
      waktu: '15:00 - 17:00 WIB',
      jarak: '2,8 km',
      kategori: 'Bahan Pupuk',
      gambar:
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600&q=80',
      badge: '10 kg',
      rating: '4.6',
      tag: 'Bahan Pupuk',
      harga: 'Rp8.000',
      satuan: '/paket',
    ),
  ];

  List<BahanItem> get _items {
    final q = _query.trim().toLowerCase();
    return _semuaItem.where((e) {
      final cocokKategori =
          _kategori == 0 || e.kategori == _kategoriList[_kategori].label;
      final cocokCari = q.isEmpty ||
          e.nama.toLowerCase().contains(q) ||
          e.penjual.toLowerCase().contains(q);
      return cocokKategori && cocokCari;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BerandaLayout(
      isTernak: true,
      kategori: _kategoriList,
      selectedKategori: _kategori,
      onKategori: (i) => setState(() => _kategori = i),
      onSearch: (v) => setState(() => _query = v),
      sectionTitle: 'Pasokan Bahan Organik Terdekat',
      items: _items,
      onNavTap: (i) => LbNav.go(context, from: 0, to: i),
      onItemTap: (item) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailPaketScreen(item: item)),
      ),
      onSwitch: (keTernak) {
        if (!keTernak) {
          // Balik ke "Untuk Dimakan"
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const BerandaScreen()),
            );
          }
        }
      },
    );
  }
}