// ============================================================
// LastBite - Daftar Mitra, Langkah 2 dari 7 (Verifikasi OTP)
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';
import 'mitra_password_screen.dart';

// Warna netral pendukung desain
const Color _kBorder = Color(0xFFE9E6E0);
const Color _kTrack = Color(0xFFECE9E4);

class MitraOtpScreen extends StatefulWidget {
  final String phoneNumber;

  const MitraOtpScreen({super.key, required this.phoneNumber});

  @override
  State<MitraOtpScreen> createState() => _MitraOtpScreenState();
}

class _MitraOtpScreenState extends State<MitraOtpScreen> {
  static const _otpLength = 6;
  static const _resendSeconds = 45;

  final _otpController = TextEditingController();
  final _focusNode = FocusNode();

  Timer? _timer;
  int _secondsLeft = _resendSeconds;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _otpController.addListener(() => setState(() {}));
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
      }
      setState(() => _secondsLeft--);
    });
  }

  String get _timerText {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _formattedPhone {
    final n = widget.phoneNumber;
    final parts = <String>[];
    if (n.length > 3) {
      parts.add(n.substring(0, 3));
      if (n.length > 7) {
        parts.add(n.substring(3, 7));
        parts.add(n.substring(7));
      } else {
        parts.add(n.substring(3));
      }
    } else {
      parts.add(n);
    }
    return '+62 ${parts.join('-')}';
  }

  Future<void> _resend() async {
    _otpController.clear();
    _startTimer();

    bool sukses = await ApiService.registerWhatsApp(widget.phoneNumber);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sukses ? 'Kode OTP baru telah dikirim.' : 'Gagal mengirim ulang kode.',
            style: GoogleFonts.nunito(color: Colors.white),
          ),
          backgroundColor: sukses ? AppColors.orange : Colors.red,
        ),
      );
    }
  }

  Future<void> _verify() async {
    final otpCode = _otpController.text.trim();

    if (otpCode.length != _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Masukkan 6 digit kode verifikasi dengan lengkap.', style: GoogleFonts.nunito(color: Colors.white)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    bool sukses = await ApiService.verifyOtp(widget.phoneNumber, otpCode);

    if (mounted) setState(() => _isLoading = false);

    if (sukses) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MitraPasswordScreen(
              phoneNumber: widget.phoneNumber,
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kode OTP salah atau tidak valid!', style: GoogleFonts.nunito(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Column(
                  children: [
                    // ---- Progress ----
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Langkah 2 dari 7',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.orange,
                          ),
                        ),
                        Text(
                          'Verifikasi OTP',
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
                        value: 2 / 7,
                        minHeight: 8,
                        color: AppColors.primary,
                        backgroundColor: _kTrack,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ---- Kartu judul ----
                    _WhiteCard(
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.orange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.flag_rounded,
                              color: AppColors.orange,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Masukkan Kode Verifikasi',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Amankan akun kemitraan toko Anda',
                                  style: GoogleFonts.nunito(
                                    fontSize: 13.5,
                                    color: AppColors.textSoft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ---- Kartu nomor tujuan ----
                    _WhiteCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kode OTP 6-digit telah dikirimkan via WhatsApp resmi ke nomor:',
                            style: GoogleFonts.nunito(
                              fontSize: 14.5,
                              height: 1.5,
                              color: AppColors.textSoft,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.bg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _kBorder, width: 1),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.chat,
                                    size: 20, color: AppColors.orange),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _formattedPhone,
                                    style: GoogleFonts.nunito(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    'Ubah',
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
                    const SizedBox(height: 16),

                    // ---- Kartu input OTP ----
                    _WhiteCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'KODE 6-DIGIT',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSoft,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildOtpBoxes(),
                          const SizedBox(height: 20),
                          Center(child: _buildResendChip()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---- Tombol Bawah ----
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verify,
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
                            Text(
                              'Verifikasi & Lanjutkan',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBoxes() {
    final text = _otpController.text;
    final activeIndex = text.length;

    return Stack(
      children: [
        Row(
          children: List.generate(_otpLength, (i) {
            final filled = i < text.length;
            final active = i == activeIndex && _focusNode.hasFocus;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(
                  height: 54,
                  child: _OtpBox(
                    digit: filled ? text[i] : null,
                    active: active,
                  ),
                ),
              ),
            );
          }),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: _otpController,
              focusNode: _focusNode,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(_otpLength),
              ],
              showCursor: false,
              enableInteractiveSelection: false,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResendChip() {
    final canResend = _secondsLeft <= 0;
    return GestureDetector(
      onTap: canResend ? _resend : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.orange.withOpacity(0.12),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              canResend ? Icons.refresh_rounded : Icons.access_time,
              size: 18,
              color: AppColors.orange,
            ),
            const SizedBox(width: 8),
            if (canResend)
              Text(
                'Kirim Ulang Kode',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.orange,
                ),
              )
            else
              Text.rich(
                TextSpan(
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: AppColors.orange,
                    fontWeight: FontWeight.w700,
                  ),
                  children: [
                    const TextSpan(text: 'Kirim Ulang Kode (dalam '),
                    TextSpan(
                      text: _timerText,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const TextSpan(text: ')'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final String? digit;
  final bool active;

  const _OtpBox({required this.digit, required this.active});

  @override
  Widget build(BuildContext context) {
    final filled = digit != null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active
              ? AppColors.orange
              : filled
                  ? AppColors.orange.withOpacity(0.4)
                  : _kBorder,
          width: active ? 1.5 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: filled
          ? Text(
              digit!,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            )
          : Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.textDark,
                shape: BoxShape.circle,
              ),
            ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;
  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: child,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

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
            'Daftar Mitra',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Verifikasi Otp',
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