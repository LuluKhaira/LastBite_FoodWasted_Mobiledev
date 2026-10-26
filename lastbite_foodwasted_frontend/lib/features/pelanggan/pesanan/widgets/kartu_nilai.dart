import 'package:flutter/material.dart';

/// Pembungkus kartu putih bersudut bulat yang dipakai semua bagian
/// halaman Beri Nilai, supaya tampilannya seragam.
class KartuNilai extends StatelessWidget {
  final Widget child;

  const KartuNilai({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}