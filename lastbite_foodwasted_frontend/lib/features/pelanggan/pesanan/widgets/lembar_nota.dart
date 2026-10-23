import 'package:flutter/material.dart';
import '../../../../core/tema/tema_lb.dart';
import '../pesanan_model.dart' show lbRp;

/// Nota pembayaran digital (modal sheet).
void tampilLembarNota(BuildContext context, Map p) {
  final metode = (p['metode'] ?? 'QRIS').toString().toUpperCase();
  final hargaSatuan = (p['harga_satuan'] as int? ?? 0);
  final qty = (p['qty'] as int? ?? 1);
  final subtotal = hargaSatuan * qty;
  final layanan = (p['biaya_layanan'] as int? ?? 1000);
  final total = (p['total'] as int? ?? subtotal + layanan);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 18),
          Row(children: [
            const Icon(Icons.receipt_long_rounded,
                color: LbColors.forest, size: 28),
            const SizedBox(width: 8),
            Text('Struk Pembelian Digital',
                style: LbText.heading(18, weight: FontWeight.w700)),
          ]),
          const SizedBox(height: 4),
          Text('No. Pesanan: #${p['kode']}',
              style: LbText.body(12,
                  color: LbColors.textGrey, weight: FontWeight.w600)),
          const Divider(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Waktu Transaksi', style: LbText.body(13)),
            Text('${p['tanggal']}, ${p['jam']} WIB',
                style: LbText.body(13, weight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Nama Toko', style: LbText.body(13)),
            Flexible(
                child: Text('${p['penjual']}',
                    textAlign: TextAlign.end,
                    style: LbText.body(13, weight: FontWeight.w700))),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Metode Pembayaran', style: LbText.body(13)),
            Text(metode,
                style: LbText.body(13,
                    weight: FontWeight.w700, color: LbColors.forest)),
          ]),
          const Divider(height: 24),
          Text('Rincian Item',
              style: LbText.heading(14, weight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
                child: Text('${p['produk']} ($qty x ${lbRp(hargaSatuan)})',
                    style: LbText.body(13))),
            Text(lbRp(subtotal),
                style: LbText.body(13, weight: FontWeight.w600)),
          ]),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Biaya Layanan LastBite', style: LbText.body(13)),
            Text(lbRp(layanan),
                style: LbText.body(13, weight: FontWeight.w600)),
          ]),
          const Divider(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Total Lunas',
                style: LbText.heading(16, weight: FontWeight.w700)),
            Text(lbRp(total),
                style: LbText.heading(18,
                    weight: FontWeight.w800, color: LbColors.forest)),
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFE8F5DC),
                borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.eco_rounded, color: LbColors.sageDeep, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Penyelamatan pangan ini mencegah ${p['co2'] ?? '1.25'} kg CO₂e terbuang ke atmosfer.',
                  style: LbText.body(11.5,
                      weight: FontWeight.w600, color: LbColors.forest),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: LbColors.forest,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup Nota',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ),
  );
}
