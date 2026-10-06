import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';

class AksiCepat extends StatelessWidget {
  const AksiCepat({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildActionItem(Icons.qr_code_scanner, 'Scan QR\nPembeli'),
        const SizedBox(width: 10),
        _buildActionItem(Icons.receipt_long, 'Riwayat\nPenjualan'),
        const SizedBox(width: 10),
        _buildActionItem(Icons.support_agent, 'Bantuan\nMitra'),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.textDark, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}