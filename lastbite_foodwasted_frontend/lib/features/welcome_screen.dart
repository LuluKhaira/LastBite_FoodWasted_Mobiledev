// ============================================================
// LastBite - lib/features/welcome_screen.dart
// Welcome: logo di atas, panel berwarna dengan tombol Masuk / Daftar di bawah.
// ============================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';

import 'auth/daftar_screen.dart';
import 'auth/masuk_screen.dart';
import 'auth/widgets/auth_ui.dart';
import 'mitra/pages/register/mitra_register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _masuk = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  late final AnimationController _ambang = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _masuk.dispose();
    _ambang.dispose();
    super.dispose();
  }

  Widget _bola(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  @override
  Widget build(BuildContext context) {
    final bawah = MediaQuery.of(context).padding.bottom;
    final panel = _masuk.drive(
      CurveTween(curve: const Interval(0, 0.6, curve: Curves.easeOutCubic)),
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          // Area logo (melayang pelan)
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Positioned(
                    top: -10,
                    left: -50,
                    child: AnimatedBuilder(
                      animation: _ambang,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(
                          0,
                          8 * math.sin(_ambang.value * math.pi),
                        ),
                        child: child,
                      ),
                      child: _bola(
                        110,
                        AppColors.primary.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 30,
                    right: 36,
                    child: AnimatedBuilder(
                      animation: _ambang,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(
                          0,
                          -8 * math.sin(_ambang.value * math.pi),
                        ),
                        child: child,
                      ),
                      child: _bola(
                        18,
                        AppColors.orange.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  Center(
                    child: AnimatedBuilder(
                      animation: _ambang,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(
                          0,
                          -8 * Curves.easeInOut.transform(_ambang.value),
                        ),
                        child: child,
                      ),
                      child: const LastBiteLogo(width: 260),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Panel berwarna di bawah
          SlideTransition(
            position: panel.drive(
              Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero),
            ),
            child: FadeTransition(
              opacity: panel,
              child: Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                padding: EdgeInsets.fromLTRB(28, 32, 28, 16 + bawah),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -60,
                      top: -70,
                      child: _bola(
                        150,
                        Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    Positioned(
                      left: -50,
                      bottom: -60,
                      child: _bola(
                        120,
                        AppColors.orange.withValues(alpha: 0.2),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AuthReveal(
                          animation: _masuk,
                          begin: 0.25,
                          end: 0.55,
                          child: Text(
                            'Selamat Datang',
                            style: AppColors.heading(fontSize: 26),
                          ),
                        ),
                        const SizedBox(height: 8),
                        AuthReveal(
                          animation: _masuk,
                          begin: 0.32,
                          end: 0.62,
                          child: Text(
                            'Setiap sisa punya kesempatan kedua. Temukan makanan hemat, pakan ternak, dan bahan pupuk dari usaha terdekat di Batam.',
                            style: AppColors.body(
                              fontSize: 13.5,
                              height: 1.45,
                              color: AppColors.textDark.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        AuthReveal(
                          animation: _masuk,
                          begin: 0.45,
                          end: 0.8,
                          child: Row(
                            children: [
                              Expanded(
                                child: AuthButton(
                                  label: 'Masuk',
                                  color: Colors.white,
                                  onPressed: () => Navigator.push(
                                    context,
                                    authRoute(const MasukScreen()),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AuthButton(
                                  label: 'Daftar',
                                  color: AppColors.orange,
                                  onPressed: () => Navigator.push(
                                    context,
                                    authRoute(const DaftarScreen()),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        AuthReveal(
                          animation: _masuk,
                          begin: 0.6,
                          end: 1,
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MitraRegisterScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Masuk sebagai Mitra Toko / Penjual →',
                                    style: AppColors.heading(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Dengan melanjutkan, kamu menyetujui Syarat & Ketentuan serta\nKebijakan Privasi Lastbite.',
                                  textAlign: TextAlign.center,
                                  style: AppColors.body(
                                    fontSize: 10.5,
                                    color: AppColors.textDark
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
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
        ],
      ),
    );
  }
}