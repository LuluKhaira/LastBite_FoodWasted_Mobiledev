import 'package:flutter/material.dart';
import '../../core/komponen/navbar_bawah.dart';
import '../../core/tema/tema_lb.dart';
import 'beranda/halaman_beranda.dart';
import 'pesanan/halaman_pesanan.dart';
// import 'favorit/halaman_favorit.dart';
// import 'profil/halaman_profil.dart';

/// Pembungkus 4 tab pelanggan + satu navbar.
/// Setelah login: Navigator.pushReplacement(context,
///   MaterialPageRoute(builder: (_) => const CangkangUtama()));
class CangkangUtama extends StatefulWidget {
  final int indeksAwal;
  const CangkangUtama({super.key, this.indeksAwal = 0});

  @override
  State<CangkangUtama> createState() => _CangkangUtamaState();
}

class _CangkangUtamaState extends State<CangkangUtama> {
  late int _indeks = widget.indeksAwal;

  // GANTI dua Center() di bawah dengan halaman Favorit & Profil milikmu.
  final List<Widget> _halaman = const [
    BerandaScreen(),
    PesananScreen(denganNavbar: false),
    Center(child: Text('Favorit')), // -> HalamanFavorit()
    Center(child: Text('Profil')), // -> HalamanProfil()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LbColors.offWhite,
      body: IndexedStack(index: _indeks, children: _halaman),
      bottomNavigationBar: LbBottomNav(
        currentIndex: _indeks,
        onTap: (i) => setState(() => _indeks = i),
      ),
    );
  }
}