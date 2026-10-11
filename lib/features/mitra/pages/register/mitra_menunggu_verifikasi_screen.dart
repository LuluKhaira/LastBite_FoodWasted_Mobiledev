import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'mitra_disetujui_screen.dart';

const _bg = Color(0xFFEAFDE1);
const _primary = Color(0xFF006B1E);
const _cardBg = Color(0xFFF3FAF0);
const _textDark = Color(0xFF10260F);
const _textSoft = Color(0xFF3F4A3C);

class MitraMenungguVerifikasiScreen extends StatefulWidget {
  final String namaToko;
  final String kategori;
  final String regId;
  final String waktuPengajuan;

  const MitraMenungguVerifikasiScreen({
    super.key,
    this.namaToko = 'Toko Roti Berkah Batam',
    this.kategori = 'Roti & Bakery',
    this.regId = '#LB-88219',
    this.waktuPengajuan = 'Hari ini, 10:15 WIB',
  });

  @override
  State<MitraMenungguVerifikasiScreen> createState() =>
      _MitraMenungguVerifikasiScreenState();
}

class _MitraMenungguVerifikasiScreenState
    extends State<MitraMenungguVerifikasiScreen> {
  int _secretTapCount = 0;
  bool _isLoading = false;

  void _simulasiDisetujuiAdmin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Status: Pendaftaran Disetujui! Masuk ke Dashboard...'),
        backgroundColor: _primary,
        duration: Duration(seconds: 1),
      ),
    );

    // Navigasi berpindah ke layar MitraDisetujuiScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MitraDisetujuiScreen()),
    );
  }

  void _cekStatusVerifikasi() {
    setState(() => _isLoading = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Memeriksa status verifikasi ke server...'),
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _simulasiDisetujuiAdmin();
      }
    });
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // ---- Main White Card ----
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          // Icon Jam Pasir (Ketuk 3x untuk bypass ACC admin)
                          GestureDetector(
                            onTap: () {
                              _secretTapCount++;
                              if (_secretTapCount >= 3) {
                                _secretTapCount = 0;
                                _simulasiDisetujuiAdmin();
                              }
                            },
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE2F5DD),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.hourglass_top_rounded,
                                    size: 48,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: _primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.access_time_filled,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          Text(
                            'Pendaftaran Sedang\nDitinjau',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: _textDark,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tim Lastbite sedang meninjau data usahamu.\n'
                            'Biasanya selesai dalam 1x24 jam. Kami akan\n'
                            'kabari lewat WhatsApp begitu disetujui.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              height: 1.5,
                              color: _textSoft,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Banner Jaminan Keamanan Data
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F6E4),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: _primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.verified_user_outlined,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Jaminan Keamanan Data',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: _textDark,
                                        ),
                                      ),
                                      Text(
                                        'Informasi tokomu tersimpan rahasia & tere...',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: _textSoft,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Ringkasan Pendaftaran Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _cardBg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'RINGKASAN PENDAFTARAN',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: _textSoft,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      'ID: ${widget.regId}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: _primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  height: 20,
                                  color: Color(0xFFD3E7CD),
                                ),
                                _SummaryRow(
                                  icon: Icons.storefront_outlined,
                                  label: 'Nama Toko',
                                  value: widget.namaToko,
                                  boldValue: true,
                                ),
                                const SizedBox(height: 12),
                                _SummaryRow(
                                  icon: Icons.bakery_dining_outlined,
                                  label: 'Kategori',
                                  value: widget.kategori,
                                  boldValue: true,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.autorenew,
                                          size: 18,
                                          color: _textSoft,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Status',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            color: _textSoft,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFECEB),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              color: Colors.redAccent,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Sedang Diverifikasi',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _SummaryRow(
                                  icon: Icons.calendar_today_outlined,
                                  label: 'Diajukan pada',
                                  value: widget.waktuPengajuan,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ---- Konfirmasi Melalui WhatsApp Card ----
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCF3D5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.chat_outlined,
                              color: _primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Konfirmasi Melalui WhatsApp',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: _textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Pastikan nomor ponsel yang didaftarkan aktif untuk menerima tautan aktivasi akun dan panduan onboarding perdana.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    height: 1.4,
                                    color: _textSoft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ---- Bottom Buttons ----
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _cekStatusVerifikasi,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.refresh, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Cek Status',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_back, size: 16, color: _primary),
                        const SizedBox(width: 6),
                        Text(
                          'Kembali ke Beranda Awal',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: _primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool boldValue;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.boldValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: _textSoft),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: _textSoft,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: boldValue ? FontWeight.w800 : FontWeight.w600,
            color: _textDark,
          ),
        ),
      ],
    );
  }
}
