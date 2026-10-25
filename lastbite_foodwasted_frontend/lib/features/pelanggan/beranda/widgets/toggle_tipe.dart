import 'package:flutter/material.dart';
import '../../../../core/tema/tema_lb.dart';

/// Toggle: Untuk Dimakan / Untuk Ternak & Pupuk.
/// Pil hijau meluncur ke sisi yang dipilih.
class LbTypeToggle extends StatelessWidget {
  final bool isTernak;
  final ValueChanged<bool> onChanged; // true = ternak

  const LbTypeToggle({
    super.key,
    required this.isTernak,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: LbColors.border),
        boxShadow: [
          BoxShadow(
            color: LbColors.sageDeep.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SizedBox(
        height: 46,
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 340),
              curve: Curves.easeOutCubic,
              alignment:
                  isTernak ? Alignment.centerRight : Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [LbColors.sage, LbColors.sageDeep],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: LbColors.sage.withValues(alpha: 0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _Segment(
                    label: 'Untuk Dimakan',
                    icon: Icons.restaurant_rounded,
                    active: !isTernak,
                    onTap: () => onChanged(false),
                  ),
                ),
                Expanded(
                  child: _Segment(
                    label: 'Untuk Ternak & Pupuk',
                    icon: Icons.pets_rounded,
                    active: isTernak,
                    onTap: () => onChanged(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final warna = active ? Colors.white : LbColors.forest;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: warna),
            duration: const Duration(milliseconds: 260),
            builder: (context, c, _) {
              final w = c ?? warna;
              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: active ? 1.12 : 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      child: Icon(icon, size: 20, color: w),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: LbText.heading(13,
                          weight: FontWeight.w600, color: w),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
