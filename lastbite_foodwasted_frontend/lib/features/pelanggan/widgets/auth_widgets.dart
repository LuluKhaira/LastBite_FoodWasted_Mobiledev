// Widget bersama untuk halaman Masuk, Daftar, dan OTP pelanggan.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// Warna pendukung (turunan palet LastBite) yang tidak ada di AppColors.
class AuthUi {
  AuthUi._();
  static const Color card = Color(0xFFF1EFE9);
  static const Color border = Color(0xFFE6E3DA);
  static const Color danger = Color(0xFFD64545);
  static const Color sageSoft = Color(0xFFE9F2D3);
  static const Color peachSoft = Color(0xFFFFE8D9);
}

/// 0812... / +62812... / 812... -> 62812... (null jika bukan nomor HP Indonesia). Sama dengan backend.
String? normalizePhone(String raw) {
  var d = raw.replaceAll(RegExp(r'\D'), '');
  if (d.isEmpty) return null;
  if (d.startsWith('62')) {
    // sudah benar
  } else if (d.startsWith('0')) {
    d = '62${d.substring(1)}';
  } else if (d.startsWith('8')) {
    d = '62$d';
  } else {
    return null;
  }
  return RegExp(r'^628[1-9][0-9]{7,11}$').hasMatch(d) ? d : null;
}

/// 6281234567890 -> +62 812 3456 7890
String formatPhoneDisplay(String normalized) {
  if (!normalized.startsWith('62')) return normalized;
  final n = normalized.substring(2);
  final b = StringBuffer('+62 ');
  for (var i = 0; i < n.length; i++) {
    if (i == 3 || i == 7) b.write(' ');
    b.write(n[i]);
  }
  return b.toString();
}

String lbPesanError(Object e) => e.toString().replaceFirst('Exception: ', '');

void showLbSnack(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? AuthUi.danger : AppColors.textDark,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(message, style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
}

/// Baris atas: tombol kembali (bulat) + chip "Butuh Bantuan?"
class LbTopBar extends StatelessWidget {
  const LbTopBar({super.key, this.showBack = true});
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (showBack)
          Material(
            color: AuthUi.card,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.maybePop(context),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.arrow_back_rounded, color: AppColors.textDark, size: 22),
              ),
            ),
          )
        else
          const SizedBox(width: 44, height: 44),
        Material(
          color: AuthUi.card,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => showLbSnack(context, 'Hubungi admin LastBite lewat WhatsApp untuk bantuan.'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.headset_mic_outlined, size: 18, color: AppColors.textDark),
                  const SizedBox(width: 8),
                  Text('Butuh Bantuan?',
                      style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Kartu sambutan di atas halaman (badge + judul + deskripsi + foto/ikon)
class LbHeroCard extends StatelessWidget {
  const LbHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.badge = 'LastBite Movement',
    this.image = 'assets/images/roti_sisa.jpg',
    this.icon = Icons.bakery_dining_rounded,
  });

  final String title;
  final String subtitle;
  final String badge;
  final String? image; // null = pakai ikon saja
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: AppColors.orange.withValues(alpha: 0.35),
      child: Icon(icon, size: 36, color: Colors.white),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AuthUi.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: AppColors.textDark.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.eco_rounded, size: 14, color: AppColors.textDark),
                      const SizedBox(width: 5),
                      Text(badge,
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 24, height: 1.2, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 8),
                Text(subtitle, style: GoogleFonts.nunito(fontSize: 14, height: 1.4, color: AppColors.textSoft)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 84,
            height: 84,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: image == null
                  ? fallback
                  : Image.asset(image!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback),
            ),
          ),
        ],
      ),
    );
  }
}

/// Segmented control (Nomor WhatsApp | Email & Sandi)
class LbSegmented extends StatelessWidget {
  const LbSegmented({super.key, required this.labels, required this.icons, required this.index, required this.onChanged});

  final List<String> labels;
  final List<IconData> icons;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: AuthUi.card, borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = i == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: selected
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icons[i], size: 18, color: selected ? AppColors.textDark : AppColors.textSoft),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        labels[i],
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                          color: selected ? AppColors.textDark : AppColors.textSoft,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

InputDecoration _decoration({String? hint, Widget? prefix, Widget? suffix}) {
  OutlineInputBorder b(Color c, [double w = 1]) =>
      OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: c, width: w));
  return InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.nunito(color: AppColors.textSoft.withValues(alpha: 0.55), fontSize: 15),
    filled: true,
    fillColor: Colors.white,
    prefixIcon: prefix,
    suffixIcon: suffix,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
    border: b(AuthUi.border),
    enabledBorder: b(AuthUi.border),
    focusedBorder: b(AppColors.primary, 2),
    errorBorder: b(AuthUi.danger),
    focusedErrorBorder: b(AuthUi.danger, 2),
    errorStyle: GoogleFonts.nunito(fontSize: 12, color: AuthUi.danger, fontWeight: FontWeight.w600),
  );
}

class LbLabel extends StatelessWidget {
  const LbLabel(this.text, {super.key, this.optional = false});
  final String text;
  final bool optional;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Row(
          children: [
            Text(text, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            if (optional) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AuthUi.card, borderRadius: BorderRadius.circular(8)),
                child: Text('Opsional',
                    style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSoft)),
              ),
            ],
          ],
        ),
      );
}

/// Input teks umum (nama, email, sandi)
class LbField extends StatefulWidget {
  const LbField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<LbField> createState() => _LbFieldState();
}

class _LbFieldState extends State<LbField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _hidden,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
      decoration: _decoration(
        hint: widget.hint,
        prefix: Icon(widget.icon, color: AppColors.textSoft, size: 21),
        suffix: widget.obscure
            ? IconButton(
                onPressed: () => setState(() => _hidden = !_hidden),
                icon: Icon(_hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.textSoft, size: 21),
              )
            : null,
      ),
    );
  }
}

/// Input nomor HP dengan chip "ID +62" dan tombol hapus
class LbPhoneField extends StatelessWidget {
  const LbPhoneField({super.key, required this.controller, this.validator, this.onSubmitted});

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9 +]')), LengthLimitingTextInputFormatter(17)],
      style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w500, color: AppColors.textDark),
      decoration: _decoration(
        hint: '812 3456 7890',
        prefix: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: AuthUi.card, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(5)),
                  child: Text('ID', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                ),
                const SizedBox(width: 8),
                Text('+62', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              ],
            ),
          ),
        ),
        suffix: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, v, __) => v.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: controller.clear,
                  icon: const Icon(Icons.cancel_outlined, color: AppColors.textSoft, size: 22),
                ),
        ),
      ),
    );
  }
}

/// Tombol utama hijau tua, bulat penuh
class LbPrimaryButton extends StatelessWidget {
  const LbPrimaryButton({super.key, required this.label, required this.onPressed, this.loading = false, this.icon = Icons.arrow_forward_rounded});

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: AppColors.textDark.withValues(alpha: 0.25), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.textDark,
            disabledBackgroundColor: AppColors.textDark.withValues(alpha: onPressed == null && !loading ? 0.35 : 0.7),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          ),
          child: loading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.6, color: Colors.white))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    if (icon != null) ...[
                      const SizedBox(width: 10),
                      Icon(icon, color: Colors.white, size: 21),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

/// Tombol sekunder (Google / Magic Link)
class LbSecondaryButton extends StatelessWidget {
  const LbSecondaryButton({super.key, required this.label, required this.leading, required this.onPressed, this.filled = false});

  final String label;
  final Widget leading;
  final VoidCallback onPressed;
  final bool filled; // true = abu (magic link), false = putih (google)

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AuthUi.card : Colors.white,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onPressed,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: filled ? null : Border.all(color: AuthUi.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              leading,
              const SizedBox(width: 12),
              Flexible(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Huruf "G" Google berwarna 4 warna
class GoogleGlyph extends StatelessWidget {
  const GoogleGlyph({super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (r) => const SweepGradient(
        colors: [Color(0xFF4285F4), Color(0xFF34A853), Color(0xFFFBBC05), Color(0xFFEA4335), Color(0xFF4285F4)],
        stops: [0.0, 0.3, 0.5, 0.75, 1.0],
      ).createShader(r),
      blendMode: BlendMode.srcIn,
      child: Text('G', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
    );
  }
}

/// Pembatas "ATAU MASUK INSTAN DENGAN"
class LbDivider extends StatelessWidget {
  const LbDivider(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AuthUi.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(text,
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: AppColors.textSoft)),
        ),
        const Expanded(child: Divider(color: AuthUi.border, thickness: 1)),
      ],
    );
  }
}

/// Kotak info hijau sage ("Masuk Tanpa Kata Sandi")
class LbInfoBox extends StatelessWidget {
  const LbInfoBox({super.key, required this.title, required this.text, this.icon = Icons.verified_outlined});
  final String title;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AuthUi.sageSoft, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: AppColors.textDark, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 23),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(text, style: GoogleFonts.nunito(fontSize: 13, height: 1.35, color: AppColors.textSoft)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
