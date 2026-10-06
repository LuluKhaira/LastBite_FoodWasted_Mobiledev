// ============================================================
// LastBite - Mitra Pendaftaran Disetujui
// Simpan sebagai: lib/features/mitra/pages/register/mitra_disetujui_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Palet Warna Resmi Last Bite
const _bg = Color(0xFFF8F6F2);       // Off White
const _primary = Color(0xFFA7C957);  // Hijau Sage
const _orange = Color(0xFFFFB07C);   // Oranye Peach
const _textDark = Color(0xFF2B3A28); // Dark Forest
const _textSoft = Color(0xFF5A6856); // Muted Sage

class MitraDisetujuiScreen extends StatefulWidget {
  const MitraDisetujuiScreen({super.key});

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
      backgroundColor: _bg,
      
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // Badge Toko Aktif
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _primary.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified,
                            color: _primary,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Toko Aktif & Terverifikasi',
                            style: GoogleFonts.nunito(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: _textDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ---- ANIMASI CEKLIS SAGE ----
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: _primary.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: const BoxDecoration(
                            color: _primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 52,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Judul & Subtitle
                    Text(
                      'Selamat Datang, Mitra!',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Akunmu sudah aktif. Yuk mulai unggah surplus pertamamu.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: _textSoft,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ---- Card Langkah Awal Mitra ----
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.rocket_launch,
                                color: _orange,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Langkah Awal Mitra',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildStepItem(
                            number: '1',
                            title:
                                'Buat paket kejutan atau cantumkan sisa bahan berkualitas',
                            desc:
                                'Pilih stok berlebih atau bahan segar siap olah hari ini.',
                          ),
                          const SizedBox(height: 14),
                          _buildStepItem(
                            number: '2',
                            title:
                                'Tentukan jam pengambilan mandiri oleh pembeli',
                            desc:
                                'Atur batas waktu pengambilan sebelum tokomu tutup.',
                          ),
                          const SizedBox(height: 14),
                          _buildStepItem(
                            number: '3',
                            title:
                                'Pantau pesanan langsung dari dashboard tokomu',
                            desc:
                                'Verifikasi kode QR saat pelanggan mengambil paket.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ---- Banner Dampak Nyata (Warna Oranye Peach Accent) ----
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _orange.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _orange.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.eco_rounded,
                              color: _textDark,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DAMPAK NYATA',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _textDark,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Tiap paket kejutan yang kamu unggah menyelamatkan bumi dan mengurangi jejak emisi karbon!',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12.5,
                                    color: _textSoft,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ---- Tombol Utama (Oranye Peach / Hijau Sage) ----
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigasi ke Dashboard Utama Mitra
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
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

  Widget _buildStepItem({
    required String number,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFFF0F5E5),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: _textSoft,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}