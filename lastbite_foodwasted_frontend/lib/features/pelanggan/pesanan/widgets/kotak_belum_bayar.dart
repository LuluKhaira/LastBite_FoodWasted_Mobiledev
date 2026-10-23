import 'package:flutter/material.dart';
import '../../../../core/tema/tema_lb.dart';
import '../pesanan_model.dart' show lbRp;
import 'tombol_lembut.dart';

/// Status: Menunggu Pembayaran (Midtrans).
class KotakBelumBayar extends StatelessWidget {
  final Map p;
  final VoidCallback onBayar;
  final VoidCallback onCek;

  const KotakBelumBayar({
    super.key,
    required this.p,
    required this.onBayar,
    required this.onCek,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LbColors.peachLight,
        borderRadius: BorderRadius.circular(22),
        border:
            Border.all(color: const Color(0xFFF2C4BC).withValues(alpha: 0.5)),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.payment_rounded,
              color: Color(0xFFD64933), size: 22),
          const SizedBox(width: 6),
          Text('Menunggu Pembayaran',
              style: LbText.heading(15,
                  weight: FontWeight.w700, color: const Color(0xFF9A2B1A))),
        ]),
        const SizedBox(height: 6),
        Text(
          'Total ${lbRp(p['total'] as int)}. Selesaikan pembayaran via Midtrans agar toko segera menyiapkan paketmu.',
          textAlign: TextAlign.center,
          style: LbText.body(12.5),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: TombolLembut(
                  icon: Icons.credit_card_rounded,
                  label: 'Bayar Sekarang',
                  onTap: onBayar,
                  kuat: true)),
          const SizedBox(width: 8),
          Expanded(
              child: TombolLembut(
                  icon: Icons.refresh_rounded,
                  label: 'Cek Status',
                  onTap: onCek)),
        ]),
      ]),
    );
  }
}
