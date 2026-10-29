import 'package:flutter/material.dart';
import '../../../../core/komponen/animasi_lb.dart';
import '../../../../core/tema/tema_lb.dart';
import 'logo_lb.dart';

/// Header Hijau Utama Pelanggan (Diselaraskan persis dengan gaya & nuansa Mitra)
class LbHeaderHijau extends StatelessWidget {
  final List<Widget> children;

  const LbHeaderHijau({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        // Gradasi hijau segar khas LastBite (sama persis dengan dashboard mitra)
        gradient: const LinearGradient(
          colors: [LbColors.sage, LbColors.sageDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: LbColors.sageDeep.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris Atas: Logo & Judul
            Row(
              children: [
                Row(
                  children: [
                    const LbLogoMark(
                      size: 44,
                      circle: true,
                      shadow: true,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LASTBITE',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          'Beranda Pelanggan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Widget anak (Lokasi & Kolom Pencarian)
            ...children,
          ],
        ),
      ),
    );
  }
}