

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'mitra_address_screen.dart';

const _bg = Color(0xFFEAFDE1);
const _primary = Color(0xFF006B1E);
const _cardBg = Color(0xFFF3FAF0);
const _selectedBg = Color(0xFFA9EE9E);
const _iconBg = Color(0xFFE2F3DC);
const _textDark = Color(0xFF10260F);
const _textSoft = Color(0xFF3F4A3C);
const _grey = Color(0xFF8C978A);


class _BusinessCategory {
  final String title;
  final String description;
  final IconData icon;

  const _BusinessCategory({
    required this.title,
    required this.description,
    required this.icon,
  });
}

const _categories = [
  _BusinessCategory(
    title: 'Roti & Bakery',
    description: 'Roti segar harian, pastry, viennoiserie, bolu',
    icon: Icons.bakery_dining_outlined,
  ),
  _BusinessCategory(
    title: 'Makanan Berat (Resto/Katering)',
    description: 'Nasi bungkus, lauk prasmanan, paket makan siang',
    icon: Icons.restaurant_outlined,
  ),
  _BusinessCategory(
    title: 'Dessert & Minuman',
    description: 'Puding, jus buah segar, artisan kopi, kue basah',
    icon: Icons.icecream_outlined,
  ),
  _BusinessCategory(
    title: 'Pakan & Pupuk Organik',
    description: 'Ampas kelapa, sisa sayuran segar untuk ternak/kebun',
    icon: Icons.eco_outlined,
  ),
];

class MitraBusinessScreen extends StatefulWidget {
  const MitraBusinessScreen({super.key});

  @override
  State<MitraBusinessScreen> createState() => _MitraBusinessScreenState();
}

class _MitraBusinessScreenState extends State<MitraBusinessScreen> {
  final _nameController = TextEditingController();

  // Indeks kategori yang terpilih. Default: yang pertama, sesuai desain.
  int _selectedIndex = 0;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _lanjutkan() {
    final kategori = _categories[_selectedIndex].title;
    debugPrint('Kategori terpilih: $kategori');

    // Pindah ke langkah berikutnya (MitraAddressScreen)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MitraAddressScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            const _Header(
              title: 'Daftar Mitra',
              subtitle: 'Nama & Kategori Usaha',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ProgressBar(step: 4, label: 'Nama & Kategori'),
                    const SizedBox(height: 24),
                    Text(
                      'Kategori Usahamu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih jenis surplus yang paling dominan di tokomu.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        height: 1.6,
                        color: _textSoft,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(height: 8),

                
                    ...List.generate(_categories.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CategoryCard(
                          category: _categories[i],
                          selected: _selectedIndex == i,
                          onTap: () => setState(() => _selectedIndex = i),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // ---- Bawah ----
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _lanjutkan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Lanjutkan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Kembali ke Buat Kata Sandi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Satu kartu pilihan kategori ----------
class _CategoryCard extends StatelessWidget {
  final _BusinessCategory category;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? _selectedBg : _cardBg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected ? _primary : _iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                color: selected ? Colors.white : _primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: selected ? _textDark : const Color(0xFF4A5A47),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      height: 1.4,
                      color: selected ? _textSoft : _grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Lingkaran centang di kanan
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: selected ? _primary : Colors.white,
                shape: BoxShape.circle,
                border: selected
                    ? null
                    : Border.all(color: const Color(0xFFCBD5C8), width: 1.5),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Progress bar + label langkah ----------
class _ProgressBar extends StatelessWidget {
  final int step;
  final String label;
  static const totalSteps = 7;

  const _ProgressBar({required this.step, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Langkah $step dari $totalSteps',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _primary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _textSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: LinearProgressIndicator(
            value: step / totalSteps,
            minHeight: 8,
            color: _primary,
            backgroundColor: const Color(0xFFD5EDCB),
          ),
        ),
      ],
    );
  }
}

// ---------- Header ----------
class _Header extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      color: _bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textSoft,
            ),
          ),
        ],
      ),
    );
  }
}
