import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/komponen/animasi_lb.dart';
import '../../../core/komponen/navbar_bawah.dart';
import '../../../core/tema/tema_lb.dart';
import 'model_bahan.dart';
import 'model_toko.dart';
import 'widgets/header_beranda.dart';
import 'widgets/baris_lokasi.dart';
import 'widgets/bilah_pencarian.dart';
import 'widgets/banner_misi.dart';
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
  // Animasi masuk besar hanya sekali per sesi aplikasi, supaya saat pindah
  // mode (dimakan <-> ternak) halaman tidak "reset" dari awal.
  static bool _sudahMasuk = false;
  late final bool _animasi;

  @override
  void initState() {
    super.initState();
    _animasi = !_sudahMasuk;
    _sudahMasuk = true;
  }

  @override
  Widget build(BuildContext context) {
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
            // ---------- HEADER HIJAU ----------
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
                      child: const LbLocationRow(),
                    ),
                    const SizedBox(height: 14),
                    LbMuncul(
                      aktif: _animasi,
                      urutan: 3,
                      child: LbSearchBar(
                        onChanged: widget.onSearch,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---------- BANNER & TOGGLE ----------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LbMuncul(
                      aktif: _animasi,
                      urutan: 4,
                      child: const LbBanner(),
                    ),
                    const SizedBox(height: 18),
                    LbMuncul(
                      aktif: _animasi,
                      urutan: 5,
                      child: LbTypeToggle(
                        isTernak: widget.isTernak,
                        onChanged: widget.onSwitch,
                      ),
                    ),
                    const SizedBox(height: 22),
                    LbMuncul(
                      aktif: _animasi,
                      urutan: 7,
                      child: LbSectionTitle(
                        title: widget.sectionTitle,
                        onLihatPeta: widget.onLihatPeta,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // ---------- ISI DAFTAR ----------
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
            else if (widget.items.isEmpty)
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
                          'Coba ganti kata kunci pencarian.',
                          textAlign: TextAlign.center,
                          style: LbText.body(12.5),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Builder(builder: (_) {
                final tokoList = TokoGroup.kelompokkan(widget.items);
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  sliver: SliverList.separated(
                    itemCount: tokoList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) {
                      final t = tokoList[i];
                      return LbMuncul(
                        // key berubah saat data/mode berubah -> animasi diputar ulang
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