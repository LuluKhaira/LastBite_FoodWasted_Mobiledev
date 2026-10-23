import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color bg = Color(0xFFFFFBF5);
  static const Color primary = Color(0xFF8BC34A);
  static const Color orange = Color(0xFFFF9800);
  static const Color textDark = Color(0xFF2D2D2D);
  static const Color textSoft = Color(0xFF8A8A8A);

  static TextStyle heading({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w700,
    Color color = textDark,
    double? height, 
    double? letterSpacing, // <--- TAMBAHKAN INI
  }) =>
      GoogleFonts.poppins(
        fontSize: fontSize, 
        fontWeight: fontWeight, 
        color: color, 
        height: height,
        letterSpacing: letterSpacing, // <--- TAMBAHKAN INI
      );

  static TextStyle body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = textDark,
    double? height,
    double? letterSpacing, // <--- TAMBAHKAN INI
  }) =>
      GoogleFonts.nunito(
        fontSize: fontSize, 
        fontWeight: fontWeight, 
        color: color, 
        height: height,
        letterSpacing: letterSpacing, // <--- TAMBAHKAN INI
      );

        // Warna tambahan untuk halaman pelanggan
  static const Color hijauTua = Color(0xFF2D5016);
  static const Color zaitun = Color(0xFF86A22F);
  static const Color hijauMuda = Color(0xFFF0F4E3);
  static const Color latar = Color(0xFFF7F6F2);
  static const Color teksSoft = Color(0xFF7A7F6E);
  static const Color merahMuda = Color(0xFFFFDDD6);
  static const Color merah = Color(0xFFB3261E);
}