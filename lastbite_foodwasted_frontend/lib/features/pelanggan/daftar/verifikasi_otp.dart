import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../beranda/api_service.dart';
import '../beranda/halaman_beranda.dart';
import '../widgets/auth_widgets.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final String purpose;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    required this.purpose,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifikasi() async {
    FocusScope.of(context).unfocus();
    final code = _otpController.text.trim();
    if (code.length != 6) {
      showLbSnack(context, 'Masukkan 6 digit kode.', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      await ApiService.verifikasiOtp(widget.phone, code, widget.purpose);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const BerandaScreen()),
        (_) => false,
      );
    } catch (e) {
      if (mounted) showLbSnack(context, lbPesanError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _kirimUlang() async {
    try {
      await ApiService.kirimUlangOtp(widget.phone, widget.purpose);
      if (mounted) showLbSnack(context, 'Kode baru sudah dikirim.');
    } catch (e) {
      if (mounted) showLbSnack(context, lbPesanError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          widget.purpose == 'login' ? 'Masuk - Verifikasi' : 'Daftar - Verifikasi',
          style: GoogleFonts.poppins(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'Masukkan Kode Verifikasi',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kami telah mengirimkan 6 digit kode verifikasi ke nomor ${formatPhoneDisplay(widget.phone)}.',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: AppColors.textSoft,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                onSubmitted: (_) => _verifikasi(),
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                  color: AppColors.textDark,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••••',
                  hintStyle: GoogleFonts.poppins(color: AppColors.textSoft, letterSpacing: 6),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.textSoft.withValues(alpha: 0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.textSoft.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.textDark, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tidak menerima kode? ',
                    style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textSoft),
                  ),
                  GestureDetector(
                    onTap: _kirimUlang,
                    child: Text(
                      'Kirim Ulang',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _loading ? null : _verifikasi,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                        )
                      : Text(
                          'Verifikasi & Masuk',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}