import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'base_card.dart';
import 'warna_lokal.dart';

class PengalihanSectionCard extends StatelessWidget {
  final bool bersedia;
  final ValueChanged<bool> onBersediaChanged;
  final String? targetKategori;
  final ValueChanged<String?> onTargetKategoriChanged;
  final TextEditingController? beratPerPaketCtrl;
  final List<Map<String, dynamic>> opsiKategori;

  const PengalihanSectionCard({
    super.key,
    required this.bersedia,
    required this.onBersediaChanged,
    required this.targetKategori,
    required this.onTargetKategoriChanged,
    this.beratPerPaketCtrl,
    this.opsiKategori = const [],
  });

  static const List<Map<String, dynamic>> _opsiDefault = [
    {'kategori': 'Pakan Ternak & Ikan', 'tipe': 'pakan', 'harga_per_kg': 5000},
    {'kategori': 'Bahan Kompos & Pupuk', 'tipe': 'kompos', 'harga_per_kg': 3000},
    {'kategori': 'Ampas Kelapa & Kopi', 'tipe': 'kompos', 'harga_per_kg': 2500},
    {'kategori': 'Limbah Organik', 'tipe': 'kompos', 'harga_per_kg': 2000},
  ];

  List<Map<String, dynamic>> get _listOpsi =>
      opsiKategori.isNotEmpty ? opsiKategori : _opsiDefault;

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.autorenew_rounded, size: 18, color: WarnaLokal.primaryDark),
                  const SizedBox(width: 8),
                  Text(
                    'PENGALIHAN PAKAN / KOMPOS',
                    style: AppColors.heading(fontSize: 12, color: WarnaLokal.textSoft),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: bersedia
                      ? WarnaLokal.primary.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  bersedia ? 'Aktif' : 'Nonaktif',
                  style: AppColors.body(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: bersedia ? WarnaLokal.primaryDark : WarnaLokal.textSoft,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Pertanyaan persetujuan mitra
          Text(
            'Apakah Anda bersedia mengalihkan sisa produk ke kategori Pakan/Kompos jika tidak terjual?',
            style: AppColors.heading(fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 10),

          // Switch / Pilihan Ya / Tidak
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: bersedia ? WarnaLokal.mint : AppColors.bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: bersedia ? WarnaLokal.primary.withValues(alpha: 0.3) : WarnaLokal.border,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bersedia
                            ? 'Ya, saya bersedia mengalihkan sisa produk'
                            : 'Tidak, saya tidak bersedia mengalihkan sisa produk',
                        style: AppColors.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: bersedia ? WarnaLokal.textDark : WarnaLokal.textSoft,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        bersedia
                            ? 'Sisa produk akan menunggu konfirmasi Anda saat melewati batas waktu.'
                            : 'Produk otomatis dinonaktifkan tanpa dialihkan jika tidak terjual.',
                        style: AppColors.body(fontSize: 10.5, color: WarnaLokal.textSoft),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: bersedia,
                  activeColor: WarnaLokal.primary,
                  onChanged: onBersediaChanged,
                ),
              ],
            ),
          ),

          // Bagian konfigurasi jika mitra bersedia
          if (bersedia) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.orange.withValues(alpha: 0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: AppColors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pengalihan HANYA dilakukan setelah produk melewati batas waktu penjualan, masih ada sisa stok, dan Anda mengonfirmasi berat riil sisa produk.',
                      style: AppColors.body(fontSize: 10.5, color: AppColors.textDark, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pilihan Kategori Tujuan Awal
            Text(
              'KATEGORI TUJUAN PENGALIHAN',
              style: AppColors.body(fontSize: 11, fontWeight: FontWeight.w800, color: WarnaLokal.textSoft),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: WarnaLokal.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: targetKategori,
                  hint: Text(
                    'Pilih Kategori Tujuan',
                    style: AppColors.body(fontSize: 12, color: WarnaLokal.textSoft),
                  ),
                  icon: Icon(Icons.arrow_drop_down, color: WarnaLokal.textDark),
                  items: _listOpsi.map((opt) {
                    final nama = '${opt['kategori']}';
                    final harga = opt['harga_per_kg'] != null && opt['harga_per_kg'] > 0
                        ? ' (Rp ${opt['harga_per_kg']}/kg)'
                        : '';
                    return DropdownMenuItem<String>(
                      value: nama,
                      child: Text(
                        '$nama$harga',
                        style: AppColors.body(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    );
                  }).toList(),
                  onChanged: onTargetKategoriChanged,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
