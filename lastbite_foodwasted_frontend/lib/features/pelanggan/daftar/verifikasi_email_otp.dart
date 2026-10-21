import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../beranda/api_service.dart';
import '../beranda/halaman_beranda.dart';
import '../widgets/auth_widgets.dart';

class EmailOtpScreen extends StatefulWidget {
  final String email;
  const EmailOtpScreen({super.key, required this.email});

  @override
  State<EmailOtpScreen> createState() => _EmailOtpScreenState();
}

class _EmailOtpScreenState extends State<EmailOtpScreen> {
  final _ctrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _verifikasi() async {
    final kode = _ctrl.text.trim();
    if (kode.length != 6) {
      showLbSnack(context, 'Masukkan 6 digit kode.', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      debugPrint('[VerifikasiEmailOtp] Verifikasi email: ${widget.email}, kode: $kode');
      await ApiService.verifikasiEmailOtp(widget.email, kode);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const BerandaScreen()),
        (_) => false,
      );
    } catch (e, stack) {
      debugPrint('[VerifikasiEmailOtp] Gagal verifikasi: $e\n$stack');
      if (mounted) showLbSnack(context, lbPesanError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _kirimUlang() async {
    try {
      debugPrint('[VerifikasiEmailOtp] Kirim ulang kode ke ${widget.email}');
      await ApiService.kirimEmailOtp(widget.email);
      if (mounted) showLbSnack(context, 'Kode baru dikirim.');
    } catch (e, stack) {
      debugPrint('[VerifikasiEmailOtp] Gagal kirim ulang: $e\n$stack');
      if (mounted) showLbSnack(context, lbPesanError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(backgroundColor: AppColors.bg, elevation: 0, foregroundColor: AppColors.textDark),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cek Email Kamu',
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Text('Kami mengirim kode 6 digit ke ${widget.email}',
                  style: GoogleFonts.nunito(fontSize: 15, color: AppColors.textSoft)),
              const SizedBox(height: 24),
              TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 28, letterSpacing: 10, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••••',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onSubmitted: (_) => _verifikasi(),
              ),
              const SizedBox(height: 20),
              LbPrimaryButton(label: 'Verifikasi & Masuk', onPressed: _verifikasi, loading: _loading),
              const SizedBox(height: 12),
              Center(
                child: TextButton(onPressed: _kirimUlang, child: const Text('Kirim ulang kode')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}