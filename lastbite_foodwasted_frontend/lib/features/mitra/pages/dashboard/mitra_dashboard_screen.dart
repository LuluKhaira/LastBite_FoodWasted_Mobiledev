import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/produk/tambah_produk_screen.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/produk/mitra_produk_screen.dart';
import 'package:lastbite_foodwasted_mobiledev/core/widgets/shimmer_loading/app_shimmer_loading.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/profil/mitra_profil_screen.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/pesanan/mitra_pesanan_screen.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/pesanan/widgets/scan_pesanan_bottomsheet.dart';

import 'widgets/mitra_bottom_nav.dart';
import 'widgets/surplus_section.dart';

class MitraDashboardScreen extends StatefulWidget {
  final String phoneNumber;

  const MitraDashboardScreen({super.key, required this.phoneNumber});

  @override
  State<MitraDashboardScreen> createState() => _MitraDashboardScreenState();
}

class _MitraDashboardScreenState extends State<MitraDashboardScreen> {
  bool _showWarningBanner = false;
  bool _isLoading = true;
  String _namaToko = 'Mitra Dashboard';
  int _pesananAktif = 0;
  int _pesananHariIni = 0;
  List<Map<String, dynamic>> _surplus = [];

  @override
  void initState() {
    super.initState();
    _muatDashboard();
  }

  // --- FUNGSI DATABASE ---
  Future<void> _muatDashboard() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getMitraDashboard(widget.phoneNumber);
    if (!mounted) return;

    if (data == null) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memuat data dashboard.');
      return;
    }

    final toko = Map<String, dynamic>.from(data['toko'] ?? {});
    setState(() {
      _isLoading = false;
      _namaToko = (toko['nama'] ?? 'Mitra Dashboard').toString();
      _showWarningBanner = data['jam_operasional_lengkap'] != true;
      _pesananAktif = int.tryParse('${data['pesanan_aktif']}') ?? 0;
      _pesananHariIni =
          int.tryParse('${data['ringkasan']?['pesanan_hari_ini']}') ?? 0;
      _surplus = ((data['surplus'] ?? []) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    });
  }

  Future<void> _bukaTambahProduk() async {
    final berhasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahProdukScreen(phoneNumber: widget.phoneNumber),
      ),
    );
    if (berhasil == true) await _muatDashboard();
  }

  void _showSnackBar(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  // --- NAVIGASI ---
  void _navigateTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _showScanBottomsheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ScanPesananBottomSheet(phoneNumber: widget.phoneNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: RefreshIndicator(
        onRefresh: _muatDashboard,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: ListShimmerLoading(count: 3),
                )
              else
                _buildKonten(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MitraBottomNav(
        currentIndex: 0,
        onDashboard: () {},
        onProduk: () => _navigateTo(MitraProdukScreen(
          phoneNumber: widget.phoneNumber,
          namaToko: _namaToko,
        )),
        onScan: _showScanBottomsheet,
        onPesanan: () => _navigateTo(MitraPesananScreen(
          phoneNumber: widget.phoneNumber,
          namaToko: _namaToko,
        )),
        onProfil: () => _navigateTo(MitraProfilScreen(
          phoneNumber: widget.phoneNumber,
        )),
        pesananBadge: _pesananAktif,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _bukaTambahProduk,
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  // --- HEADER (blok hijau segar / primary, layout tetap) ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lokasi Toko',
            style: AppColors.body(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.location_on,
                  color: AppColors.textDark, size: 18),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  _namaToko,
                  overflow: TextOverflow.ellipsis,
                  style: AppColors.heading(
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.textDark, size: 20),
            ],
          ),
          const SizedBox(height: 18),

          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              onTap: () => _navigateTo(MitraProdukScreen(
                phoneNumber: widget.phoneNumber,
                namaToko: _namaToko,
              )),
              readOnly: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                icon: const Icon(Icons.search, color: AppColors.textSoft),
                hintText: 'Cari produk surplusmu...',
                hintStyle: AppColors.body(
                  color: AppColors.textSoft,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // KARTU PESANAN HARI INI
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pesanan Hari Ini',
                      style: AppColors.body(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSoft,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$_pesananHariIni',
                          style: AppColors.heading(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pesanan',
                          style: AppColors.heading(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.hijauMuda,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: _pesananHariIni > 0
                                  ? AppColors.orange
                                  : AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _pesananHariIni > 0
                                ? 'Ada pesanan masuk'
                                : 'Belum ada pesanan masuk',
                            style: AppColors.body(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppColors.textDark,
                      size: 28,
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

  // --- KONTEN UTAMA ---
  Widget _buildKonten() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_showWarningBanner) ...[
            _buildWarningBanner(),
            const SizedBox(height: 16),
          ],

          // Grid Menu Cepat
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Menu Cepat',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                'Lihat semua',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _menuKategori(
                icon: Icons.qr_code_scanner,
                title: 'Scan QR',
                onTap: _showScanBottomsheet,
              ),
              _menuKategori(
                icon: Icons.history,
                title: 'Riwayat',
                onTap: () => _showSnackBar('Fitur segera hadir'),
              ),
              _menuKategori(
                icon: Icons.headset_mic,
                title: 'Bantuan',
                onTap: () => _showSnackBar('Fitur segera hadir'),
              ),
              _menuKategori(
                icon: Icons.inventory_2,
                title: 'Stok',
                onTap: () => _navigateTo(MitraProdukScreen(
                  phoneNumber: widget.phoneNumber,
                  namaToko: _namaToko,
                )),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Surplus Section (List Vertikal)
          SurplusSection(
            items: _surplus,
            onProductTap: (_) async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MitraProdukScreen(
                    phoneNumber: widget.phoneNumber,
                    namaToko: _namaToko,
                  ),
                ),
              );
              _muatDashboard();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _menuKategori({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.hijauMuda,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.textDark, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 16, color: AppColors.textSoft),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.access_time_filled,
                  color: AppColors.textDark,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lengkapi Jam Operasional Dulu, Yuk',
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kami butuh jam bukamu supaya batas pengambilan pesanan tidak kelewat jam tutup toko.',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: AppColors.textSoft,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _showWarningBanner = false),
                child: const Icon(
                  Icons.close,
                  color: AppColors.textSoft,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: Text(
                'Isi Sekarang',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: AppColors.textDark,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}