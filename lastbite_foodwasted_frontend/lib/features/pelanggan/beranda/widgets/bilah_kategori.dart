import 'package:flutter/material.dart';
import '../../../../core/komponen/animasi_lb.dart';
import '../../../../core/tema/tema_lb.dart';
import '../model_bahan.dart';

/// Filter kategori (chip yang bisa digeser). Chip masuk berurutan dari kanan.
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
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(vertical: 2),
        itemCount: kategori.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final active = i == selected;
          final k = kategori[i];

          return LbMuncul(
            urutan: i < 5 ? i : 0,
            jeda: const Duration(milliseconds: 60),
            dari: const Offset(24, 0),
            child: LbTekan(
              onTap: () => onSelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOut,
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
                            color: LbColors.sage.withValues(alpha: 0.45),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: active ? 1.15 : 1,
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutBack,
                      child: Icon(
                        k.icon,
                        size: 20,
                        color: active ? Colors.white : LbColors.sageDeep,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 260),
                      style: LbText.heading(
                        13,
                        weight: FontWeight.w600,
                        color: active ? Colors.white : LbColors.forest,
                      ),
                      child: Text(k.label),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
