import 'package:flutter/material.dart';
import '../../../../core/komponen/animasi_lb.dart';
import '../../../../core/tema/tema_lb.dart';

class KategoriItemData {
  final String nama;
  final String labelTampilan;
  final String emoji;
  final Color bgIconInactive;

  const KategoriItemData({
    required this.nama,
    required this.labelTampilan,
    required this.emoji,
    required this.bgIconInactive,
  });
}

/// Baris pemilih kategori squircle presisi sesuai desain mockup:
/// - Semua (🥗)
/// - Roti & Kue (🥐)
/// - Makanan (🍱)
/// - Bahan Dapur (🍞)
/// - Minuman (🧋)
class BarisKategoriPelanggan extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const BarisKategoriPelanggan({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const List<KategoriItemData> listKategori = [
    KategoriItemData(
      nama: 'Semua',
      labelTampilan: 'Semua',
      emoji: '🥗',
      bgIconInactive: Color(0xFFE8F5E9),
    ),
    KategoriItemData(
      nama: 'Roti & Kue',
      labelTampilan: 'Roti & Kue',
      emoji: '🥐',
      bgIconInactive: Color(0xFFFEF3E2),
    ),
    KategoriItemData(
      nama: 'Makanan',
      labelTampilan: 'Makanan',
      emoji: '🍱',
      bgIconInactive: Color(0xFFFDF0ED),
    ),
    KategoriItemData(
      nama: 'Bahan Dapur',
      labelTampilan: 'Bahan\nDapur',
      emoji: '🍞',
      bgIconInactive: Color(0xFFEBF7EE),
    ),
    KategoriItemData(
      nama: 'Minuman',
      labelTampilan: 'Minuman',
      emoji: '🧋',
      bgIconInactive: Color(0xFFE8F7F8),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: listKategori.map((k) {
          final isSelected = selected.toLowerCase() == k.nama.toLowerCase();

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: LbTekan(
                onTap: () => onSelected(k.nama),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  height: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: isSelected
                        ? const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF5CB82C),
                              Color(0xFF388E3C),
                            ],
                          )
                        : null,
                    color: isSelected ? null : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : const Color(0xFFF1EFEA),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color(0xFF388E3C).withValues(alpha: 0.35)
                            : Colors.black.withValues(alpha: 0.04),
                        blurRadius: isSelected ? 10 : 8,
                        offset: isSelected
                            ? const Offset(0, 4)
                            : const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Kotak Ikon / Squircle dalam
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFD4EAB8)
                              : k.bgIconInactive,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          k.emoji,
                          style: const TextStyle(fontSize: 21),
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Label Teks (Tinggi konsisten agar icon sejajar sempurna)
                      SizedBox(
                        height: 26,
                        child: Center(
                          child: Text(
                            k.labelTampilan,
                            textAlign: TextAlign.center,
                            style: LbText.heading(
                              k.labelTampilan.contains('\n') ? 10 : 11,
                              weight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF2D3748),
                              height: 1.15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
