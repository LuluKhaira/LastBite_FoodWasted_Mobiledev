import 'package:flutter/material.dart';
import '../../../../core/tema/tema_lb.dart';

/// Tab Aktif / Riwayat beserta jumlahnya.
class TabPesanan extends StatelessWidget {
  final int tab; // 0 aktif, 1 riwayat
  final int jumlahAktif;
  final int jumlahRiwayat;
  final ValueChanged<int> onGanti;

  const TabPesanan({
    super.key,
    required this.tab,
    required this.jumlahAktif,
    required this.jumlahRiwayat,
    required this.onGanti,
  });

  Widget _item(int i, String label, int n) {
    final sel = tab == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => onGanti(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: sel ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: sel
                ? [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ]
                : null,
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(label,
                style: LbText.heading(14,
                    weight: FontWeight.w600,
                    color: sel ? LbColors.forest : LbColors.textGrey)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: sel ? LbColors.forest : const Color(0xFFE3E8D8),
                  borderRadius: BorderRadius.circular(10)),
              child: Text('$n',
                  style: LbText.body(11,
                      weight: FontWeight.w800,
                      color: sel ? Colors.white : LbColors.textGrey)),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: LbColors.sageLight, borderRadius: BorderRadius.circular(28)),
      child: Row(children: [
        _item(0, 'Aktif', jumlahAktif),
        _item(1, 'Riwayat', jumlahRiwayat),
      ]),
    );
  }
}
