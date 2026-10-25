import 'package:flutter/material.dart';
import '../../../../core/komponen/animasi_lb.dart';
import '../../../../core/tema/tema_lb.dart';

class LbSectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onLihatPeta;

  const LbSectionTitle({super.key, required this.title, this.onLihatPeta});

  @override
  Widget build(BuildContext context) {
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
        LbTekan(
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
                const Icon(Icons.map_outlined,
                    size: 18, color: LbColors.sageDeep),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
