import 'package:flutter/material.dart';
import '../../../../core/tema/tema_lb.dart';
import 'kotak_belum_bayar.dart';
import 'kotak_menunggu.dart';
import 'langkah_status.dart';
import 'qr_pengambilan.dart';
import 'tombol_lembut.dart';

/// Kartu pesanan di tab "Aktif".
class KartuPesananAktif extends StatelessWidget {
  final Map<String, dynamic> p;
  final VoidCallback onMaps;
  final VoidCallback onHubungi;
  final VoidCallback onBayar;
  final VoidCallback onCek;
  final VoidCallback onBatal;
  final ValueChanged<String> onDisalin;

  const KartuPesananAktif({
    super.key,
    required this.p,
    required this.onMaps,
    required this.onHubungi,
    required this.onBayar,
    required this.onCek,
    required this.onBatal,
    required this.onDisalin,
  });

  @override
  Widget build(BuildContext context) {
    final statusStr = '${p['status']}'.toLowerCase();
    final siap = statusStr == 'siap' || statusStr == 'ready_for_pickup';
    final belumBayar =
        p['status_bayar'] != 'lunas' && (p['total'] as int? ?? 0) > 0;
    final step = siap ? 1 : 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: LbColors.sageLight,
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.bakery_dining_rounded,
                color: LbColors.sageDeep, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${p['penjual']}',
                  style: LbText.heading(16, weight: FontWeight.w700)),
              Text('${p['qty']}x ${p['produk']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LbText.body(13)),
              Text('Kode: #${p['kode']}',
                  style: LbText.body(11.5,
                      weight: FontWeight.w800, color: LbColors.sageDeep)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        LangkahStatus(step: step),
        const SizedBox(height: 16),
        if (belumBayar)
          KotakBelumBayar(p: p, onBayar: onBayar, onCek: onCek)
        else if (siap)
          QrPengambilan(p: p, onDisalin: onDisalin)
        else
          KotakMenunggu(p: p),
        const SizedBox(height: 16),
        Row(children: [
          const Icon(Icons.location_on_outlined,
              size: 20, color: LbColors.sageDeep),
          const SizedBox(width: 6),
          Text('Lokasi Pengambilan',
              style: LbText.heading(14, weight: FontWeight.w700)),
        ]),
        const SizedBox(height: 4),
        Text('${p['alamat'] ?? '-'}', style: LbText.body(12.5, height: 1.4)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: TombolLembut(
                  icon: Icons.near_me_outlined,
                  label: 'Buka Maps',
                  onTap: onMaps)),
          const SizedBox(width: 10),
          Expanded(
              child: TombolLembut(
                  icon: Icons.chat_outlined,
                  label: 'Hubungi Toko',
                  onTap: onHubungi,
                  kuat: true)),
        ]),
        // Tombol Batalkan: hanya jika masih Menunggu & belum siap
        if (!siap && !belumBayar) ...[
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onBatal,
            child: Container(
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4F2),
                border: Border.all(color: const Color(0xFFF2C4BC)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.cancel_outlined,
                    size: 18, color: Color(0xFFD64933)),
                const SizedBox(width: 6),
                Text(
                  'Batalkan Pesanan',
                  style: LbText.heading(13.5,
                      weight: FontWeight.w600, color: const Color(0xFFD64933)),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Pembatalan & pengembalian dana penuh tersedia sebelum paket siap diambil',
              textAlign: TextAlign.center,
              style: LbText.body(11, color: LbColors.textGrey),
            ),
          ),
        ],
      ]),
    );
  }
}
