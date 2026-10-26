import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../beranda/api_service.dart';
import '../../../core/tema/tema_lb.dart';
import 'pesanan_model.dart';
import 'widgets/kartu_bintang_nilai.dart';
import 'widgets/kartu_catatan_ulasan.dart';
import 'widgets/kartu_foto_ulasan.dart';
import 'widgets/kartu_toko_nilai.dart';

/// Halaman "Beri Nilai" (satu layar penuh, menggantikan dialog lama).
/// Pop dengan hasil `true` kalau penilaian berhasil terkirim.
class HalamanBeriNilai extends StatefulWidget {
  final String kode;
  final String penjual;
  final String alamat;
  final String produk;
  final String gambar;
  final int qty;
  final int hargaSatuan;
  final int hargaAsliSatuan;

  const HalamanBeriNilai({
    super.key,
    required this.kode,
    required this.penjual,
    required this.alamat,
    required this.produk,
    required this.gambar,
    required this.qty,
    required this.hargaSatuan,
    required this.hargaAsliSatuan,
  });

  /// Untuk data mentah dari API (dipakai di halaman Pesanan -> tab Riwayat).
  factory HalamanBeriNilai.dariMap(Map p) {
    int i(dynamic v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
    return HalamanBeriNilai(
      kode: '${p['kode'] ?? ''}',
      penjual: '${p['penjual'] ?? ''}',
      alamat: '${p['alamat'] ?? ''}',
      produk: '${p['produk'] ?? ''}',
      gambar: '${p['gambar'] ?? ''}',
      qty: i(p['qty']) == 0 ? 1 : i(p['qty']),
      hargaSatuan: i(p['harga_satuan']),
      hargaAsliSatuan: i(p['harga_asli_satuan']),
    );
  }

  /// Untuk model [Pesanan] (dipakai di halaman Ulasan & Penilaian Resto).
  factory HalamanBeriNilai.dariPesanan(Pesanan p) => HalamanBeriNilai(
        kode: p.kode,
        penjual: p.penjual,
        alamat: p.alamat,
        produk: p.produk,
        gambar: p.gambar,
        qty: p.qty,
        hargaSatuan: p.hargaSatuan,
        hargaAsliSatuan: p.hargaAsliSatuan,
      );

  @override
  State<HalamanBeriNilai> createState() => _HalamanBeriNilaiState();
}

class _HalamanBeriNilaiState extends State<HalamanBeriNilai> {
  int _bintang = 0;
  final Set<String> _tag = {};
  final TextEditingController _ulasan = TextEditingController();
  final List<XFile> _foto = [];
  bool _mengirim = false;

  @override
  void dispose() {
    _ulasan.dispose();
    super.dispose();
  }

  void _snack(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: LbColors.forest,
        content: Text(t, style: LbText.body(13, color: Colors.white)),
      ));
  }

  Future<void> _pilihFoto() async {
    if (_foto.length >= KartuFotoUlasan.maks) return;
    try {
      final x = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1280,
      );
      if (x != null && mounted) setState(() => _foto.add(x));
    } catch (_) {
      _snack('Tidak bisa membuka galeri.');
    }
  }

  Future<void> _kirim() async {
    if (_mengirim) return;
    if (_bintang == 0) {
      _snack('Pilih bintang dulu ya.');
      return;
    }
    setState(() => _mengirim = true);
    try {
      await ApiService.beriNilaiLengkap(
        kode: widget.kode,
        rating: _bintang,
        ulasan: _ulasan.text.trim(),
        tag: _tag.toList(),
        foto: _foto,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _mengirim = false);
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LbColors.offWhite,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                children: [
                  _barisStatus(),
                  const SizedBox(height: 14),
                  KartuTokoNilai(
                    penjual: widget.penjual,
                    alamat: widget.alamat,
                    produk: widget.produk,
                    gambar: widget.gambar,
                    qty: widget.qty,
                    hargaSatuan: widget.hargaSatuan,
                    hargaAsliSatuan: widget.hargaAsliSatuan,
                  ),
                  const SizedBox(height: 14),
                  KartuBintangNilai(
                    bintang: _bintang,
                    onBintang: (n) => setState(() => _bintang = n),
                    tag: _tag,
                    onTag: (t) => setState(
                        () => _tag.contains(t) ? _tag.remove(t) : _tag.add(t)),
                  ),
                  const SizedBox(height: 14),
                  KartuCatatanUlasan(controller: _ulasan),
                  const SizedBox(height: 14),
                  KartuFotoUlasan(
                    foto: _foto,
                    onTambah: _pilihFoto,
                    onHapus: (i) => setState(() => _foto.removeAt(i)),
                  ),
                ],
              ),
            ),
            _tombolKirim(),
          ],
        ),
      ),
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
        child: Row(
          children: [
            IconButton(
              onPressed: _mengirim ? null : () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded,
                  color: LbColors.forest),
            ),
            const SizedBox(width: 4),
            Text('Beri Nilai',
                style: LbText.heading(20,
                    weight: FontWeight.w700, color: LbColors.forest)),
          ],
        ),
      );

  Widget _barisStatus() => Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text('Pesanan #${widget.kode}',
                style: LbText.heading(12.5,
                    weight: FontWeight.w700, color: LbColors.forest)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: LbColors.sage.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded,
                    size: 15, color: LbColors.sageDeep),
                const SizedBox(width: 5),
                Text('Selesai',
                    style: LbText.heading(12.5,
                        weight: FontWeight.w700, color: LbColors.sageDeep)),
              ],
            ),
          ),
        ],
      );

  Widget _tombolKirim() {
    final aktif = _bintang > 0 && !_mengirim;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: LbColors.offWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: aktif ? 1 : 0.55,
            child: GestureDetector(
              onTap: _kirim,
              child: Container(
                width: double.infinity,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [LbColors.sage, LbColors.sageDeep],
                  ),
                ),
                child: _mengirim
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome_rounded,
                              size: 20, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('Kirim Penilaian',
                              style: LbText.heading(16,
                                  weight: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield_outlined,
                  size: 14, color: LbColors.textGrey),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Ulasanmu membantu UMKM lokal Batam berkembang.',
                  textAlign: TextAlign.center,
                  style: LbText.body(11.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}