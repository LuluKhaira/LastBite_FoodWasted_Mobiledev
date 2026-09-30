// ============================================================
// LastBite - Daftar Mitra, Langkah 2 dari 7 (Verifikasi OTP)
// Simpan sebagai: lib/features/mitra/pages/register/mitra_otp_screen.dart
// ============================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mitra_password_screen.dart';

const _bg = Color(0xFFEAFDE1);
const _primary = Color(0xFF006B1E);
const _fieldBg = Color(0xFFE6F6DE);
const _emptyBox = Color(0xFFF0FAEA);
const _textDark = Color(0xFF10260F);
const _textSoft = Color(0xFF3F4A3C);

class MitraOtpScreen extends StatefulWidget {
  // Nomor dikirim dari halaman langkah 1 (hanya digit, tanpa +62).
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

  // initState() dipanggil sekali saat halaman dibuat.
  @override
  void initState() {
    super.initState();
    _startTimer();
    // Setiap isi input berubah, gambar ulang kotak-kotak OTP.
    _otpController.addListener(() => setState(() {}));
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel(); // hentikan timer supaya tidak jalan terus
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Hitung mundur tiap 1 detik.
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

  // 8123456789 -> 812-3456-789
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

  void _resend() {
    // TODO: panggil API untuk kirim ulang OTP
    _otpController.clear();
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kode baru telah dikirim.')),
    );
  }

  void _verify() {
    if (_otpController.text.length != _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan 6 digit kode verifikasi.')),
      );
      return;
    }
    // TODO: kirim ke server untuk dicek, kalau benar lanjut ke langkah 3.
    debugPrint('Verifikasi OTP: ${_otpController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
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
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: _primary,
                          ),
                        ),
                        Text(
                          'Verifikasi OTP',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _textSoft,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: const LinearProgressIndicator(
                        value: 2 / 7,
                        minHeight: 8,
                        color: _primary,
                        backgroundColor: Color(0xFFD5EDCB),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ---- Kartu judul ----
                    _WhiteCard(
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: _fieldBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.mark_chat_unread_rounded,
                                color: _primary, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Masukkan Kode Verifikasi',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: _textDark,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Amankan akun kemitraan toko Anda',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
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

                    // ---- Kartu nomor tujuan ----
                    _WhiteCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kode OTP 6-digit telah dikirimkan via WhatsApp resmi ke nomor:',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              height: 1.6,
                              color: _textSoft,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: _fieldBg,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.chat,
                                    size: 20, color: _primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _formattedPhone,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: _textDark,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  // Kembali ke halaman langkah 1 untuk ganti nomor.
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    'Ubah',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
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
                    const SizedBox(height: 16),

                    // ---- Kartu input OTP ----
                    _WhiteCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KODE 6-DIGIT',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _textSoft,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildOtpBoxes(),
                          const SizedBox(height: 16),
                          Center(child: _buildResendChip()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ---- Peringatan ----
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.shield,
                              size: 20, color: Color(0xFF6B7B68)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Jangan bagikan kode verifikasi ini kepada siapa pun, termasuk pihak yang mengatasnamakan Lastbite.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                height: 1.5,
                                color: _textSoft,
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
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _verify,
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
                            'Verifikasi & Lanjutkan',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Butuh bantuan? ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: _textSoft,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: buka WhatsApp Care (nanti pakai package url_launcher)
                          debugPrint('WhatsApp Care ditekan');
                        },
                        child: Row(
                          children: [
                            Text(
                              'Hubungi WhatsApp Care Lastbite',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: _primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.open_in_new,
                                size: 16, color: _primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 6 kotak OTP. Trik: satu TextField tak terlihat (Opacity 0) diletakkan
  // di atas kotak-kotak, jadi keyboard tetap muncul dan input tetap 1 string.
  Widget _buildOtpBoxes() {
    final text = _otpController.text;
    final activeIndex = text.length; // kotak yang sedang diisi

    return Stack(
      children: [
        Row(
          children: List.generate(_otpLength, (i) {
            final filled = i < text.length;
            final active = i == activeIndex && _focusNode.hasFocus;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == _otpLength - 1 ? 0 : 8),
                child: AspectRatio(
                  aspectRatio: 1,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _fieldBg,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              canResend ? Icons.refresh_rounded : Icons.access_time,
              size: 18,
              color: canResend ? _primary : const Color(0xFF6B7B68),
            ),
            const SizedBox(width: 6),
            if (canResend)
              Text(
                'Kirim Ulang Kode',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                ),
              )
            else
              Text.rich(
                TextSpan(
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: const Color(0xFF6B7B68),
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

// ---------- Satu kotak OTP: terisi / aktif / kosong ----------
class _OtpBox extends StatelessWidget {
  final String? digit;
  final bool active;

  const _OtpBox({required this.digit, required this.active});

  @override
  Widget build(BuildContext context) {
    final filled = digit != null;

    return Container(
      decoration: BoxDecoration(
        color: filled
            ? _fieldBg
            : active
                ? Colors.white
                : _emptyBox,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active
              ? _primary
              : filled
                  ? const Color(0xFFCDEBC3)
                  : Colors.transparent,
          width: active ? 1.5 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: filled
          ? Text(
              digit!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            )
          : active
              // Garis kursor
              ? Container(width: 2, height: 26, color: _primary)
              // Titik placeholder
              : Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFCBD5C8),
                    shape: BoxShape.circle,
                  ),
                ),
    );
  }
}

// ---------- Kartu putih ----------
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ---------- Header ----------
class _Header extends StatelessWidget {
  const _Header();

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
            'Daftar Mitra',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          Text(
            'Verifikasi Otp',
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