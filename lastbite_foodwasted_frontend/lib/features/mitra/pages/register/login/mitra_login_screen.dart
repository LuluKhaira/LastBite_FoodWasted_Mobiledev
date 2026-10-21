import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lastbite_foodwasted_mobiledev/core/config/api_config.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/dashboard/mitra_dashboard_screen.dart'; // Sesuaikan path dashboard kamu

class MitraLoginScreen extends StatefulWidget {
  const MitraLoginScreen({super.key});

  @override
  State<MitraLoginScreen> createState() => _MitraLoginScreenState();
}

class _MitraLoginScreenState extends State<MitraLoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---- FUNGSI KONEKSI KE BACKEND LARAVEL ----
  Future<void> _handleLogin() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    // Validasi kosong
    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor/Email dan kata sandi wajib diisi.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/login-mitra');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'identifier': identifier, // Menyesuaikan input (bisa email/no hp)
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Berhasil login
        // TODO: Simpan token Sancton jika diperlukan (misal pakai SharedPreferences)
        // final token = data['token']; 

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login berhasil!')),
        );

        // Pindah ke Dashboard Mitra
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MitraDashboardScreen(phoneNumber: identifier),
          ),
        );
      } else {
        // Gagal dari server (misal password salah)
        final message = data['message'] ?? 'Gagal masuk, periksa kembali data Anda.';
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      // Error koneksi / jaringan
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan koneksi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleForgot() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur lupa kata sandi segera hadir.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.orange.withValues(alpha: 0.08),
              AppColors.bg,
            ],
            stops: const [0.0, 0.45],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ===== Logo =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.eco, color: AppColors.primary, size: 30),
                        const SizedBox(width: 8),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Last',
                                style: AppColors.heading(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                              TextSpan(
                                text: 'Bite',
                                style: AppColors.heading(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ===== Judul =====
                    Text(
                      'Selamat Datang Kembali',
                      textAlign: TextAlign.center,
                      style: AppColors.heading(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Masuk untuk mengelola toko dan produk Anda',
                      textAlign: TextAlign.center,
                      style: AppColors.body(
                        fontSize: 13.5,
                        color: AppColors.textSoft,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ===== Kartu form =====
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.textDark.withValues(alpha: 0.06),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // --- Username / Email ---
                          Text(
                            'Nomor WhatsApp atau Email',
                            style: AppColors.body(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _identifierController,
                            keyboardType: TextInputType.emailAddress,
                            style: AppColors.body(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                            decoration: _inputDecoration(
                              hint: 'Masukkan nomor WhatsApp atau email',
                              icon: Icons.person_outline,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // --- Kata sandi + Lupa? ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Kata Sandi',
                                style: AppColors.body(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              GestureDetector(
                                onTap: _handleForgot,
                                child: Text(
                                  'Lupa?',
                                  style: AppColors.body(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: AppColors.body(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                            decoration: _inputDecoration(
                              hint: 'Masukkan kata sandi',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textSoft,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),

                          // --- Tombol Masuk ---
                          Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Masuk',
                                          style: AppColors.body(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward, size: 18),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ===== Bawah: Belum punya akun? =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum punya akun? ',
                          style: AppColors.body(
                            fontSize: 13.5,
                            color: AppColors.textSoft,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'Buat akun',
                            style: AppColors.body(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      prefixIcon: Icon(icon, color: AppColors.textSoft, size: 21),
      suffixIcon: suffix,
      hintText: hint,
      hintStyle: AppColors.body(
        fontSize: 14,
        color: AppColors.textSoft.withValues(alpha: 0.6),
      ),
      filled: true,
      fillColor: AppColors.primary.withValues(alpha: 0.06),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      enabledBorder: border(AppColors.primary.withValues(alpha: 0.3)),
      focusedBorder: border(AppColors.primary, 1.5),
      border: border(AppColors.primary.withValues(alpha: 0.3)),
    );
  }
}