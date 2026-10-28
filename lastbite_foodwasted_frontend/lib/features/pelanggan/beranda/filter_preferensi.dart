import 'package:flutter/material.dart';
import '../../../core/tema/tema_lb.dart';

/// Filter beranda: fokus ke urutan & harga saja.
/// (Kategori dipindah ke halaman toko, jarak dihapus.)
class FilterPreferensiScreen extends StatefulWidget {
  final bool isTernak;

  /// Filter yang sedang aktif (hasil pop sebelumnya) supaya pilihan tetap
  /// tampil saat layar ini dibuka lagi.
  final Map<String, dynamic>? initial;

  const FilterPreferensiScreen({
    super.key,
    required this.isTernak,
    this.initial,
  });

  @override
  State<FilterPreferensiScreen> createState() => _FilterPreferensiScreenState();
}

class _FilterPreferensiScreenState extends State<FilterPreferensiScreen> {
  static const _urutanList = ['Rekomendasi', 'Harga Terendah'];
  static const _hargaList = [
    'Semua Harga',
    'Di bawah Rp25.000',
    'Rp25.000–Rp50.000',
    'Di atas Rp50.000',
  ];

  String urutan = 'Rekomendasi';
  bool tersedia = false;
  String harga = 'Semua Harga';

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      final u = (i['urutan'] ?? urutan).toString();
      urutan = _urutanList.contains(u) ? u : 'Rekomendasi';
      tersedia = i['tersedia'] == true;
      harga = (i['harga'] ?? harga).toString();
    }
  }

  void reset() => setState(() {
        urutan = 'Rekomendasi';
        tersedia = false;
        harga = 'Semua Harga';
      });

  @override
  Widget build(BuildContext context) {
    final title =
        widget.isTernak ? 'Filter Ternak & Pupuk' : 'Filter Untuk Dimakan';

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
        title: Text(title, style: LbText.heading(18, weight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: reset,
            child: Text('Reset',
                style: LbText.heading(13.5,
                    weight: FontWeight.w600, color: LbColors.sageDeep)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _heading('Urutkan berdasarkan'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in _urutanList)
                _choice(item, urutan == item,
                    () => setState(() => urutan = item)),
            ],
          ),
          const SizedBox(height: 28),
          _heading('Rentang harga'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in _hargaList)
                _choice(item, harga == item, () => setState(() => harga = item)),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: LbColors.border),
            ),
            child: SwitchListTile(
              value: tersedia,
              activeColor: Colors.white,
              activeTrackColor: LbColors.sageDeep,
              onChanged: (v) => setState(() => tersedia = v),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              title: Text(
                widget.isTernak
                    ? 'Hanya yang masih tersedia'
                    : 'Hanya makanan yang masih tersedia',
                style: LbText.heading(13.5, weight: FontWeight.w600),
              ),
              subtitle: Text(
                'Sembunyikan produk yang sudah habis',
                style: LbText.body(12),
              ),
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => Navigator.pop(context, {
              'urutan': urutan,
              'tersedia': tersedia,
              'harga': harga,
            }),
            child: Container(
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [LbColors.sage, LbColors.sageDeep],
                ),
                boxShadow: [
                  BoxShadow(
                    color: LbColors.sage.withValues(alpha: 0.45),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                'Terapkan Filter',
                style: LbText.heading(15,
                    weight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heading(String title) =>
      Text(title, style: LbText.heading(15, weight: FontWeight.w700));

  Widget _choice(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? LbColors.sageDeep : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? LbColors.sageDeep : LbColors.border,
          ),
        ),
        child: Text(
          label,
          style: LbText.body(
            12.5,
            weight: FontWeight.w700,
            color: selected ? Colors.white : LbColors.forest,
          ),
        ),
      ),
    );
  }
}