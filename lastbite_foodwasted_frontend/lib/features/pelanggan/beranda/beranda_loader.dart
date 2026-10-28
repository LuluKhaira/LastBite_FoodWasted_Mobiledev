import 'dart:async';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'beranda_widgets.dart';
import 'filter_preferensi.dart';

/// Lokasi pembeli sementara (Batam Center) sampai fitur GPS dibuat.
const double kLatPembeli = 1.1300;
const double kLngPembeli = 104.0500;

/// Dipakai BerandaScreen & BerandaUntukTernakScreen:
/// ambil data dari API, cari (debounce), dan filter harga/urutan.
///
/// ATURAN KATEGORI UTAMA TOKO:
/// Toko tampil di beranda sesuai jenis produk yang PALING BANYAK ia unggah
/// ('dimakan' atau 'ternak'). Kalau jumlahnya sama, toko masuk 'dimakan'.
/// Toko tetap boleh menjual jenis lain; produk itu ikut tampil di halaman
/// toko, tetapi tokonya tidak pindah beranda.
/// Jumlah dihitung dari SEMUA produk toko (tanpa terpengaruh pencarian/filter).
mixin BerandaLoader<T extends StatefulWidget> on State<T> {
  bool get isTernak;

  String query = '';
  Map<String, dynamic>? filter;
  List<BahanItem> items = [];
  bool loading = true;
  String? error;

  Timer? _debounce;
  int _reqId = 0;

  @override
  void initState() {
    super.initState();
    muatData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// true kalau ada filter yang berbeda dari bawaan (untuk titik penanda).
  bool get filterAktif {
    final f = filter;
    if (f == null) return false;
    return (f['urutan'] ?? 'Rekomendasi') != 'Rekomendasi' ||
        f['tersedia'] == true ||
        (f['harga'] ?? 'Semua Harga') != 'Semua Harga';
  }

  static String _kunciToko(BahanItem it) {
    final p = it.penjual.trim();
    return p.isEmpty ? 'Toko' : p;
  }

  Future<List<BahanItem>> _ambil(String tipe, {required bool polos}) async {
    final data = await ApiService.getProduk(
      tipe: tipe,
      q: polos ? null : query,
      filter: polos ? null : filter,
      lat: kLatPembeli,
      lng: kLngPembeli,
    );
    // tipe dipastikan sesuai permintaan, supaya pengelompokan tidak
    // bergantung pada isi JSON.
    return data.map((j) => BahanItem.fromJson({...j, 'tipe': tipe})).toList();
  }

  static int _angkaHarga(String rp) =>
      int.tryParse(rp.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  Future<void> muatData() async {
    final id = ++_reqId;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final adaSaringan = query.trim().isNotEmpty || filter != null;

      // Daftar lengkap (untuk menghitung kategori utama toko) dan daftar
      // hasil pencarian/filter. Tanpa pencarian/filter keduanya sama.
      final lengkap = await Future.wait([
        _ambil('dimakan', polos: true),
        _ambil('ternak', polos: true),
      ]);
      final hasil = adaSaringan
          ? await Future.wait([
              _ambil('dimakan', polos: false),
              _ambil('ternak', polos: false),
            ])
          : lengkap;

      // Hitung jumlah produk per toko per jenis.
      final nDimakan = <String, int>{};
      final nTernak = <String, int>{};
      for (final it in lengkap[0]) {
        nDimakan[_kunciToko(it)] = (nDimakan[_kunciToko(it)] ?? 0) + 1;
      }
      for (final it in lengkap[1]) {
        // Produk dimakan yang kedaluwarsa lalu dialihkan ke pakan/kompos
        // tetap dihitung sebagai produk "dimakan" (jenis aslinya).
        final m = it.sudahDialihkan ? nDimakan : nTernak;
        m[_kunciToko(it)] = (m[_kunciToko(it)] ?? 0) + 1;
      }

      // DIAGNOSA: lihat di terminal flutter run
      debugPrint('[Beranda] dimakan=$nDimakan | ternak=$nTernak '
          '| beranda=${isTernak ? "ternak" : "dimakan"}');
      debugPrint('[Beranda] produk ternak dari API: '
          '${lengkap[1].map((e) => "${e.nama} (penjual: ${e.penjual})").toList()}');

      bool tokoUtamaTernak(String kunci) =>
          (nTernak[kunci] ?? 0) > (nDimakan[kunci] ?? 0);

      // Jenis sendiri dulu, lalu jenis lain; hanya toko yang kategori
      // utamanya cocok dengan beranda ini.
      final urut = isTernak
          ? [...hasil[1], ...hasil[0]]
          : [...hasil[0], ...hasil[1]];
      final tampil = urut
          .where((it) => tokoUtamaTernak(_kunciToko(it)) == isTernak)
          .toList();

      if ((filter?['urutan'] ?? '') == 'Harga Terendah') {
        tampil.sort(
            (a, b) => _angkaHarga(a.harga).compareTo(_angkaHarga(b.harga)));
      }

      if (!mounted || id != _reqId) return;
      setState(() {
        items = tampil;
        loading = false;
      });
    } catch (e) {
      if (!mounted || id != _reqId) return;
      setState(() {
        items = [];
        loading = false;
        error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void cariTeks(String v) {
    query = v;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), muatData);
  }

  Future<void> bukaFilter() async {
    final hasil = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FilterPreferensiScreen(isTernak: isTernak, initial: filter),
      ),
    );
    if (hasil == null) return; // ditutup tanpa menerapkan
    filter = hasil;
    muatData();
  }
}