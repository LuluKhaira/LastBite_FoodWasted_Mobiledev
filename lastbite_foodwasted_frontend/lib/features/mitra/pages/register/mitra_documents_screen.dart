import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'mitra_menunggu_verifikasi_screen.dart';

const _bg = Color(0xFFEAFDE1);
const _primary = Color(0xFF006B1E);
const _cardBg = Color(0xFFF3FAF0);
const _cardBorder = Color(0xFFD9ECD2);
const _textDark = Color(0xFF10260F);
const _textSoft = Color(0xFF3F4A3C);
const _grey = Color(0xFF8C978A);

class MitraDocumentsScreen extends StatefulWidget {
  const MitraDocumentsScreen({super.key});

  @override
  State<MitraDocumentsScreen> createState() => _MitraDocumentsScreenState();
}

class _MitraDocumentsScreenState extends State<MitraDocumentsScreen> {
  String? _ktpFile;
  String? _npwpFile;
  String? _halalFile;

  bool _setujuSyarat = false;

  void _pilihFile(String jenis, void Function(String) onPicked) {
    onPicked('$jenis-scan.jpg');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$jenis terpilih (simulasi, belum upload asli).')),
    );
  }

  void _selesai() {
    if (_ktpFile == null) {
      _showError('Foto KTP pemilik usaha wajib diunggah.');
      return;
    }
    if (!_setujuSyarat) {
      _showError('Kamu harus menyetujui Syarat & Ketentuan dulu.');
      return;
    }

    // Navigasi ke Halaman Menunggu Verifikasi
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MitraMenungguVerifikasiScreen(),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            const _Header(title: 'Daftar Mitra', subtitle: 'Dokumen Pendukung'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ProgressBar(
                      step: 5,
                      total: 6,
                      label: 'Dokumen Pendukung',
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Verifikasi Dokumen Usaha',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload dokumen untuk memastikan keabsahan toko di Lastbite.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        height: 1.6,
                        color: _textSoft,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ---- KTP (wajib) ----
                    _DocumentCard(
                      icon: Icons.badge_outlined,
                      title: 'KTP Pemilik Usaha',
                      requiredLabel: 'Wajib',
                      buttonLabel: _ktpFile == null
                          ? 'Pilih Foto KTP (Maks. 5 MB)'
                          : 'Terpilih: $_ktpFile',
                      helperText: 'Format JPG, PNG, atau PDF jelas terbaca',
                      picked: _ktpFile != null,
                      onTap: () => _pilihFile(
                        'KTP',
                        (f) => setState(() => _ktpFile = f),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: _grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Data KTP dienkripsi & hanya digunakan untuk validasi identitas mitra.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              height: 1.4,
                              color: _textSoft,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ---- NPWP (opsional) ----
                    _DocumentCard(
                      icon: Icons.description_outlined,
                      title: 'NPWP Usaha / Pribadi',
                      requiredLabel: 'Opsional',
                      optional: true,
                      buttonLabel: _npwpFile == null
                          ? 'Upload NPWP (Maks. 5 MB)'
                          : 'Terpilih: $_npwpFile',
                      helperText: 'Format JPG, PNG, atau PDF (Maks. 5 MB) - boleh dikosongkan bila belum ada',
                      picked: _npwpFile != null,
                      onTap: () => _pilihFile(
                        'NPWP',
                        (f) => setState(() => _npwpFile = f),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ---- Sertifikat Halal (opsional) ----
                    _DocumentCard(
                      icon: Icons.verified_outlined,
                      title: 'Sertifikat Halal / Pengajuan SEHATI',
                      requiredLabel: 'Opsional',
                      optional: true,
                      buttonLabel: _halalFile == null
                          ? 'Upload Dokumen Halal / SEHATI'
                          : 'Terpilih: $_halalFile',
                      helperText: 'Foto sertifikat halal atau bukti pendaftaran program SEHATI (opsional)',
                      picked: _halalFile != null,
                      onTap: () => _pilihFile(
                        'Sertifikat Halal',
                        (f) => setState(() => _halalFile = f),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: _grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Belum punya sertifikat halal? Tetap bisa mendaftar, program SEHATI pemerintah tersedia secara gratis.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              height: 1.4,
                              color: _textSoft,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ---- Checkbox syarat & ketentuan ----
                    GestureDetector(
                      onTap: () =>
                          setState(() => _setujuSyarat = !_setujuSyarat),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _setujuSyarat,
                            activeColor: _primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (value) =>
                                setState(() => _setujuSyarat = value ?? false),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: Text.rich(
                                TextSpan(
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    height: 1.5,
                                    color: _textSoft,
                                  ),
                                  children: const [
                                    TextSpan(text: 'Saya menyetujui '),
                                    TextSpan(
                                      text: 'Syarat & Ketentuan Kemitraan',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: _textDark,
                                      ),
                                    ),
                                    TextSpan(text: ' serta '),
                                    TextSpan(
                                      text: 'Kebijakan Privasi',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: _textDark,
                                      ),
                                    ),
                                    TextSpan(text: ' Lastbite.'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---- Bawah ----
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selesai,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Selesai',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

// ---------- Kartu satu dokumen ----------
class _DocumentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String requiredLabel;
  final bool optional;
  final String buttonLabel;
  final String helperText;
  final bool picked;
  final VoidCallback onTap;

  const _DocumentCard({
    required this.icon,
    required this.title,
    required this.requiredLabel,
    required this.buttonLabel,
    required this.helperText,
    required this.picked,
    required this.onTap,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
              ),
              Text(
                requiredLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: optional ? _grey : _primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: picked ? _primary : const Color(0xFFBFE0B8),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      picked ? Icons.check_circle : icon,
                      color: _primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      buttonLabel,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: _primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      helperText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: _grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Progress bar + label langkah ----------
class _ProgressBar extends StatelessWidget {
  final int step;
  final int total;
  final String label;

  const _ProgressBar({
    required this.step,
    required this.total,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Langkah $step dari $total',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _primary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _textSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: LinearProgressIndicator(
            value: step / total,
            minHeight: 8,
            color: _primary,
            backgroundColor: const Color(0xFFD5EDCB),
          ),
        ),
      ],
    );
  }
}

// ---------- Header ----------
class _Header extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      color: _bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textSoft,
            ),
          ),
        ],
      ),
    );
  }
}
