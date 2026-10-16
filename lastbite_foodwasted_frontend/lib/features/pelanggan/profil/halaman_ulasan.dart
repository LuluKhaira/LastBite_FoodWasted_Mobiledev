import 'package:flutter/material.dart';
import '../beranda/api_service.dart';
import '../beranda/beranda_widgets.dart';
import '../beranda/pesanan_model.dart';
import 'profil_widgets.dart';

// ============================================================
// ULASAN & PENILAIAN RESTO
// Dari pesanan berstatus "selesai" (GET /api/pesanan). Bintang disimpan
// lewat POST /api/pesanan/{kode}/rating.
// ============================================================
class UlasanScreen extends StatefulWidget {
  const UlasanScreen({super.key});

  @override
  State<UlasanScreen> createState() => _UlasanScreenState();
}

class _UlasanScreenState extends State<UlasanScreen> {
  List<Pesanan> _selesai = [];
  bool _loading = true;
  String? _error;

  List<Pesanan> get _belum => _selesai.where((p) => p.rating == null).toList();
  List<Pesanan> get _sudah => _selesai.where((p) => p.rating != null).toList();

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat({bool senyap = false}) async {
    if (!senyap) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final d = await ApiService.getPesanan();
      if (!mounted) return;
      setState(() {
        _selesai =
            d.map(Pesanan.fromJson).where((p) => p.status == 'selesai').toList();
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (_selesai.isEmpty) _error = pkPesanError(e);
      });
      if (senyap) pkSnack(context, pkPesanError(e));
    }
  }

  Future<void> _nilai(Pesanan p) async {
    final bintang = await pkBeriBintang(context, judulToko: p.penjual);
    if (bintang == null) return;
    try {
      await ApiService.beriNilai(p.kode, bintang);
      if (!mounted) return;
      pkSnack(context, 'Terima kasih atas penilaianmu!');
      _muat(senyap: true);
    } catch (e) {
      if (mounted) pkSnack(context, pkPesanError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LbColors.offWhite,
      body: SafeArea(
        child: Column(
          children: [
            const PkHeader(title: 'Ulasan & Penilaian Resto'),
            Expanded(child: _isi()),
          ],
        ),
      ),
    );
  }

  Widget _isi() {
    if (_loading) {
      return const Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(strokeWidth: 3, color: LbColors.sageDeep),
        ),
      );
    }
    if (_error != null) return PkError(pesan: _error!, onRetry: _muat);

    return RefreshIndicator(
      color: LbColors.sageDeep,
      onRefresh: () => _muat(senyap: true),
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
        children: [
          if (_selesai.isEmpty) _kosong(),
          if (_belum.isNotEmpty) ...[
            _label('MENUNGGU PENILAIAN', _belum.length),
            for (final p in _belum) ...[_kartu(p), const SizedBox(height: 12)],
          ],
          if (_sudah.isNotEmpty) ...[
            _label('ULASAN SAYA', _sudah.length),
            for (final p in _sudah) ...[_kartu(p), const SizedBox(height: 12)],
          ],
        ],
      ),
    );
  }

  Widget _label(String teks, int n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 14, 0, 10),
      child: Text('$teks ($n)',
          style: LbText.heading(12,
              weight: FontWeight.w700,
              color: LbColors.textGrey,
              letterSpacing: 0.8)),
    );
  }

  Widget _kosong() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.all(24),
      decoration: pkKartuDeco(),
      child: Column(
        children: [
          const Icon(Icons.star_border_rounded,
              size: 42, color: LbColors.sageDeep),
          const SizedBox(height: 10),
          Text('Belum ada pesanan selesai',
              style: LbText.heading(15, weight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            'Setelah pesananmu diambil, kamu bisa memberi bintang untuk resto di sini.',
            textAlign: TextAlign.center,
            style: LbText.body(12.5, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _kartu(Pesanan p) {
    final r = p.rating;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: pkKartuDeco(),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 62,
              height: 62,
              child: LbNetImage(url: p.gambar),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.penjual,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: LbText.heading(14, weight: FontWeight.w600, height: 1.25)),
                const SizedBox(height: 2),
                Text('${p.qty}x ${p.produk}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LbText.body(12.5, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(p.waktuLengkap, style: LbText.body(11.5)),
                const SizedBox(height: 6),
                if (r != null)
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < r ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 20,
                        color: i < r ? LbColors.peach : const Color(0xFFD5D1C7),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => _nilai(p),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: [LbColors.sage, LbColors.sageDeep],
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 16, color: Colors.white),
                          const SizedBox(width: 5),
                          Text('Beri Nilai',
                              style: LbText.heading(12.5,
                                  weight: FontWeight.w600, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}