import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/dashboard/mitra_dashboard_screen.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/produk/mitra_produk_screen.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/dashboard/widgets/mitra_bottom_nav.dart';
import 'package:lastbite_foodwasted_mobiledev/core/widgets/shimmer_loading/app_shimmer_loading.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/pesanan/mitra_pesanan_screen.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/pesanan/widgets/scan_pesanan_bottomsheet.dart';

import 'jam_buka_screen.dart';
import 'rekening_screen.dart';
import 'ulasan_screen.dart';
import 'edit_profil_toko_screen.dart';
import 'pin_sandi_screen.dart';
import 'notifikasi_pengaturan_screen.dart';
import 'riwayat_transaksi_screen.dart';
import 'paket_terselamatkan_screen.dart';

class _UI {
  static Color get primary => AppColors.primary;
  static Color get primaryText => AppColors.zaitun;
  static Color get primaryBg => AppColors.hijauMuda;
  static Color get textSoft => const Color(0xFF6B6B6B);
  static Color get border => AppColors.textSoft.withValues(alpha: 0.15);
}

class MitraProfilScreen extends StatefulWidget {
  final String phoneNumber;

  const MitraProfilScreen({super.key, required this.phoneNumber});

  @override
  State<MitraProfilScreen> createState() => _MitraProfilScreenState();
}

class _MitraProfilScreenState extends State<MitraProfilScreen> {
  bool _isLoading = true;
  bool _isTokoBuka = true;

  String _namaToko = 'Holland Bakery';
  String _alamat = 'Jl. Engku Putri No. 8, Batam Center';
  String _rating = '4.9';
  String _ulasan = '180+ Ulasan';
  int _paketTerselamatkan = 142;
  int _pesananAktif = 0;

  @override
  void initState() {
    super.initState();
    _muatProfil();
    _muatJumlahPesanan();
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

  Future<void> _muatJumlahPesanan() async {
    final data = await ApiService.getMitraDashboard(widget.phoneNumber);
    if (data != null && mounted) {
      setState(() {
        _pesananAktif = int.tryParse('${data['pesanan_aktif']}') ?? 0;
      });
    }
  }

  Future<void> _ubahStatusToko(bool buka) async {
    setState(() => _isTokoBuka = buka);
    final ok = await ApiService.setTokoStatus(widget.phoneNumber, buka);
    if (!mounted || ok) return;

    setState(() => _isTokoBuka = !buka);
    _info('Gagal mengubah status toko.');
  }

  void _buka(Widget halaman) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => halaman),
    );
  }

  Future<void> _editProfil() async {
    final hasil = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilTokoScreen(
          namaToko: _namaToko,
          alamat: _alamat,
          phoneNumber: widget.phoneNumber,
        ),
      ),
    );
    if (hasil != null && mounted) {
      setState(() {
        _namaToko = hasil['nama'] ?? _namaToko;
        _alamat = hasil['alamat'] ?? _alamat;
      });
    }
  }

  Future<void> _keluar() async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.merahMuda,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded,
                    color: AppColors.merah, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                'Keluar dari akun toko?',
                textAlign: TextAlign.center,
                style: AppColors.heading(fontSize: 17),
              ),
              const SizedBox(height: 8),
              Text(
                'Kamu perlu masuk lagi untuk mengelola pesanan dan produk tokomu.',
                textAlign: TextAlign.center,
                style: AppColors.body(
                  fontSize: 13,
                  color: _UI.textSoft,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(color: _UI.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: AppColors.heading(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.merah,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Ya, Keluar',
                        style: AppColors.heading(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (ya != true || !mounted) return;

    // TODO: hapus sesi/token login di sini, lalu arahkan ke halaman login, mis.:
    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(builder: (_) => const LoginScreen()),
    //   (route) => false,
    // );
    _info('Berhasil keluar dari akun toko');
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _info(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan, style: AppColors.body(color: Colors.white)),
        backgroundColor: AppColors.textDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: MitraBottomNav(
        currentIndex: 4,
        onDashboard: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                MitraDashboardScreen(phoneNumber: widget.phoneNumber),
          ),
        ),
        onProduk: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MitraProdukScreen(phoneNumber: widget.phoneNumber),
          ),
        ),
        onScan: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) =>
                ScanPesananBottomSheet(phoneNumber: widget.phoneNumber),
          );
        },
        onPesanan: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                MitraPesananScreen(phoneNumber: widget.phoneNumber),
          ),
        ),
        onProfil: () {},
        pesananBadge: _pesananAktif,
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await _muatProfil();
            await _muatJumlahPesanan();
          },
          color: _UI.primaryText,
          child: _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: ListShimmerLoading(count: 3),
                )
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // 1. HEADER (TANPA PANAH BACK)
                      _buildHeader(),

                      // 2. KONTEN BAWAH
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 60),
                            _buildStatistikKemitraan(),
                            const SizedBox(height: 24),
                            _buildGridMenu(),
                            const SizedBox(height: 24),
                            _buildSectionTitle('PENGATURAN UMUM'),
                            const SizedBox(height: 10),
                            _buildMenuList(),
                            const SizedBox(height: 24),
                            _buildTombolKeluar(),
                            const SizedBox(height: 20),
                            _buildFooterVersion(),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // --- HEADER LENGKUNG HIJAU SEGAR + FOTO PROFIL ---
  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: 180,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: -20,
                bottom: -40,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 30,
          child: Text(
            'Profil Toko',
            style: AppColors.heading(fontSize: 18, color: AppColors.textDark),
          ),
        ),
        Positioned(
          top: 120,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.hijauMuda,
              child: Icon(
                Icons.storefront_rounded,
                size: 50,
                color: AppColors.textDark,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- STATISTIK KEMITRAAN ---
  Widget _buildStatistikKemitraan() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _UI.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _namaToko,
            style: AppColors.heading(fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            _alamat,
            textAlign: TextAlign.center,
            style: AppColors.body(fontSize: 12, color: _UI.textSoft),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.hijauMuda),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.star_rounded,
                  color: Colors.amber,
                  value: _rating,
                  label: _ulasan,
                  onTap: () => _buka(
                    UlasanScreen(rating: _rating, jumlahUlasan: _ulasan),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.hijauMuda,
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.eco_rounded,
                  color: _UI.primaryText,
                  value: '$_paketTerselamatkan',
                  label: 'Paket Terselamatkan',
                  onTap: () => _buka(
                    PaketTerselamatkanScreen(total: _paketTerselamatkan),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(
              value,
              style: AppColors.heading(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppColors.body(fontSize: 11, color: _UI.textSoft),
        ),
      ],
      ),
    );
  }

  // --- GRID MENU ---
  Widget _buildGridMenu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildGridItem(
          icon: Icons.access_time_rounded,
          label: 'Jam Buka',
          onTap: () => _buka(JamBukaScreen(phoneNumber: widget.phoneNumber)),
        ),
        _buildGridItem(
          icon: Icons.account_balance_outlined,
          label: 'Rekening',
          onTap: () => _buka(RekeningScreen(namaToko: _namaToko)),
        ),
        _buildGridItem(
          icon: Icons.chat_bubble_outline,
          label: 'Ulasan',
          onTap: () => _buka(UlasanScreen(rating: _rating, jumlahUlasan: _ulasan)),
        ),
        _buildGridItem(
          icon: Icons.shopping_bag_outlined,
          label: 'Wadah',
          onTap: () => _info('Pengaturan Wadah'),
        ),
      ],
    );
  }

  Widget _buildGridItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _UI.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _UI.primaryBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.textDark, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppColors.body(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // --- MENU LIST ---
  Widget _buildMenuList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _UI.border),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profil Toko',
            onTap: _editProfil,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.lock_outline,
            title: 'PIN & Kata Sandi',
            onTap: () => _buka(const PinSandiScreen()),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.notifications_none,
            title: 'Notifikasi',
            onTap: () => _buka(const NotifikasiPengaturanScreen()),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.receipt_long_outlined,
            title: 'Riwayat Transaksi',
            onTap: () => _buka(const RiwayatTransaksiScreen()),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.headset_mic_outlined,
            title: 'Pusat Bantuan Mitra',
            onTap: () => _info('Hubungi CS'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textDark, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppColors.body(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.chevron_right, color: _UI.textSoft, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTombolKeluar() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _keluar,
        icon: const Icon(Icons.logout, color: AppColors.merah, size: 20),
        label: Text(
          'Keluar dari Akun Toko',
          style: AppColors.heading(fontSize: 14, color: AppColors.merah),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.merahMuda,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterVersion() {
    return Column(
      children: [
        Text(
          'Lastbite Partner v1.4.2',
          style: AppColors.body(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _UI.textSoft),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.eco, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              'Mendukung Gerakan Zero Food Waste Indonesia',
              style: AppColors.body(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppColors.body(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: _UI.textSoft,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 50,
      endIndent: 16,
      color: AppColors.bg,
    );
  }
}