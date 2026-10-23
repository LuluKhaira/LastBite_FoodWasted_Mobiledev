import 'package:flutter/material.dart';
import '../../../../core/tema/tema_lb.dart';
import '../../beranda/widgets/gambar_jaringan.dart';
import '../pesanan_model.dart' show lbRp;

/// Kartu pesanan di tab "Riwayat".
class KartuRiwayat extends StatelessWidget {
  final Map<String, dynamic> p;
  final VoidCallback onNota;
  final VoidCallback onNilai;

  const KartuRiwayat({
    super.key,
    required this.p,
    required this.onNota,
    required this.onNilai,
  });

  @override
  Widget build(BuildContext context) {
    final statusStr = '${p['status']}'.toLowerCase();
    final selesai = statusStr == 'selesai' || statusStr == 'completed';
    final dibatalkan = statusStr == 'dibatalkan' || statusStr == 'cancelled';
    final label = selesai
        ? (p['baru'] == true ? 'Baru Selesai' : 'Selesai')
        : (dibatalkan ? 'Dibatalkan' : 'Gagal');
    final metode = (p['metode'] ?? 'QRIS').toString().toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 64,
              height: 64,
              child: LbNetImage(
                  url: '${p['gambar'] ?? ''}',
                  fallbackIcon: Icons.fastfood_rounded),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text('${p['tanggal']}, ${p['jam']} WIB',
                        style: LbText.body(12, weight: FontWeight.w700))),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: selesai
                        ? LbColors.sageLight
                        : const Color(0xFFFBE3DE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    label,
                    style: LbText.body(11,
                        weight: FontWeight.w800,
                        color: selesai
                            ? LbColors.sageDeep
                            : const Color(0xFFD64933)),
                  ),
                ),
              ]),
              const SizedBox(height: 2),
              Text('${p['penjual']}',
                  style: LbText.heading(15.5, weight: FontWeight.w700)),
              Text('${p['qty']}x ${p['produk']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LbText.body(12.5)),
            ]),
          ),
        ]),
        // Dampak lingkungan
        if (selesai) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5DC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: LbColors.sage.withValues(alpha: 0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.eco_rounded, size: 18, color: LbColors.sageDeep),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Cegah ${p['co2'] ?? '1.25'} kg CO₂e • ${p['makanan'] ?? '0.5'} kg Makanan',
                  style: LbText.body(12,
                      weight: FontWeight.w700, color: LbColors.forest),
                ),
              ),
            ]),
          ),
        ],
        // Info refund
        if (dibatalkan) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0ED),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF2C4BC)),
            ),
            child: Row(children: [
              const Icon(Icons.replay_circle_filled_rounded,
                  size: 18, color: Color(0xFFD64933)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  p['status_bayar'] == 'refund'
                      ? 'Dana ${lbRp(p['total'] as int)} berhasil dikembalikan penuh (Refund Selesai).'
                      : 'Pengembalian dana ${lbRp(p['total'] as int)} sedang diproses via $metode.',
                  style: LbText.body(11.5,
                      weight: FontWeight.w700, color: const Color(0xFF9A2B1A)),
                ),
              ),
            ]),
          ),
        ],
        const SizedBox(height: 12),
        // Total & tombol aksi
        Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Total Pembayaran',
                  style: LbText.body(11, color: LbColors.textGrey)),
              Text(
                '${lbRp(p['total'] as int)} ($metode)',
                style: LbText.heading(16,
                    weight: FontWeight.w700,
                    color: selesai ? LbColors.sageDeep : LbColors.forest),
              ),
            ]),
          ),
          if (selesai) ...[
            GestureDetector(
              onTap: onNota,
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LbColors.sageLight,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: LbColors.sage.withValues(alpha: 0.4)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.receipt_long_rounded,
                      size: 16, color: LbColors.forest),
                  const SizedBox(width: 4),
                  Text('Nota',
                      style: LbText.heading(12,
                          weight: FontWeight.w700, color: LbColors.forest)),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            if (p['rating'] == null)
              GestureDetector(
                onTap: onNilai,
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: LbColors.sageDeep,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.star_rounded,
                        color: Colors.white, size: 17),
                    const SizedBox(width: 4),
                    Text('Beri Nilai',
                        style: LbText.heading(12,
                            weight: FontWeight.w600, color: Colors.white)),
                  ]),
                ),
              )
            else
              Row(children: [
                const Icon(Icons.star_rounded,
                    color: Color(0xFFF2A93B), size: 18),
                const SizedBox(width: 3),
                Text('${p['rating']}',
                    style: LbText.body(13, weight: FontWeight.w800)),
              ]),
          ],
        ]),
      ]),
    );
  }
}
