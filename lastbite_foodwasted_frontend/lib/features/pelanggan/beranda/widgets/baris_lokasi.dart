import 'package:flutter/material.dart';
import '../../../../core/tema/tema_lb.dart';

class LbLocationRow extends StatelessWidget {
  const LbLocationRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF4E3),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on_rounded,
                  size: 19, color: LbColors.sageDeep),
              const SizedBox(width: 6),
              Text('Batam Center',
                  style: LbText.heading(13, weight: FontWeight.w600)),
              const SizedBox(width: 2),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 20, color: LbColors.forest),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: LbColors.sage.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text('3 km', style: LbText.heading(13, weight: FontWeight.w600)),
        ),
      ],
    );
  }
}
