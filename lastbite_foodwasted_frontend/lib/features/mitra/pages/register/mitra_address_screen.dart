import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mitra_documents_screen.dart';

const _bg = Color(0xFFEAFDE1);
const _primary = Color(0xFF006B1E);
const _fieldBorder = Color(0xFFE1EBDD);
const _textDark = Color(0xFF10260F);
const _textSoft = Color(0xFF3F4A3C);
const _grey = Color(0xFF8C978A);

class MitraAddressScreen extends StatefulWidget {
  const MitraAddressScreen({super.key});

  @override
  State<MitraAddressScreen> createState() => _MitraAddressScreenState();
}

class _MitraAddressScreenState extends State<MitraAddressScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  // Koordinat pin peta. Nanti ini diisi dari hasil geser peta asli.
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
      const SnackBar(content: Text('Fitur geser pin peta menyusul.')),
    );
  }

  void _lanjutkan() {
    if (_nameController.text.trim().isEmpty) {
      _showError('Nama usaha wajib diisi.');
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      _showError('Alamat lengkap usaha wajib diisi.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MitraDocumentsScreen()),
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
            const _Header(title: 'Daftar Mitra', subtitle: 'Alamat Usaha'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ProgressBar(
                        step: 4, total: 6, label: 'Nama & Alamat Usaha'),
                    const SizedBox(height: 24),
                    Text(
                      'Nama & Alamat Usaha',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Informasikan nama toko dan lokasi penjemputan surplus makanan oleh pelanggan.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        height: 1.6,
                        color: _textSoft,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _FieldLabel(label: 'Nama Usaha / Toko', required: true),
                    const SizedBox(height: 8),
                    _WhiteField(
                      controller: _nameController,
                      hint: 'Dapur Roti Manis Batam',
                      icon: Icons.storefront_outlined,
                    ),
                    const SizedBox(height: 8),
                    _HintRow(
                      text:
                          'Gunakan nama yang tertera jelas pada plang atau spanduk tokomu.',
                    ),
                    const SizedBox(height: 24),

                    _FieldLabel(label: 'Alamat Lengkap Usaha', required: true),
                    const SizedBox(height: 8),
                    _WhiteField(
                      controller: _addressController,
                      hint: 'Komp. Mahkota Raya Blok C No. 12, Teluk Tering',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    _HintRow(
                      text:
                          'Cantumkan nomor ruko dan patokan yang mudah ditemukan.',
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Titik Penjemputan (Peta GPS)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.my_location,
                                size: 14, color: _primary),
                            const SizedBox(width: 4),
                            Text(
                              'GPS Akurat',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: _primary,
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
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 18, color: _primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Batam Center, Batam',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: _textDark,
                                  ),
                                ),
                                Text(
                                  '${_lat.toStringAsFixed(4)}° N, ${_lng.toStringAsFixed(4)}° E',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    color: _grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _ubahPinPeta,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDFF0D8),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.edit_location_alt,
                                      size: 16, color: _primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Ubah Pin Peta',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _primary,
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
                      onPressed: _lanjutkan,
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
                          Text(
                            'Lanjutkan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 22),
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
                        const Icon(Icons.chevron_left, size: 18, color: _primary),
                        Text(
                          'Kembali ke Buat Kata Sandi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
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
            // Latar hijau-biru sebagai pengganti tile peta asli.
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFDCEFE0), Color(0xFFCFE8F0)],
                ),
              ),
            ),
            // Badge "Sinyal Stabil"
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
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
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.storefront,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Titik Ambil',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.location_on,
                      size: 40, color: Color(0xFFE23D28)),
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
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        if (required)
          Text(
            'Wajib',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _primary,
            ),
          ),
      ],
    );
  }
}

// ---------- Input putih dipakai ulang ----------
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
      style: GoogleFonts.plusJakartaSans(fontSize: 15, color: _textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14.5, color: _grey),
        prefixIcon: icon != null ? Icon(icon, color: _grey) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _fieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
      ),
    );
  }
}

// ---------- Baris hint dengan ikon info ----------
class _HintRow extends StatelessWidget {
  final String text;
  const _HintRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, size: 16, color: _grey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.4,
              color: _textSoft,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------- Progress bar + label langkah ----------
class _ProgressBar extends StatelessWidget {
  final int step;
  final int total;
  final String label;

  const _ProgressBar(
      {required this.step, required this.total, required this.label});

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
                fontWeight: FontWeight.w700,
                color: _textSoft,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _primary,
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