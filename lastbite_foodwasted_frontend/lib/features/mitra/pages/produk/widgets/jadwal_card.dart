import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'base_card.dart';
import 'warna_lokal.dart';

class JadwalCard extends StatelessWidget {
  final TimeOfDay mulaiAmbil;
  final TimeOfDay batasMaksimal;
  final DateTime kadaluarsa;
  final bool tampilKadaluarsa;
  final TimeOfDay? jamTutupToko;
  final bool tokoLibur;
  final VoidCallback onPilihMulai;
  final VoidCallback onPilihBatas;
  final VoidCallback onPilihKadaluarsa;

  const JadwalCard({
    super.key,
    required this.mulaiAmbil,
    required this.batasMaksimal,
    required this.kadaluarsa,
    required this.onPilihMulai,
    required this.onPilihBatas,
    required this.onPilihKadaluarsa,
    this.tampilKadaluarsa = true,
    this.jamTutupToko,
    this.tokoLibur = false,
  });

  String _formatJam(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String get _teksToko {
    if (tokoLibur) return 'Toko libur hari ini';
    if (jamTutupToko != null) return 'Toko tutup ${_formatJam(jamTutupToko!)}';
    return 'Jam buka belum diatur';
  }

  String _formatTanggalJam(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}  $hh:$mi';
  }

  @override
  Widget build(BuildContext context) {
    Widget timeBox(String label, TimeOfDay time, VoidCallback onTap) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppColors.body(fontSize: 10, fontWeight: FontWeight.w700, color: WarnaLokal.textSoft)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: WarnaLokal.border)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatJam(time), style: AppColors.heading(fontSize: 14, color: WarnaLokal.textDark)),
                    Text('WIB', style: AppColors.body(fontSize: 11, color: WarnaLokal.textSoft)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('JADWAL PENGAMBILAN', style: AppColors.heading(fontSize: 12, color: WarnaLokal.textSoft)),
              Row(
                children: [
                  Icon(Icons.storefront, size: 14, color: tokoLibur ? Colors.red : WarnaLokal.primaryDark),
                  const SizedBox(width: 4),
                  Text(_teksToko, style: AppColors.body(fontSize: 11, fontWeight: FontWeight.w700, color: tokoLibur ? Colors.red : WarnaLokal.primaryDark)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              timeBox('MULAI AMBIL', mulaiAmbil, onPilihMulai),
              const SizedBox(width: 12),
              timeBox('BATAS MAKSIMAL', batasMaksimal, onPilihBatas),
            ],
          ),
          if (tampilKadaluarsa) ...[
            const SizedBox(height: 16),
            Text('KADALUARSA PRODUK', style: AppColors.body(fontSize: 10, fontWeight: FontWeight.w700, color: WarnaLokal.textSoft)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: onPilihKadaluarsa,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: WarnaLokal.border)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.event_busy_outlined, size: 16, color: WarnaLokal.primaryDark),
                        const SizedBox(width: 8),
                        Text(_formatTanggalJam(kadaluarsa), style: AppColors.heading(fontSize: 14, color: WarnaLokal.textDark)),
                      ],
                    ),
                    Text('WIB', style: AppColors.body(fontSize: 11, color: WarnaLokal.textSoft)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.autorenew, size: 16, color: WarnaLokal.primaryDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Setelah lewat waktu ini, produk otomatis pindah ke kategori Pakan Ternak & Ikan.', style: AppColors.body(fontSize: 11, color: WarnaLokal.textSoft)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: WarnaLokal.primaryDark),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Pelanggan mengambil pesanan langsung sebelum toko tutup.', style: AppColors.body(fontSize: 11, color: WarnaLokal.textSoft)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}