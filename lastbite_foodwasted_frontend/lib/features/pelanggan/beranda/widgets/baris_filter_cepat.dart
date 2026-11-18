import 'package:flutter/material.dart';
import '../../../../core/komponen/animasi_lb.dart';
import '../../../../core/tema/tema_lb.dart';

/// Baris tombol saringan cepat di Beranda Pelanggan:
/// - Terdekat (< 2 km)
/// - Rating 4.8+
/// - Diskon > 50%
class BarisFilterCepat extends StatelessWidget {
  final bool filterTerdekat;
  final bool filterRating;
  final bool filterDiskon;
  final VoidCallback onToggleTerdekat;
  final VoidCallback onToggleRating;
  final VoidCallback onToggleDiskon;

  const BarisFilterCepat({
    super.key,
    required this.filterTerdekat,
    required this.filterRating,
    required this.filterDiskon,
    required this.onToggleTerdekat,
    required this.onToggleRating,
    required this.onToggleDiskon,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildPill(
            label: 'Terdekat (< 2 km)',
            icon: Icons.near_me_rounded,
            iconColor: const Color(0xFF2E7D32),
            isActive: filterTerdekat,
            onTap: onToggleTerdekat,
          ),
          const SizedBox(width: 8),
          _buildPill(
            label: 'Rating 4.8+',
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFFFB300),
            isActive: filterRating,
            onTap: onToggleRating,
          ),
          const SizedBox(width: 8),
          _buildPill(
            label: 'Diskon > 50%',
            icon: Icons.local_offer_rounded,
            iconColor: const Color(0xFFE53935),
            isActive: filterDiskon,
            onTap: onToggleDiskon,
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required String label,
    required IconData icon,
    required Color iconColor,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return LbTekan(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? LbColors.sageLight : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isActive ? LbColors.sage : const Color(0xFFE8E5DC),
            width: isActive ? 1.4 : 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? LbColors.sage.withValues(alpha: 0.22)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? LbColors.forest : iconColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: LbText.body(
                12.5,
                weight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: isActive ? LbColors.forest : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

