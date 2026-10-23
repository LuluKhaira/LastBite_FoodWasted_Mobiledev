import 'package:flutter/material.dart';
import '../../../../core/tema/tema_lb.dart';

class TombolLembut extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool kuat;

  const TombolLembut({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.kuat = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: kuat ? LbColors.sage.withValues(alpha: 0.55) : LbColors.sageLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 18, color: LbColors.forest),
          const SizedBox(width: 6),
          Text(label,
              style: LbText.heading(13.5,
                  weight: FontWeight.w600, color: LbColors.forest)),
        ]),
      ),
    );
  }
}
