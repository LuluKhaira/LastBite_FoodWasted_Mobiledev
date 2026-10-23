import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';

class SurplusSection extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final void Function(Map<String, dynamic>)? onProductTap;

  const SurplusSection({
    super.key,
    this.items = const [],
    this.onProductTap,
  });

  static String _rupiah(dynamic v) {
    final n = num.tryParse('$v') ?? 0;
    final s = n.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp $buf';
  }

  // "20:00:00" -> "20.00 WIB"
  static String? _batas(dynamic v) {
    if (v == null) return null;
    final p = '$v'.split(':');
    if (p.length < 2) return null;
    return '${p[0]}.${p[1]} WIB';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Produk Sedang Tayang',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            Text(
              '${items.length} Aktif',
              style: GoogleFonts.nunito(
                fontSize: 11,
                color: AppColors.textSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Belum ada produk yang tayang. Tekan tombol + untuk menambah.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textSoft),
            ),
          )
        else
          ...items.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _kartu(p),
              )),
      ],
    );
  }

  Widget _kartu(Map<String, dynamic> p) {
    final batas = _batas(p['waktu_selesai']);
    final stok = int.tryParse('${p['stok']}') ?? 0;
    final adaAsli = (num.tryParse('${p['harga_asli']}') ?? 0) > 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onProductTap != null ? () => onProductTap!(p) : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bakery_dining,
                    size: 36, color: AppColors.textDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (stok <= 3)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.orange.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Cepat Habis',
                              style: GoogleFonts.nunito(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        if (batas != null)
                          Text(
                            'Batas $batas',
                            style: GoogleFonts.nunito(
                                fontSize: 10.5, color: AppColors.textSoft),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${p['nama_produk'] ?? '-'}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _rupiah(p['harga_diskon']),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        if (adaAsli) ...[
                          const SizedBox(width: 6),
                          Text(
                            _rupiah(p['harga_asli']),
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              color: AppColors.textSoft,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sisa stok: $stok',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
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
