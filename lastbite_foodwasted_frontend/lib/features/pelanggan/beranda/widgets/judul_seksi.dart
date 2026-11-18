import 'package:flutter/material.dart';
import '../../../../core/komponen/animasi_lb.dart';
import '../../../../core/tema/tema_lb.dart';

class LbSectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onLihatPeta;
  final String? subtitle;
  final VoidCallback? onReset;

  const LbSectionTitle({
    super.key,
    required this.title,
    this.onLihatPeta,
    this.subtitle,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    // Tampilan dengan Reset & Subtitle (Mockup Beranda Baru)
    if (onReset != null || subtitle != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: LbText.heading(
                    17,
                    weight: FontWeight.w700,
                    color: const Color(0xFF212B27),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: LbText.body(
                      12,
                      weight: FontWeight.w500,
                      color: const Color(0xFF717D6E),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onReset != null)
            LbTekan(
              onTap: onReset,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Reset',
                      style: LbText.heading(
                        13.5,
                        weight: FontWeight.w600,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.refresh_rounded,
                      size: 17,
                      color: Color(0xFF2E7D32),
                    ),
                  ],
                ),
              ),
            )
          else if (onLihatPeta != null)
            _buildTombolPeta(),
        ],
      );
    }

    // Tampilan standar lama (dengan lingkaran ikon eco)
    return Row(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.4, end: 1),
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          builder: (context, v, child) =>
              Transform.scale(scale: v, child: child),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: LbColors.sageLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco_rounded,
                size: 21, color: LbColors.sageDeep),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              title,
              key: ValueKey(title),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: LbText.heading(16, weight: FontWeight.w700, height: 1.25),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (onLihatPeta != null) _buildTombolPeta(),
      ],
    );
  }

  Widget _buildTombolPeta() {
    return LbTekan(
      onTap: onLihatPeta,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: LbColors.sageLight,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Lihat Peta',
              style: LbText.body(13,
                  weight: FontWeight.w700, color: LbColors.sageDeep),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.map_outlined, size: 18, color: LbColors.sageDeep),
          ],
        ),
      ),
    );
  }
}
