import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/dashboard/mitra_dashboard_screen.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/profil/mitra_profil_screen.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/produk/tambah_produk_screen.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/dashboard/widgets/mitra_bottom_nav.dart';
import 'package:lastbite_foodwasted_mobiledev/core/widgets/shimmer_loading/app_shimmer_loading.dart';

// IMPORT BOTTOM SHEET KAMU DI SINI
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/pesanan/widgets/scan_pesanan_bottomsheet.dart';

import 'detail_produk_screen.dart';
import 'models/produk_model.dart';

class _UI {
  static Color get primary => AppColors.primary;
  static Color get orange => AppColors.orange;
  static Color get primaryText =>
      HSLColor.fromColor(AppColors.primary).withLightness(0.28).toColor();
  static Color get orangeText =>
      HSLColor.fromColor(AppColors.orange).withLightness(0.35).toColor();
  static Color get primaryBg => AppColors.primary.withValues(alpha: 0.1);
  static Color get orangeBg => AppColors.orange.withValues(alpha: 0.1);
  static Color get textSoft => const Color(0xFF6B6B6B);
  static Color get border => AppColors.textSoft.withValues(alpha: 0.15);
}

String _rp(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

class MitraProdukScreen extends StatefulWidget {
  final String phoneNumber;
  final String? namaToko;

  const MitraProdukScreen({
    super.key,
    required this.phoneNumber,
    this.namaToko,
  });

  @override
  State<MitraProdukScreen> createState() => _MitraProdukScreenState();
}

class _MitraProdukScreenState extends State<MitraProdukScreen> {
  StatusProduk _tab = StatusProduk.tayang;
  String _kategori = 'Semua Paket';
  String _query = '';
  final _searchFocus = FocusNode();

  bool _isLoading = true;
  bool _isTokoBuka = true;
  List<Produk> _produk = [];
  String _namaToko = 'Holland Bakery – Batam Center';

  List<String> get _kategoriList => [
    'Semua Paket',
    'Bakery & Pastry',
    'Roti Manis',
    'Pakan & Olahan',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.namaToko != null) _namaToko = widget.namaToko!;
    _muatProduk();
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _muatProduk() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getMitraProduk(widget.phoneNumber);
    if (!mounted) return;

    if (data == null) {
      setState(() => _isLoading = false);
      _info('Gagal memuat produk.');
      return;
    }
    setState(() {
      _isLoading = false;
      _produk = data.map(Produk.fromJson).toList();
    });
  }

  Future<void> _ubahStatusToko(bool buka) async {
    setState(() => _isTokoBuka = buka);
    final ok = await ApiService.setTokoStatus(widget.phoneNumber, buka);
    if (!mounted || ok) return;
    setState(() => _isTokoBuka = !buka);
    _info('Gagal mengubah status toko.');
  }

  int _hitung(StatusProduk s) => _produk.where((p) => p.statusUI == s).length;

  List<Produk> get _tampil {
    return _produk.where((p) {
      final cocokTab = p.statusUI == _tab;
      final cocokKategori =
          _kategori == 'Semua Paket' || p.kategori == _kategori;
      final cocokCari = p.nama.toLowerCase().contains(
        _query.trim().toLowerCase(),
      );
      return cocokTab && cocokKategori && cocokCari;
    }).toList();
  }

  int get _totalKuota => _produk
      .where((p) => p.statusUI == StatusProduk.tayang)
      .fold(0, (a, p) => a + p.kuota);
  int get _totalTerjual => _produk
      .where((p) => p.statusUI == StatusProduk.tayang)
      .fold(0, (a, p) => a + (p.kuota - p.stok));
  int get _totalSisa => _totalKuota - _totalTerjual;

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

  Future<void> _ubahStok(Produk p, int delta) async {
    final stokBaru = (p.stok + delta).clamp(0, p.kuota);
    if (stokBaru == p.stok) return;

    final ok = await ApiService.updateStokProduk(
      widget.phoneNumber,
      p.id,
      stokBaru,
    );
    if (!mounted) return;

    if (ok) {
      await _muatProduk();
    } else {
      _info('Gagal menyimpan stok. Coba lagi.');
    }
  }

  Future<void> _bukaTambahProduk() async {
    final berhasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahProdukScreen(phoneNumber: widget.phoneNumber),
      ),
    );
    if (berhasil == true && mounted) {
      await _muatProduk();
      _info('Produk berhasil ditambahkan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final daftar = _tampil;

    return Scaffold(
      backgroundColor: AppColors.bg,
      floatingActionButton: FloatingActionButton(
        onPressed: _bukaTambahProduk,
        backgroundColor: _UI.primaryText,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
      bottomNavigationBar: MitraBottomNav(
        currentIndex: 1,
        onDashboard: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                MitraDashboardScreen(phoneNumber: widget.phoneNumber),
          ),
        ),
        onProduk: () {},
        // UBAH BAGIAN INI: LANGSUNG TAMPILKAN BOTTOM SHEET
        onScan: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) =>
                ScanPesananBottomSheet(phoneNumber: widget.phoneNumber),
          );
        },
        onPesanan: () => _info('Halaman Pesanan belum dibuat'),
        onProfil: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MitraProfilScreen(phoneNumber: widget.phoneNumber),
          ),
        ),
        pesananBadge: 3,
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _muatProduk,
          color: _UI.primaryText,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            children: [
              _HeaderSection(namaToko: _namaToko),
              const SizedBox(height: 16),
              _StoreSummaryCard(
                namaToko: _namaToko,
                isTokoBuka: _isTokoBuka,
                onUbahStatusToko: _ubahStatusToko,
                totalKuota: _totalKuota,
                totalTerjual: _totalTerjual,
                totalSisa: _totalSisa,
              ),
              const SizedBox(height: 12),
              const _SurpriseBanner(),
              const SizedBox(height: 16),
              _SearchAndFilterBar(
                searchFocus: _searchFocus,
                onSearchChanged: (v) => setState(() => _query = v),
                onFilterTap: () => _info('Filter Kategori'),
              ),
              const SizedBox(height: 16),
              _StatusTabs(
                currentTab: _tab,
                hitungTayang: _hitung(StatusProduk.tayang),
                hitungTerjadwal: _hitung(StatusProduk.terjadwal),
                hitungHabis: _hitung(StatusProduk.habis),
                onTabChanged: (val) => setState(() => _tab = val),
              ),
              const SizedBox(height: 12),
              _CategoryFilters(
                categories: _kategoriList,
                selectedCategory: _kategori,
                onCategorySelected: (val) => setState(() => _kategori = val),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const ListShimmerLoading(count: 3)
              else if (daftar.isEmpty)
                _EmptyState()
              else
                for (final p in daftar)
                  _ProductCard(
                    produk: p,
                    phoneNumber: widget.phoneNumber,
                    onUbahStok: _ubahStok,
                    onRefresh: _muatProduk,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final String namaToko;
  const _HeaderSection({required this.namaToko});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Produk Saya', style: AppColors.heading(fontSize: 20)),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _UI.primaryBg,
            shape: BoxShape.circle,
            border: Border.all(color: _UI.primary.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              namaToko.isNotEmpty
                  ? namaToko.substring(0, 2).toUpperCase()
                  : 'HB',
              style: AppColors.heading(fontSize: 14, color: _UI.primaryText),
            ),
          ),
        ),
      ],
    );
  }
}

class _StoreSummaryCard extends StatelessWidget {
  final String namaToko;
  final bool isTokoBuka;
  final ValueChanged<bool> onUbahStatusToko;
  final int totalKuota, totalTerjual, totalSisa;

  const _StoreSummaryCard({
    required this.namaToko,
    required this.isTokoBuka,
    required this.onUbahStatusToko,
    required this.totalKuota,
    required this.totalTerjual,
    required this.totalSisa,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _UI.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _UI.primaryBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  color: _UI.primaryText,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaToko,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppColors.heading(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isTokoBuka
                                ? _UI.primaryText
                                : _UI.orangeText,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isTokoBuka ? 'Etalase Terbuka' : 'Etalase Tutup',
                          style: AppColors.body(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isTokoBuka
                                ? _UI.primaryText
                                : _UI.orangeText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Switch(
                value: isTokoBuka,
                onChanged: onUbahStatusToko,
                activeColor: Colors.white,
                activeTrackColor: _UI.primaryText,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: _UI.textSoft.withValues(alpha: 0.3),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatBox(
                title: 'Total Kuota',
                value: '$totalKuota',
                sub: 'Paket',
                icon: Icons.inventory_2_outlined,
                iconColor: _UI.primaryText,
              ),
              const SizedBox(width: 12),
              _buildStatBox(
                title: 'Terjual',
                value: '$totalTerjual',
                sub: 'Sisa $totalSisa',
                icon: Icons.shopping_bag_outlined,
                iconColor: _UI.orangeText,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppColors.body(fontSize: 11, color: _UI.textSoft),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: AppColors.heading(
                          fontSize: 18,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        sub,
                        style: AppColors.body(
                          fontSize: 11,
                          color: _UI.textSoft,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(icon, color: iconColor, size: 24),
          ],
        ),
      ),
    );
  }
}

class _SurpriseBanner extends StatelessWidget {
  const _SurpriseBanner();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _UI.primaryBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: _UI.primaryText,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Konsep Surprise Box: ',
                    style: AppColors.body(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _UI.primaryText,
                    ),
                  ),
                  TextSpan(
                    text: 'Cukup sediakan kuota tanpa perlu memilih roti satu per satu saat jam sibuk.',
                    style: AppColors.body(
                      fontSize: 12,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilterBar extends StatelessWidget {
  final FocusNode searchFocus;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterTap;

  const _SearchAndFilterBar({
    required this.searchFocus,
    required this.onSearchChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _UI.border),
            ),
            child: TextField(
              focusNode: searchFocus,
              onChanged: onSearchChanged,
              style: AppColors.body(fontSize: 14),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: _UI.textSoft,
                  size: 22,
                ),
                hintText: 'Cari nama paket kejutan...',
                hintStyle: AppColors.body(fontSize: 13, color: _UI.textSoft),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _UI.border),
            ),
            child: Icon(Icons.tune_rounded, color: _UI.textSoft, size: 22),
          ),
        ),
      ],
    );
  }
}

class _StatusTabs extends StatelessWidget {
  final StatusProduk currentTab;
  final int hitungTayang, hitungTerjadwal, hitungHabis;
  final ValueChanged<StatusProduk> onTabChanged;

  const _StatusTabs({
    required this.currentTab,
    required this.hitungTayang,
    required this.hitungTerjadwal,
    required this.hitungHabis,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _UI.border),
      ),
      child: Row(
        children: [
          _buildTabItem('Tayang', StatusProduk.tayang, hitungTayang),
          _buildTabItem('Terjadwal', StatusProduk.terjadwal, hitungTerjadwal),
          _buildTabItem('Habis', StatusProduk.habis, hitungHabis),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, StatusProduk status, int count) {
    final isActive = currentTab == status;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? _UI.primaryBg : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppColors.heading(
                  fontSize: 12,
                  color: isActive ? _UI.primaryText : _UI.textSoft,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive
                      ? _UI.primaryText
                      : _UI.textSoft.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: AppColors.heading(
                    fontSize: 10,
                    color: isActive ? Colors.white : _UI.textSoft,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const _CategoryFilters({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final k = categories[i];
          final isActive = k == selectedCategory;
          return GestureDetector(
            onTap: () => onCategorySelected(k),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? _UI.primaryText : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? _UI.primaryText : _UI.border,
                ),
              ),
              child: Row(
                children: [
                  if (i == 0) ...[
                    Icon(
                      Icons.grid_view_rounded,
                      size: 14,
                      color: isActive ? Colors.white : _UI.textSoft,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    k,
                    style: AppColors.body(
                      fontSize: 12.5,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                      color: isActive ? Colors.white : _UI.textSoft,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Produk produk;
  final String phoneNumber;
  final Function(Produk, int) onUbahStok;
  final VoidCallback onRefresh;

  const _ProductCard({
    required this.produk,
    required this.phoneNumber,
    required this.onUbahStok,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isWarning = produk.cepatHabis;
    final progressColor = isWarning ? _UI.orangeText : _UI.primaryText;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                DetailProdukScreen(produk: produk, phoneNumber: phoneNumber),
          ),
        );
        if (result == true) {
          onRefresh();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _UI.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 90,
                        height: 90,
                        child: produk.gambar != null
                            ? Image.network(
                                produk.gambar!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _fotoKosong(),
                              )
                            : _fotoKosong(),
                      ),
                    ),
                    if (produk.adaDiskon)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _UI.orangeText,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-${produk.diskon}%',
                            style: AppColors.heading(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildBadgeMini(
                            'Tayang',
                            _UI.primaryBg,
                            _UI.primaryText,
                            true,
                          ),
                          const SizedBox(width: 6),
                          if (isWarning)
                            _buildBadgeMini(
                              'Cepat Habis',
                              _UI.orangeBg,
                              _UI.orangeText,
                              false,
                            )
                          else
                            _buildBadgeMini(
                              produk.kategori,
                              AppColors.bg,
                              _UI.textSoft,
                              false,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        produk.nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppColors.heading(fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        produk.deskripsi,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppColors.body(
                          fontSize: 12,
                          color: _UI.textSoft,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _rp(produk.harga),
                            style: AppColors.heading(
                              fontSize: 16,
                              color: _UI.primaryText,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (produk.adaDiskon)
                            Text(
                              _rp(produk.hargaAsli),
                              style:
                                  AppColors.body(
                                    fontSize: 12,
                                    color: _UI.textSoft,
                                  ).copyWith(
                                    decoration: TextDecoration.lineThrough,
                                  ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isWarning
                                ? Icons.local_fire_department_rounded
                                : Icons.inventory_2_outlined,
                            size: 16,
                            color: progressColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tersisa ${produk.stok} dari ${produk.kuota} ${produk.satuan.replaceAll('/', '')}',
                            style: AppColors.body(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: progressColor,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${produk.persen}%',
                        style: AppColors.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: progressColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: produk.rasio.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: _UI.textSoft.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(progressColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: _UI.textSoft,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Ambil: ${produk.jamAmbil}',
                      style: AppColors.body(
                        fontSize: 12,
                        color: _UI.textSoft,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _UI.border),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 36),
                        icon: Icon(
                          Icons.remove_rounded,
                          size: 18,
                          color: _UI.textSoft,
                        ),
                        onPressed: () => onUbahStok(produk, -1),
                      ),
                      Text(
                        '${produk.stok} ${produk.satuan.replaceAll('/', '')}',
                        style: AppColors.heading(fontSize: 13),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 36),
                        icon: Icon(
                          Icons.add_rounded,
                          size: 18,
                          color: _UI.primaryText,
                        ),
                        onPressed: () => onUbahStok(produk, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeMini(String text, Color bg, Color fg, bool showDot) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: AppColors.body(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fotoKosong() {
    return Container(
      color: _UI.primaryBg,
      child: Icon(
        Icons.fastfood_rounded,
        color: _UI.primary.withValues(alpha: 0.5),
        size: 32,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _UI.primaryBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: _UI.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada produk di sini',
            style: AppColors.body(
              fontSize: 14,
              color: _UI.textSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
