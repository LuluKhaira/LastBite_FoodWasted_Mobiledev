import 'package:flutter/material.dart';

import '../beranda/api_service.dart';
import '../beranda/beranda_widgets.dart';
import '../beranda/lb_nav.dart';
import 'kartu_favorit.dart';
import 'model_favorit.dart';

/// Tab "Favorit": daftar toko yang disimpan pelanggan.
class FavoritScreen extends StatefulWidget {
  const FavoritScreen({super.key});

  @override
  State<FavoritScreen> createState() => _FavoritScreenState();
}

class _FavoritScreenState extends State<FavoritScreen> {
  List<TokoFavorit> _toko = [];
  bool _loading = true;
  String? _error;
  DateTime? _diperbarui;

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
      final data = await ApiService.getMitraFavorit();
      if (!mounted) return;
      setState(() {
        _toko = data.map(TokoFavorit.dariJson).toList();
        _diperbarui = DateTime.now();
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _snack(String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: LbColors.forest,
          content: Text(pesan, style: LbText.body(13, color: Colors.white)),
        ),
      );
  }

  Future<void> _hapus(TokoFavorit t) async {
    final posisi = _toko.indexOf(t);
    if (posisi < 0) return;
    setState(() => _toko.removeAt(posisi)); // langsung hilang dari layar
    try {
      await ApiService.hapusMitraFavorit(t.idMitra);
      _snack('${t.nama} dihapus dari favorit');
    } catch (e) {
      if (!mounted) return;
      setState(() => _toko.insert((posisi.clamp(0, _toko.length) as int), t));
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _buka(TokoFavorit t) {
    // Detail paket dibuka dari Beranda; di sini arahkan pelanggan ke sana.
    _snack('Pilih paket ${t.nama} di Beranda untuk memesan');
    LbNav.go(context, from: 2, to: 0);
  }

  void _ingatkan(TokoFavorit t) {
    _snack('Kami ingatkan saat ${t.nama} punya paket lagi');
  }

  String get _labelDiperbarui {
    final d = _diperbarui;
    if (d == null) return 'Memuat…';
    final menit = DateTime.now().difference(d).inMinutes;
    if (menit < 1) return 'Diperbarui baru saja';
    if (menit < 60) return 'Diperbarui $menit menit lalu';
    return 'Diperbarui ${menit ~/ 60} jam lalu';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LbColors.offWhite,
      bottomNavigationBar: LbBottomNav(
        currentIndex: 2,
        onTap: (i) => LbNav.go(context, from: 2, to: i),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: LbColors.sageDeep,
          onRefresh: () => _muat(senyap: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            children: [
              const LbHeader(title: 'Favorit'),
              const SizedBox(height: 18),
              _ringkasan(),
              const SizedBox(height: 14),
              ..._isi(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ringkasan() {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${_toko.length} Toko Tersimpan',
            style: LbText.heading(16, weight: FontWeight.w700),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: LbColors.sageLight,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.autorenew_rounded,
                  size: 14, color: LbColors.sageDeep),
              const SizedBox(width: 5),
              Text(
                _labelDiperbarui,
                style: LbText.body(11.5,
                    weight: FontWeight.w700, color: LbColors.forest),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _isi() {
    if (_loading) {
      return const [
        Padding(
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
      ];
    }

    if (_error != null) {
      return [
        _pesanTengah(
          ikon: Icons.cloud_off_rounded,
          judul: 'Gagal memuat favorit',
          isi: _error!,
          tombol: TextButton.icon(
            onPressed: _muat,
            icon: const Icon(Icons.refresh_rounded, color: LbColors.forest),
            label: Text('Coba lagi',
                style: LbText.heading(13, weight: FontWeight.w600)),
          ),
        ),
      ];
    }

    if (_toko.isEmpty) {
      return [
        _pesanTengah(
          ikon: Icons.favorite_border_rounded,
          judul: 'Belum ada toko favorit',
          isi: 'Tap ikon hati di halaman paket untuk menyimpan toko kesukaanmu.',
        ),
      ];
    }

    return [
      for (final t in _toko) ...[
        KartuFavorit(
          key: ValueKey(t.idMitra),
          toko: t,
          onBuka: () => _buka(t),
          onIngatkan: () => _ingatkan(t),
          onHapus: () => _hapus(t),
        ),
        const SizedBox(height: 14),
      ],
    ];
  }

  Widget _pesanTengah({
    required IconData ikon,
    required String judul,
    required String isi,
    Widget? tombol,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: LbColors.sageLight,
              shape: BoxShape.circle,
            ),
            child: Icon(ikon, size: 34, color: LbColors.sageDeep),
          ),
          const SizedBox(height: 14),
          Text(judul, style: LbText.heading(15, weight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(isi, textAlign: TextAlign.center, style: LbText.body(12.5)),
          if (tombol != null) ...[const SizedBox(height: 10), tombol],
        ],
      ),
    );
  }
}