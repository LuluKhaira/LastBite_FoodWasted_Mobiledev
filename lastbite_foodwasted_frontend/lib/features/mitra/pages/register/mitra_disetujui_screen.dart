import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import '../dashboard/mitra_dashboard_screen.dart';

class MitraDisetujuiScreen extends StatefulWidget {
  final String? phoneNumber;

  const MitraDisetujuiScreen({
    super.key,
    this.phoneNumber,
  });

  @override
  State<MitraDisetujuiScreen> createState() => _MitraDisetujuiScreenState();
}

class _MitraDisetujuiScreenState extends State<MitraDisetujuiScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Bagian Tengah yang Presisi di Tengah Layar
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ---- ANIMASI CEKLIS SAGE ----
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          width: 95,
                          height: 95,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 56,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Judul & Subtitle
                    Text(
                      'Selamat Datang, Mitra!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Akunmu sudah aktif. Yuk mulai unggah surplus pertamamu.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        color: AppColors.textSoft,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---- Tombol Utama di Bawah ----
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MitraDashboardScreen(
                          phoneNumber: widget.phoneNumber ?? '', // Mengirimkan nomor telepon ke dashboard
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Masuk ke Dashboard',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}