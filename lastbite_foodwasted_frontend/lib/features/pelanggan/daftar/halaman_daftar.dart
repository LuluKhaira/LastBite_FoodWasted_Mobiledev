import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../beranda/api_service.dart';
import '../widgets/auth_widgets.dart';
import 'verifikasi_otp.dart';

class UserRegisterScreen extends StatefulWidget {
  const UserRegisterScreen({super.key});

  @override
  State<UserRegisterScreen> createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends State<UserRegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _setuju = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    if (!_setuju) {
      showLbSnack(context, 'Centang persetujuan Ketentuan Layanan dulu ya.', error: true);
      return;
    }

    final phone = normalizePhone(_phoneCtrl.text)!;

    setState(() => _loading = true);
    try {
      await ApiService.daftarOtp(
        name: _nameCtrl.text.trim(),
        phone: phone,
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OtpVerificationScreen(phone: phone, purpose: 'register')),
      );
    } catch (e) {
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
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LbTopBar(),
                const SizedBox(height: 18),
                const LbHeroCard(
                  title: 'Gabung Jadi\nPenyelamat Pangan',
                  subtitle: 'Daftar gratis dan mulai selamatkan makanan lezat sebelum terbuang.',
                  image: 'assets/images/sayuran.jpg',
                  icon: Icons.volunteer_activism_rounded,
                ),
                const SizedBox(height: 26),
                const LbLabel('Nama Lengkap'),
                LbField(
                  controller: _nameCtrl,
                  hint: 'Nama kamu',
                  icon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'Nama wajib diisi';
                    if (t.length < 3) return 'Nama minimal 3 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                const LbLabel('Nomor WhatsApp'),
                LbPhoneField(
                  controller: _phoneCtrl,
                  validator: (v) => normalizePhone(v ?? '') == null ? 'Masukkan nomor HP Indonesia yang valid' : null,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text('Kode OTP akan dikirim ke WhatsApp ini untuk verifikasi.',
                      style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textSoft)),
                ),
                const SizedBox(height: 18),
                const LbLabel('Email', optional: true),
                LbField(
                  controller: _emailCtrl,
                  hint: 'nama@email.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return null;
                    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t) ? null : 'Format email tidak valid';
                  },
                ),
                const SizedBox(height: 18),
                const LbLabel('Kata Sandi', optional: true),
                LbField(
                  controller: _passCtrl,
                  hint: 'Minimal 8 karakter',
                  icon: Icons.lock_outline_rounded,
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    final t = v ?? '';
                    if (t.isEmpty) return null;
                    if (t.length < 8) return 'Kata sandi minimal 8 karakter';
                    if (_emailCtrl.text.trim().isEmpty) return 'Isi email dulu untuk memakai kata sandi';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text('Email & sandi opsional, dipakai kalau kamu mau masuk tanpa OTP.',
                      style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textSoft)),
                ),
                const SizedBox(height: 20),
                _barisSetuju(),
                const SizedBox(height: 22),
                LbPrimaryButton(label: 'Daftar & Kirim OTP', onPressed: _submit, loading: _loading),
                const SizedBox(height: 22),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text('Sudah punya akun? ', style: GoogleFonts.nunito(fontSize: 15, color: AppColors.textDark)),
                      GestureDetector(
                        onTap: () => Navigator.maybePop(context),
                        child: Text('Masuk',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _barisSetuju() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 14, 10),
      decoration: BoxDecoration(color: AuthUi.card, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Checkbox(
            value: _setuju,
            onChanged: (v) => setState(() => _setuju = v ?? false),
            activeColor: AppColors.textDark,
            side: const BorderSide(color: AppColors.textSoft, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: GoogleFonts.nunito(fontSize: 13.5, height: 1.45, color: AppColors.textSoft),
                children: [
                  const TextSpan(text: 'Saya menyetujui '),
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