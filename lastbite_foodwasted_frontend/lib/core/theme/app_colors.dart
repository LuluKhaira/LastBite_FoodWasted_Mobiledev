import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color bg = Color(0xFFFFFBF5);        // sesuaikan dengan desain
  static const Color primary = Color(0xFF8BC34A);   // sesuaikan
  static const Color orange = Color(0xFFFF9800);    // sesuaikan
  static const Color textDark = Color(0xFF2D2D2D);  // sesuaikan
  static const Color textSoft = Color(0xFF8A8A8A);  // sesuaikan

  static TextStyle heading({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w700,
    Color color = textDark,
  }) =>
      GoogleFonts.poppins(fontSize: fontSize, fontWeight: fontWeight, color: color);

  static TextStyle body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = textDark,
  }) =>
      GoogleFonts.nunito(fontSize: fontSize, fontWeight: fontWeight, color: color);
}