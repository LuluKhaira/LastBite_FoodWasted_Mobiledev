// ============================================================
// LastBite - Daftar Mitra, Langkah 4 dari 6 (Nama & Alamat Usaha)
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';

import 'mitra_documents_screen.dart';

const Color _kBorder = Color(0xFFE9E6E0);
const Color _kTrack = Color(0xFFECE9E4);

class MitraAddressScreen extends StatefulWidget {
  final String phoneNumber;

  const MitraAddressScreen({super.key, required this.phoneNumber});

  @override
  State<MitraAddressScreen> createState() => _MitraAddressScreenState();
}

class _MitraAddressScreenState extends State<MitraAddressScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;

  final double _lat = 1.1301;
  final double _lng = 104.0529;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _ubahPinPeta() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Fitur geser pin peta menyusul.',
          style: GoogleFonts.nunito(color: Colors.white),
        ),
        backgroundColor: AppColors.orange,
      ),
    );
  }

  Future<void> _lanjutkan() async {
    final namaUsaha = _nameController.text.trim();
    final alamat = _addressController.text.trim();

    if (namaUsaha.isEmpty) {
      _showError('Nama usaha wajib diisi.');
      return;
    }
    if (alamat.isEmpty) {
      _showError('Alamat lengkap usaha wajib diisi.');
      return;
    }

    setState(() => _isLoading = true);

    bool sukses = await ApiService.setAddress(
      widget.phoneNumber,
      namaUsaha,
      alamat,
    );

    setState(() => _isLoading = false);

    if (sukses) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MitraDocumentsScreen(
              phoneNumber:
                  widget.phoneNumber, // <-- Kirim nomor HP ke langkah dokumen
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        _showError('Gagal menyimpan nama usaha & alamat ke server.');
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
            const _Header(title: 'Daftar Mitra', subtitle: 'Alamat Usaha'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ProgressBar(
                      step: 4,
                      total: 6,
                      label: 'Nama & Alamat Usaha',
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Nama & Alamat Usaha',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Informasikan nama toko dan lokasi penjemputan surplus makanan oleh pelanggan.',
                      style: GoogleFonts.nunito(
                        fontSize: 14.5,
                        height: 1.6,
                        color: AppColors.textSoft,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ---- Field 1: Nama Usaha ----
                    const _FieldLabel(
                      label: 'Nama Usaha / Toko',
                      required: true,
                    ),
                    const SizedBox(height: 8),
                    _WhiteField(
                      controller: _nameController,
                      hint: 'Dapur Roti Manis Batam',
                      icon: Icons.storefront_outlined,
                    ),
                    const SizedBox(height: 8),
                    const _HintRow(
                      text: 'Gunakan nama yang tertera jelas pada plang atau spanduk tokomu.',
                    ),
                    const SizedBox(height: 24),

                    // ---- Field 2: Alamat Lengkap ----
                    const _FieldLabel(
                      label: 'Alamat Lengkap Usaha',
                      required: true,
                    ),
                    const SizedBox(height: 8),
                    _WhiteField(
                      controller: _addressController,
                      hint: 'Komp. Mahkota Raya Blok C No. 12, Teluk Tering',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    const _HintRow(
                      text: 'Cantumkan nomor ruko dan patokan yang mudah ditemukan.',
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Titik Penjemputan (Peta GPS)',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.my_location,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'GPS Akurat',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _MapPreview(onUbahPin: _ubahPinPeta),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _kBorder, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 18,
                            color: AppColors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Batam Center, Batam',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  '${_lat.toStringAsFixed(4)}° N, ${_lng.toStringAsFixed(4)}° E',
                                  style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    color: AppColors.textSoft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _ubahPinPeta,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.orange.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.edit_location_alt,
                                    size: 16,
                                    color: AppColors.orange,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Ubah Pin Peta',
                                    style: GoogleFonts.nunito(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.orange,
                                    ),
                                  ),
                                ],
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

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _lanjutkan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: AppColors.textDark,
                        disabledBackgroundColor: AppColors.orange.withOpacity(
                          0.6,
                        ),
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
                                Text(
                                  'Lanjutkan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 22,
                                  color: AppColors.textDark,
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.chevron_left,
                          size: 18,
                          color: AppColors.orange,
                        ),
                        Text(
                          'Kembali ke Buat Kata Sandi',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.orange,
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

class _MapPreview extends StatelessWidget {
  final VoidCallback onUbahPin;
  const _MapPreview({required this.onUbahPin});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFDCEFE0), Color(0xFFCFE8F0)],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Sinyal Stabil',
                      style: GoogleFonts.nunito(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.storefront,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Titik Ambil',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.location_on,
                    size: 40,
                    color: Color(0xFFE23D28),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: onUbahPin),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;

  const _FieldLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        if (required)
          Text(
            'Wajib',
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.orange,
            ),
          ),
      ],
    );
  }
}

class _WhiteField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final int maxLines;

  const _WhiteField({
    required this.controller,
    required this.hint,
    this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.nunito(fontSize: 15, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(
          fontSize: 14,
          color: AppColors.textSoft.withOpacity(0.6),
        ),
        prefixIcon: icon != null ? Icon(icon, color: AppColors.textSoft) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
        ),
      ),
    );
  }
}

class _HintRow extends StatelessWidget {
  final String text;
  const _HintRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, size: 16, color: AppColors.textSoft),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 13.5,
              height: 1.4,
              color: AppColors.textSoft,
            ),
          ),
        ),
      ],
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      color: AppColors.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSoft,
            ),
          ),
        ],
      ),
    );
  }
}
