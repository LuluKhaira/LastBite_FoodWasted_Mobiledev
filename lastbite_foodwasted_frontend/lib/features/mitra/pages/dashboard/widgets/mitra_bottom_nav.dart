import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';

class MitraBottomNav extends StatelessWidget {
  final int currentIndex;
  final VoidCallback? onDashboard;
  final VoidCallback? onProduk;
  final VoidCallback? onScan;
  final VoidCallback? onPesanan;
  final VoidCallback? onProfil;
  final int pesananBadge;

  const MitraBottomNav({
    super.key,
    required this.currentIndex,
    this.onDashboard,
    this.onProduk,
    this.onScan,
    this.onPesanan,
    this.onProfil,
    this.pesananBadge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: [
              _item(0, Icons.grid_view_rounded, 'Dashboard', onDashboard),
              _item(1, Icons.inventory_2_outlined, 'Produk', onProduk),
              Expanded(
                child: Transform.translate(
                  offset: const Offset(0, -14),
                  child: Center(
                    child: GestureDetector(
                      onTap: onScan,
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppColors.textDark,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.textDark.withValues(alpha: 0.3),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.qr_code_scanner,
                            color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                ),
              ),
              _item(3, Icons.receipt_long_outlined, 'Pesanan', onPesanan,
                  badge: pesananBadge),
              _item(4, Icons.storefront_outlined, 'Profil', onProfil),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(
    int index,
    IconData icon,
    String label,
    VoidCallback? onTap, {
    int badge = 0,
  }) {
    final aktif = currentIndex == index;
    final warna = aktif ? AppColors.textDark : AppColors.textSoft;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: warna, size: 26),
                if (badge > 0)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$badge',
                        style: AppColors.body(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppColors.body(
                fontSize: 11.5,
                fontWeight: aktif ? FontWeight.w800 : FontWeight.w600,
                color: warna,
              ),
            ),
          ],
        ),
      ),
    );
  }
}