import 'package:flutter/material.dart';
import '../../../../core/tema/tema_lb.dart';
import '../../beranda/widgets/gambar_jaringan.dart';
import '../pesanan_model.dart';
import 'kartu_nilai.dart';

/// Bagian "Rincian Toko & Item": nama toko, alamat, dan paket yang dibeli.
class KartuTokoNilai extends StatelessWidget {
  final String penjual;
  final String alamat;
  final String produk;
  final String gambar;
  final int qty;
  final int hargaSatuan;
  final int hargaAsliSatuan;

  const KartuTokoNilai({
    super.key,
    required this.penjual,
    required this.alamat,
    required this.produk,
    required this.gambar,
    required this.qty,
    required this.hargaSatuan,
    required this.hargaAsliSatuan,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = hargaSatuan * qty;
    final asli = hargaAsliSatuan * qty;
    final hemat = (asli > subtotal && asli > 0)
        ? (((asli - subtotal) / asli) * 100).round()
        : 0;

    return KartuNilai(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rincian Toko & Item',
              style: LbText.heading(15, weight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 58,
                  height: 58,
                  child: LbNetImage(url: gambar, fallbackIcon: Icons.fastfood_rounded),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(penjual,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: LbText.heading(16,
                            weight: FontWeight.w700, height: 1.2)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 15, color: LbColors.textGrey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(alamat,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: LbText.body(12.5)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LbColors.sage.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: LbNetImage(url: gambar, fallbackIcon: Icons.fastfood_rounded),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${qty}x $produk',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: LbText.heading(14, weight: FontWeight.w600)),
                      if (hemat > 0) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: LbColors.peachLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('Hemat $hemat%',
                                  style: LbText.heading(11,
                                      weight: FontWeight.w700,
                                      color: const Color(0xFFB4532A))),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                lbRp(asli),
                                overflow: TextOverflow.ellipsis,
                                style: LbText.body(11.5).copyWith(
                                    decoration: TextDecoration.lineThrough),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(lbRp(subtotal),
                    style: LbText.heading(15,
                        weight: FontWeight.w700, color: LbColors.sageDeep)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}