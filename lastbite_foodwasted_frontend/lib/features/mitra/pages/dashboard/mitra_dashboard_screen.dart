import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/produk/tambah_produk_screen.dart';
import 'widgets/kartu_info_toko.dart';
import 'widgets/aksi_cepat.dart';
import 'widgets/ringkasan_section.dart';
import 'widgets/surplus_section.dart';

class MitraDashboardScreen extends StatefulWidget {
  // Nomor WhatsApp mitra, dipakai untuk mengambil data miliknya dari server
  final String phoneNumber;

  const MitraDashboardScreen({super.key, required this.phoneNumber});

  @override
  State<MitraDashboardScreen> createState() => _MitraDashboardScreenState();
}

class _MitraDashboardScreenState extends State<MitraDashboardScreen> {
  bool _isTokoBuka = true;
  bool _showWarningBanner = false;
  bool _isLoading = true;
  String _namaToko = 'Mitra Dashboard';
  int _pesananAktif = 0;
  int _pesananHariIni = 0;
  double _pendapatan = 0;
  int _porsi = 0;
  double _co2Kg = 0;
  List<Map<String, dynamic>> _surplus = [];

  @override
  void initState() {
    super.initState();
    _muatDashboard();
  }

  // Ambil data terbaru dari server (dipanggil saat layar dibuka & saat layar ditarik ke bawah)
  Future<void> _muatDashboard() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getMitraDashboard(widget.phoneNumber);
    if (!mounted) return;

    if (data == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat data dashboard. Tarik layar ke bawah untuk mencoba lagi.'),
        ),
      );
      return;
    }

    final toko = Map<String, dynamic>.from(data['toko'] ?? {});
    setState(() {
      _isLoading = false;
      _namaToko = (toko['nama'] ?? 'Mitra Dashboard').toString();
      _isTokoBuka = toko['buka'] == true;
      // Banner muncul hanya kalau jam operasional belum diisi
      _showWarningBanner = data['jam_operasional_lengkap'] != true;
      _pesananAktif = int.tryParse('${data['pesanan_aktif']}') ?? 0;

      final r = Map<String, dynamic>.from(data['ringkasan'] ?? {});
      _pesananHariIni = int.tryParse('${r['pesanan_hari_ini']}') ?? 0;
      _pendapatan = double.tryParse('${r['pendapatan_hari_ini']}') ?? 0;
      _porsi = int.tryParse('${r['porsi_terselamatkan']}') ?? 0;
      _co2Kg = double.tryParse('${r['co2_kg']}') ?? 0;
      _surplus = ((data['surplus'] ?? []) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    });
  }

  // Buka form tambah produk; kalau berhasil disimpan, muat ulang dashboard
  Future<void> _bukaTambahProduk() async {
    final berhasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahProdukScreen(phoneNumber: widget.phoneNumber),
      ),
    );
    if (berhasil == true) {
      await _muatDashboard();
    }
  }

  // Simpan status buka/tutup ke server; kalau gagal, kembalikan tombolnya
  Future<void> _ubahStatusToko(bool buka) async {
    setState(() => _isTokoBuka = buka);
    final berhasil = await ApiService.setTokoStatus(widget.phoneNumber, buka);
    if (!mounted || berhasil) return;

    setState(() => _isTokoBuka = !buka);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gagal mengubah status toko. Coba lagi.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _muatDashboard,
              color: AppColors.primary,
              child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                          namaToko: _namaToko,
                          isTokoBuka: _isTokoBuka,
                          onStatusChanged: _ubahStatusToko,
                        ),
                        const SizedBox(height: 12),
                        if (_showWarningBanner) _buildWarningBanner(),
                        const SizedBox(height: 16),
                        const AksiCepat(),
                        const SizedBox(height: 20),
                        RingkasanSection(
                          pesananHariIni: _pesananHariIni,
                          pesananAktif: _pesananAktif,
                          pendapatan: _pendapatan,
                          porsi: _porsi,
                          co2Kg: _co2Kg,
                        ),
                        const SizedBox(height: 20),
                        SurplusSection(items: _surplus),
                        const SizedBox(height: 16),
                        _buildTipsBanner(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ),

            if (_isLoading)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(minHeight: 3),
              ),
            
            Positioned(
              right: 16,
              bottom: 76,
              child: FloatingActionButton(
                onPressed: _bukaTambahProduk,
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
                  _namaToko,
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
                  'Makanan yang diunggah sebelum jam 17.00 rata-rata laku dalam 35 menit! Coba upload produk lebih awal untuk penjualan maksimal.',
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
            isLabelVisible: _pesananAktif > 0,
            label: Text('$_pesananAktif'),
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