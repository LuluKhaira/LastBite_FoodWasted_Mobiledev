import 'package:flutter/material.dart';
import '../../../../core/komponen/animasi_lb.dart';
import '../../../../core/tema/tema_lb.dart';
import '../model_bahan.dart';
import 'gambar_jaringan.dart';

/// Kartu produk di daftar beranda. Mengecil sedikit saat ditekan.
/// (Favorit disimpan dari halaman Detail Paket, bukan dari kartu ini.)
class BahanCard extends StatelessWidget {
  final BahanItem item;
  final int index;
  final VoidCallback? onTap;

  const BahanCard({
    super.key,
    required this.item,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final it = item;
    final logoColor = index.isEven ? LbColors.sageDeep : LbColors.peach;
    final habis = it.badge == 'Habis';

    return LbTekan(
      onTap: onTap,
      skala: 0.97,
      child: Opacity(
        opacity: habis ? 0.65 : 1,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: LbColors.border),
            boxShadow: [
              BoxShadow(
                color: LbColors.sageDeep.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---------------- GAMBAR ----------------
                SizedBox(
                  width: 118,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LbNetImage(url: it.gambar),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: it.isSedekah
                                ? const Color(0xFF059669)
                                : Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (it.isSedekah) ...[
                                const Icon(Icons.volunteer_activism_rounded,
                                    size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  'Sedekah',
                                  style: LbText.body(10.5,
                                      weight: FontWeight.w800,
                                      color: Colors.white),
                                ),
                              ] else ...[
                                Text(
                                  it.badge,
                                  style: LbText.body(11,
                                      weight: FontWeight.w800,
                                      color: LbColors.forest),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: logoColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            it.inisial,
                            style: LbText.heading(10.5,
                                weight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // ---------------- DETAIL ----------------
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: LbColors.sageLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 15, color: LbColors.sageDeep),
                              const SizedBox(width: 3),
                              Text(
                                it.rating,
                                style: LbText.body(12,
                                    weight: FontWeight.w800,
                                    color: LbColors.forest),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        it.nama,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: LbText.heading(14,
                            weight: FontWeight.w600, height: 1.3),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        it.penjual,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LbText.body(12, weight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 1),
                            child: Icon(Icons.schedule_rounded,
                                size: 14, color: LbColors.textGrey),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'Ambil hari ini: ${it.waktu} | ${it.jarak}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: LbText.body(10.5, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(it.tagIcon, size: 14, color: LbColors.sageDeep),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              it.tag,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: LbText.body(11.5,
                                  weight: FontWeight.w700,
                                  color: LbColors.sageDeep),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (it.hargaAsli != null)
                        Text(
                          it.hargaAsli!,
                          style: LbText.body(11).copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                it.isSedekah ? 'Gratis' : it.harga,
                                style: LbText.heading(19, weight: FontWeight.w800).copyWith(
                                  color: it.isSedekah ? const Color(0xFF059669) : null,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: it.isSedekah
                                  ? const Color(0xFFD1FAE5)
                                  : (it.gratis
                                      ? LbColors.sageLight
                                      : LbColors.peachLight),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              it.isSedekah ? 'Sedekah' : it.satuan,
                              style: LbText.body(
                                11,
                                weight: FontWeight.w700,
                                color: it.isSedekah
                                    ? const Color(0xFF047857)
                                    : (it.gratis
                                        ? LbColors.sageDeep
                                        : LbColors.peachDeep),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kerangka kartu saat data masih dimuat (berkedip pelan).
class KartuKerangka extends StatelessWidget {
  const KartuKerangka({super.key});

  Widget _kotak(double w, double h, {double r = 10}) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: LbColors.sageLight,
          borderRadius: BorderRadius.circular(r),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return LbBerkedip(
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: LbColors.border),
        ),
        child: Row(
          children: [
            _kotak(118, double.infinity, r: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kotak(140, 14),
                  const SizedBox(height: 8),
                  _kotak(90, 12),
                  const SizedBox(height: 10),
                  _kotak(double.infinity, 10),
                  const Spacer(),
                  _kotak(110, 22),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
