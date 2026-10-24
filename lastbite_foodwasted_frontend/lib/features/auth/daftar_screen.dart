import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';

import 'widgets/auth_ui.dart';
import 'masuk_screen.dart';

// Import layar OTP
import '../pelanggan/daftar/verifikasi_email_otp.dart';
import '../pelanggan/daftar/verifikasi_otp.dart';

class DaftarScreen extends StatefulWidget {
  const DaftarScreen({super.key});

  @override
  State<DaftarScreen> createState() => _DaftarScreenState();
}

class _DaftarScreenState extends State<DaftarScreen> {
  final _form = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _id = TextEditingController();
  final _sandi = TextEditingController();
  bool _setuju = false;
  bool _loading = false;

  @override
  void dispose() {
    _nama.dispose();
    _id.dispose();
    _sandi.dispose();
    super.dispose();
  }

  Future<void> _daftar() async {
    FocusScope.of(context).unfocus();
    if (!(_form.currentState?.validate() ?? false)) return;
    if (!_setuju) {
      authSnack(
        context,
        'Setujui Syarat & Ketentuan terlebih dahulu',
        error: true,
      );
      return;
    }
    setState(() => _loading = true);

    final inputId = _id.text.trim();
    final isEmail = inputId.contains('@');

    if (isEmail) {
      // Pendaftaran menggunakan Email
      final result = await ApiService.register(
        name: _nama.text.trim(),
        identifier: inputId,
        password: _sandi.text.trim(),
      );

      if (!mounted) return;
      setState(() => _loading = false);

      if (result['ok']) {
        authSnack(context, result['message']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => EmailOtpScreen(email: inputId)),
        );
      } else {
        authSnack(context, result['message'], error: true);
      }
    } else {
      // Pendaftaran menggunakan Nomor HP (Fonnte / WhatsApp OTP)
      final success = await ApiService.registerWhatsApp(inputId);

      if (!mounted) return;
      setState(() => _loading = false);

      if (success) {
        authSnack(context, 'Kode OTP berhasil dikirim via WhatsApp.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OtpVerificationScreen(phone: inputId, purpose: 'register'),
          ),
        );
      } else {
        authSnack(
          context,
          ApiService.lastErrorMessage ?? 'Gagal mengirim OTP.',
          error: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Daftar',
      subtitle:
          'Buat akun baru dan mulai selamatkan makanan dari usaha terdekat di Batam.',
      formKey: _form,
      children: [
        AuthField(
          controller: _nama,
          hint: 'Nama lengkap',
          icon: Icons.person_outline_rounded,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          validator: (v) =>
              (v ?? '').trim().isEmpty ? 'Nama wajib diisi' : null,
        ),
        AuthField(
          controller: _id,
          hint: 'Email atau nomor HP',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: authValidasiId,
        ),
        AuthField(
          controller: _sandi,
          hint: 'Kata sandi (min. 8 karakter)',
          icon: Icons.lock_outline_rounded,
          password: true,
          textInputAction: TextInputAction.done,
          validator: (v) {
            final t = v ?? '';
            if (t.length < 8) return 'Minimal 8 karakter';
            if (!RegExp(r'[A-Za-z]').hasMatch(t) ||
                !RegExp(r'\d').hasMatch(t)) {
              return 'Gunakan kombinasi huruf dan angka';
            }
            return null;
          },
        ),
        AuthSwitchRow(
          label: 'Saya menyetujui Syarat & Ketentuan serta Kebijakan Privasi',
          value: _setuju,
          onChanged: (v) => setState(() => _setuju = v),
        ),
        const SizedBox(height: 14),
        AuthButton(label: 'Daftar', onPressed: _daftar, loading: _loading),
        const SizedBox(height: 18),
        AuthSocialButton(
          icon: Text('G', style: AppColors.heading(fontSize: 18)),
          label: 'Daftar dengan Google',
          onTap: () => authSnack(context, 'Daftar dengan Google segera hadir'),
        ),
        AuthSocialButton(
          icon: const Icon(Icons.apple, size: 22, color: AppColors.textDark),
          label: 'Daftar dengan Apple',
          onTap: () => authSnack(context, 'Daftar dengan Apple segera hadir'),
        ),
        const SizedBox(height: 10),
        AuthBottomLink(
          teks: 'Sudah punya akun?',
          aksi: 'Masuk',
          onTap: () => Navigator.pushReplacement(
            context,
            authRoute(const MasukScreen()),
          ),
        ),
      ],
    );
  }
}