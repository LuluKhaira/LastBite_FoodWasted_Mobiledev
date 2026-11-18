import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/komponen/animasi_lb.dart';
import '../../../../core/tema/tema_lb.dart';

/// Banner Promo Slider di Beranda Pelanggan:
/// - Kartu 1: "Selamatkan Makanan Lezat Diskon s/d 70%" + "Jelajahi Sekarang"
/// - Kartu 2: "Paket Kejutan Hemat 60%" + "Ambil Paket"
/// - Indikator 3 titik di pojok kanan atas
class CarouselPromoBeranda extends StatefulWidget {
  final VoidCallback? onJelajahi;

  const CarouselPromoBeranda({
    super.key,
    this.onJelajahi,
  });

  @override
  State<CarouselPromoBeranda> createState() => _CarouselPromoBerandaState();
}

class _CarouselPromoBerandaState extends State<CarouselPromoBeranda> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  static const int _totalCards = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  void _startTimer() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      final nextPage = (_currentPage + 1) % _totalCards;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 175,
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (i) {
                setState(() => _currentPage = i);
                _startTimer();
              },
              physics: const BouncingScrollPhysics(),
              children: [
                _buildCardOne(),
                _buildCardTwo(),
                _buildCardThree(),
              ],
            ),

            // Indikator 3 titik di kanan atas
            Positioned(
              top: 14,
              right: 18,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_totalCards, (i) {
                  final active = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: active ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Kartu 1: Diskon s/d 70% + Roti Sisa / Artisan
  Widget _buildCardOne() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF43A047),
            Color(0xFF2E7D32),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -15,
            top: 12,
            bottom: 12,
            child: Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.45),
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/roti_sisa.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.white.withValues(alpha: 0.2),
                      child: const Icon(Icons.bakery_dining_rounded,
                          color: Colors.white, size: 50),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 130, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '100% Higienis & Layak Santap',
                        style: LbText.body(
                          10.5,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Selamatkan Makanan\nLezat Diskon s/d 70%',
                  style: LbText.heading(
                    15.5,
                    weight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                LbTekan(
                  onTap: widget.onJelajahi,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 7.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Jelajahi Sekarang',
                      style: LbText.heading(
                        12,
                        weight: FontWeight.w700,
                        color: const Color(0xFF2E7D32),
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

  /// Kartu 2: Paket Kejutan Hemat 60%
  Widget _buildCardTwo() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF388E3C),
            Color(0xFF1B5E20),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -15,
            top: 12,
            bottom: 12,
            child: Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.45),
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/sayuran.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.white.withValues(alpha: 0.2),
                      child: const Icon(Icons.restaurant_rounded,
                          color: Colors.white, size: 50),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 130, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paket Kejutan\nHemat 60%',
                      style: LbText.heading(
                        16.5,
                        weight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stok terbatas tiap sore...',
                      style: LbText.body(
                        11.5,
                        color: Colors.white.withValues(alpha: 0.88),
                        weight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                LbTekan(
                  onTap: widget.onJelajahi,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 7.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Ambil Paket',
                      style: LbText.heading(
                        12,
                        weight: FontWeight.w700,
                        color: const Color(0xFF1B5E20),
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

  /// Kartu 3: Kurangi Food Waste
  Widget _buildCardThree() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E7D32),
            Color(0xFF004D40),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004D40).withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -15,
            top: 12,
            bottom: 12,
            child: Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.45),
                    width: 3.5,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/holland_bakery.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.white.withValues(alpha: 0.2),
                      child: const Icon(Icons.storefront_rounded,
                          color: Colors.white, size: 50),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 130, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bantu Kurangi\nFood Waste Hari Ini',
                      style: LbText.heading(
                        15.5,
                        weight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Makan enak sambil berhemat',
                      style: LbText.body(
                        11.5,
                        color: Colors.white.withValues(alpha: 0.88),
                        weight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                LbTekan(
                  onTap: widget.onJelajahi,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 7.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Lihat Toko',
                      style: LbText.heading(
                        12,
                        weight: FontWeight.w700,
                        color: const Color(0xFF004D40),
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
