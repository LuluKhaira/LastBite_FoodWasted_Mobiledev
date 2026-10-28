import 'package:flutter/material.dart';
import '../../../core/tema/tema_lb.dart';
import 'detail_paket.dart';
import 'model_toko.dart';
import 'widgets/kartu_paket.dart';

/// Halaman satu toko/mitra/petani: info toko + semua paketnya.
class TokoScreen extends StatelessWidget {
  final TokoGroup toko;

  const TokoScreen({super.key, required this.toko});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LbColors.offWhite,
      appBar: AppBar(
        backgroundColor: LbColors.offWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: LbColors.forest),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          toko.nama,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: LbText.heading(16, weight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          // ---------- INFO TOKO ----------
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: LbColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: LbColors.sageLight,
                    shape: BoxShape.circle,
                  ),
                  child: Text(toko.inisial,
                      style: LbText.heading(20, weight: FontWeight.w700)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(toko.nama,
                          style: LbText.heading(16, weight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 16, color: Color(0xFFF5A623)),
                          const SizedBox(width: 3),
                          Text(toko.rating,
                              style: LbText.body(12.5, weight: FontWeight.w700)),
                          Text('  •  ${toko.jarak}  •  ${toko.waktu}',
                              style: LbText.body(12.5)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: LbColors.textGrey),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(toko.alamat,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: LbText.body(12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${toko.jumlahPaket} paket dari toko ini',
            style: LbText.heading(15, weight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          // ---------- SEMUA PAKET ----------
          for (var i = 0; i < toko.items.length; i++) ...[
            BahanCard(
              item: toko.items[i],
              index: i,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailPaketScreen(item: toko.items[i]),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}