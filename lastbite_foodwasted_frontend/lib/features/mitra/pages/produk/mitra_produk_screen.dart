import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/dashboard/mitra_dashboard_screen.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/profil/mitra_profil_screen.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/produk/tambah_produk_screen.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/dashboard/widgets/mitra_bottom_nav.dart';
import 'package:lastbite_foodwasted_mobiledev/core/widgets/shimmer_loading/app_shimmer_loading.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/pesanan/mitra_pesanan_screen.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/pesanan/widgets/scan_pesanan_bottomsheet.dart';

import 'detail_produk_screen.dart';
import 'models/produk_model.dart';
import 'widgets/dialog_konfirmasi_pengalihan.dart';

class _UI {
  static Color get primary => AppColors.primary;
  static Color get orange => AppColors.orange;
  static Color get primaryText => AppColors.zaitun;
  static Color get orangeText =>
      HSLColor.fromColor(AppColors.orange).withLightness(0.35).toColor();
  static Color get primaryBg => AppColors.hijauMuda;
  static Color get orangeBg => AppColors.orange.withValues(alpha: 0.1);
  static Color get textSoft => const Color(0xFF6B6B6B);
  static Color get border => AppColors.textSoft.withValues(alpha: 0.15);
}

String _rp(int v) {
  if (v == 0) return 'Gratis';
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

  int _pesananAktif = 0;

  // Dibuat dari kategori produk yang benar-benar ada, supaya produk yang
  // dialihkan ke Pakan Ternak & Ikan ikut punya filter.
  List<String> get _kategoriList {
    final unik = {for (final p in _produk) p.kategori}.toList()..sort();
    return ['Semua Paket', ...unik];
  }

  @override
  void initState() {
    super.initState();
    if (widget.namaToko != null) _namaToko = widget.namaToko!;
    _muatProduk();
    _muatJumlahPesanan();
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
        backgroundColor: AppColors.primary,
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
            builder: (_) => MitraPesananScreen(
              phoneNumber: widget.phoneNumber,
              namaToko: _namaToko,
            ),
          ),
        ),
        onProfil: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MitraProfilScreen(phoneNumber: widget.phoneNumber),
          ),
        ),
        pesananBadge: _pesananAktif,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeaderTabs(),
            _buildKategoriFilter(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _muatProduk();
                  await _muatJumlahPesanan();
                },
                color: _UI.primaryText,
                child: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: ListShimmerLoading(count: 3),
                      )
                    : daftar.isEmpty
                        ? _EmptyState()
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                            itemCount: daftar.length,
                            itemBuilder: (context, i) {
                              final p = daftar[i];
                              return _ProductCardRef(
                                produk: p,
                                phoneNumber: widget.phoneNumber,
                                onUbahStok: _ubahStok,
                                onRefresh: _muatProduk,
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HEADER: blok hijau segar (primary) + tab pill ---
  Widget _buildHeaderTabs() {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 0),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Produk Saya',
                style: AppColors.heading(fontSize: 18, color: AppColors.textDark),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _buildTabItem('Tayang', StatusProduk.tayang),
                _buildTabItem('Terjadwal', StatusProduk.terjadwal),
                _buildTabItem('Habis', StatusProduk.habis),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, StatusProduk status) {
    final isActive = _tab == status;
    final count = _hitung(status);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppColors.body(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isActive
                        ? AppColors.textDark
                        : AppColors.textDark.withValues(alpha: 0.7),
                  ),
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 3),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.orange
                        : Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: AppColors.body(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKategoriFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: AppColors.bg,
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _kategoriList.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final k = _kategoriList[i];
            final isActive = k == _kategori;

            return GestureDetector(
              onTap: () => setState(() => _kategori = k),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? AppColors.primary : _UI.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (i == 0) ...[
                      Icon(
                        Icons.grid_view_rounded,
                        size: 16,
                        color: isActive ? AppColors.textDark : _UI.textSoft,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      k,
                      style: AppColors.body(
                        fontSize: 12.5,
                        fontWeight:
                            isActive ? FontWeight.w800 : FontWeight.w600,
                        color: isActive ? AppColors.textDark : _UI.textSoft,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- KARTU PRODUK (OVERFLOW DIPERBAIKI) ---
class _ProductCardRef extends StatelessWidget {
  final Produk produk;
  final String phoneNumber;
  final Function(Produk, int) onUbahStok;
  final VoidCallback onRefresh;

  const _ProductCardRef({
    required this.produk,
    required this.phoneNumber,
    required this.onUbahStok,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isWarning = produk.cepatHabis;
    final barColor = isWarning ? AppColors.orange : AppColors.primary;
    final labelColor = isWarning ? _UI.orangeText : AppColors.textDark;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                DetailProdukScreen(produk: produk, phoneNumber: phoneNumber),
          ),
        );
        if (result == true) onRefresh();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isWarning
                                      ? AppColors.orange.withValues(alpha: 0.18)
                                      : AppColors.hijauMuda,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '#${produk.id} • ${produk.kategori}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppColors.body(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: isWarning
                                        ? _UI.orangeText
                                        : AppColors.textDark,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: barColor.withValues(alpha: 0.6),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${produk.persen}%',
                                style: AppColors.heading(
                                  fontSize: 10,
                                  color: labelColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        produk.nama,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppColors.heading(fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          if (produk.harga == 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: const Color(0xFF81C784)),
                              ),
                              child: Text(
                                'Gratis',
                                style: AppColors.heading(
                                  fontSize: 13,
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),
                            )
                          else
                            Flexible(
                              child: Text(
                                _rp(produk.harga),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppColors.heading(
                                    fontSize: 15, color: AppColors.textDark),
                              ),
                            ),
                          const SizedBox(width: 6),
                          if (produk.adaDiskon)
                            Flexible(
                              child: Text(
                                _rp(produk.hargaAsli),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppColors.body(
                                  fontSize: 11,
                                  color: _UI.textSoft,
                                ).copyWith(
                                    decoration: TextDecoration.lineThrough),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: _UI.textSoft,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              produk.jamAmbil,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppColors.body(
                                fontSize: 11,
                                color: _UI.textSoft,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (produk.tampilBadgePakan) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.orange.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.autorenew,
                                  size: 11, color: _UI.orangeText),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  produk.labelBadgePakan,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppColors.body(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: _UI.orangeText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                      Flexible(
                        child: Text(
                          'Tersisa ${produk.stok} dari ${produk.kuota}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppColors.body(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: labelColor,
                          ),
                        ),
                      ),
                      Text(
                        '${produk.persen}%',
                        style: AppColors.body(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: labelColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: produk.rasio.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: _UI.textSoft.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(barColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    produk.deskripsi,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppColors.body(fontSize: 11, color: _UI.textSoft),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _UI.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => onUbahStok(produk, -1),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.remove_rounded,
                            size: 16,
                            color: _UI.textSoft,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '${produk.stok}',
                          style: AppColors.heading(fontSize: 12),
                        ),
                      ),
                      InkWell(
                        onTap: () => onUbahStok(produk, 1),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.add_rounded,
                            size: 16,
                            color: _UI.primaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (produk.isMenungguKonfirmasi) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.orange.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: AppColors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Produk kedaluwarsa, masih ada sisa. Alihkan atau buang?',
                            style: AppColors.heading(
                              fontSize: 12,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.autorenew_rounded, size: 16),
                        label: Text(
                          'Alihkan / Buang',
                          style: AppColors.body(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        onPressed: () {
                          DialogKonfirmasiPengalihan.show(
                            context,
                            produk: produk,
                            phoneNumber: phoneNumber,
                            onBerhasil: onRefresh,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (produk.draf) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.rocket_launch_rounded, size: 16),
                  label: Text(
                    'Tayangkan',
                    style: AppColors.body(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  onPressed: () async {
                    final res = await ApiService.setProdukAktif(
                      phoneNumber,
                      produk.id,
                      true,
                    );
                    if (res['ok'] == true) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(res['message'] ?? 'Produk berhasil ditayangkan!'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                      onRefresh();
                    } else {
                      if (!context.mounted) return;
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
                              const SizedBox(width: 8),
                              Text('Gagal Menayangkan', style: AppColors.heading(fontSize: 15)),
                            ],
                          ),
                          content: Text(
                            res['message'] ?? 'Produk tidak memenuhi syarat untuk ditayangkan.',
                            style: AppColors.body(fontSize: 13),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text('Tutup', style: AppColors.body(color: AppColors.primary, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ],
        ),
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