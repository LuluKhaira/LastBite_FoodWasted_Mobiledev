import 'package:flutter/material.dart';
import 'beranda_widgets.dart';
import 'beranda_loader.dart';
import 'detail_paket.dart';
import 'halaman_toko.dart';
import 'lb_nav.dart';
import 'beranda_untukternak.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen>
    with BerandaLoader<BerandaScreen> {
  @override
  bool get isTernak => false;

  @override
  Widget build(BuildContext context) {
    return BerandaLayout(
      isTernak: false,
      onSearch: cariTeks,
      loading: loading,
      errorMessage: error,
      onRetry: muatData,
      sectionTitle: 'Toko dengan Paket Kejutan',
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