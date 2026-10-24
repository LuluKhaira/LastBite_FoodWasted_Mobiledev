import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';

/// Komponen UI bersama untuk Splash, Welcome, Masuk, dan Daftar.
class AuthUI {
  static const Color textSoft = Color(0xFF6B6B6B);

  /// Pembesaran logo. File lastbite_logo.png punya banyak area transparan,
  /// jadi gambarnya di-zoom agar logo terlihat besar.
  /// Kalau PNG sudah dipotong rapat (crop), ubah jadi 1.0.
  static const double logoZoom = 3.2;

  /// Oranye lebih gelap (turunan AppColors.orange) agar teks link terbaca di atas putih.
  static Color get orangeText =>
      HSLColor.fromColor(AppColors.orange).withLightness(0.36).toColor();
}

/// Transisi halaman: fade halus (elemen di dalamnya punya animasi sendiri).
Route<T> authRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 650),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) => FadeTransition(
      opacity: anim.drive(CurveTween(curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}

void authSnack(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(msg, style: AppColors.body(color: Colors.white)),
        backgroundColor: error ? AppColors.merah : AppColors.textDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
}

String? authValidasiId(String? v) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return 'Wajib diisi';
  if (t.contains('@')) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)
        ? null
        : 'Format email tidak valid';
  }
  final digit = t.replaceAll(RegExp(r'[^0-9]'), '');
  return digit.length >= 9 ? null : 'Masukkan email atau nomor HP yang valid';
}

/// Logo LastBite (polos, tanpa wadah). Hero membuatnya berpindah mulus antar halaman.
/// [width] menentukan ukuran kanvas gambar, [zoom] memperbesar tampilan logo
/// tanpa mengubah tata letak di sekitarnya.
class LastBiteLogo extends StatelessWidget {
  final double width;
  final double zoom;
  final bool hero;

  const LastBiteLogo({
    super.key,
    required this.width,
    this.zoom = AuthUI.logoZoom,
    this.hero = true,
  });

  @override
  Widget build(BuildContext context) {
    final gambar = Transform.scale(
      scale: zoom,
      child: Image.asset(
        'assets/images/lastbite_logo.png',
        width: width,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => Icon(
          Icons.eco_rounded,
          size: width * 0.5,
          color: AppColors.primary,
        ),
      ),
    );
    return hero ? Hero(tag: 'lastbite_logo', child: gambar) : gambar;
  }
}

/// Muncul bertahap (fade + geser naik) pada rentang [begin, end] dari sebuah animasi.
class AuthReveal extends StatelessWidget {
  final Animation<double> animation;
  final double begin;
  final double end;
  final Offset offset;
  final Widget child;

  const AuthReveal({
    super.key,
    required this.animation,
    required this.begin,
    required this.end,
    required this.child,
    this.offset = const Offset(0, 0.25),
  });

  @override
  Widget build(BuildContext context) {
    final curved = animation.drive(
      CurveTween(curve: Interval(begin, end, curve: Curves.easeOutCubic)),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: curved.drive(Tween<Offset>(begin: offset, end: Offset.zero)),
        child: child,
      ),
    );
  }
}

/// Kerangka Masuk/Daftar: header berwarna (judul + deskripsi) dan kartu putih berisi form.
class AuthShell extends StatefulWidget {
  final String title;
  final String subtitle;
  final GlobalKey<FormState>? formKey;
  final List<Widget> children;

  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.formKey,
  });

  @override
  State<AuthShell> createState() => _AuthShellState();
}

class _AuthShellState extends State<AuthShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _bola(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  List<Widget> _isi() {
    return List.generate(widget.children.length, (i) {
      final b = (0.3 + i * 0.05).clamp(0.0, 0.7).toDouble();
      final e = (b + 0.3).clamp(0.0, 1.0).toDouble();
      return AuthReveal(
        animation: _c,
        begin: b,
        end: e,
        child: widget.children[i],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final kartu = _c.drive(
      CurveTween(curve: const Interval(0.15, 0.75, curve: Curves.easeOutCubic)),
    );
    final bawah = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -50,
            child: _bola(190, Colors.white.withValues(alpha: 0.15)),
          ),
          Positioned(
            top: 120,
            right: 40,
            child: _bola(16, AppColors.orange.withValues(alpha: 0.6)),
          ),
          Positioned(
            top: 60,
            left: -40,
            child: _bola(100, AppColors.orange.withValues(alpha: 0.18)),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.maybePop(context),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AuthReveal(
                    animation: _c,
                    begin: 0,
                    end: 0.5,
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: AppColors.heading(fontSize: 30),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.subtitle,
                            style: AppColors.body(
                              fontSize: 13.5,
                              height: 1.45,
                              color: AppColors.textDark.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Expanded(
                  child: SlideTransition(
                    position: kartu.drive(
                      Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ),
                    ),
                    child: FadeTransition(
                      opacity: kartu,
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(36)),
                        ),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(24, 30, 24, 24 + bawah),
                          child: Form(
                            key: widget.formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _isi(),
                            ),
                          ),
                        ),
                      ),
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

class AuthField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool password;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;

  const AuthField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.password = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  bool _sembunyi = true;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );
    final garis = AppColors.textSoft.withValues(alpha: 0.4);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.password && _sembunyi,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        validator: widget.validator,
        style: AppColors.body(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppColors.body(fontSize: 13.5, color: AppColors.textSoft),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(widget.icon, size: 20, color: AuthUI.textSoft),
          suffixIcon: widget.password
              ? IconButton(
                  icon: Icon(
                    _sembunyi
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: AuthUI.textSoft,
                  ),
                  onPressed: () => setState(() => _sembunyi = !_sembunyi),
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: border(garis),
          enabledBorder: border(garis),
          focusedBorder: border(AppColors.orange, 1.8),
          errorBorder: border(AppColors.merah),
          focusedErrorBorder: border(AppColors.merah, 1.8),
          errorStyle: AppColors.body(fontSize: 11.5, color: AppColors.merah),
        ),
      ),
    );
  }
}

class AuthButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final Color color;

  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.textDark,
          disabledBackgroundColor: color.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: AppColors.textDark,
                  strokeWidth: 2.2,
                ),
              )
            : Text(
                label,
                style: AppColors.heading(fontSize: 14.5, letterSpacing: 0.4),
              ),
      ),
    );
  }
}

/// Tombol outline lebar: ikon di kiri, label, panah di kanan.
class AuthSocialButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const AuthSocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: AppColors.textSoft.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              SizedBox(width: 24, child: Center(child: icon)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppColors.body(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: AppColors.textDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthSwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const AuthSwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppColors.body(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          thumbColor: const WidgetStatePropertyAll(Colors.white),
          trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? AppColors.orange
                : AppColors.textSoft.withValues(alpha: 0.35),
          ),
          trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ],
    );
  }
}

class AuthBottomLink extends StatelessWidget {
  final String teks;
  final String aksi;
  final VoidCallback onTap;

  const AuthBottomLink({
    super.key,
    required this.teks,
    required this.aksi,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '$teks ',
            style: AppColors.body(fontSize: 13, color: AuthUI.textSoft),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              aksi,
              style: AppColors.body(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AuthUI.orangeText,
              ).copyWith(decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }
}