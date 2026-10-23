import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/dashboard/mitra_dashboard_screen.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/produk/mitra_produk_screen.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/profil/mitra_profil_screen.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/dashboard/widgets/mitra_bottom_nav.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/pesanan/widgets/scan_pesanan_bottomsheet.dart';

class MitraPesananScreen extends StatefulWidget {
  final String phoneNumber;
  final int initialTab;
  final String namaToko;

  const MitraPesananScreen({
    super.key,
    required this.phoneNumber,
    this.initialTab = 0,
    this.namaToko = 'Toko Saya',
  });

  @override
  State<MitraPesananScreen> createState() => _MitraPesananScreenState();
}

class _MitraPesananScreenState extends State<MitraPesananScreen> {
  // Index item "Pesanan" di MitraBottomNav. Sesuaikan dengan urutan di widget-nya.
  static const int _navIndexPesanan = 3;

  // Status yang dianggap sudah tidak aktif (tidak dihitung di badge).
  // Sesuaikan dengan nilai status yang dikirim backend.
  static const List<String> _statusSelesai = [
    'selesai',
    'ditolak',
    'dibatalkan',
    'batal',
    'kedaluwarsa',
  ];

  int _tab = 0; // 0: Semua, 1: Baru, 2: Siap, 3: Selesai/Riwayat
  bool _loading = true;
  List<Map<String, dynamic>> _data = [];
  Timer? _timer;

  int _pesananAktif = 0;
  String get _namaToko => widget.namaToko;

  final List<String> _tabLabels = ['Semua', 'Baru', 'Siap Diambil', 'Selesai'];

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    _muatData();
    _muatBadge();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      _muatData(diam: true);
      _muatBadge();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _tabParam {
    switch (_tab) {
      case 1:
        return 'baru';
      case 2:
        return 'siap';
      case 3:
        return 'riwayat';
      default:
        return 'semua';
    }
  }

  Future<void> _muatData({bool diam = false}) async {
    if (!diam && mounted) setState(() => _loading = true);

    final res = await ApiService.getMitraPesanan(
      widget.phoneNumber,
      tab: _tabParam,
    );
    if (!mounted) return;

    if (res['ok'] == true) {
      setState(() {
        _data = List<Map<String, dynamic>>.from(res['data'] ?? []);
        _loading = false;
      });
    } else {
      if (!diam) {
        setState(() => _loading = false);
        _snack(res['message'] ?? 'Gagal memuat pesanan');
      }
    }
  }

  // Hitung jumlah pesanan aktif untuk badge, terpisah dari tab yang dibuka.
  Future<void> _muatBadge() async {
    final res = await ApiService.getMitraPesanan(
      widget.phoneNumber,
      tab: 'semua',
    );
    if (!mounted || res['ok'] != true) return;

    final list = List<Map<String, dynamic>>.from(res['data'] ?? []);
    final aktif = list.where((p) {
      final s = (p['status'] ?? '').toString().toLowerCase();
      return !_statusSelesai.contains(s);
    }).length;

    if (aktif != _pesananAktif) {
      setState(() => _pesananAktif = aktif);
    }
  }

  Future<void> _refreshSemua() async {
    await Future.wait([_muatData(diam: true), _muatBadge()]);
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Pesanan Masuk',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () => _refreshSemua(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildTabSelector(),
            const SizedBox(height: 12),
            Expanded(child: _buildIsi()),
          ],
        ),
      ),
      bottomNavigationBar: MitraBottomNav(
        currentIndex: _navIndexPesanan,
        onDashboard: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MitraDashboardScreen(
              phoneNumber: widget.phoneNumber,
            ),
          ),
        ),
        onProduk: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MitraProdukScreen(
              phoneNumber: widget.phoneNumber,
              namaToko: _namaToko,
            ),
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
        onPesanan: () {}, // sudah di halaman ini
        onProfil: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MitraProfilScreen(
              phoneNumber: widget.phoneNumber,
            ),
          ),
        ),
        pesananBadge: _pesananAktif,
      ),
    );
  }

  Widget _buildIsi() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshSemua,
      color: AppColors.primary,
      child: _data.isEmpty
          // ListView supaya pull-to-refresh tetap jalan saat data kosong
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                Center(
                  child: Text(
                    'Belum ada pesanan',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppColors.textSoft,
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: _data.length,
              itemBuilder: (ctx, i) => _buildKartuPesanan(_data[i]),
            ),
    );
  }

  Widget _buildTabSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(_tabLabels.length, (i) {
          final sel = _tab == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_tabLabels[i]),
              selected: sel,
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              labelStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: sel ? Colors.white : AppColors.textDark,
              ),
              onSelected: (val) {
                if (val && _tab != i) {
                  setState(() => _tab = i);
                  _muatData();
                }
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildKartuPesanan(Map<String, dynamic> p) {
    final kode = p['kode'] ?? '';
    final produk = p['produk'] ?? 'Produk';
    final qty = p['qty'] ?? 1;
    final total = p['total'] ?? 0;
    final status = p['status'] ?? 'menunggu';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textSoft.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#$kode',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toString().toUpperCase(),
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$qty x $produk',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Total: Rp $total',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}