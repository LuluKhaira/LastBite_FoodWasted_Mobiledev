import 'package:flutter/material.dart';
import 'beranda_widgets.dart';
import 'halaman_beranda.dart';
import 'halaman_pesanan.dart';
import 'halaman_profil.dart';

/// Navigasi antar tab bottom nav.
/// 0 = Beranda, 1 = Pesanan, 2 = Favorit (belum ada), 3 = Profil
class LbNav {
  LbNav._();

  static void go(
    BuildContext context, {
    required int from,
    required int to,
  }) {
    if (from == to) return;

    if (to == 0 || to == 1 || to == 3) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 220),
          pageBuilder: (ctx, __, ___) {
            if (to == 0) return const BerandaScreen();
            if (to == 1) return const PesananScreen();
            return ProfilScreen(
              // setelah logout: buang semua halaman, kembali ke halaman awal
              // aplikasi (route '/' = home di MaterialApp)
              onLoggedOut: () => Navigator.of(ctx)
                  .pushNamedAndRemoveUntil('/', (_) => false),
            );
          },
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: LbColors.forest,
          content: Text(
            'Halaman Favorit segera hadir',
            style: LbText.body(13, color: Colors.white),
          ),
        ),
      );
  }
}