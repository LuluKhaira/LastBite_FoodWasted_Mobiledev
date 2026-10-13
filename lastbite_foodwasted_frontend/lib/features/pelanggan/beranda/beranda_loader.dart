import 'dart:async';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'beranda_widgets.dart';
import 'filter_preferensi.dart';

/// Lokasi pembeli sementara (Batam Center) sampai fitur GPS dibuat.
const double kLatPembeli = 1.1300;
const double kLngPembeli = 104.0500;

/// Dipakai BerandaScreen & BerandaUntukTernakScreen:
/// ambil data dari API, cari (debounce), kategori, dan filter.
mixin BerandaLoader<T extends StatefulWidget> on State<T> {
  bool get isTernak;
  List<LbKategori> get kategoriList;

  int kategoriIndex = 0;
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
        ((f['jarak'] as num?) ?? 10) < 10 ||
        f['tersedia'] == true ||
        (f['harga'] ?? 'Semua Harga') != 'Semua Harga' ||
        ((f['kategori'] as List?) ?? const []).isNotEmpty;
  }

  List<String>? _kategoriEfektif() {
    final fk = List<String>.from((filter?['kategori'] as List?) ?? const []);
    if (fk.isNotEmpty) return fk;
    if (kategoriIndex > 0) return [kategoriList[kategoriIndex].label];
    return null;
  }

  Future<void> muatData() async {
    final id = ++_reqId;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final data = await ApiService.getProduk(
        tipe: isTernak ? 'ternak' : 'dimakan',
        kategori: _kategoriEfektif(),
        q: query,
        filter: filter,
        lat: kLatPembeli,
        lng: kLngPembeli,
      );
      if (!mounted || id != _reqId) return;
      setState(() {
        items = data.map(BahanItem.fromJson).toList();
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

  void pilihKategori(int i) {
    kategoriIndex = i;
    // memilih chip kategori menggantikan kategori dari layar filter
    if (filter != null) filter = {...filter!, 'kategori': <String>[]};
    muatData();
  }

  Future<void> bukaFilter() async {
    final hasil = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => FilterPreferensiScreen(isTernak: isTernak, initial: filter),
      ),
    );
    if (hasil == null) return; // ditutup tanpa menerapkan
    filter = hasil;

    final kat = List<String>.from((hasil['kategori'] as List?) ?? const []);
    final idx = kat.length == 1
        ? kategoriList.indexWhere((k) => k.label == kat.first)
        : -1;
    setState(() => kategoriIndex = idx > 0 ? idx : 0);
    muatData();
  }
}