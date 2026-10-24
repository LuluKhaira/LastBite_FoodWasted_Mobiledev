import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';
import 'widgets/auth_ui.dart';
import 'daftar_screen.dart';

class MasukScreen extends StatefulWidget {
  const MasukScreen({super.key});

  @override
  State<MasukScreen> createState() => _MasukScreenState();
}

class _MasukScreenState extends State<MasukScreen> {
  final _form = GlobalKey<FormState>();
  final _id = TextEditingController();
  final _sandi = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _id.dispose();
    _sandi.dispose();
    super.dispose();
  }

  Future<void> _masuk() async {
    FocusScope.of(context).unfocus();
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    // Memanggil API login yang terhubung ke backend Laravel (/api/login-mitra)
    final result = await ApiService.loginMitra(
      _id.text.trim(),
      _sandi.text.trim(),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['ok']) {
      authSnack(context, result['message']);
      // TODO: Tambahkan navigasi ke halaman dashboard/beranda di sini setelah berhasil login
    } else {
      authSnack(context, result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Masuk',
      subtitle:
          'Senang melihatmu lagi. Masuk untuk lanjut menyelamatkan makanan dari usaha terdekat.',
      formKey: _form,
      children: [
        AuthField(
          controller: _id,
          hint: 'Email atau nomor HP',
          icon: Icons.person_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: authValidasiId,
        ),
        AuthField(
          controller: _sandi,
          hint: 'Kata sandi',
          icon: Icons.lock_outline_rounded,
          password: true,
          textInputAction: TextInputAction.done,
          validator: (v) =>
              (v ?? '').isEmpty ? 'Kata sandi wajib diisi' : null,
        ),
        const SizedBox(height: 4),
        AuthButton(label: 'Masuk', onPressed: _masuk, loading: _loading),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => authSnack(context, 'Lupa kata sandi segera hadir'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Lupa kata sandi?',
                style: AppColors.body(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AuthUI.orangeText,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        AuthSocialButton(
          icon: Text('G', style: AppColors.heading(fontSize: 18)),
          label: 'Masuk dengan Google',
          onTap: () => authSnack(context, 'Masuk dengan Google segera hadir'),
        ),
        AuthSocialButton(
          icon: const Icon(Icons.apple, size: 22, color: AppColors.textDark),
          label: 'Masuk dengan Apple',
          onTap: () => authSnack(context, 'Masuk dengan Apple segera hadir'),
        ),
        const SizedBox(height: 10),
        AuthBottomLink(
          teks: 'Belum punya akun?',
          aksi: 'Daftar',
          onTap: () => Navigator.pushReplacement(
            context,
            authRoute(const DaftarScreen()),
          ),
        ),
      ],
    );
  }
}