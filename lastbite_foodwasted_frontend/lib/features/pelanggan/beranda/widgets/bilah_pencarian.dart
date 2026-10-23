import 'package:flutter/material.dart';
import '../../../../core/tema/tema_lb.dart';

class LbSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilter; // dipanggil saat tombol filter ditekan
  final bool filterAktif; // true = tampilkan titik penanda

  const LbSearchBar({
    super.key,
    this.onChanged,
    this.onFilter,
    this.filterAktif = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.only(left: 18, right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: LbColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: LbColors.forest, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              cursorColor: LbColors.sageDeep,
              style: LbText.body(14, color: LbColors.forest),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Cari makanan, resto, atau pakan ternak...',
                hintStyle: LbText.body(14, color: LbColors.textGrey),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onFilter,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: filterAktif ? LbColors.sage : LbColors.sageLight,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.tune_rounded,
                      size: 22, color: LbColors.forest),
                  if (filterAktif)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: LbColors.peach,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
