import 'package:flutter/material.dart';

/// Logo LastBite (ikon apel-bumi). Dipakai di header & kartu sambutan.
/// File gambar: assets/images/logo_mark.png (transparan).
class LbLogoMark extends StatelessWidget {
  const LbLogoMark({
    super.key,
    this.size = 44,
    this.padding,
    this.circle = false,
    this.shadow = true,
  });

  final double size;
  final EdgeInsetsGeometry? padding;
  final bool circle;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: padding ?? EdgeInsets.all(size * 0.14),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(size * 0.3),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Image.asset(
        'assets/images/logo_mark.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.eco_rounded, color: const Color(0xFF6E8B3D), size: size * 0.6),
      ),
    );
  }
}