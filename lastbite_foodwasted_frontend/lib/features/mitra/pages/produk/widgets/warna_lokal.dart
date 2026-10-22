import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';

class WarnaLokal {
  // Hijau Sage yang lebih cerah dan fresh (sesuai brand guide)
  static Color get primary => AppColors.primary; 
  
  // Hijau gelap HANYA untuk teks agar terbaca (jangan terlalu hitam)
  static Color get primaryDark =>
      HSLColor.fromColor(AppColors.primary).withLightness(0.35).toColor();

  // Oranye Peach untuk aksen/badge (menggantikan warna danger yang mencolok)
  static Color get accent => AppColors.orange; 

  // Background hijau sangat pudar untuk container toggle
  static Color get mint =>
      Color.alphaBlend(AppColors.primary.withValues(alpha: 0.08), Colors.white);

  // Background hijau pudar untuk kartu terpilih
  static Color get mintDeep =>
      Color.alphaBlend(AppColors.primary.withValues(alpha: 0.15), Colors.white);

  // Border abu-abu halus
  static Color get border => AppColors.textSoft.withValues(alpha: 0.2);
  
  static Color get bg => AppColors.bg;
  static Color get textDark => AppColors.textDark;
  static Color get textSoft => AppColors.textSoft;
}