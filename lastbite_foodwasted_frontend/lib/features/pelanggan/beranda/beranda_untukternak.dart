import 'package:flutter/material.dart';
import 'beranda_widgets.dart';
import 'beranda_loader.dart';
import 'detail_paket.dart';
import 'lb_nav.dart';
import 'halaman_beranda.dart';

class BerandaUntukTernakScreen extends StatefulWidget {
  const BerandaUntukTernakScreen({super.key});

  @override
  State<BerandaUntukTernakScreen> createState() =>
      _BerandaUntukTernakScreenState();
}

class _BerandaUntukTernakScreenState extends State<BerandaUntukTernakScreen>
    with BerandaLoader<BerandaUntukTernakScreen> {
  static const List<LbKategori> _kategoriList = [
    LbKategori('Semua', Icons.apps_rounded),
    LbKategori('Pakan Ternak', Icons.agriculture_rounded),
    LbKategori('Bahan Pupuk', Icons.eco_rounded),
  ];

  @override
  bool get isTernak => true;

  @override
  List<LbKategori> get kategoriList => _kategoriList;

  @override
  Widget build(BuildContext context) {
    return BerandaLayout(
      isTernak: true,
      kategori: _kategoriList,
      selectedKategori: kategoriIndex,
      onKategori: pilihKategori,
      onSearch: cariTeks,
      onFilter: bukaFilter,
      filterAktif: filterAktif,
      loading: loading,
      errorMessage: error,
      onRetry: muatData,
      sectionTitle: 'Pasokan Bahan Organik Terdekat',
      items: items,
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
