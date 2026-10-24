import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import '../pesanan_ui.dart';

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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_ikon.length, (i) {
        final done = semuaSelesai || i < _aktif;
        final current = !semuaSelesai && i == _aktif;

        // Warna garis di kiri & kanan
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
        final Color ikonColor = (done || current)
            ? Colors.white
            : AppColors.textSoft.withValues(alpha: 0.6);

        return Expanded(
          child: Column(
            children: [
              // --- Bagian Ikon & Garis ---
              SizedBox(
                height: 48, // Tinggi tetap agar garis lurus sempurna
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Garis kiri & kanan diposisikan di tengah vertikal
                    Row(
                      children: [
                        Expanded(child: Container(height: 3, color: kiri)),
                        // Spacer selebar ikon (48) supaya garis tidak menembus ikon
                        const SizedBox(width: 48), 
                        Expanded(child: Container(height: 3, color: kanan)),
                      ],
                    ),
                    // Ikon lingkaran
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
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(_ikon[i], size: current ? 24 : 20, color: ikonColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // --- Bagian Teks ---
              Text(
                _label[i],
                textAlign: TextAlign.center,
                maxLines: 2,
                style: GoogleFonts.nunito(
                  fontSize: 11, // Sedikit dikecilkan agar tidak terlalu turun
                  height: 1.2,
                  fontWeight: current ? FontWeight.w800 : FontWeight.w600,
                  color: current
                      ? AppColors.textDark
                      : (done ? AppColors.hijauTua : AppColors.textSoft),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}