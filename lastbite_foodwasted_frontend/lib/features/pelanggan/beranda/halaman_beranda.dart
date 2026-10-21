import 'package:flutter/material.dart';
import 'beranda_widgets.dart';
import 'beranda_loader.dart';
import 'detail_paket.dart';
import 'lb_nav.dart';
import 'beranda_untukternak.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen>
    with BerandaLoader<BerandaScreen> {
  static const List<LbKategori> _kategoriList = [
    LbKategori('Semua', Icons.apps_rounded),
    LbKategori('Roti & Bakery', Icons.bakery_dining_rounded),
    LbKategori('Makanan Siap Saji', Icons.lunch_dining_rounded),
    LbKategori('Sayur & Buah', Icons.eco_rounded),
  ];

  @override
  bool get isTernak => false;

  @override
  List<LbKategori> get kategoriList => _kategoriList;

  @override
  Widget build(BuildContext context) {
    return BerandaLayout(
      isTernak: false,
      kategori: _kategoriList,
      selectedKategori: kategoriIndex,
      onKategori: pilihKategori,
      onSearch: cariTeks,
      onFilter: bukaFilter,
      filterAktif: filterAktif,
      loading: loading,
      errorMessage: error,
      onRetry: muatData,
      sectionTitle: 'Paket Kejutan di Sekitarmu',
      items: items,
      onNavTap: (i) => LbNav.go(context, from: 0, to: i),
      onItemTap: (item) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailPaketScreen(item: item)),
      ),
      onSwitch: (keTernak) {
        if (keTernak) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BerandaUntukTernakScreen()),
          );
        }
      },
    );
  }
}
