import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import '../pesanan_ui.dart';

/// Garis proses pesanan ala Shopee, dibuat besar dan jelas untuk pengguna lanjut usia.
///  - Hijau  = tahap yang sudah lewat
///  - Oranye = tahap yang sedang berjalan (lebih besar + bercahaya)
///  - Abu    = tahap berikutnya
class OrderStatusTracker extends StatelessWidget {
  final PesananFase fase;
  const OrderStatusTracker({super.key, required this.fase});

  static const _ikon = [
    Icons.receipt_long_rounded,
    Icons.soup_kitchen_rounded,
    Icons.shopping_bag_rounded,
    Icons.check_circle_rounded,
  ];
  static const _label = [
    'Pesanan\nMasuk',
    'Sedang\nDisiapkan',
    'Siap\nDiambil',
    'Selesai',
  ];

  // Tahap yang sedang berjalan.
  int get _aktif => switch (fase) {
        PesananFase.bayar => 0,
        PesananFase.baru => 1,
        PesananFase.siap => 2,
        PesananFase.selesai => 3,
        PesananFase.batal => -1,
      };

  @override
  Widget build(BuildContext context) {
    if (fase == PesananFase.batal) return const SizedBox.shrink();

    final semuaSelesai = fase == PesananFase.selesai;
    final abu = AppColors.textSoft.withValues(alpha: 0.25);

    Widget langkah(int i) {
      final done = semuaSelesai || i < _aktif;
      final current = !semuaSelesai && i == _aktif;

      final kiri = i == 0
          ? Colors.transparent
          : ((semuaSelesai || i <= _aktif) ? AppColors.primary : abu);
      final kanan = i == _ikon.length - 1
          ? Colors.transparent
          : ((semuaSelesai || i < _aktif) ? AppColors.primary : abu);

      final Color bg = done
          ? AppColors.primary
          : current
              ? AppColors.orange
              : Colors.white;
      final Color ikon = (done || current)
          ? Colors.white
          : AppColors.textSoft.withValues(alpha: 0.6);

      return Expanded(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Container(height: 3, color: kiri)),
                Container(
                  width: current ? 48 : 42,
                  height: current ? 48 : 42,
                  decoration: BoxDecoration(
                    color: bg,
                    shape: BoxShape.circle,
                    border: (done || current)
                        ? null
                        : Border.all(color: abu, width: 2),
                    boxShadow: current
                        ? [
                            BoxShadow(
                              color: AppColors.orange.withValues(alpha: 0.35),
                              blurRadius: 10,
                              spreadRadius: 3,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(_ikon[i], size: current ? 26 : 22, color: ikon),
                ),
                Expanded(child: Container(height: 3, color: kanan)),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 34,
              child: Text(
                _label[i],
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  height: 1.2,
                  fontWeight: current ? FontWeight.w800 : FontWeight.w600,
                  color: current
                      ? AppColors.textDark
                      : (done ? AppColors.hijauTua : AppColors.textSoft),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_ikon.length, langkah),
    );
  }
}
