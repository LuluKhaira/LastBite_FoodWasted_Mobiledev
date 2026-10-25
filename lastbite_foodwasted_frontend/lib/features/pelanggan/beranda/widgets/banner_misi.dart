import 'package:flutter/material.dart';
import '../../../../core/komponen/animasi_lb.dart';
import '../../../../core/tema/tema_lb.dart';
import 'gambar_jaringan.dart';

/// Banner "Misi Zero Waste". Lingkaran dekorasi bernapas pelan,
/// foto makanan melayang.
class LbBanner extends StatefulWidget {
  const LbBanner({super.key});

  @override
  State<LbBanner> createState() => _LbBannerState();
}

class _LbBannerState extends State<LbBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  )..repeat(reverse: true);
  late final Animation<double> _a =
      CurvedAnimation(parent: _c, curve: Curves.easeInOut);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      constraints: const BoxConstraints(minHeight: 148),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3F9E6), Color(0xFFD5EAAB)],
        ),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: LbColors.sageDeep.withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Lingkaran dekorasi yang bernapas
          AnimatedBuilder(
            animation: _a,
            builder: (context, _) {
              final v = _a.value;
              return Stack(
                children: [
                  Positioned(
                    right: -34 + 10 * v,
                    top: -46 + 6 * v,
                    child: Transform.scale(
                      scale: 1 + 0.06 * v,
                      child: _circle(
                          160, LbColors.sage.withValues(alpha: 0.38)),
                    ),
                  ),
                  Positioned(
                    right: -20 - 8 * v,
                    bottom: -40 + 8 * v,
                    child: Transform.scale(
                      scale: 1 + 0.08 * (1 - v),
                      child: _circle(
                          104, LbColors.peach.withValues(alpha: 0.6)),
                    ),
                  ),
                  Positioned(
                    left: -26 + 8 * v,
                    bottom: -34,
                    child: _circle(86, LbColors.sage.withValues(alpha: 0.3)),
                  ),
                ],
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: LbColors.sageDeep,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.eco_rounded,
                                size: 13, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              'MISI ZERO WASTE',
                              style: LbText.heading(
                                9.5,
                                weight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Selamatkan Makanan\nHari Ini!',
                        style: LbText.heading(18,
                            weight: FontWeight.w700, height: 1.2),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '1 paket yang diselamatkan setara dengan menangkal 1.2 kg emisi jejak karbon CO2.',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: LbText.body(
                          11.5,
                          color: LbColors.forest.withValues(alpha: 0.85),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                LbMelayang(
                  jarak: 5,
                  putar: 0.025,
                  sudutAwal: 0.05,
                  child: Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.14),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: const LbNetImage(
                        url:
                            'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500&q=80',
                        fallbackIcon: Icons.eco_rounded,
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
