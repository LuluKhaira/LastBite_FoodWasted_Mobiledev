import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/produk/models/surplus_draft.dart';
import 'base_card.dart';
import 'warna_lokal.dart';

class _Kategori {
  final String nama;
  final String sub;
  final IconData ikon;
  const _Kategori(this.nama, this.sub, this.ikon);
}

const _kategoriManusia = [
  _Kategori('Roti & Pastry', 'Croissant, ish', Icons.bakery_dining),
  _Kategori('Roti Tawar', 'Loaf & gandum', Icons.breakfast_dining),
  _Kategori('Siap Santap', 'Bento, lauk hangat', Icons.rice_bowl),
  _Kategori('Sayur & Buah', 'Surplus segar', Icons.eco),
  _Kategori('Bahan & Olahan Dapur', 'Saus, selai, sisa produksi aman', Icons.soup_kitchen),
];

const _kategoriPakan = [
  _Kategori('Bahan Kompos & Pupuk', 'Sisa sayur, buah, daun', Icons.compost),
  _Kategori('Pakan Ternak & Ikan', 'Ampas tahu, dedak, roti', Icons.pets),
  _Kategori('Ampas Kelapa & Kopi', 'Limbah barista & pertanian', Icons.coffee),
  _Kategori('Limbah Organik', 'Kulit buah, sayur sortir', Icons.grass),
];

class TargetKategoriCard extends StatelessWidget {
  final TargetSurplus target;
  final String? kategori;
  final ValueChanged<TargetSurplus> onTargetChanged;
  final ValueChanged<String> onKategoriChanged;

  const TargetKategoriCard({
    super.key,
    required this.target,
    required this.kategori,
    required this.onTargetChanged,
    required this.onKategoriChanged,
  });

  @override
  Widget build(BuildContext context) {
    final listKategori = target == TargetSurplus.manusia ? _kategoriManusia : _kategoriPakan;

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TARGET & KATEGORI', style: AppColors.heading(fontSize: 12, color: WarnaLokal.textSoft)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: WarnaLokal.accent.withValues(alpha: 0.15), 
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Text('Langkah 1', style: AppColors.body(fontSize: 11, fontWeight: FontWeight.w700, color: WarnaLokal.accent)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Toggle Target
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: WarnaLokal.mint, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onTargetChanged(TargetSurplus.manusia),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: target == TargetSurplus.manusia ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: target == TargetSurplus.manusia ? [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                        ] : [],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant, size: 16, color: target == TargetSurplus.manusia ? WarnaLokal.primaryDark : WarnaLokal.textSoft),
                          const SizedBox(width: 6),
                          Text('Konsumsi Manusia', style: AppColors.body(fontSize: 12, fontWeight: FontWeight.w700, color: target == TargetSurplus.manusia ? WarnaLokal.textDark : WarnaLokal.textSoft)),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onTargetChanged(TargetSurplus.pakan),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: target == TargetSurplus.pakan ? WarnaLokal.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.eco, size: 16, color: target == TargetSurplus.pakan ? Colors.white : WarnaLokal.textSoft),
                          const SizedBox(width: 6),
                          Text('Pakan / Kompos', style: AppColors.body(fontSize: 12, fontWeight: FontWeight.w700, color: target == TargetSurplus.pakan ? Colors.white : WarnaLokal.textSoft)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          Text('PILIH KATEGORI PAKET', style: AppColors.body(fontSize: 11, fontWeight: FontWeight.w700, color: WarnaLokal.textSoft)),
          const SizedBox(height: 12),
          
          // Grid Kategori menggunakan LayoutBuilder agar presisi 2 kolom
          LayoutBuilder(
            builder: (context, constraints) {
              final double spacing = 10.0;
              // Hitung lebar: (Total Lebar - Jarak) dibagi 2
              final double itemWidth = (constraints.maxWidth - spacing) / 2;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: listKategori.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final _Kategori k = entry.value;
                  final bool dipilih = kategori == k.nama;
                  
                  // Cek apakah ini item terakhir DAN jumlah item ganjil
                  final bool isLastOddItem = (index == listKategori.length - 1) && (listKategori.length % 2 != 0);
                  // Jika iya, lebarnya penuh. Jika tidak, setengah.
                  final double currentWidth = isLastOddItem ? constraints.maxWidth : itemWidth;

                  return GestureDetector(
                    onTap: () => onKategoriChanged(k.nama),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: currentWidth,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: dipilih ? WarnaLokal.mintDeep : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: dipilih ? WarnaLokal.primary : WarnaLokal.border, 
                          width: dipilih ? 1.5 : 1
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(k.ikon, size: 20, color: dipilih ? WarnaLokal.primaryDark : WarnaLokal.textSoft),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(k.nama, style: AppColors.body(fontSize: 12, fontWeight: FontWeight.w700, color: WarnaLokal.textDark), maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text(k.sub, style: AppColors.body(fontSize: 10, color: WarnaLokal.textSoft), maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}