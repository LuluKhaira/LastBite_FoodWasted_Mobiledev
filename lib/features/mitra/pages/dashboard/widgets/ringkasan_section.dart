import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';

class RingkasanSection extends StatelessWidget {
  const RingkasanSection({super.key});

  @override
  Widget build(BuildContext context) {
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
              'Update 16.42 WIB',
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
                          '8',
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                            '3 Perlu disiapkan sekarang',
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
                child: Icon(Icons.shopping_bag_outlined, color: AppColors.textDark, size: 28),
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
                        Text('Pendapatan', style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textSoft)),
                        const Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppColors.textDark),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Rp 128.000', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.sync, size: 12, color: AppColors.textSoft),
                        const SizedBox(width: 4),
                        Text('Cair otomatis besok', style: GoogleFonts.nunito(fontSize: 10, color: AppColors.textSoft)),
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
                        Text('Terselamatkan', style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textSoft)),
                        const Icon(Icons.eco_outlined, size: 16, color: AppColors.textDark),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('12 Porsi', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.trending_up, size: 12, color: AppColors.textDark),
                        const SizedBox(width: 4),
                        Text('14,4 kg CO2 dicegah', style: GoogleFonts.nunito(fontSize: 10, color: AppColors.textSoft)),
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