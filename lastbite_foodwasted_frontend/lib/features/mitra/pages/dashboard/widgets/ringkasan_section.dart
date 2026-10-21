import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';

class RingkasanSection extends StatelessWidget {
  final int pesananHariIni;
  final int pesananAktif;
  final double pendapatan;
  final int porsi;
  final double co2Kg;

  const RingkasanSection({
    super.key,
    this.pesananHariIni = 0,
    this.pesananAktif = 0,
    this.pendapatan = 0,
    this.porsi = 0,
    this.co2Kg = 0,
  });

  static String _rupiah(double v) {
    final s = v.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp $buf';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final jam =
        '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}';
    final co2Teks = co2Kg.toStringAsFixed(1).replaceAll('.', ',');

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ringkasan Hari Ini',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            Text(
              'Update $jam WIB',
              style: GoogleFonts.nunito(
                fontSize: 11,
                color: AppColors.textSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pesanan Hari Ini',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: AppColors.textDark.withValues(alpha: 0.8),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$pesananHariIni',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Pesanan',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.textDark,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            pesananAktif > 0
                                ? '$pesananAktif Perlu disiapkan sekarang'
                                : 'Belum ada pesanan masuk',
                            style: GoogleFonts.nunito(
                              fontSize: 10.5,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shopping_bag_outlined,
                    color: AppColors.textDark, size: 28),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pendapatan',
                            style: GoogleFonts.nunito(
                                fontSize: 11, color: AppColors.textSoft)),
                        const Icon(Icons.account_balance_wallet_outlined,
                            size: 16, color: AppColors.textDark),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(_rupiah(pendapatan),
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.sync,
                            size: 12, color: AppColors.textSoft),
                        const SizedBox(width: 4),
                        Text('Cair otomatis besok',
                            style: GoogleFonts.nunito(
                                fontSize: 10, color: AppColors.textSoft)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Terselamatkan',
                            style: GoogleFonts.nunito(
                                fontSize: 11, color: AppColors.textSoft)),
                        const Icon(Icons.eco_outlined,
                            size: 16, color: AppColors.textDark),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('$porsi Porsi',
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.trending_up,
                            size: 12, color: AppColors.textDark),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text('$co2Teks kg CO2 dicegah',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.nunito(
                                  fontSize: 10, color: AppColors.textSoft)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}