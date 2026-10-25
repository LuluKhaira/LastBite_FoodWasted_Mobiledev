import 'package:flutter/material.dart';
import '../../../../core/tema/tema_lb.dart';

/// Gambar network dengan placeholder, fade-in halus & fallback.
class LbNetImage extends StatelessWidget {
  final String url;
  final IconData fallbackIcon;

  const LbNetImage({
    super.key,
    required this.url,
    this.fallbackIcon = Icons.image_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      frameBuilder: (context, child, frame, sync) {
        if (sync) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOut,
          child: child,
        );
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(color: LbColors.sageLight);
      },
      errorBuilder: (context, error, stack) {
        return Container(
          color: LbColors.sageLight,
          alignment: Alignment.center,
          child: Icon(fallbackIcon, color: LbColors.sageDeep, size: 30),
        );
      },
    );
  }
}
