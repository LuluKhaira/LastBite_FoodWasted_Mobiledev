import 'package:flutter/material.dart';

import '../beranda/beranda_widgets.dart';
import '../beranda/pesanan_model.dart' show lbRp;
import 'model_favorit.dart';

/// Kartu satu toko di halaman Favorit.
class KartuFavorit extends StatelessWidget {
  final TokoFavorit toko;
  final VoidCallback onBuka; // tap kartu / tombol Pesan
  final VoidCallback onIngatkan; // tombol Ingatkan
  final VoidCallback onHapus; // tap ikon hati

  const KartuFavorit({
    super.key,
    required this.toko,
    required this.onBuka,
    required this.onIngatkan,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toko.tersedia ? onBuka : null,
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- gambar ----------
            SizedBox(
              width: 92,
              height: 92,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: toko.gambar.isEmpty
                    ? Container(
                        color: LbColors.sageLight,
                        alignment: Alignment.center,
                        child: const Icon(Icons.storefront_rounded,
                            color: LbColors.sageDeep, size: 32),
                      )
                    : LbNetImage(
                        url: toko.gambar,
                        fallbackIcon: Icons.storefront_rounded,
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // ---------- detail ----------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          toko.nama,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LbText.heading(15, weight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onHapus,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.favorite_rounded,
                              size: 24, color: Color(0xFFE5484D)),
                        ),
                      ),
                    ],
                  ),
                  if (toko.infoLokasi.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      toko.infoLokasi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LbText.body(12),
                    ),
                  ],
                  const SizedBox(height: 6),
                  _barisStatus(),
                  const SizedBox(height: 8),
                  _barisHargaTombol(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barisStatus() {
    final Color warna;
    final String teks;
    if (toko.tersedia) {
      warna = LbColors.sageDeep;
      teks = toko.stok == 1 ? 'Tersisa 1 paket' : 'Tersisa ${toko.stok} paket';
    } else if (toko.adaProduk) {
      warna = LbColors.peachDeep;
      teks = 'Sedang habis';
    } else {
      warna = LbColors.textGrey;
      teks = 'Belum ada paket';
    }

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: warna, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            toko.tersedia && toko.waktu.isNotEmpty
                ? '$teks • ${toko.waktu}'
                : teks,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LbText.body(12, weight: FontWeight.w700, color: warna),
          ),
        ),
      ],
    );
  }

  Widget _barisHargaTombol() {
    final punyaHarga = toko.adaProduk;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: punyaHarga
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (toko.adaHargaCoret)
                      Text(
                        lbRp(toko.hargaAsli!),
                        style: LbText.body(11).copyWith(
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        toko.harga == 0 ? 'Gratis' : lbRp(toko.harga),
                        style: LbText.heading(17, weight: FontWeight.w700),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 8),
        if (toko.tersedia)
          _tombol('Pesan', aktif: true, onTap: onBuka)
        else if (toko.adaProduk)
          _tombol('Ingatkan', aktif: false, onTap: onIngatkan),
      ],
    );
  }

  Widget _tombol(String label,
      {required bool aktif, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: aktif ? null : LbColors.peachLight,
          gradient: aktif
              ? const LinearGradient(
                  colors: [LbColors.sage, LbColors.sageDeep],
                )
              : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: LbText.heading(
            12.5,
            weight: FontWeight.w700,
            color: aktif ? Colors.white : LbColors.peachDeep,
          ),
        ),
      ),
    );
  }
}