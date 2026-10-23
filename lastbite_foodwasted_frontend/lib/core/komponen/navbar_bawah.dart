import 'package:flutter/material.dart';
import '../tema/tema_lb.dart';

/// Bottom nav melayang. Dipakai oleh CangkangUtama (satu kali saja).
class LbBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const LbBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Beranda'),
    (Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Pesanan'),
    (Icons.favorite_border_rounded, Icons.favorite_rounded, 'Favorit'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: LbColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_items.length, (i) {
              final active = i == currentIndex;
              final item = _items[i];

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: active
                          ? LbColors.sage.withValues(alpha: 0.28)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          active ? item.$2 : item.$1,
                          size: 24,
                          color: active ? LbColors.forest : LbColors.textGrey,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.$3,
                          style: LbText.body(
                            11,
                            weight: active ? FontWeight.w800 : FontWeight.w600,
                            color: active ? LbColors.forest : LbColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
