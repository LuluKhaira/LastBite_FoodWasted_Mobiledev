import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'base_card.dart';
import 'warna_lokal.dart';

class JadwalCard extends StatelessWidget {
  final TimeOfDay mulaiAmbil;
  final TimeOfDay batasMaksimal;
  final VoidCallback onPilihMulai;
  final VoidCallback onPilihBatas;

  const JadwalCard({
    super.key,
    required this.mulaiAmbil,
    required this.batasMaksimal,
    required this.onPilihMulai,
    required this.onPilihBatas,
  });

  String _formatJam(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

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
                  Icon(Icons.storefront, size: 14, color: WarnaLokal.primaryDark),
                  const SizedBox(width: 4),
                  Text('Toko tutup 22:00', style: AppColors.body(fontSize: 11, fontWeight: FontWeight.w700, color: WarnaLokal.primaryDark)),
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