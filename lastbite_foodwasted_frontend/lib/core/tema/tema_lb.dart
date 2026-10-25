import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// WARNA LASTBITE
// Disamakan dengan aplikasi Mitra (hijau #8BC34A, latar krem #FFFBF5)
// ============================================================
class LbColors {
  LbColors._();

  static const Color offWhite = Color(0xFFFFFBF5); // background (sama dgn mitra)
  static const Color sage = Color(0xFF8BC34A); // hijau utama (sama dgn mitra)
  static const Color peach = Color(0xFFFFB07C); // oranye peach

  static const Color sageDeep = Color(0xFF689F38); // ikon / teks hijau
  static const Color sageLight = Color(0xFFEFF5E1); // chip & latar lembut
  static const Color peachLight = Color(0xFFFFEADB);
  static const Color peachDeep = Color(0xFFC9692F);

  static const Color forest = Color(0xFF2F4F2A); // judul & teks utama
  static const Color textGrey = Color(0xFF7B8374); // teks sekunder
  static const Color border = Color(0xFFEFEBE3);

  // Header hijau (dipakai di semua halaman pelanggan)
  static const Color headerAtas = Color(0xFF9CCC5A);
  static const Color headerBawah = Color(0xFF8BC34A);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [headerAtas, headerBawah],
  );
}

// ============================================================
// FONT: Poppins (heading) + Nunito (isi teks)
// ============================================================
class LbText {
  LbText._();

  static TextStyle heading(
    double size, {
    FontWeight weight = FontWeight.w600,
    Color color = LbColors.forest,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w500,
    Color color = LbColors.textGrey,
    double? height,
  }) {
    return GoogleFonts.nunito(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }
}
