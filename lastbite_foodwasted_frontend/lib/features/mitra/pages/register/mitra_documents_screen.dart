// ============================================================
// LastBite - Daftar Mitra, Langkah 5 dari 6 (Dokumen Pendukung)
// ============================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';

import 'mitra_menunggu_verifikasi_screen.dart';

const Color _kBorder = Color(0xFFE9E6E0);
const Color _kTrack = Color(0xFFECE9E4);

class MitraDocumentsScreen extends StatefulWidget {
  final String phoneNumber;

  const MitraDocumentsScreen({super.key, required this.phoneNumber});

  @override
  State<MitraDocumentsScreen> createState() => _MitraDocumentsScreenState();
}

class _MitraDocumentsScreenState extends State<MitraDocumentsScreen> {
  File? _ktpFile;
  File? _npwpFile;
  File? _halalFile;

  bool _setujuSyarat = false;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pilihSumberFile(Function(File) onFileSelected) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Sumber Dokumen',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.orange),
              title: Text(
                'Kamera',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
              ),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (pickedFile != null) {
                  setState(() => onFileSelected(File(pickedFile.path)));
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primary,
              ),
              title: Text(
                'Galeri',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
              ),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (pickedFile != null) {
                  setState(() => onFileSelected(File(pickedFile.path)));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selesai() async {
    if (_ktpFile == null) {
      _showError('Foto KTP pemilik usaha wajib diunggah.');
      return;
    }
    if (!_setujuSyarat) {
      _showError('Kamu harus menyetujui Syarat & Ketentuan dulu.');
      return;
    }

    setState(() => _isLoading = true);

    bool sukses = await ApiService.setDocuments(
      phoneNumber: widget.phoneNumber,
      ktpPath: _ktpFile!.path,
      npwpPath: _npwpFile?.path,
      halalPath: _halalFile?.path,
    );

    setState(() => _isLoading = false);

    if (sukses) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MitraMenungguVerifikasiScreen(
              phoneNumber: widget.phoneNumber,
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        _showError('Gagal mengunggah dokumen ke server.');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.nunito(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
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
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload dokumen asli untuk memastikan keabsahan toko di LastBite.',
                      style: GoogleFonts.nunito(
                        fontSize: 14.5,
                        height: 1.6,
                        color: AppColors.textSoft,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ---- KTP (wajib) ----
                    _DocumentCard(
                      icon: Icons.badge_outlined,
                      title: 'KTP Pemilik Usaha',
                      requiredLabel: 'Wajib',
                      buttonLabel: _ktpFile == null
                          ? 'Ambil / Pilih Foto KTP'
                          : 'KTP Terpilih (${_ktpFile!.path.split('/').last})',
                      helperText: 'Foto KTP asli tampak jelas dan tidak blur',
                      picked: _ktpFile != null,
                      onTap: () => _pilihSumberFile(
                        (file) => setState(() => _ktpFile = file),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppColors.textSoft,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Data KTP dienkripsi & hanya digunakan untuk validasi identitas mitra.',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              height: 1.4,
                              color: AppColors.textSoft,
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
                          ? 'Upload NPWP (Opsional)'
                          : 'NPWP Terpilih (${_npwpFile!.path.split('/').last})',
                      helperText: 'Boleh dikosongkan bila belum ada',
                      picked: _npwpFile != null,
                      onTap: () => _pilihSumberFile(
                        (file) => setState(() => _npwpFile = file),
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
                          ? 'Upload Dokumen Halal / SEHATI (Opsional)'
                          : 'Halal Terpilih (${_halalFile!.path.split('/').last})',
                      helperText:
                          'Foto sertifikat halal atau bukti pendaftaran SEHATI',
                      picked: _halalFile != null,
                      onTap: () => _pilihSumberFile(
                        (file) => setState(() => _halalFile = file),
                      ),
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
                            activeColor: AppColors.orange,
                            checkColor: AppColors.textDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (value) =>
                                setState(() => _setujuSyarat = value ?? false),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text.rich(
                                TextSpan(
                                  style: GoogleFonts.nunito(
                                    fontSize: 13.5,
                                    height: 1.5,
                                    color: AppColors.textSoft,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Saya menyetujui '),
                                    TextSpan(
                                      text: 'Syarat & Ketentuan Kemitraan',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const TextSpan(text: ' serta '),
                                    TextSpan(
                                      text: 'Kebijakan Privasi',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const TextSpan(text: ' LastBite.'),
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
                  onPressed: _isLoading ? null : _selesai,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: AppColors.textDark,
                    disabledBackgroundColor: AppColors.orange.withOpacity(0.6),
                    elevation: 3,
                    shadowColor: AppColors.orange.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.textDark,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 20,
                              color: AppColors.textDark,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Selesai',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
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
        border: Border.all(color: _kBorder, width: 1),
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
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Text(
                requiredLabel,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: optional ? AppColors.textSoft : AppColors.orange,
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
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: picked ? AppColors.orange : _kBorder,
                  width: picked ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: picked ? AppColors.orange : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      picked ? Icons.check_circle : icon,
                      color: picked ? AppColors.textDark : AppColors.orange,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      buttonLabel,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      helperText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: AppColors.textSoft,
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
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.orange,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSoft,
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
            color: AppColors.primary,
            backgroundColor: _kTrack,
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        Text(
          subtitle,
          style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
