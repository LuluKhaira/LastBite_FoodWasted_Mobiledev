import 'package:flutter/material.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/tema/tema_lb.dart';

/// Gambar network dengan resolusi otomatis URL API, placeholder, fade-in halus & fallback.
class LbNetImage extends StatelessWidget {
  final String url;
  final IconData fallbackIcon;
  final BoxFit fit;

  const LbNetImage({
    super.key,
    required this.url,
    this.fallbackIcon = Icons.image_outlined,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = ApiConfig.resolveImageUrl(url);

    Widget fallbackBox() => Container(
          color: LbColors.sageLight,
          alignment: Alignment.center,
          child: Icon(fallbackIcon, color: LbColors.sageDeep, size: 30),
        );

    if (resolvedUrl.isEmpty) {
      return fallbackBox();
    }

    if (resolvedUrl.startsWith('assets/')) {
      return Image.asset(
        resolvedUrl,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => fallbackBox(),
      );
    }

    return Image.network(
      resolvedUrl,
      fit: fit,
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
        debugPrint('[LbNetImage] Gagal memuat gambar: $resolvedUrl | Error: $error');
        return fallbackBox();
      },
    );
  }
}
