import 'package:flutter/material.dart';
import 'beranda_widgets.dart';
import 'halaman_beranda.dart';
import 'halaman_pesanan.dart';

/// Navigasi antar tab bottom nav.
/// 0 = Beranda, 1 = Pesanan, 2 = Favorit (belum ada), 3 = Profil (belum ada)
class LbNav {
  LbNav._();

  static void go(
    BuildContext context, {
    required int from,
    required int to,
  }) {
    if (from == to) return;

    if (to == 0 || to == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 220),
          pageBuilder: (_, __, ___) =>
              to == 0 ? const BerandaScreen() : const PesananScreen(),
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
            to == 2 ? 'Halaman Favorit segera hadir' : 'Halaman Profil segera hadir',
            style: LbText.body(13, color: Colors.white),
          ),
        ),
      );
  }
}