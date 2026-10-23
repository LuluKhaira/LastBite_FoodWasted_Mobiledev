import 'package:flutter/material.dart';
import '../../../../core/tema/tema_lb.dart';
import '../model_bahan.dart';

/// Filter kategori (chip yang bisa digeser).
class LbKategoriBar extends StatelessWidget {
  final List<LbKategori> kategori;
  final int selected;
  final ValueChanged<int> onSelected;

  const LbKategoriBar({
    super.key,
    required this.kategori,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: kategori.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final active = i == selected;
          final k = kategori[i];

          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                color: active ? null : Colors.white,
                gradient: active
                    ? const LinearGradient(
                        colors: [LbColors.sage, LbColors.sageDeep])
                    : null,
                border: Border.all(
                  color: active ? Colors.transparent : LbColors.border,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: LbColors.sage.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(k.icon,
                      size: 20,
                      color: active ? Colors.white : LbColors.sageDeep),
                  const SizedBox(width: 8),
                  Text(
                    k.label,
                    style: LbText.heading(
                      13,
                      weight: FontWeight.w600,
                      color: active ? Colors.white : LbColors.forest,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
