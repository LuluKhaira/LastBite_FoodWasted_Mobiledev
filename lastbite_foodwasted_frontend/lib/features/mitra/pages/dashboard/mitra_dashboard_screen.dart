import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'widgets/kartu_info_toko.dart';
import 'widgets/aksi_cepat.dart';
import 'widgets/ringkasan_section.dart';
import 'widgets/surplus_section.dart';

class MitraDashboardScreen extends StatefulWidget {
  const MitraDashboardScreen({super.key});

  @override
  State createState() => _MitraDashboardScreenState();
}

class _MitraDashboardScreenState extends State {
  bool _isTokoBuka = true;
  bool _showWarningBanner = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 90),
              child: Column(
                children: [
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        KartuInfoToko(
                          isTokoBuka: _isTokoBuka,
                          onStatusChanged: (val) {
                            setState(() {
                              _isTokoBuka = val;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        if (_showWarningBanner) _buildWarningBanner(),
                        const SizedBox(height: 16),
                        const AksiCepat(),
                        const SizedBox(height: 20),
                        const RingkasanSection(),
                        const SizedBox(height: 20),
                        const SurplusSection(),
                        const SizedBox(height: 16),
                        _buildTipsBanner(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Positioned(
              right: 16,
              bottom: 76,
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: AppColors.primary,
                elevation: 3,
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'LastBite',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Mitra Toko',
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Mitra Dashboard',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: AppColors.textSoft,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none, color: AppColors.textDark, size: 26),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.access_time_filled, color: AppColors.textDark, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lengkapi Jam Operasional Dulu, Yuk',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showWarningBanner = false;
                  });
                },
                child: const Icon(Icons.close, color: AppColors.textSoft, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              'Kami butuh jam bukamu supaya batas pengambilan pesanan tidak kelewat jam tutup toko.',
              style: GoogleFonts.nunito(
                fontSize: 11.5,
                color: AppColors.textSoft,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: AppColors.textDark,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Isi Sekarang',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_outline, color: AppColors.textDark, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips Jitu Mitra',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'Makanan yang diunggah sebelum jam 17.00 rata-rata laku dalam 35 menit! Coba upload surplus lebih awal untuk penjualan maksimal.',
                  style: GoogleFonts.nunito(
                    fontSize: 10.5,
                    color: AppColors.textSoft,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.textDark,
      unselectedItemColor: AppColors.textSoft,
      selectedLabelStyle: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500),
      currentIndex: 0,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded),
          label: 'Dashboard',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          label: 'Produk',
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
          ),
          label: 'Scan QR',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            label: const Text('3'),
            backgroundColor: AppColors.orange,
            child: const Icon(Icons.assignment_outlined),
          ),
          label: 'Pesanan',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.storefront_outlined),
          label: 'Profil',
        ),
      ],
    );
  }
}