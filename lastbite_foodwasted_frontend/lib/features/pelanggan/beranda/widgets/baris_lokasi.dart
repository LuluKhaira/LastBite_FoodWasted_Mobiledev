import 'package:flutter/material.dart';
import '../../../../core/komponen/animasi_lb.dart';
import '../../../../core/tema/tema_lb.dart';

/// Lokasi + radius. Dirancang untuk di atas header hijau.
class LbLocationRow extends StatelessWidget {
  final VoidCallback? onLokasi;
  final VoidCallback? onRadius;

  const LbLocationRow({super.key, this.onLokasi, this.onRadius});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LbTekan(
          onTap: onLokasi,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
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
        ),
        const SizedBox(width: 10),
        LbTekan(
          onTap: onRadius,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
            ),
            child: Text(
              '3 km',
              style: LbText.heading(13,
                  weight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
