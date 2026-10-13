// ============================================================
// LastBite - Daftar Mitra, Langkah 3 dari 6 (Buat Kata Sandi)
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';

import 'mitra_address_screen.dart';

const Color _kBorder = Color(0xFFE9E6E0);
const Color _kTrack = Color(0xFFECE9E4);

class MitraPasswordScreen extends StatefulWidget {
  final String phoneNumber;

  const MitraPasswordScreen({super.key, required this.phoneNumber});

  @override
  State<MitraPasswordScreen> createState() => _MitraPasswordScreenState();
}

class _MitraPasswordScreenState extends State<MitraPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _lanjutkan() async {
    if (!_hasMinLength) {
      _showError('Kata sandi minimal 8 karakter.');
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      _showError('Konfirmasi kata sandi tidak sama.');
      return;
    }

    setState(() => _isLoading = true);

    // Kirim password ke backend Laravel
    bool sukses = await ApiService.setPassword(
      widget.phoneNumber,
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (sukses) {
      if (mounted) {
        // Langsung lompat ke MitraAddressScreen (Langkah 4 dari 6)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MitraAddressScreen(phoneNumber: widget.phoneNumber),
          ),
        );
      }
    } else {
      if (mounted) {
        _showError('Gagal menyimpan kata sandi ke server.');
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
            const _Header(title: 'Daftar Mitra', subtitle: 'Buat Kata Sandi'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ProgressBar(step: 3, label: 'BUAT KATA SANDI'),
                    const SizedBox(height: 24),
                    Text(
                      'Buat Kata Sandi Akun',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kata sandi ini digunakan untuk masuk ke dashboard mitra tokomu.',
                      style: GoogleFonts.nunito(
                        fontSize: 14.5,
                        height: 1.6,
                        color: AppColors.textSoft,
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
                        border: Border.all(color: _kBorder, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
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
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _PasswordField(
                            controller: _passwordController,
                            hint: 'Minimal 8 karakter',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscurePassword,
                            onToggle: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
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
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _PasswordField(
                            controller: _confirmController,
                            hint: 'Ulangi kata sandi',
                            icon: Icons.lock_reset_rounded,
                            obscure: _obscureConfirm,
                            onToggle: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
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
                    child: Text(
                      'Kembali ke Verifikasi OTP',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.orange,
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
      style: GoogleFonts.nunito(fontSize: 15, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(
          fontSize: 14,
          color: AppColors.textSoft.withOpacity(0.6),
        ),
        prefixIcon: Icon(icon, color: AppColors.textSoft, size: 22),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.textSoft,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: AppColors.bg,
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
          color: checked
              ? AppColors.primary
              : AppColors.textSoft.withOpacity(0.5),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13.5,
            fontWeight: checked ? FontWeight.w700 : FontWeight.w500,
            color: checked ? AppColors.textDark : AppColors.textSoft,
          ),
        ),
      ],
    );
  }
}

// ---------- Progress bar + label langkah (Total 6 langkah) ----------
class _ProgressBar extends StatelessWidget {
  final int step;
  final String label;
  static const totalSteps = 6;

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
            value: step / totalSteps,
            minHeight: 8,
            color: AppColors.primary,
            backgroundColor: _kTrack,
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