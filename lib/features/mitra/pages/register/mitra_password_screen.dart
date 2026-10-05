// ============================================================
// LastBite - Daftar Mitra, Langkah 3 dari 7 (Buat Kata Sandi)
// Simpan sebagai: lib/features/mitra/pages/register/mitra_password_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mitra_business_screen.dart';

const _bg = Color(0xFFEAFDE1);
const _primary = Color(0xFF006B1E);
const _fieldBg = Color(0xFFF5FAF2);
const _fieldBorder = Color(0xFFE1EBDD);
const _textDark = Color(0xFF10260F);
const _textSoft = Color(0xFF3F4A3C);
const _grey = Color(0xFF8C978A);

class MitraPasswordScreen extends StatefulWidget {
  const MitraPasswordScreen({super.key});

  @override
  State<MitraPasswordScreen> createState() => _MitraPasswordScreenState();
}

class _MitraPasswordScreenState extends State<MitraPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    // Setiap ketikan berubah, gambar ulang tanda centang syarat kata sandi.
    _passwordController.addListener(() => setState(() {}));
    _confirmController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _hasMinLength => _passwordController.text.length >= 8;

  bool get _hasLetterAndNumber {
    final text = _passwordController.text;
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(text);
    final hasNumber = RegExp(r'[0-9]').hasMatch(text);
    return hasLetter && hasNumber;
  }

  void _lanjutkan() {
    if (!_hasMinLength) {
      _showError('Kata sandi minimal 8 karakter.');
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      _showError('Konfirmasi kata sandi tidak sama.');
      return;
    }
    // TODO: simpan kata sandi (kirim ke server saat submit akhir).
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MitraBusinessScreen()),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            const _Header(
              title: 'Daftar Mitra',
              subtitle: 'Buat Kata Sandi',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProgressBar(step: 3, label: 'BUAT KATA SANDI'),
                    const SizedBox(height: 24),
                    Text(
                      'Buat Kata Sandi Akun',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kata sandi ini digunakan untuk masuk ke dashboard mitra tokomu.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        height: 1.6,
                        color: _textSoft,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ---- Kartu form ----
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kata Sandi',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _PasswordField(
                            controller: _passwordController,
                            hint: 'Minimal 8 karakter',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscurePassword,
                            onToggle: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          const SizedBox(height: 12),
                          _RuleRow(
                            checked: _hasMinLength,
                            label: 'Minimal 8 karakter',
                          ),
                          const SizedBox(height: 6),
                          _RuleRow(
                            checked: _hasLetterAndNumber,
                            label: 'Kombinasi huruf dan angka',
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Konfirmasi Kata Sandi',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _PasswordField(
                            controller: _confirmController,
                            hint: 'Ulangi kata sandi',
                            icon: Icons.lock_reset_rounded,
                            obscure: _obscureConfirm,
                            onToggle: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
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
                      child: Text(
                        'Lanjutkan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Kembali ke Verifikasi OTP',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _primary,
                      ),
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

// ---------- Input kata sandi dengan ikon mata ----------
class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.plusJakartaSans(fontSize: 16, color: _textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 15, color: _grey),
        prefixIcon: Icon(icon, color: _grey, size: 22),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: _grey,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: _fieldBg,
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

// ---------- Baris centang syarat kata sandi ----------
class _RuleRow extends StatelessWidget {
  final bool checked;
  final String label;

  const _RuleRow({required this.checked, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          checked ? Icons.check_circle : Icons.circle_outlined,
          size: 18,
          color: checked ? _primary : _grey,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: checked ? FontWeight.w700 : FontWeight.w500,
            color: checked ? _primary : _grey,
          ),
        ),
      ],
    );
  }
}

// ---------- Progress bar + label langkah (dipakai ulang tiap halaman) ----------
class _ProgressBar extends StatelessWidget {
  final int step;
  final String label;
  static const totalSteps = 7;

  const _ProgressBar({required this.step, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Langkah $step dari $totalSteps',
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
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: LinearProgressIndicator(
            value: step / totalSteps,
            minHeight: 8,
            color: _primary,
            backgroundColor: const Color(0xFFD5EDCB),
          ),
        ),
      ],
    );
  }
}

// ---------- Header (dipakai ulang tiap halaman) ----------
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