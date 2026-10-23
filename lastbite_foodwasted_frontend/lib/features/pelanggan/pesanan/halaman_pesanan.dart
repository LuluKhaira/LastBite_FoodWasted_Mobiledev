import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/komponen/navbar_bawah.dart';
import '../../../core/tema/tema_lb.dart';
import '../beranda/api_service.dart';
import '../beranda/lb_nav.dart';
import 'widgets/dialog_pesanan.dart';
import 'widgets/kartu_pesanan.dart';
import 'widgets/kartu_riwayat.dart';
import 'widgets/lembar_nota.dart';
import 'widgets/tab_pesanan.dart';

/// Halaman "Pesanan Saya". Hanya berisi state, pemuatan data, dan aksi.
/// Tampilan dipecah ke folder widgets/.
class PesananScreen extends StatefulWidget {
  /// true  = halaman ini menampilkan navbar sendiri (dibuka lewat push).
  /// false = dipakai di dalam CangkangUtama (navbar sudah ada di cangkang).
  final bool denganNavbar;

  const PesananScreen({super.key, this.denganNavbar = true});
  @override
  State<PesananScreen> createState() => _PesananScreenState();
}

class _PesananScreenState extends State<PesananScreen> {
  List<Map<String, dynamic>> _data = [];
  bool _loading = true;
  int _tab = 0; // 0 aktif, 1 riwayat
  Timer? _timer;
  bool _menyegarkan = false;

  @override
  void initState() {
    super.initState();
    _muat();
    // Polling status tiap 6 detik agar update dari Mitra langsung terefleksi
    _timer =
        Timer.periodic(const Duration(seconds: 6), (_) => _muat(diam: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _muat({bool diam = false}) async {
    try {
      final d = await ApiService.getPesanan();
      if (mounted) {
        setState(() {
          _data = d;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted && !diam) {
        setState(() => _loading = false);
        _snack(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _segarkan() async {
    if (_menyegarkan) return;
    setState(() => _menyegarkan = true);
    await _muat();
    if (!mounted) return;
    setState(() => _menyegarkan = false);
    _snack('Pesanan diperbarui');
  }

  void _snack(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: LbColors.forest,
          content: Text(t, style: LbText.body(13, color: Colors.white))));
  }

  bool _aktif(Map p) =>
      (p['status'] == 'menunggu' ||
          p['status'] == 'siap' ||
          p['status'] == 'WAITING_PREPARATION' ||
          p['status'] == 'READY_FOR_PICKUP') &&
      (p['status_bayar'] == 'lunas' ||
          p['status_bayar'] == 'menunggu' ||
          p['status_bayar'] == 'belum');

  List<Map<String, dynamic>> get _aktifList => _data.where(_aktif).toList();
  List<Map<String, dynamic>> get _riwayatList =>
      _data.where((p) => !_aktif(p)).toList();

  @override
  Widget build(BuildContext context) {
    final list = _tab == 0 ? _aktifList : _riwayatList;

    return Scaffold(
      backgroundColor: LbColors.offWhite,
      bottomNavigationBar: widget.denganNavbar
          ? LbBottomNav(
              currentIndex: 1,
              onTap: (i) {
                if (i != 1) LbNav.go(context, from: 1, to: i);
              },
            )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _muat(),
          color: LbColors.forest,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pesanan Saya',
                            style: LbText.heading(24, weight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('Pantau status dan pengambilan paket makananmu',
                            style: LbText.body(13)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _tombolSegarkan(),
                ],
              ),
              const SizedBox(height: 16),
              TabPesanan(
                tab: _tab,
                jumlahAktif: _aktifList.length,
                jumlahRiwayat: _riwayatList.length,
                onGanti: (i) => setState(() => _tab = i),
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                        child: CircularProgressIndicator(
                            color: LbColors.forest)))
              else if (list.isEmpty)
                _kosong()
              else
                for (final p in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _tab == 0
                        ? KartuPesananAktif(
                            p: p,
                            onMaps: () => _bukaMaps(p),
                            onHubungi: () => _hubungi(p),
                            onBayar: () => _bayar(p),
                            onCek: () => _cekBayar(p),
                            onBatal: () => _batal(p),
                            onDisalin: (kode) => _snack(
                                'Kode pengambilan $kode berhasil disalin'),
                          )
                        : KartuRiwayat(
                            p: p,
                            onNota: () => tampilLembarNota(context, p),
                            onNilai: () => _beriNilai(p),
                          ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tombolSegarkan() => GestureDetector(
        onTap: _segarkan,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: LbColors.border),
          ),
          child: _menyegarkan
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: LbColors.sageDeep,
                  ),
                )
              : const Icon(Icons.refresh_rounded,
                  color: LbColors.forest, size: 24),
        ),
      );

  Widget _kosong() => Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(
                _tab == 0
                    ? Icons.takeout_dining_outlined
                    : Icons.history_rounded,
                size: 48,
                color: LbColors.textGrey.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 10),
              Text(
                _tab == 0
                    ? 'Belum ada pesanan aktif'
                    : 'Belum ada riwayat pesanan',
                style: LbText.body(14),
              ),
            ],
          ),
        ),
      );

  // ---------------- AKSI PENGGUNA ----------------
  Future<void> _bayar(Map p) async {
    try {
      final url = await ApiService.buatPembayaran('${p['kode']}');
      await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _cekBayar(Map p) async {
    try {
      final s = await ApiService.cekBayar('${p['kode']}');
      _snack(s == 'lunas'
          ? 'Pembayaran lunas! Toko segera menyiapkan pesanan.'
          : 'Status pembayaran: $s');
      _muat();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _bukaMaps(Map p) async {
    final lat = p['lat'], lng = p['lng'];
    final uri = (lat != null && lng != null)
        ? Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng')
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('${p['alamat']}')}');
    await launchUrl(uri, webOnlyWindowName: '_blank');
  }

  Future<void> _hubungi(Map p) async {
    var no = '${p['telp_toko'] ?? ''}'.replaceAll(RegExp(r'[^0-9]'), '');
    if (no.isEmpty) return _snack('Nomor telepon toko belum tersedia');
    if (no.startsWith('0')) no = '62${no.substring(1)}';
    await launchUrl(Uri.parse('https://wa.me/$no'),
        webOnlyWindowName: '_blank');
  }

  Future<void> _batal(Map p) async {
    final ya = await dialogKonfirmasiBatal(context, p['total'] as int);
    if (!ya) return;
    try {
      await ApiService.batalPesanan('${p['kode']}');
      _snack('Pesanan berhasil dibatalkan. Dana dikembalikan penuh.');
      _muat();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _beriNilai(Map p) async {
    final n = await dialogBeriNilai(context, '${p['penjual']}');
    if (n == null) return;
    try {
      await ApiService.beriNilai('${p['kode']}', n);
      _snack('Terima kasih atas ulasanmu!');
      _muat();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
