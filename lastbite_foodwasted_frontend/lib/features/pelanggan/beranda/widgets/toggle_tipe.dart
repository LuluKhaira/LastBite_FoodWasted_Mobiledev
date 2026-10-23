import 'package:flutter/material.dart';
import '../../../../core/tema/tema_lb.dart';

/// Toggle: Untuk Dimakan / Untuk Ternak & Pupuk.
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
      ),
      child: Row(
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        height: 46,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: active
              ? const LinearGradient(colors: [LbColors.sage, LbColors.sageDeep])
              : const LinearGradient(
                  colors: [Colors.transparent, Colors.transparent]),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: LbColors.sage.withValues(alpha: 0.45),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 20, color: active ? Colors.white : LbColors.forest),
              const SizedBox(width: 8),
              Text(
                label,
                style: LbText.heading(
                  13,
                  weight: FontWeight.w600,
                  color: active ? Colors.white : LbColors.forest,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
