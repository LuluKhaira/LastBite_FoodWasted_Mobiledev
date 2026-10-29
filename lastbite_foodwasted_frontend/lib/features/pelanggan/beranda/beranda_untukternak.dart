import 'package:flutter/material.dart';
import 'beranda_widgets.dart';
import 'beranda_loader.dart';
import 'detail_paket.dart';
import 'halaman_toko.dart';
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
  @override
  bool get isTernak => true;

  @override
  Widget build(BuildContext context) {
    return BerandaLayout(
      isTernak: true,
      onSearch: cariTeks,
      loading: loading,
      errorMessage: error,
      onRetry: muatData,
      sectionTitle: 'Penyedia Bahan Organik Terdekat',
      items: items,
      onNavTap: (i) => LbNav.go(context, from: 0, to: i),
      onTokoTap: (toko) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TokoScreen(toko: toko)),
      ),
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