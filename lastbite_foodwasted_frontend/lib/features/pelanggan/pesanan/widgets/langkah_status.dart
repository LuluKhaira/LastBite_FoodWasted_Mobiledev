import 'package:flutter/material.dart';
import '../../../../core/tema/tema_lb.dart';

/// Stepper: Dibayar -> Siap Diambil -> Selesai.
/// [step]: 0 = Dibayar, 1 = Siap Diambil, 2 = Selesai.
class LangkahStatus extends StatelessWidget {
  final int step;
  const LangkahStatus({super.key, required this.step});

  Widget _dot(int i, IconData icon, String label) {
    final done = i < step;
    final now = i == step;
    final active = done || now;

    return Column(children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? LbColors.sageDeep : LbColors.sageLight,
          border: now
              ? Border.all(
                  color: LbColors.forest.withValues(alpha: 0.35), width: 4)
              : null,
        ),
        child: Icon(
          done ? Icons.check_rounded : icon,
          size: 20,
          color: active ? Colors.white : LbColors.textGrey,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: LbText.body(
          11,
          weight: now ? FontWeight.w800 : FontWeight.w600,
          color: active ? LbColors.forest : LbColors.textGrey,
        ),
      ),
    ]);
  }

  Widget _garis(bool aktif) => Expanded(
        child: Container(
          height: 3,
          margin: const EdgeInsets.only(bottom: 18),
          color: aktif ? LbColors.sageDeep : LbColors.sageLight,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _dot(0, Icons.payments_outlined, 'Dibayar'),
      _garis(step >= 1),
      _dot(1, Icons.storefront_outlined, 'Siap Diambil'),
      _garis(step >= 2),
      _dot(2, Icons.done_all_rounded, 'Selesai'),
    ]);
  }
}
