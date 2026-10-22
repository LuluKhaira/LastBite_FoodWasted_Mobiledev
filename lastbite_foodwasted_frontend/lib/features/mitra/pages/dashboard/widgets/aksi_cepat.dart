import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';

class AksiCepat extends StatelessWidget {
  final VoidCallback? onScanQR;
  final VoidCallback? onRiwayat;
  final VoidCallback? onBantuan;

  const AksiCepat({
    super.key,
    this.onScanQR,
    this.onRiwayat,
    this.onBantuan,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildActionItem(Icons.qr_code_scanner, 'Scan QR\nPembeli', onScanQR),
        const SizedBox(width: 10),
        _buildActionItem(Icons.receipt_long, 'Riwayat\nPenjualan', onRiwayat),
        const SizedBox(width: 10),
        _buildActionItem(Icons.support_agent, 'Bantuan\nMitra', onBantuan),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback? onTap) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
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
        ),
      ),
    );
  }
}
