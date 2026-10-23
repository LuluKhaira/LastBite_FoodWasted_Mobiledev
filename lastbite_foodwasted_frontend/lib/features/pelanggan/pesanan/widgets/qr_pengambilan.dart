import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/tema/tema_lb.dart';

/// Status: Siap Diambil (QR + kode manual + batas waktu).
class QrPengambilan extends StatelessWidget {
  final Map p;
  final ValueChanged<String> onDisalin;

  const QrPengambilan({super.key, required this.p, required this.onDisalin});

  String _teksSisa() {
    final batas = DateTime.tryParse('${p['batas_ambil']}')?.toLocal();
    if (batas == null) return 'Ambil hari ini sebelum jam tutup toko';

    final d = batas.difference(DateTime.now());
    if (d.isNegative) return 'Batas pengambilan sudah lewat';

    final j = d.inHours, m = d.inMinutes % 60;
    final jam =
        '${batas.hour.toString().padLeft(2, '0')}.${batas.minute.toString().padLeft(2, '0')}';
    return 'Ambil sebelum $jam WIB (Sisa ${j > 0 ? '$j jam ' : ''}$m mnt)';
  }

  @override
  Widget build(BuildContext context) {
    final kode = '${p['kode_ambil'] ?? 'LB-749201'}';
    final sisa = _teksSisa();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6E6),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LbColors.sage.withValues(alpha: 0.35)),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.qr_code_scanner_rounded,
              size: 20, color: LbColors.forest),
          const SizedBox(width: 6),
          Text(
            'Tunjukkan QR ini ke kasir saat mengambil',
            style: LbText.body(12.5,
                weight: FontWeight.w800, color: LbColors.forest),
          ),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: QrImageView(
            data: '${p['kode']}|$kode', // Format: KodePesanan|KodeAmbil
            size: 190,
            eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square, color: LbColors.forest),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: LbColors.forest,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'KODE PENGAMBILAN MANUAL',
          style: LbText.body(11,
              weight: FontWeight.w800, color: LbColors.forest),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: LbColors.sage.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            Expanded(
              child: Text(
                kode,
                style: LbText.heading(22,
                        weight: FontWeight.w700, color: LbColors.sageDeep)
                    .copyWith(letterSpacing: 2),
              ),
            ),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: kode));
                onDisalin(kode);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: LbColors.sageLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  const Icon(Icons.copy_rounded,
                      size: 16, color: LbColors.forest),
                  const SizedBox(width: 4),
                  Text('Salin',
                      style: LbText.body(12,
                          weight: FontWeight.w700, color: LbColors.forest)),
                ]),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
              color: const Color(0xFFFFDDD3),
              borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.timer_outlined,
                size: 17, color: Color(0xFFD64933)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                sisa,
                textAlign: TextAlign.center,
                style: LbText.body(12,
                    weight: FontWeight.w700, color: const Color(0xFF9A2B1A)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
