import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../beranda/api_service.dart';
import '../beranda/halaman_beranda.dart';
import '../daftar/halaman_daftar.dart';
import '../daftar/verifikasi_otp.dart';
import '../daftar/verifikasi_email_otp.dart';
import '../widgets/auth_widgets.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final _phoneForm = GlobalKey<FormState>();
  final _emailForm = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  int _tab = 0; // 0 = WhatsApp, 1 = Email
  bool _loading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_tab == 0) {
      await _masukWhatsApp();
    } else {
      await _masukEmail();
    }
  }

  Future<void> _masukWhatsApp() async {
    if (!_phoneForm.currentState!.validate()) return;
    final phone = normalizePhone(_phoneCtrl.text)!;

    setState(() => _loading = true);
    try {
      await ApiService.masukOtp(phone);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OtpVerificationScreen(phone: phone, purpose: 'login')),
      );
    } catch (e) {
      if (mounted) showLbSnack(context, lbPesanError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _masukEmail() async {
    if (!_emailForm.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await ApiService.login(_emailCtrl.text.trim(), _passCtrl.text);
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

  /// Kirim kode OTP 6 digit ke email lalu buka layar verifikasi.
  Future<void> _kirimOtpEmail() async {
    FocusScope.of(context).unfocus();
    final email = _emailCtrl.text.trim();

    if (!_emailRegex.hasMatch(email)) {
      // Pindah ke tab Email supaya kolomnya terlihat
      if (_tab != 1) setState(() => _tab = 1);
      showLbSnack(context, 'Isi email yang valid dulu di kolom Email Akun.', error: true);
      return;
    }

    setState(() => _loading = true);
    try {
      debugPrint('[HalamanMasuk] Mengirim OTP ke email: $email (via ${ApiService.baseUrl})');
      await ApiService.kirimEmailOtp(email);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EmailOtpScreen(email: email)),
      );
    } catch (e, stack) {
      debugPrint('[HalamanMasuk] Gagal kirim OTP email: $e\n$stack');
      if (mounted) showLbSnack(context, lbPesanError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LbTopBar(),
              const SizedBox(height: 18),
              const LbHeroCard(
                title: 'Selamat Datang\nKembali',
                subtitle: 'Lanjutkan misi menyelamatkan pangan lezat bernutrisi dan merawat kelestarian bumi kita.',
              ),
              const SizedBox(height: 24),
              LbSegmented(
                labels: const ['Nomor WhatsApp', 'Email & Sandi'],
                icons: const [Icons.phone_iphone_rounded, Icons.alternate_email_rounded],
                index: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
              const SizedBox(height: 22),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _tab == 0 ? _tabWhatsApp() : _tabEmail(),
              ),
              const SizedBox(height: 22),
              LbPrimaryButton(label: 'Lanjutkan Masuk', onPressed: _submit, loading: _loading),
              const SizedBox(height: 22),
              const LbDivider('ATAU MASUK INSTAN DENGAN'),
              const SizedBox(height: 18),
              LbSecondaryButton(
                label: 'Lanjutkan dengan Akun Google',
                leading: const GoogleGlyph(),
                onPressed: () => showLbSnack(context, 'Masuk dengan Google segera hadir.'),
              ),
              const SizedBox(height: 12),
              LbSecondaryButton(
                filled: true,
                label: 'Kirim Kode OTP ke Email',
                leading: const Icon(Icons.mark_email_read_outlined, color: AppColors.textDark, size: 24),
                onPressed: _kirimOtpEmail,
              ),
              const SizedBox(height: 26),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Belum memiliki akun LastBite? ',
                        style: GoogleFonts.nunito(fontSize: 15, color: AppColors.textDark)),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const UserRegisterScreen()),
                      ),
                      child: Text('Daftar Akun Baru',
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            decoration: TextDecoration.underline,
                          )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _kotakPrivasi(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabWhatsApp() {
    return Form(
      key: _phoneForm,
      child: Column(
        key: const ValueKey('wa'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text('Nomor WhatsApp atau HP',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: AuthUi.peachSoft, borderRadius: BorderRadius.circular(10)),
                child: Text('★ Paling Cepat',
                    style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w700, color: const Color(0xFFD9772F))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LbPhoneField(
            controller: _phoneCtrl,
            onSubmitted: (_) => _submit(),
            validator: (v) => normalizePhone(v ?? '') == null ? 'Masukkan nomor HP Indonesia yang valid' : null,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text.rich(
              TextSpan(
                style: GoogleFonts.nunito(fontSize: 13, height: 1.4, color: AppColors.textSoft),
                children: [
                  const TextSpan(text: 'Contoh pengisian: '),
                  TextSpan(text: '0812 3456 7890', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  const TextSpan(text: ' (Kode OTP akan dikirim otomatis ke akun WhatsApp Anda).'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const LbInfoBox(
            title: 'Masuk Tanpa Kata Sandi',
            text: 'Kami mengirimkan kode angka 6 digit lewat WhatsApp',
          ),
        ],
      ),
    );
  }

  Widget _tabEmail() {
    return Form(
      key: _emailForm,
      child: Column(
        key: const ValueKey('email'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LbLabel('Email Akun'),
          LbField(
            controller: _emailCtrl,
            hint: 'nama@email.com',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) {
              final t = (v ?? '').trim();
              if (t.isEmpty) return 'Email wajib diisi';
              if (!_emailRegex.hasMatch(t)) return 'Format email tidak valid';
              return null;
            },
          ),
          const SizedBox(height: 16),
          const LbLabel('Kata Sandi'),
          LbField(
            controller: _passCtrl,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            validator: (v) => (v ?? '').isEmpty ? 'Kata sandi wajib diisi' : null,
          ),
        ],
      ),
    );
  }

  Widget _kotakPrivasi() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AuthUi.card, borderRadius: BorderRadius.circular(20)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.textDark, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: GoogleFonts.nunito(fontSize: 13.5, height: 1.45, color: AppColors.textSoft),
                children: [
                  const TextSpan(text: 'Privasi Anda terjaga. Masuk berarti menyetujui '),
                  TextSpan(text: 'Ketentuan Layanan', style: GoogleFonts.nunito(decoration: TextDecoration.underline, color: AppColors.textDark)),
                  const TextSpan(text: ' & '),
                  TextSpan(text: 'Kebijakan Privasi', style: GoogleFonts.nunito(decoration: TextDecoration.underline, color: AppColors.textDark)),
                  const TextSpan(text: ' LastBite.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}