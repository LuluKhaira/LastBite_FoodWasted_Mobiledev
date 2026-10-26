import 'package:flutter/material.dart';
import '../../../../core/tema/tema_lb.dart';
import 'kartu_nilai.dart';

/// Bagian bintang 1-5, keterangan, dan tag cepat ("Porsi Melimpah", dst).
class KartuBintangNilai extends StatelessWidget {
  final int bintang;
  final ValueChanged<int> onBintang;
  final Set<String> tag;
  final ValueChanged<String> onTag;

  const KartuBintangNilai({
    super.key,
    required this.bintang,
    required this.onBintang,
    required this.tag,
    required this.onTag,
  });

  static const daftarTag = [
    'Makanan Masih Hangat & Enak',
    'Porsi Melimpah',
    'Pelayanan Ramah',
    'Sangat Higienis',
  ];

  static const _label = [
    'Ketuk bintang untuk menilai',
    'Kurang puas',
    'Biasa saja',
    'Lumayan',
    'Puas!',
    'Luar biasa! Sangat puas & segar.',
  ];

  @override
  Widget build(BuildContext context) {
    return KartuNilai(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Text('Bagaimana kualitas\nmakananmu?',
                    style: LbText.heading(17,
                        weight: FontWeight.w700, height: 1.25)),
              ),
              Expanded(
                flex: 2,
                child: Text('Bantu merchant berkembang',
                    textAlign: TextAlign.right,
                    style: LbText.body(12,
                        weight: FontWeight.w600, color: LbColors.sageDeep)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                GestureDetector(
                  onTap: () => onBintang(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i <= bintang
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 42,
                      color: i <= bintang
                          ? const Color(0xFFF2A93B)
                          : const Color(0xFFD5D1C7),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(_label[bintang],
              textAlign: TextAlign.center, style: LbText.body(13.5)),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final t in daftarTag) _chip(t)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String t) {
    final pilih = tag.contains(t);
    return GestureDetector(
      onTap: () => onTag(t),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: pilih
              ? LbColors.sage.withValues(alpha: 0.45)
              : LbColors.offWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: pilih ? LbColors.sageDeep : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Text(t,
            style: LbText.body(13,
                weight: FontWeight.w600, color: LbColors.forest)),
      ),
    );
  }
}