import 'package:flutter/material.dart';
import 'beranda_widgets.dart';
import 'pesanan_model.dart';
import 'nota_pesanan.dart';
import 'lb_nav.dart';

class PesananScreen extends StatefulWidget {
  const PesananScreen({super.key});

  @override
  State<PesananScreen> createState() => _PesananScreenState();
}

class _PesananScreenState extends State<PesananScreen> {
  int _tab = 1; // 0 = Aktif, 1 = Riwayat
  final List<Pesanan> _riwayat = daftarPesanan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LbColors.offWhite,
      bottomNavigationBar: LbBottomNav(
        currentIndex: 1,
        onTap: (i) => LbNav.go(context, from: 1, to: i),
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
                    const LbHeader(title: 'Pesanan'),
                    const SizedBox(height: 20),
                    _titleRow(),
                    const SizedBox(height: 16),
                    _tabs(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (_tab == 1)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                sliver: SliverList.separated(
                  itemCount: _riwayat.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, i) {
                    final p = _riwayat[i];
                    return _PesananCard(
                      p: p,
                      onNota: () => showNotaPesanan(
                        context,
                        p,
                        onPesanLagi: () =>
                            LbNav.go(context, from: 1, to: 0),
                      ),
                      onAksi: () {
                        if (p.baru) {
                          _showRating(p);
                        } else {
                          LbNav.go(context, from: 1, to: 0);
                        }
                      },
                    );
                  },
                ),
              )
            else
              SliverToBoxAdapter(child: _emptyAktif()),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // JUDUL + BANTUAN
  // ============================================================
  Widget _titleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pesanan Saya',
                style: LbText.heading(25, weight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                'Kelola penyelamatan makanan aktifmu',
                style: LbText.body(13),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: LbColors.forest,
                content: Text(
                  'Pusat bantuan segera hadir',
                  style: LbText.body(13, color: Colors.white),
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: LbColors.sageLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.headset_mic_outlined,
                  size: 19,
                  color: LbColors.forest,
                ),
                const SizedBox(width: 7),
                Text(
                  'Bantuan',
                  style: LbText.heading(13, weight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TAB AKTIF / RIWAYAT
  // ============================================================
  Widget _tabs() {
    Widget item(int i, String label, {int? count}) {
      final active = _tab == i;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _tab = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: active
                    ? const [LbColors.sage, LbColors.sageDeep]
                    : const [Colors.transparent, Colors.transparent],
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: LbColors.sage.withValues(alpha: 0.45),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: LbText.heading(
                    14,
                    weight: FontWeight.w600,
                    color: active ? Colors.white : LbColors.forest,
                  ),
                ),
                if (count != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : LbColors.sageDeep,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$count',
                      style: LbText.heading(
                        11.5,
                        weight: FontWeight.w700,
                        color: active ? LbColors.sageDeep : Colors.white,
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

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: LbColors.border),
      ),
      child: Row(
        children: [
          item(0, 'Aktif', count: 0),
          item(1, 'Riwayat', count: _riwayat.length),
        ],
      ),
    );
  }

  Widget _emptyAktif() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: LbColors.sageLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 40,
              color: LbColors.sageDeep,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada pesanan aktif',
            style: LbText.heading(16, weight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Yuk selamatkan makanan di sekitarmu dan kurangi food waste hari ini.',
            textAlign: TextAlign.center,
            style: LbText.body(13, height: 1.4),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => LbNav.go(context, from: 1, to: 0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [LbColors.sage, LbColors.sageDeep],
                ),
                boxShadow: [
                  BoxShadow(
                    color: LbColors.sage.withValues(alpha: 0.45),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                'Cari Makanan',
                style: LbText.heading(
                  14,
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BERI NILAI
  // ============================================================
  void _showRating(Pesanan p) {
    int stars = 5;
    final pageContext = context;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setS) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
              decoration: const BoxDecoration(
                color: LbColors.offWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: LbColors.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Beri Nilai Pesananmu',
                      style: LbText.heading(18, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.penjual,
                      textAlign: TextAlign.center,
                      style: LbText.body(13),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final on = i < stars;
                        return GestureDetector(
                          onTap: () => setS(() => stars = i + 1),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              on
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 42,
                              color: on
                                  ? LbColors.peach
                                  : const Color(0xFFD5D1C7),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 22),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(pageContext).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: LbColors.forest,
                            content: Text(
                              'Terima kasih atas penilaianmu!',
                              style: LbText.body(13, color: Colors.white),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                            colors: [LbColors.sage, LbColors.sageDeep],
                          ),
                        ),
                        child: Text(
                          'Kirim Penilaian',
                          style: LbText.heading(
                            15,
                            weight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ============================================================
// KARTU PESANAN
// ============================================================
class _PesananCard extends StatelessWidget {
  final Pesanan p;
  final VoidCallback onNota;
  final VoidCallback onAksi;

  const _PesananCard({
    required this.p,
    required this.onNota,
    required this.onAksi,
  });

  Widget _button({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required Color fg,
    Color? bg,
    bool gradient = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: gradient ? null : bg,
          gradient: gradient
              ? const LinearGradient(
                  colors: [LbColors.sage, LbColors.sageDeep],
                )
              : null,
          borderRadius: BorderRadius.circular(22),
          boxShadow: gradient
              ? [
                  BoxShadow(
                    color: LbColors.sage.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 6),
            Text(
              label,
              style: LbText.heading(13, weight: FontWeight.w600, color: fg),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: LbColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- atas: foto + info ----------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 66,
                        height: 66,
                        child: LbNetImage(url: p.gambar),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                size: 15,
                                color: LbColors.textGrey,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  p.waktuLengkap,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: LbText.body(
                                    12.5,
                                    weight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (!p.baru) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: LbColors.sageLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_rounded,
                                        size: 14,
                                        color: LbColors.sageDeep,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        'Selesai',
                                        style: LbText.body(
                                          11.5,
                                          weight: FontWeight.w800,
                                          color: LbColors.sageDeep,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: p.baru ? 10 : 6),
                          Text(
                            p.penjual,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: LbText.heading(
                              15,
                              weight: FontWeight.w600,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${p.qty}x ${p.produk}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: LbText.body(13, weight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ---------- dampak lingkungan ----------
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF5E2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        p.baru ? Icons.eco_rounded : Icons.park_outlined,
                        size: 18,
                        color: LbColors.sageDeep,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cegah ${p.co2} kg CO₂e • ${p.makanan} kg Makanan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LbText.body(
                            12.5,
                            weight: FontWeight.w800,
                            color: LbColors.forest,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ---------- total + tombol ----------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.baru ? 'Total Pembayaran' : 'Total',
                            style: LbText.body(12, weight: FontWeight.w800),
                          ),
                          const SizedBox(height: 1),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              lbRp(p.total),
                              style: LbText.heading(
                                20,
                                weight: FontWeight.w700,
                                color: p.baru
                                    ? LbColors.sageDeep
                                    : LbColors.forest,
                              ),
                            ),
                          ),
                          if (p.baru)
                            Text(
                              '${p.metode} • Lunas',
                              style: LbText.body(11.5, weight: FontWeight.w700),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _button(
                      label: 'Nota',
                      icon: Icons.receipt_long_outlined,
                      onTap: onNota,
                      fg: LbColors.forest,
                      bg: LbColors.sageLight,
                    ),
                    const SizedBox(width: 8),
                    if (p.baru)
                      _button(
                        label: 'Beri Nilai',
                        icon: Icons.star_rounded,
                        onTap: onAksi,
                        fg: Colors.white,
                        gradient: true,
                      )
                    else
                      _button(
                        label: 'Pesan Lagi',
                        icon: Icons.replay_rounded,
                        onTap: onAksi,
                        fg: LbColors.forest,
                        bg: LbColors.sage.withValues(alpha: 0.3),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // ---------- pita "Baru Selesai" ----------
          if (p.baru)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  color: LbColors.peach,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      size: 15,
                      color: LbColors.forest,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Baru Selesai',
                      style: LbText.heading(
                        11.5,
                        weight: FontWeight.w600,
                        color: LbColors.forest,
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