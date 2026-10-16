import 'package:flutter/material.dart';
import 'halaman_beranda.dart';
import 'halaman_pesanan.dart';
import '../favorit/halaman_favorit.dart';
import '../profil/halaman_profil.dart';

/// Navigasi antar tab bottom nav.
/// 0 = Beranda, 1 = Pesanan, 2 = Favorit, 3 = Profil
class LbNav {
  LbNav._();

  static void go(
    BuildContext context, {
    required int from,
    required int to,
  }) {
    if (from == to) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (ctx, __, ___) {
          if (to == 0) return const BerandaScreen();
          if (to == 1) return const PesananScreen();
          if (to == 2) return const FavoritScreen();
          return ProfilScreen(
            // setelah logout: buang semua halaman, kembali ke halaman awal
            // aplikasi (route '/' = home di MaterialApp)
            onLoggedOut: () =>
                Navigator.of(ctx).pushNamedAndRemoveUntil('/', (_) => false),
          );
        },
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }
}