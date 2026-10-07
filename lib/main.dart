// ============================================================
// LastBite - lib/main.dart (titik awal aplikasi)
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_colors.dart';
import 'features/pelanggan/halaman/welcome_screen.dart';

void main() {
  runApp(const LastBiteApp());
}

class LastBiteApp extends StatelessWidget {
  const LastBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LastBite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppColors.primary,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      ),
      home: const WelcomeScreen(),
    );
  }
}