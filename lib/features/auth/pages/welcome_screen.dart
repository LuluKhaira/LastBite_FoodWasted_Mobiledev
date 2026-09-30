// ============================================================
// LastBite - lib/features/auth/pages/welcome_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_colors.dart';
import '../../mitra/pages/register/mitra_register_screen.dart';

// ---------- HALAMAN WELCOME ----------
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold = kerangka halaman (background, appbar, body).
    return Scaffold(
      backgroundColor: AppColors.background,
      // SafeArea = supaya konten tidak tertutup notch / status bar.
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          // Column = susun widget dari atas ke bawah.
          child: Column(
            children: [
              const SizedBox(height: 32),
              const _Badge(),
              const SizedBox(height: 20),
              Text(
                'Setiap sisa punya\nkesempatan kedua.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Temukan makanan hemat, pakan ternak, dan\nbahan pupuk dari usaha terdekat di Batam.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  height: 1.6,
                  color: AppColors.subtitle,
                ),
              ),

              // Expanded = ambil semua sisa ruang, jadi logo otomatis
              // berada di tengah dan tombol terdorong ke bawah.
              Expanded(
                child: Center(
                  // Transform.scale memperbesar gambar tanpa dibatasi tinggi Expanded.
                  // Ubah angka scale (1.0 = normal) sesuai selera: 1.8 / 2.0 / 2.2.
                  child: Transform.scale(
                    scale: 2.0,
                    child: Image.asset(
                    'assets/images/lastbite_logo.png',
                    width: 260,
                    fit: BoxFit.contain,
                    // Kalau gambar belum ada, tampilkan ikon supaya tidak error.
                    errorBuilder: (context, error, stack) => const Icon(
                      Icons.eco_rounded,
                      size: 120,
                      color: AppColors.primary,
                    ),
                  ),
                  ),
                ),
              ),

              // Tombol utama
              _PrimaryButton(
                label: 'Mulai Selamatkan',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  // TODO: pindah ke halaman beranda
                  debugPrint('Mulai Selamatkan ditekan');
                },
              ),
              const SizedBox(height: 12),

              // Tombol Google
              _GoogleButton(
                onPressed: () {
                  // TODO: login Google (nanti pakai Firebase Auth / API)
                  debugPrint('Google ditekan');
                },
              ),
              const SizedBox(height: 12),

              // Tombol HP / Email
              _PrimaryButton(
                label: 'Lanjutkan dengan HP / Email',
                icon: Icons.mail_outline_rounded,
                iconOnLeft: true,
                onPressed: () {
                  // TODO: pindah ke halaman login HP/Email
                  debugPrint('HP / Email ditekan');
                },
              ),
              const SizedBox(height: 14),

              // Link mitra
              TextButton(
                onPressed: () {
                  // Navigator.push = buka halaman baru di atas halaman ini.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MitraRegisterScreen(),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Masuk sebagai Mitra Toko / Penjual',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 16, color: AppColors.primary),
                  ],
                ),
              ),

              // Teks syarat & ketentuan
              // Text.rich = satu paragraf dengan gaya teks yang berbeda-beda.
              Text.rich(
                TextSpan(
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    height: 1.6,
                    color: AppColors.footer,
                  ),
                  children: const [
                    TextSpan(text: 'Dengan melanjutkan, kamu menyetujui '),
                    TextSpan(
                      text: 'Syarat & Ketentuan',
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                    TextSpan(text: ' serta '),
                    TextSpan(
                      text: 'Kebijakan Privasi',
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                    TextSpan(text: ' Lastbite.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- 4. KOMPONEN KECIL (dipecah supaya kode rapi & bisa dipakai ulang) ----------

// Badge "LASTBITE BATAM"
class _Badge extends StatelessWidget {
  const _Badge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.badgeBg,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppColors.badgeBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.dot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'LASTBITE BATAM',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// Tombol hijau tua (dipakai 2x: "Mulai Selamatkan" dan "HP / Email")
class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool iconOnLeft;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.iconOnLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: const StadiumBorder(), // bentuk pil / bulat penuh
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Kalau iconOnLeft = true, ikon menempel di kiri (seperti tombol email).
            if (iconOnLeft)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(icon, size: 24),
                ),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!iconOnLeft) ...[
                  Icon(icon, size: 22),
                  const SizedBox(width: 12),
                ],
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Tombol putih "Lanjutkan dengan Google"
class _GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _GoogleButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textDark,
          side: const BorderSide(color: AppColors.outline),
          shape: const StadiumBorder(),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 12),
                // Sementara pakai huruf "G". Nanti ganti dengan Image.asset logo Google asli.
                child: Text(
                  'G',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4285F4),
                  ),
                ),
              ),
            ),
            Text(
              'Lanjutkan dengan Google',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}