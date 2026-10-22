import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/dashboard/mitra_dashboard_screen.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/produk/mitra_produk_screen.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/dashboard/widgets/mitra_bottom_nav.dart';
import 'package:lastbite_foodwasted_mobiledev/core/widgets/shimmer_loading/app_shimmer_loading.dart';

class MitraProfilScreen extends StatefulWidget {
  final String phoneNumber;

  const MitraProfilScreen({super.key, required this.phoneNumber});

  @override
  State<MitraProfilScreen> createState() => _MitraProfilScreenState();
}

class _MitraProfilScreenState extends State<MitraProfilScreen> {
  bool _isLoading = true;
  bool _isTokoBuka = true;

  // Data profil mockup / API
  String _namaToko = 'Holland Bakery – Batam Center';
  String _kategori = 'Roti & Kue';
  String _alamat = 'Jl. Engku Putri No. 8, Batam Center';
  String _rating = '4.9';
  String _ulasan = '180+ Ulasan Positif';
  int _paketTerselamatkan = 142;
  String _pendapatan = '2.84 jt';

  @override
  void initState() {
    super.initState();
    _muatProfil();
  }

  Future<void> _muatProfil() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getMitraDashboard(widget.phoneNumber);
    if (!mounted) return;

    if (data != null) {
      final toko = Map<String, dynamic>.from(data['toko'] ?? {});
      setState(() {
        if (toko['nama'] != null && toko['nama'].toString().isNotEmpty) {
          _namaToko = toko['nama'].toString();
        }
        _isTokoBuka = toko['buka'] == true;
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _ubahStatusToko(bool buka) async {
    setState(() => _isTokoBuka = buka);
    final ok = await ApiService.setTokoStatus(widget.phoneNumber, buka);
    if (!mounted || ok) return;

    setState(() => _isTokoBuka = !buka);
    _info('Gagal mengubah status toko.');
  }

  void _info(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: MitraBottomNav(
        currentIndex: 4, // Tab Profil
        onDashboard: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MitraDashboardScreen(phoneNumber: widget.phoneNumber),
          ),
        ),
        onProduk: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MitraProdukScreen(phoneNumber: widget.phoneNumber),
          ),
        ),
        onScan: () => _info('Pindai QR pengambilan pesanan'),
        onPesanan: () => _info('Halaman Pesanan belum dibuat'),
        onProfil: () {},
        pesananBadge: 3,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _muatProfil,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                if (_isLoading)
                  const ListShimmerLoading(count: 3)
                else ...[
                  _buildCardToko(),
                  const SizedBox(height: 16),
                  _buildStatistikKemitraan(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('KELOLA OPERASIONAL'),
                  const SizedBox(height: 10),
                  _buildCardOperasional(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('KEAMANAN & PERANGKAT'),
                  const SizedBox(height: 10),
                  _buildCardKeamanan(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('BANTUAN & LEGALITAS'),
                  const SizedBox(height: 10),
                  _buildCardBantuan(),
                  const SizedBox(height: 24),
                  _buildTombolKeluar(),
                  const SizedBox(height: 20),
                  _buildFooterVersion(),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Header Atas
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.storefront, color: AppColors.textDark, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MITRA LASTBITE',
                style: GoogleFonts.nunito(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: AppColors.textSoft,
                ),
              ),
              Text(
                'Profil Toko',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none, color: AppColors.textDark, size: 24),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings_outlined, color: AppColors.textDark, size: 24),
        ),
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: AppColors.textDark,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  // Kartu Utama Identitas Toko
  Widget _buildCardToko() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.bakery_dining, color: AppColors.textDark, size: 36),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified, color: AppColors.textDark, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildBadge(Icons.check_circle, 'Terverifikasi',
                            AppColors.primary.withValues(alpha: 0.4), AppColors.textDark),
                        const SizedBox(width: 6),
                        _buildBadge(null, _kategori, AppColors.bg, AppColors.textDark),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _namaToko,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSoft),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _alamat,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: AppColors.textSoft,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _info('Edit Profil Toko'),
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _isTokoBuka ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isTokoBuka ? 'Toko Buka' : 'Toko Tutup',
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        _isTokoBuka
                            ? 'Siap menerima pesanan surplus'
                            : 'Menerima pesanan dinonaktifkan',
                        style: GoogleFonts.nunito(
                          fontSize: 11.5,
                          color: AppColors.textSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isTokoBuka,
                  onChanged: _ubahStatusToko,
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.textDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Section Statistik Kemitraan
  Widget _buildStatistikKemitraan() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart, color: AppColors.textDark, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Statistik Kemitraan',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Bulan Ini',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('⭐ $_rating', _ulasan, AppColors.primary.withValues(alpha: 0.15)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('🍃 $_paketTerselamatkan', 'Paket Terselamatkan', AppColors.primary.withValues(alpha: 0.15)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('💵 $_pendapatan', 'Pendapatan', AppColors.primary.withValues(alpha: 0.15)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Kartu Menu Kelola Operasional
  Widget _buildCardOperasional() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.access_time,
            title: 'Jam Operasional & Ambil',
            subtitle: 'Setiap Hari • Ambil: 19.00 - 21.00 WIB',
            onTap: () => _info('Pengaturan Jam Operasional'),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.account_balance,
            title: 'Rekening & Pencairan',
            subtitle: 'BCA •••• 8821 • Otomatis Tiap Senin',
            badgeText: 'BCA',
            onTap: () => _info('Pengaturan Rekening'),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.chat_bubble_outline,
            title: 'Ulasan & Kepuasan',
            subtitle: '4.9 / 5.0 dari 180 ulasan pembeli',
            onTap: () => _info('Lihat Ulasan'),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.shopping_bag_outlined,
            title: 'Wadah & Kantong Ramah',
            subtitle: 'Pembeli Bawa Kantong Sendiri (Aktif)',
            onTap: () => _info('Pengaturan Wadah'),
          ),
        ],
      ),
    );
  }

  // Kartu Menu Keamanan
  Widget _buildCardKeamanan() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.badge_outlined,
            title: 'Kelola Akses Kasir',
            subtitle: '2 Staf Kasir terdaftar',
            onTap: () => _info('Akses Kasir'),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.volume_up_outlined,
            title: 'Bel & Suara Pesanan',
            subtitle: 'Aktif (Volume Maksimal & Berulang)',
            onTap: () => _info('Pengaturan Suara'),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.history,
            title: 'PIN & Kata Sandi Toko',
            subtitle: 'Terakhir diperbarui 2 bulan lalu',
            onTap: () => _info('Ubah PIN'),
          ),
        ],
      ),
    );
  }

  // Kartu Menu Bantuan & Legalitas
  Widget _buildCardBantuan() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.headset_mic_outlined,
            title: 'Pusat Bantuan Mitra',
            subtitle: 'WhatsApp Support Lastbite (Respon Cepat)',
            onTap: () => _info('Hubungi CS'),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.verified_user_outlined,
            title: 'Legalitas & Dokumen',
            subtitle: 'NIB Terverifikasi & Halal ID21004812',
            onTap: () => _info('Dokumen Toko'),
          ),
        ],
      ),
    );
  }

  // Tombol Keluar Akun
  Widget _buildTombolKeluar() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () => _info('Berhasil keluar dari akun toko'),
        icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
        label: Text(
          'Keluar dari Akun Toko',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.redAccent,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // Footer Versi Aplikasi
  Widget _buildFooterVersion() {
    return Column(
      children: [
        Text(
          'Lastbite Partner v1.4.2',
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSoft,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.eco, size: 14, color: AppColors.textDark),
            const SizedBox(width: 4),
            Text(
              'Mendukung Gerakan Zero Food Waste Indonesia',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper Widget Komponen Kecil
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.nunito(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: AppColors.textSoft,
      ),
    );
  }

  Widget _buildStatCard(String angka, String sub, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            angka,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: GoogleFonts.nunito(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSoft,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.textDark, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: GoogleFonts.nunito(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 11.5,
                      color: AppColors.textSoft,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSoft, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData? icon, String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 52,
      endIndent: 14,
      color: AppColors.bg,
    );
  }
}