import 'package:flutter/material.dart';
import '../../../core/tema/tema_lb.dart';
import 'detail_paket.dart';
import 'model_bahan.dart';
import 'model_toko.dart';
import 'widgets/kartu_paket.dart';

/// Halaman satu toko/mitra/petani: info toko + paketnya,
/// dengan tab kategori ala Shopee yang menempel di atas saat di-scroll.
class TokoScreen extends StatefulWidget {
  final TokoGroup toko;

  const TokoScreen({super.key, required this.toko});

  @override
  State<TokoScreen> createState() => _TokoScreenState();
}

class _TokoScreenState extends State<TokoScreen> {
  static const _semua = 'Semua';
  String _kategori = _semua;

  TokoGroup get toko => widget.toko;

  /// "Semua" + kategori unik yang benar-benar ada di toko ini.
  List<String> get _tabs {
    final unik = <String>[];
    for (final it in toko.items) {
      final k = it.kategori.trim();
      if (k.isNotEmpty && !unik.contains(k)) unik.add(k);
    }
    return [_semua, ...unik];
  }

  List<BahanItem> get _tampil => _kategori == _semua
      ? toko.items
      : toko.items.where((e) => e.kategori.trim() == _kategori).toList();

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs;
    final daftar = _tampil;

    return Scaffold(
      backgroundColor: LbColors.offWhite,
      appBar: AppBar(
        backgroundColor: LbColors.offWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: LbColors.forest),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          toko.nama,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: LbText.heading(16, weight: FontWeight.w700),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ---------- INFO TOKO ----------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: _infoToko(),
            ),
          ),

          // ---------- TAB KATEGORI (menempel) ----------
          if (tabs.length > 2)
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabKategoriDelegate(
                tabs: tabs,
                selected: _kategori,
                onSelected: (k) => setState(() => _kategori = k),
              ),
            ),

          // ---------- DAFTAR PAKET ----------
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  '${daftar.length} paket'
                  '${_kategori == _semua ? ' dari toko ini' : ' · $_kategori'}',
                  style: LbText.heading(14, weight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (daftar.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text('Belum ada paket di kategori ini',
                          style: LbText.body(13)),
                    ),
                  ),
                for (var i = 0; i < daftar.length; i++) ...[
                  BahanCard(
                    item: daftar[i],
                    index: i,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPaketScreen(item: daftar[i]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoToko() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LbColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: LbColors.sageLight,
              shape: BoxShape.circle,
            ),
            child: Text(toko.inisial,
                style: LbText.heading(20, weight: FontWeight.w700)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(toko.nama,
                    style: LbText.heading(16, weight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 16, color: Color(0xFFF5A623)),
                    const SizedBox(width: 3),
                    Text(toko.rating,
                        style: LbText.body(12.5, weight: FontWeight.w700)),
                    Text('  •  ${toko.jarak}  •  ${toko.waktu}',
                        style: LbText.body(12.5)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: LbColors.textGrey),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(toko.alamat,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: LbText.body(12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab kategori bergaya Shopee: teks saja, yang aktif hijau tebal
/// dengan garis bawah. Menempel di bawah AppBar saat di-scroll.
class _TabKategoriDelegate extends SliverPersistentHeaderDelegate {
  final List<String> tabs;
  final String selected;
  final ValueChanged<String> onSelected;

  _TabKategoriDelegate({
    required this.tabs,
    required this.selected,
    required this.onSelected,
  });

  static const double _tinggi = 48;

  @override
  double get minExtent => _tinggi;

  @override
  double get maxExtent => _tinggi;

  @override
  bool shouldRebuild(covariant _TabKategoriDelegate old) =>
      old.selected != selected || old.tabs.length != tabs.length;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: _tinggi,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: LbColors.border),
          bottom: BorderSide(color: LbColors.border),
        ),
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: tabs.length,
        itemBuilder: (context, i) {
          final aktif = tabs[i] == selected;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelected(tabs[i]),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: LbText.heading(
                      13.5,
                      weight: aktif ? FontWeight.w700 : FontWeight.w500,
                      color: aktif ? LbColors.sageDeep : LbColors.textGrey,
                    ),
                    child: Text(tabs[i]),
                  ),
                  const Spacer(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    height: 3,
                    width: aktif ? 26 : 0,
                    decoration: BoxDecoration(
                      color: LbColors.sageDeep,
                      borderRadius: BorderRadius.circular(3),
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