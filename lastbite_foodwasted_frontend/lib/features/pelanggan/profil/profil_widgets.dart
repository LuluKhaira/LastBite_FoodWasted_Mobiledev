import 'package:flutter/material.dart';
import '../beranda/beranda_widgets.dart';

/// Komponen bersama yang dipakai oleh halaman Alamat, Bantuan, dan Ulasan.
BoxDecoration pkKartuDeco({Color? color}) => BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: LbColors.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.035),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    );

void pkSnack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(msg, style: LbText.body(13, color: Colors.white)),
        backgroundColor: LbColors.forest,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
}

/// Mengubah pesan Exception dari API menjadi pesan yang lebih ramah.
String pkPesanError(Object e) {
  final m = e.toString().replaceFirst('Exception: ', '');
  return m.contains('Unauthenticated')
      ? 'Masuk dulu ya untuk memakai fitur ini.'
      : m;
}

class PkHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final bool logo;

  const PkHeader({
    super.key,
    required this.title,
    this.trailing,
    this.logo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded,
                color: LbColors.forest, size: 26),
          ),
          if (logo) ...[
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [LbColors.sage, LbColors.sageDeep],
                ),
              ),
              child: const Icon(Icons.eco_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LbText.heading(18.5, weight: FontWeight.w700),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class PkError extends StatelessWidget {
  final String pesan;
  final VoidCallback onRetry;

  const PkError({
    super.key,
    required this.pesan,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 44, color: LbColors.sageDeep),
            const SizedBox(height: 12),
            Text(pesan,
                textAlign: TextAlign.center, style: LbText.body(13)),
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded,
                  color: LbColors.forest),
              label: Text('Coba lagi',
                  style: LbText.heading(13, weight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Menampilkan pemilih rating 1—5 dan mengembalikan nilai yang dipilih.
Future<int?> pkBeriBintang(
  BuildContext context, {
  required String judulToko,
}) {
  int stars = 5;
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
        decoration: const BoxDecoration(
          color: LbColors.offWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: LbColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 20),
              Text('Beri Nilai Pesananmu',
                  style: LbText.heading(18, weight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(judulToko,
                  textAlign: TextAlign.center, style: LbText.body(13)),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final on = i < stars;
                  return GestureDetector(
                    onTap: () => setS(() => stars = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        on ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 42,
                        color: on ? LbColors.peach : const Color(0xFFD5D1C7),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: () => Navigator.pop(ctx, stars),
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      colors: [LbColors.sage, LbColors.sageDeep],
                    ),
                  ),
                  child: Text('Kirim Penilaian',
                      style: LbText.heading(15,
                          weight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
