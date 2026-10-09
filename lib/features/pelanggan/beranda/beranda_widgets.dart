import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'filter_preferensi.dart';

// ============================================================
// WARNA LASTBITE
// ============================================================
class LbColors {
  LbColors._();

  // Warna utama (sesuai permintaan)
  static const Color offWhite = Color(0xFFF8F6F2); // background
  static const Color sage = Color(0xFFA7C957); // hijau sage
  static const Color peach = Color(0xFFFFB07C); // oranye peach

  // Turunan warna
  static const Color sageDeep = Color(0xFF86A83A); // ujung gradient / ikon
  static const Color sageLight = Color(0xFFEDF3DC); // chip & latar lembut
  static const Color peachLight = Color(0xFFFFEADB);
  static const Color peachDeep = Color(0xFFC9692F);

  // Teks
  static const Color forest = Color(0xFF2F4F2A); // judul & teks utama
  static const Color textGrey = Color(0xFF7B8374); // teks sekunder
  static const Color border = Color(0xFFEAE7E0);
}

// ============================================================
// FONT: Poppins (heading) + Nunito (isi teks)
// ============================================================
class LbText {
  LbText._();

  static TextStyle heading(
    double size, {
    FontWeight weight = FontWeight.w600,
    Color color = LbColors.forest,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w500,
    Color color = LbColors.textGrey,
    double? height,
  }) {
    return GoogleFonts.nunito(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }
}

// ============================================================
// MODEL DATA
// ============================================================
class BahanItem {
  final String nama;
  final String penjual;
  final String inisial;
  final String waktu;
  final String jarak;
  final String kategori;
  final String gambar;
  final String badge; // contoh: "20 kg" / "3 tersisa"
  final String rating;
  final String tag;
  final IconData tagIcon;
  final String harga;
  final String satuan; // "Gratis" / "/paket" / "/karung"
  final String? hargaAsli; // harga coret (opsional)

  const BahanItem({
    required this.nama,
    required this.penjual,
    required this.inisial,
    required this.waktu,
    required this.jarak,
    required this.kategori,
    required this.gambar,
    required this.badge,
    required this.rating,
    required this.tag,
    required this.harga,
    required this.satuan,
    this.tagIcon = Icons.eco_rounded,
    this.hargaAsli,
  });

  bool get gratis => harga == 'Rp0';
}

class LbKategori {
  final String label;
  final IconData icon;
  const LbKategori(this.label, this.icon);
}

// ============================================================
// GAMBAR NETWORK (dengan placeholder & fallback)
// ============================================================
class LbNetImage extends StatelessWidget {
  final String url;
  final IconData fallbackIcon;

  const LbNetImage({
    super.key,
    required this.url,
    this.fallbackIcon = Icons.image_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(color: LbColors.sageLight);
      },
      errorBuilder: (context, error, stack) {
        return Container(
          color: LbColors.sageLight,
          alignment: Alignment.center,
          child: Icon(fallbackIcon, color: LbColors.sageDeep, size: 30),
        );
      },
    );
  }
}

// ============================================================
// HEADER
// ============================================================
class LbHeader extends StatelessWidget {
  const LbHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Logo daun
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [LbColors.sage, LbColors.sageDeep],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(26),
              bottomRight: Radius.circular(26),
              topRight: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            boxShadow: [
              BoxShadow(
                color: LbColors.sage.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.eco_rounded, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 12),

        // Judul
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LASTBITE',
                style: LbText.heading(
                  11,
                  weight: FontWeight.w700,
                  color: LbColors.sageDeep,
                  letterSpacing: 1.6,
                ),
              ),
              Text(
                'Beranda',
                style: LbText.heading(
                  27,
                  weight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),

        // Notifikasi
        SizedBox(
          width: 42,
          height: 42,
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  size: 28,
                  color: LbColors.forest,
                ),
              ),
              Positioned(
                top: 8,
                right: 9,
                child: IgnorePointer(
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: LbColors.peach,
                      shape: BoxShape.circle,
                      border: Border.all(color: LbColors.offWhite, width: 1.8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Avatar
        Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(2.5),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [LbColors.sage, LbColors.sageDeep],
            ),
          ),
          child: ClipOval(
            child: Container(
              color: Colors.white,
              child: const LbNetImage(
                url: 'https://i.pravatar.cc/150?img=32',
                fallbackIcon: Icons.person_rounded,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// LOKASI + RADIUS
// ============================================================
class LbLocationRow extends StatelessWidget {
  const LbLocationRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF4E3),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 19,
                color: LbColors.sageDeep,
              ),
              const SizedBox(width: 6),
              Text(
                'Batam Center',
                style: LbText.heading(13, weight: FontWeight.w600),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: LbColors.forest,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: LbColors.sage.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            '3 km',
            style: LbText.heading(13, weight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// SEARCH BAR
// ============================================================
class LbSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilter;
  const LbSearchBar({super.key, this.onChanged, this.onFilter});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.only(left: 18, right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: LbColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: LbColors.forest, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              cursorColor: LbColors.sageDeep,
              style: LbText.body(14, color: LbColors.forest),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Cari makanan, resto, atau pakan ternak...',
                hintStyle: LbText.body(14, color: LbColors.textGrey),
              ),
            ),
          ),
          Material(
            color: LbColors.sageLight,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onFilter,
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  Icons.tune_rounded,
                  size: 22,
                  color: LbColors.forest,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BANNER MISI ZERO WASTE
// ============================================================
class LbBanner extends StatelessWidget {
  const LbBanner({super.key});

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      constraints: const BoxConstraints(minHeight: 144),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEBF3D6), Color(0xFFD2E3A6)],
        ),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -46,
            child: _circle(160, LbColors.sage.withValues(alpha: 0.38)),
          ),
          Positioned(
            right: -20,
            bottom: -40,
            child: _circle(104, LbColors.peach.withValues(alpha: 0.6)),
          ),
          Positioned(
            left: -26,
            bottom: -34,
            child: _circle(86, LbColors.sage.withValues(alpha: 0.3)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: LbColors.sageDeep,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.eco_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'MISI ZERO WASTE',
                              style: LbText.heading(
                                9.5,
                                weight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Selamatkan Makanan\nHari Ini!',
                        style: LbText.heading(
                          18,
                          weight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '1 paket yang diselamatkan setara dengan menangkal 1.2 kg emisi jejak karbon CO2.',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: LbText.body(
                          11.5,
                          color: LbColors.forest.withValues(alpha: 0.85),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Transform.rotate(
                  angle: 0.05,
                  child: Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: const LbNetImage(
                        url:
                            'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500&q=80',
                        fallbackIcon: Icons.eco_rounded,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TOGGLE: UNTUK DIMAKAN / UNTUK TERNAK & PUPUK
// ============================================================
class LbTypeToggle extends StatelessWidget {
  final bool isTernak;
  final ValueChanged<bool> onChanged; // true = ternak

  const LbTypeToggle({
    super.key,
    required this.isTernak,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: LbColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Segment(
              label: 'Untuk Dimakan',
              icon: Icons.restaurant_rounded,
              active: !isTernak,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _Segment(
              label: 'Untuk Ternak & Pupuk',
              icon: Icons.pets_rounded,
              active: isTernak,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        height: 46,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: active
              ? const LinearGradient(
                  colors: [LbColors.sage, LbColors.sageDeep],
                )
              : const LinearGradient(
                  colors: [Colors.transparent, Colors.transparent],
                ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: LbColors.sage.withValues(alpha: 0.45),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: active ? Colors.white : LbColors.forest,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: LbText.heading(
                  13,
                  weight: FontWeight.w600,
                  color: active ? Colors.white : LbColors.forest,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FILTER KATEGORI
// ============================================================
class LbKategoriBar extends StatelessWidget {
  final List<LbKategori> kategori;
  final int selected;
  final ValueChanged<int> onSelected;

  const LbKategoriBar({
    super.key,
    required this.kategori,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: kategori.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final active = i == selected;
          final k = kategori[i];

          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                color: active ? null : Colors.white,
                gradient: active
                    ? const LinearGradient(
                        colors: [LbColors.sage, LbColors.sageDeep],
                      )
                    : null,
                border: Border.all(
                  color: active ? Colors.transparent : LbColors.border,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: LbColors.sage.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    k.icon,
                    size: 20,
                    color: active ? Colors.white : LbColors.sageDeep,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    k.label,
                    style: LbText.heading(
                      13,
                      weight: FontWeight.w600,
                      color: active ? Colors.white : LbColors.forest,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// JUDUL SECTION
// ============================================================
class LbSectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onLihatPeta;

  const LbSectionTitle({super.key, required this.title, this.onLihatPeta});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: LbColors.sageLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.eco_rounded,
            size: 21,
            color: LbColors.sageDeep,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: LbText.heading(
              16,
              weight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onLihatPeta,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Lihat Peta',
                style: LbText.body(
                  13,
                  weight: FontWeight.w700,
                  color: LbColors.sageDeep,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.map_outlined,
                size: 19,
                color: LbColors.sageDeep,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// KARTU PRODUK
// ============================================================
class BahanCard extends StatefulWidget {
  final BahanItem item;
  final int index;
  final VoidCallback? onTap;

  const BahanCard({
    super.key,
    required this.item,
    required this.index,
    this.onTap,
  });

  @override
  State<BahanCard> createState() => _BahanCardState();
}

class _BahanCardState extends State<BahanCard> {
  bool _fav = false;

  @override
  Widget build(BuildContext context) {
    final it = widget.item;
    final logoColor =
        widget.index.isEven ? LbColors.sageDeep : LbColors.peach;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: LbColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------------- GAMBAR ----------------
              SizedBox(
                width: 118,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: LbNetImage(url: it.gambar),
                      ),
                    ),

                    // Badge berat / sisa
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          it.badge,
                          style: LbText.body(
                            11,
                            weight: FontWeight.w800,
                            color: LbColors.forest,
                          ),
                        ),
                      ),
                    ),

                    // Logo toko (inisial)
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: logoColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          it.inisial,
                          style: LbText.heading(
                            10.5,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // ---------------- DETAIL ----------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: LbColors.sageLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 15,
                              color: LbColors.sageDeep,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              it.rating,
                              style: LbText.body(
                                12,
                                weight: FontWeight.w800,
                                color: LbColors.forest,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Judul
                    Text(
                      it.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: LbText.heading(
                        14,
                        weight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Penjual
                    Text(
                      it.penjual,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LbText.body(12, weight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),

                    // Waktu + jarak
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 1),
                          child: Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: LbColors.textGrey,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Ambil hari ini: ${it.waktu} | ${it.jarak}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: LbText.body(10.5, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Tag kategori
                    Row(
                      children: [
                        Icon(it.tagIcon, size: 14, color: LbColors.sageDeep),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            it.tag,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: LbText.body(
                              11.5,
                              weight: FontWeight.w700,
                              color: LbColors.sageDeep,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Harga coret (kalau ada)
                    if (it.hargaAsli != null)
                      Text(
                        it.hargaAsli!,
                        style: LbText.body(11).copyWith(
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),

                    // Harga + satuan + favorit
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              it.harga,
                              style: LbText.heading(
                                19,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: it.gratis
                                ? LbColors.sageLight
                                : LbColors.peachLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            it.satuan,
                            style: LbText.body(
                              11,
                              weight: FontWeight.w700,
                              color: it.gratis
                                  ? LbColors.sageDeep
                                  : LbColors.peachDeep,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => _fav = !_fav),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: Icon(
                                _fav
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                key: ValueKey(_fav),
                                size: 25,
                                color: _fav
                                    ? LbColors.peach
                                    : LbColors.textGrey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// BOTTOM NAV MELAYANG
// ============================================================
class LbBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const LbBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Beranda'),
    (Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Pesanan'),
    (Icons.favorite_border_rounded, Icons.favorite_rounded, 'Favorit'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: LbColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_items.length, (i) {
              final active = i == currentIndex;
              final item = _items[i];

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: active
                          ? LbColors.sage.withValues(alpha: 0.28)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          active ? item.$2 : item.$1,
                          size: 24,
                          color: active
                              ? LbColors.forest
                              : LbColors.textGrey,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.$3,
                          style: LbText.body(
                            11,
                            weight:
                                active ? FontWeight.w800 : FontWeight.w600,
                            color: active
                                ? LbColors.forest
                                : LbColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LAYOUT HALAMAN BERANDA (dipakai kedua mode)
// ============================================================
class BerandaLayout extends StatefulWidget {
  final bool isTernak;
  final ValueChanged<bool> onSwitch; // true = pindah ke ternak
  final List<LbKategori> kategori;
  final int selectedKategori;
  final ValueChanged<int> onKategori;
  final String sectionTitle;
  final List<BahanItem> items;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onLihatPeta;
  final ValueChanged<int>? onNavTap;

  const BerandaLayout({
    super.key,
    required this.isTernak,
    required this.onSwitch,
    required this.kategori,
    required this.selectedKategori,
    required this.onKategori,
    required this.sectionTitle,
    required this.items,
    this.onSearch,
    this.onLihatPeta,
    this.onNavTap,
  });

  @override
  State<BerandaLayout> createState() => _BerandaLayoutState();
}

class _BerandaLayoutState extends State<BerandaLayout> {
  int _nav = 0;
  Map<String, dynamic> _filter = {};

  Future<void> _openFilter() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => FilterPreferensiScreen(isTernak: widget.isTernak),
      ),
    );
    if (result != null && mounted) {
      setState(() => _filter = result);
    }
  }

  List<BahanItem> get _filteredItems {
    final selected = (_filter['kategori'] as List<String>?) ?? <String>[];
    final maxKm = (_filter['jarak'] as double?) ?? 10.0;
    final onlyAvailable = (_filter['tersedia'] as bool?) ?? false;
    final price = (_filter['harga'] as String?) ?? 'Semua Harga';
    final order = (_filter['urutan'] as String?) ?? 'Rekomendasi';
    var result = widget.items.where((item) {
      if (selected.isNotEmpty && !selected.contains(item.kategori)) return false;
      final km = double.tryParse(item.jarak.replaceAll(' km', '').replaceAll(',', '.')) ?? 99;
      if (km > maxKm) return false;
      if (onlyAvailable && (item.badge.toLowerCase().contains('habis') || item.badge == '0')) return false;
      final amount = int.tryParse(item.harga.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (price == 'Di bawah Rp25.000' && amount >= 25000) return false;
      if (price == 'Rp25.000–Rp50.000' && (amount < 25000 || amount > 50000)) return false;
      if (price == 'Di atas Rp50.000' && amount <= 50000) return false;
      return true;
    }).toList();

    if (order == 'Jarak Terdekat') {
      result.sort((a, b) {
        final ak = double.tryParse(a.jarak.replaceAll(' km', '').replaceAll(',', '.')) ?? 99;
        final bk = double.tryParse(b.jarak.replaceAll(' km', '').replaceAll(',', '.')) ?? 99;
        return ak.compareTo(bk);
      });
    } else if (order == 'Harga Terendah') {
      result.sort((a, b) {
        final ap = int.tryParse(a.harga.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final bp = int.tryParse(b.harga.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return ap.compareTo(bp);
      });
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LbColors.offWhite,
      bottomNavigationBar: LbBottomNav(
        currentIndex: _nav,
        onTap: (i) {
          setState(() => _nav = i);
          widget.onNavTap?.call(i);
        },
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LbHeader(),
                    const SizedBox(height: 16),
                    const LbLocationRow(),
                    const SizedBox(height: 14),
                    LbSearchBar(onChanged: widget.onSearch, onFilter: _openFilter),
                    const SizedBox(height: 18),
                    const LbBanner(),
                    const SizedBox(height: 18),
                    LbTypeToggle(
                      isTernak: widget.isTernak,
                      onChanged: widget.onSwitch,
                    ),
                    const SizedBox(height: 16),
                    LbKategoriBar(
                      kategori: widget.kategori,
                      selected: widget.selectedKategori,
                      onSelected: widget.onKategori,
                    ),
                    const SizedBox(height: 22),
                    LbSectionTitle(
                      title: widget.sectionTitle,
                      onLihatPeta: widget.onLihatPeta,
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
            if (_filteredItems.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 48,
                    horizontal: 32,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: LbColors.sageLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.search_off_rounded,
                          size: 34,
                          color: LbColors.sageDeep,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Belum ada yang cocok',
                        style: LbText.heading(15, weight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Coba ganti kata kunci atau kategori lain.',
                        textAlign: TextAlign.center,
                        style: LbText.body(12.5),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                sliver: SliverList.separated(
                  itemCount: _filteredItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, i) =>
                      BahanCard(item: _filteredItems[i], index: i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}