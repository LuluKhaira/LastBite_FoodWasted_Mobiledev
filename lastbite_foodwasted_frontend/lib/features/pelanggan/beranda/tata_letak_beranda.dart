import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/komponen/animasi_lb.dart';
import '../../../core/komponen/navbar_bawah.dart';
import '../../../core/tema/tema_lb.dart';
import 'model_bahan.dart';
import 'model_toko.dart';
import 'widgets/header_beranda.dart';
import 'widgets/bilah_pencarian.dart';
import 'widgets/baris_alamat_pengguna.dart';
import 'widgets/sheet_pilih_lokasi.dart';
import 'widgets/baris_filter_cepat.dart';
import 'widgets/carousel_promo_beranda.dart';
import 'widgets/baris_kategori_pelanggan.dart';
import 'widgets/toggle_tipe.dart';
import 'widgets/judul_seksi.dart';
import 'widgets/kartu_paket.dart';
import 'widgets/kartu_toko.dart';

/// Layout halaman beranda (dipakai mode dimakan & ternak).
/// Navbar hanya tampil bila [onNavTap] diisi. Di dalam CangkangUtama,
/// JANGAN isi onNavTap karena navbar sudah ada di cangkang.
class BerandaLayout extends StatefulWidget {
  final bool isTernak;
  final ValueChanged<bool> onSwitch; // true = pindah ke ternak
  final String sectionTitle;
  final List<BahanItem> items;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onLihatPeta;
  final ValueChanged<int>? onNavTap;
  final ValueChanged<BahanItem>? onItemTap;
  final ValueChanged<TokoGroup>? onTokoTap;
  final bool loading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const BerandaLayout({
    super.key,
    required this.isTernak,
    required this.onSwitch,
    required this.sectionTitle,
    required this.items,
    this.onSearch,
    this.onLihatPeta,
    this.onNavTap,
    this.onItemTap,
    this.onTokoTap,
    this.loading = false,
    this.errorMessage,
    this.onRetry,
  });

  @override
  State<BerandaLayout> createState() => _BerandaLayoutState();
}

class _BerandaLayoutState extends State<BerandaLayout> {
  // Animasi masuk besar hanya sekali per sesi aplikasi
  static bool _sudahMasuk = false;
  late final bool _animasi;

  // Status alamat lokasi pengguna (default: Batam Center)
  String _lokasiTeks = 'Batam Center • Jl. Ahmad Yani';

  // Status saringan cepat & kategori pelanggan
  String _selectedKategori = 'Semua';
  bool _filterTerdekat = false;
  bool _filterRating = false;
  bool _filterDiskon = false;

  @override
  void initState() {
    super.initState();
    _animasi = !_sudahMasuk;
    _sudahMasuk = true;
  }

  void _resetFilter() {
    setState(() {
      _selectedKategori = 'Semua';
      _filterTerdekat = false;
      _filterRating = false;
      _filterDiskon = false;
    });
    widget.onRetry?.call();
  }

  void _bukaDialogUbahLokasi(BuildContext context) async {
    final hasil = await SheetPilihLokasi.tampilkan(
      context,
      lokasiSaatIni: _lokasiTeks,
    );
    if (hasil != null && mounted) {
      setState(() {
        _lokasiTeks = hasil.judulLengkap;
      });
    }
  }

  List<BahanItem> get _filteredItems {
    var list = widget.items;

    // Filter Kategori
    final activeKat = _selectedKategori.toLowerCase();
    if (activeKat != 'semua') {
      list = list.where((it) {
        final k = it.kategori.toLowerCase();
        final tag = it.tag.toLowerCase();
        final nama = it.nama.toLowerCase();

        if (activeKat == 'roti & kue') {
          return k.contains('roti') ||
              k.contains('kue') ||
              k.contains('pastry') ||
              k.contains('bakery') ||
              tag.contains('roti') ||
              tag.contains('kue') ||
              nama.contains('roti') ||
              nama.contains('kue');
        } else if (activeKat == 'makanan') {
          return k.contains('makan') ||
              k.contains('santap') ||
              k.contains('siap') ||
              k.contains('nasi') ||
              tag.contains('makan') ||
              nama.contains('nasi') ||
              nama.contains('ayam') ||
              nama.contains('mie');
        } else if (activeKat == 'bahan dapur') {
          return k.contains('bahan') ||
              k.contains('dapur') ||
              k.contains('olahan') ||
              k.contains('sayur') ||
              k.contains('buah') ||
              tag.contains('bahan') ||
              tag.contains('dapur');
        } else if (activeKat == 'minuman') {
          return k.contains('minum') ||
              k.contains('kopi') ||
              k.contains('jus') ||
              k.contains('tea') ||
              k.contains('teh') ||
              tag.contains('minum') ||
              nama.contains('kopi') ||
              nama.contains('jus') ||
              nama.contains('teh');
        }
        return k.contains(activeKat) ||
            tag.contains(activeKat) ||
            nama.contains(activeKat);
      }).toList();
    }

    // Filter Terdekat (< 2 km)
    if (_filterTerdekat) {
      list = list.where((it) {
        final d = it.jarakKm;
        return d != null && d <= 2.0;
      }).toList();
    }

    // Filter Rating 4.8+
    if (_filterRating) {
      list = list.where((it) => it.ratingNilai >= 4.8).toList();
    }

    // Filter Diskon > 50%
    if (_filterDiskon) {
      list = list.where((it) => it.diskonPersen >= 50).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final displayItems = _filteredItems;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: LbColors.offWhite,
        bottomNavigationBar: widget.onNavTap == null
            ? null
            : LbBottomNav(
                currentIndex: 0,
                onTap: (i) => widget.onNavTap!(i),
              ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ---------- HEADER HIJAU (Tanpa Baris Lokasi Lama) ----------
            SliverToBoxAdapter(
              child: LbMuncul(
                aktif: _animasi,
                dari: const Offset(0, -30),
                durasi: const Duration(milliseconds: 650),
                child: LbHeaderHijau(
                  children: [
                    LbMuncul(
                      aktif: _animasi,
                      urutan: 2,
                      child: LbSearchBar(
                        onChanged: widget.onSearch,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---------- TAMPILAN BERANDA PELANGGAN BARU ----------
            if (!widget.isTernak)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),

                    // Baris Informasi Lokasi: [📍 Batam Center • Jl. Ahmad Yani    Ubah Lokasi]
                    LbMuncul(
                      aktif: _animasi,
                      urutan: 3,
                      child: BarisAlamatPengguna(
                        alamat: _lokasiTeks,
                        onUbahLokasi: () => _bukaDialogUbahLokasi(context),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 1. Baris Saringan Cepat (Terdekat < 2km, Rating 4.8+, Diskon > 50%)
                    LbMuncul(
                      aktif: _animasi,
                      urutan: 4,
                      child: BarisFilterCepat(
                        filterTerdekat: _filterTerdekat,
                        filterRating: _filterRating,
                        filterDiskon: _filterDiskon,
                        onToggleTerdekat: () => setState(
                            () => _filterTerdekat = !_filterTerdekat),
                        onToggleRating: () =>
                            setState(() => _filterRating = !_filterRating),
                        onToggleDiskon: () =>
                            setState(() => _filterDiskon = !_filterDiskon),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Banner Promo Slider Carousel
                    LbMuncul(
                      aktif: _animasi,
                      urutan: 5,
                      child: const CarouselPromoBeranda(),
                    ),
                    const SizedBox(height: 18),

                    // 3. Baris Kategori Squircle (Semua, Roti & Kue, Makanan, Bahan Dapur, Minuman)
                    LbMuncul(
                      aktif: _animasi,
                      urutan: 6,
                      child: BarisKategoriPelanggan(
                        selected: _selectedKategori,
                        onSelected: (k) =>
                            setState(() => _selectedKategori = k),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4. Judul Seksi: Cepat Habis di Sekitarmu ⚡ + Reset ↺
                    LbMuncul(
                      aktif: _animasi,
                      urutan: 7,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: LbSectionTitle(
                          title: 'Cepat Habis di Sekitarmu ⚡',
                          subtitle:
                              'Penyelamatan pangan terbaik hari ini di Batam',
                          onReset: _resetFilter,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              )
            else
              // Mode Ternak: tetap sediakan pengalih mode kembali ke konsumsi manusia
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LbTypeToggle(
                        isTernak: true,
                        onChanged: widget.onSwitch,
                      ),
                      const SizedBox(height: 18),
                      LbSectionTitle(
                        title: widget.sectionTitle,
                        onLihatPeta: widget.onLihatPeta,
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),

            // ---------- ISI DAFTAR PRODUK & TOKO ----------
            if (widget.loading)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                sliver: SliverList.separated(
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, __) => const KartuKerangka(),
                ),
              )
            else if (widget.errorMessage != null)
              SliverToBoxAdapter(
                child: LbMuncul(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 40, horizontal: 32),
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_off_rounded,
                            size: 44, color: LbColors.sageDeep),
                        const SizedBox(height: 12),
                        Text(
                          widget.errorMessage!,
                          textAlign: TextAlign.center,
                          style: LbText.body(13),
                        ),
                        const SizedBox(height: 14),
                        TextButton.icon(
                          onPressed: widget.onRetry,
                          icon: const Icon(Icons.refresh_rounded,
                              color: LbColors.forest),
                          label: Text(
                            'Coba lagi',
                            style: LbText.heading(13, weight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (displayItems.isEmpty)
              SliverToBoxAdapter(
                child: LbMuncul(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 48, horizontal: 32),
                    child: Column(
                      children: [
                        LbMelayang(
                          jarak: 4,
                          putar: 0.03,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: LbColors.sageLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.search_off_rounded,
                                size: 34, color: LbColors.sageDeep),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text('Belum ada yang cocok',
                            style: LbText.heading(15, weight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          'Coba sesuaikan saringan atau kata kunci pencarian.',
                          textAlign: TextAlign.center,
                          style: LbText.body(12.5),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: _resetFilter,
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Reset Saringan'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Builder(builder: (_) {
                final tokoList = TokoGroup.kelompokkan(displayItems);
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  sliver: SliverList.separated(
                    itemCount: tokoList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) {
                      final t = tokoList[i];
                      return LbMuncul(
                        key: ValueKey('${t.nama}-${widget.isTernak}-$i'),
                        urutan: i < 6 ? i : 0,
                        jeda: const Duration(milliseconds: 70),
                        dari: const Offset(0, 32),
                        child: KartuToko(
                          toko: t,
                          onTokoTap: widget.onTokoTap == null
                              ? null
                              : () => widget.onTokoTap!(t),
                          onItemTap: widget.onItemTap,
                        ),
                      );
                    },
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
