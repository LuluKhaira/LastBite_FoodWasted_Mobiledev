import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFFF8F6F2);          // Off White
  static const primary = Color(0xFFA7C957);     // Hijau Sage[cite: 13]
  static const orange = Color(0xFFFFB07C);      // Oranye Peach[cite: 13]
  static const textDark = Color(0xFF2B3A28);    // Dark Forest[cite: 13]
  static const textSoft = Color(0xFF5A6856);    // Muted Sage[cite: 13]

  // Helper TextStyles Berdasarkan Guideline LastBite
  
  // 1. Heading (Poppins) untuk Judul
  static TextStyle heading({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w800,
    Color color = textDark,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  // 2. Body / Isi Teks (Nunito) untuk Deskripsi & Tombol
  static TextStyle body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = textSoft,
  }) {
    return GoogleFonts.nunito(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}