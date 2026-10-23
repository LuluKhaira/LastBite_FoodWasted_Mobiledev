import 'package:flutter/material.dart';
import '../../../../core/tema/tema_lb.dart';

/// Status: Menunggu Konfirmasi & Penyiapan.
class KotakMenunggu extends StatelessWidget {
  final Map p;
  const KotakMenunggu({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    final estWaktu = p['estimasi_waktu'] ?? '18.45 WIB';
    final estMin = p['estimasi_menit'] ?? 20;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6E6),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LbColors.sage.withValues(alpha: 0.35)),
      ),
      child: Column(children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
              color: LbColors.sageLight, shape: BoxShape.circle),
          child: const Icon(Icons.hourglass_bottom_rounded,
              color: LbColors.sageDeep, size: 30),
        ),
        const SizedBox(height: 12),
        Text(
          'Menunggu Konfirmasi & Penyiapan',
          textAlign: TextAlign.center,
          style: LbText.heading(16, weight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Toko sedang mengemas paket kejutanmu. QR pengambilan akan otomatis aktif setelah pesanan siap.',
          textAlign: TextAlign.center,
          style: LbText.body(12.5, height: 1.45),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.schedule_rounded,
                size: 16, color: LbColors.sageDeep),
            const SizedBox(width: 6),
            Text(
              'Estimasi siap: $estWaktu (± $estMin mnt)',
              style: LbText.body(12,
                  weight: FontWeight.w800, color: LbColors.forest),
            ),
          ]),
        ),
      ]),
    );
  }
}
