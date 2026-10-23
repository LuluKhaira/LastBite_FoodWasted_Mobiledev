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

  const MitraPesananScreen({
    super.key,
    required this.phoneNumber,
    this.initialTab = 0,
  });

  @override
  State<MitraPesananScreen> createState() => _MitraPesananScreenState();
}

class _MitraPesananScreenState extends State<MitraPesananScreen> {
  int _tab = 0; // 0: Semua, 1: Baru, 2: Siap, 3: Selesai/Riwayat
  bool _loading = true;
  List<Map<String, dynamic>> _data = [];
  Timer? _timer;

  final List<String> _tabLabels = ['Semua', 'Baru', 'Siap Diambil', 'Selesai'];

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    _muatData();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) => _muatData(diam: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _muatData({bool diam = false}) async {
    if (!diam) setState(() => _loading = true);
    
    String tabParam = 'semua';
    if (_tab == 1) tabParam = 'baru';
    if (_tab == 2) tabParam = 'siap';
    if (_tab == 3) tabParam = 'riwayat';

    final res = await ApiService.getMitraPesanan(widget.phoneNumber, tab: tabParam);
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
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () => _muatData(),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _muatData(),
          color: AppColors.primary,
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildTabSelector(),
              const SizedBox(height: 12),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : _data.isEmpty
                        ? Center(
                            child: Text(
                              'Belum ada pesanan',
                              style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textSoft),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _data.length,
                            itemBuilder: (ctx, i) => _buildKartuPesanan(_data[i]),
                          ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MitraBottomNav(
        currentIndex: 0,
        onDashboard: () {},
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
            builder: (context) => ScanPesananBottomSheet(phoneNumber: widget.phoneNumber),
          );
        },
        onPesanan: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MitraPesananScreen(
              phoneNumber: widget.phoneNumber,
            ),
          ),
        ),
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
                if (val) {
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
              Text('#$kode', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toString().toUpperCase(),
                  style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('$qty x $produk', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600)),
          Text('Total: Rp $total', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }
}