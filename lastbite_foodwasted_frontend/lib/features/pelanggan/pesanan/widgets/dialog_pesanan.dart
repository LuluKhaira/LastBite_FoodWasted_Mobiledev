import 'package:flutter/material.dart';
import '../../../../core/tema/tema_lb.dart';
import '../pesanan_model.dart' show lbRp;

/// Dialog konfirmasi batal. Mengembalikan true jika user memilih "Ya".
Future<bool> dialogKonfirmasiBatal(BuildContext context, int total) async {
  final ya = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Batalkan pesanan?',
          style: LbText.heading(18, weight: FontWeight.w700)),
      content: Text(
        'Dana sebesar ${lbRp(total)} akan dikembalikan penuh karena paket belum disiapkan oleh toko.',
        style: LbText.body(13.5, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('Kembali',
              style: LbText.body(13.5, color: LbColors.textGrey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD64933),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Ya, Batalkan',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
  return ya == true;
}

/// Dialog bintang 1-5. Mengembalikan nilai, atau null jika dibatalkan.
Future<int?> dialogBeriNilai(BuildContext context, String penjual) async {
  int n = 5;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text('Beri Nilai & Ulasan',
            style: LbText.heading(18, weight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bagaimana kualitas makanan dari $penjual?',
                style: LbText.body(13)),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: () => setS(() => n = i),
                  icon: Icon(
                    i <= n ? Icons.star_rounded : Icons.star_border_rounded,
                    color: const Color(0xFFF2A93B),
                    size: 34,
                  ),
                ),
            ]),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: LbColors.forest,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kirim Nilai',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
  return ok == true ? n : null;
}
