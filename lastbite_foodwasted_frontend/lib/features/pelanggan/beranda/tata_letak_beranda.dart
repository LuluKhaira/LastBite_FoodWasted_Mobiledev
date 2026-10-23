import 'package:flutter/material.dart';
import '../../../core/komponen/navbar_bawah.dart';
import '../../../core/tema/tema_lb.dart';
import 'model_bahan.dart';
import 'widgets/header_beranda.dart';
import 'widgets/baris_lokasi.dart';
import 'widgets/bilah_pencarian.dart';
import 'widgets/banner_misi.dart';
import 'widgets/toggle_tipe.dart';
import 'widgets/bilah_kategori.dart';
import 'widgets/judul_seksi.dart';
import 'widgets/kartu_paket.dart';

/// Layout halaman beranda (dipakai mode dimakan & ternak).
/// Navbar hanya tampil bila [onNavTap] diisi. Di dalam CangkangUtama,
/// JANGAN isi onNavTap karena navbar sudah ada di cangkang.
class BerandaLayout extends StatefulWidget {
  final bool isTernak;
  final ValueChanged<bool> onSwitch; // true = pindah ke ternak
  final List<LbKategori> kategori;
  final int selectedKategori;
  final ValueChanged<int> onKategori;
  final String sectionTitle;
  final List<BahanItem> items;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onLihatPeta;
  final ValueChanged<int>? onNavTap;
  final ValueChanged<BahanItem>? onItemTap;
  final VoidCallback? onFilter;
  final bool filterAktif;
  final bool loading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const BerandaLayout({
    super.key,
    required this.isTernak,
    required this.onSwitch,
    required this.kategori,
    required this.selectedKategori,
    required this.onKategori,
    required this.sectionTitle,
    required this.items,
    this.onSearch,
    this.onLihatPeta,
    this.onNavTap,
    this.onItemTap,
    this.onFilter,
    this.filterAktif = false,
    this.loading = false,
    this.errorMessage,
    this.onRetry,
  });

  @override
  State<BerandaLayout> createState() => _BerandaLayoutState();
}

class _BerandaLayoutState extends State<BerandaLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LbColors.offWhite,
      bottomNavigationBar: widget.onNavTap == null
          ? null
          : LbBottomNav(
              currentIndex: 0,
              onTap: (i) => widget.onNavTap!(i),
            ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LbHeader(),
                    const SizedBox(height: 16),
                    const LbLocationRow(),
                    const SizedBox(height: 14),
                    LbSearchBar(
                      onChanged: widget.onSearch,
                      onFilter: widget.onFilter,
                      filterAktif: widget.filterAktif,
                    ),
                    const SizedBox(height: 18),
                    const LbBanner(),
                    const SizedBox(height: 18),
                    LbTypeToggle(
                      isTernak: widget.isTernak,
                      onChanged: widget.onSwitch,
                    ),
                    const SizedBox(height: 16),
                    LbKategoriBar(
                      kategori: widget.kategori,
                      selected: widget.selectedKategori,
                      onSelected: widget.onKategori,
                    ),
                    const SizedBox(height: 22),
                    LbSectionTitle(
                      title: widget.sectionTitle,
                      onLihatPeta: widget.onLihatPeta,
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
            if (widget.loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 56),
                  child: Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: LbColors.sageDeep,
                      ),
                    ),
                  ),
                ),
              )
            else if (widget.errorMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
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
              )
            else if (widget.items.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: LbColors.sageLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.search_off_rounded,
                            size: 34, color: LbColors.sageDeep),
                      ),
                      const SizedBox(height: 14),
                      Text('Belum ada yang cocok',
                          style: LbText.heading(15, weight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        'Coba ganti kata kunci, kategori, atau filter lain.',
                        textAlign: TextAlign.center,
                        style: LbText.body(12.5),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                sliver: SliverList.separated(
                  itemCount: widget.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, i) => BahanCard(
                    item: widget.items[i],
                    index: i,
                    onTap: widget.onItemTap == null
                        ? null
                        : () => widget.onItemTap!(widget.items[i]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
