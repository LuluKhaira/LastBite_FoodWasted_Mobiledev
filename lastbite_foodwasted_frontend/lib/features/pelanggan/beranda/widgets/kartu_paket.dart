import 'package:flutter/material.dart';
import '../../../../core/tema/tema_lb.dart';
import '../model_bahan.dart';
import 'gambar_jaringan.dart';

/// Kartu produk di daftar beranda.
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: LbColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
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
                        borderRadius: BorderRadius.circular(18),
                        child: LbNetImage(url: it.gambar),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          it.badge,
                          style: LbText.body(11,
                              weight: FontWeight.w800, color: LbColors.forest),
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
                              it.harga,
                              style:
                                  LbText.heading(19, weight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: it.gratis
                                ? LbColors.sageLight
                                : LbColors.peachLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            it.satuan,
                            style: LbText.body(
                              11,
                              weight: FontWeight.w700,
                              color: it.gratis
                                  ? LbColors.sageDeep
                                  : LbColors.peachDeep,
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
    );
  }
}