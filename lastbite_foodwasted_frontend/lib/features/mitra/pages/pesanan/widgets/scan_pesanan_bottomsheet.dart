import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import '../scan_ambil_pesanan_screen.dart';

/// Lembar pilihan singkat dari tombol scan di bottom nav (Dashboard, Produk, dst).
/// Nama kelas & parameter SAMA dengan versi lama, jadi Dashboard/Produk tidak perlu diubah.
/// Semua pilihan membuka layar scan sungguhan (ScanAmbilPesananScreen) yang terhubung ke server.
class ScanPesananBottomSheet extends StatelessWidget {
  final String phoneNumber;
  const ScanPesananBottomSheet({super.key, required this.phoneNumber});

  void _buka(BuildContext context, {required bool manual}) {
    final nav = Navigator.of(context);
    nav.pop(); // tutup lembar ini
    nav.push(
      MaterialPageRoute(
        builder: (_) => ScanAmbilPesananScreen(
          phoneNumber: phoneNumber,
          mulaiManual: manual,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSoft.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text('Ambil Pesanan', style: AppColors.heading(fontSize: 19)),
          const SizedBox(height: 4),
          Text(
            'Pilih cara memeriksa pesanan pembeli',
            style: AppColors.body(fontSize: 14, color: AppColors.textSoft),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton.icon(
              onPressed: () => _buka(context, manual: false),
              icon: const Icon(Icons.qr_code_scanner_rounded,
                  color: Colors.white, size: 26),
              label: Text('Scan QR Pembeli',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _buka(context, manual: true),
              icon: const Icon(Icons.keyboard_rounded,
                  color: AppColors.hijauTua),
              label: Text('Masukkan Kode Manual',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.hijauTua)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}