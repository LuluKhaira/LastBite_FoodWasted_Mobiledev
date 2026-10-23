import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// WARNA LASTBITE
// ============================================================
class LbColors {
  LbColors._();

  static const Color offWhite = Color(0xFFF8F6F2); // background
  static const Color sage = Color(0xFFA7C957); // hijau sage
  static const Color peach = Color(0xFFFFB07C); // oranye peach

  static const Color sageDeep = Color(0xFF86A83A);
  static const Color sageLight = Color(0xFFEDF3DC);
  static const Color peachLight = Color(0xFFFFEADB);
  static const Color peachDeep = Color(0xFFC9692F);

  static const Color forest = Color(0xFF2F4F2A); // judul & teks utama
  static const Color textGrey = Color(0xFF7B8374); // teks sekunder
  static const Color border = Color(0xFFEAE7E0);
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
