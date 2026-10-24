// ============================================================
// LastBite - lib/features/splash_screen.dart
// Splash: latar putih, lingkaran besar di pojok, logo di tengah.
// Otomatis lanjut ke WelcomeScreen.
// ============================================================

import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';

import 'auth/widgets/auth_ui.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(() async {
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      Navigator.pushReplacement(context, authRoute(const WelcomeScreen()));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Animation<double> _iv(double a, double b, Curve curve) =>
      _c.drive(CurveTween(curve: Interval(a, b, curve: curve)));

  Widget _lingkaran(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Lingkaran pojok kanan atas
          Positioned(
            top: -90,
            right: -90,
            child: ScaleTransition(
              scale: _iv(0, 0.55, Curves.easeOutBack),
              child: _lingkaran(260, AppColors.orange),
            ),
          ),
          // Lingkaran pojok kiri bawah
          Positioned(
            bottom: -100,
            left: -100,
            child: ScaleTransition(
              scale: _iv(0.1, 0.65, Curves.easeOutBack),
              child: _lingkaran(280, AppColors.primary),
            ),
          ),
          // Logo
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _iv(0.25, 0.8, Curves.elasticOut),
                  child: FadeTransition(
                    opacity: _iv(0.25, 0.5, Curves.easeOut),
                    child: const LastBiteLogo(width: 240),
                  ),
                ),
                const SizedBox(height: 14),
                AuthReveal(
                  animation: _c,
                  begin: 0.6,
                  end: 0.95,
                  child: Text(
                    'SELAMATKAN MAKANAN, JAGA MASA DEPAN',
                    textAlign: TextAlign.center,
                    style: AppColors.heading(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.2,
                      color: AppColors.textSoft,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}