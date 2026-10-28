import 'package:flutter/material.dart';
import '../../../../../core/tema/tema_lb.dart';
import '../model_bahan.dart';
import '../model_toko.dart';

/// Kartu satu toko di beranda: info toko di atas, paket-paketnya
/// bisa digeser ke samping di bawahnya.
class KartuToko extends StatelessWidget {
  final TokoGroup toko;
  final VoidCallback? onTokoTap;
  final ValueChanged<BahanItem>? onItemTap;

  const KartuToko({
    super.key,
    required this.toko,
    this.onTokoTap,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LbColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- INFO TOKO ----------
          InkWell(
            onTap: onTokoTap,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 10, 0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: LbColors.sageLight,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      toko.inisial,
                      style: LbText.heading(16, weight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          toko.nama,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LbText.heading(14, weight: FontWeight.w600),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 15, color: Color(0xFFF5A623)),
                            const SizedBox(width: 2),
                            Text(toko.rating,
                                style: LbText.body(12, weight: FontWeight.w700)),
                            _titik(),
                            Flexible(
                              child: Text(toko.jarak,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: LbText.body(12)),
                            ),
                            _titik(),
                            Flexible(
                              child: Text(toko.waktu,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: LbText.body(12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: LbColors.sageLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${toko.jumlahPaket} paket',
                      style: LbText.body(11, weight: FontWeight.w700,
                          color: LbColors.forest),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: LbColors.textGrey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ---------- PAKET (geser ke samping) ----------
          SizedBox(
            height: 164,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: toko.items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => _ProdukMini(
                item: toko.items[i],
                onTap: onItemTap == null ? null : () => onItemTap!(toko.items[i]),
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _titik() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Container(
          width: 3,
          height: 3,
          decoration: const BoxDecoration(
            color: LbColors.textGrey,
            shape: BoxShape.circle,
          ),
        ),
      );
}

class _ProdukMini extends StatelessWidget {
  final BahanItem item;
  final VoidCallback? onTap;

  const _ProdukMini({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final habis = item.badge == 'Habis';

    return SizedBox(
      width: 124,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 124,
                height: 88,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _foto(item.gambar),
                    if (habis) Container(color: Colors.white.withValues(alpha: 0.6)),
                    Positioned(
                      left: 6,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: habis ? LbColors.textGrey : LbColors.forest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item.badge,
                          style: LbText.body(10,
                              weight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.nama,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: LbText.body(12,
                  weight: FontWeight.w700, color: LbColors.forest, height: 1.25),
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  item.gratis ? 'Gratis' : item.harga,
                  style: LbText.heading(12.5,
                      weight: FontWeight.w700, color: LbColors.peachDeep),
                ),
                if (item.hargaAsli != null) ...[
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      item.hargaAsli!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LbText.body(10.5).copyWith(
                          decoration: TextDecoration.lineThrough),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _foto(String url) {
    Widget kosong() => Container(
          color: LbColors.sageLight,
          alignment: Alignment.center,
          child: const Icon(Icons.restaurant_rounded,
              color: LbColors.sageDeep, size: 26),
        );
    if (url.isEmpty) return kosong();
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, p) =>
          p == null ? child : Container(color: LbColors.sageLight),
      errorBuilder: (_, __, ___) => kosong(),
    );
  }
}