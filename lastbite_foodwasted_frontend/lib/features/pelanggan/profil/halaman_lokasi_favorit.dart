import 'package:flutter/material.dart';
import '../beranda/api_service.dart';
import '../beranda/beranda_widgets.dart';
import 'halaman_bantuan.dart';
import 'profil_widgets.dart';

// ============================================================
// LOKASI AMBIL FAVORIT
// ============================================================
class LokasiFavoritScreen extends StatefulWidget {
  const LokasiFavoritScreen({super.key});

  @override
  State<LokasiFavoritScreen> createState() => _LokasiFavoritScreenState();
}

class _LokasiFavoritScreenState extends State<LokasiFavoritScreen> {
  List<Map<String, dynamic>> _favorit = [];
  bool _loading = true;
  String? _error;
  bool _kelola = false;

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
      final hasil = await ApiService.getMitraFavorit();
      if (!mounted) return;
      setState(() {
        _favorit = hasil;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (_favorit.isEmpty) _error = pkPesanError(e);
      });
      if (senyap) pkSnack(context, pkPesanError(e));
    }
  }

  Future<void> _hapusFavorit(Map<String, dynamic> m) async {
    try {
      await ApiService.hapusMitraFavorit((m['id_mitra'] as num).toInt());
      if (!mounted) return;
      pkSnack(context, '${m['nama']} dihapus dari favorit');
      _muat(senyap: true);
    } catch (e) {
      if (mounted) pkSnack(context, pkPesanError(e));
    }
  }

  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LbColors.offWhite,
      body: SafeArea(
        child: Column(
          children: [
            PkHeader(
              title: 'Lokasi Ambil Favorit',
              trailing: IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BantuanScreen()),
                ),
                icon: const Icon(Icons.help_outline_rounded,
                    color: LbColors.forest, size: 26),
              ),
            ),
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
          _headerMitra(),
          const SizedBox(height: 12),
          if (_favorit.isEmpty)
            _kosongFavorit()
          else
            for (final m in _favorit) ...[
              _kartuMitra(m),
              const SizedBox(height: 12),
            ],
          const SizedBox(height: 10),
          _catatan(),
        ],
      ),
    );
  }

  // ---------- mitra favorit ----------
  Widget _headerMitra() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mitra Ambil Favorit',
                  style: LbText.heading(18, weight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('Titik langganan penyelamatan makananmu',
                  style: LbText.body(12.5)),
            ],
          ),
        ),
        if (_favorit.isNotEmpty)
          GestureDetector(
            onTap: () => setState(() => _kelola = !_kelola),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
              child: Text(_kelola ? 'Selesai' : 'Kelola',
                  style: LbText.heading(13,
                      weight: FontWeight.w700, color: LbColors.forest)),
            ),
          ),
      ],
    );
  }

  Widget _kosongFavorit() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: pkKartuDeco(),
      child: Row(
        children: [
          const Icon(Icons.favorite_border_rounded,
              size: 30, color: LbColors.sageDeep),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Belum ada mitra favorit. Tekan ikon hati di halaman detail paket untuk menyimpannya di sini.',
              style: LbText.body(12.5, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartuMitra(Map<String, dynamic> m) {
    final waktu = '${m['waktu'] ?? ''}'.trim();
    final alamat = '${m['alamat'] ?? ''}'.trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: pkKartuDeco(),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 66,
              height: 66,
              child: LbNetImage(url: '${m['gambar'] ?? ''}'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${m['nama'] ?? ''}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: LbText.heading(14.5, weight: FontWeight.w600, height: 1.25)),
                if (alamat.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(alamat,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LbText.body(12.5,
                          weight: FontWeight.w700, color: LbColors.sageDeep)),
                ],
                if (waktu.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 15, color: LbColors.peachDeep),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text('Biasa ambil jam $waktu',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: LbText.body(11.5, weight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (_kelola)
            GestureDetector(
              onTap: () => _hapusFavorit(m),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: LbColors.peachLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    size: 22, color: LbColors.peachDeep),
              ),
            )
          else
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: LbColors.sageLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_rounded,
                  size: 22, color: LbColors.sageDeep),
            ),
        ],
      ),
    );
  }

  Widget _catatan() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LbColors.sageLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco_outlined, size: 26, color: LbColors.sageDeep),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Menyimpan mitra favorit memudahkanmu menyelamatkan makanan di tempat yang sama dan ikut menghemat emisi karbon.',
              style: LbText.body(12.5, color: LbColors.forest, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}