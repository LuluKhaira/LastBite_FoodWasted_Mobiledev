import 'package:flutter/material.dart';
import '../../../../core/tema/tema_lb.dart';
import 'kartu_nilai.dart';

/// Bagian "Catatan Ulasan" dengan penghitung karakter (maks 500).
class KartuCatatanUlasan extends StatelessWidget {
  final TextEditingController controller;

  const KartuCatatanUlasan({super.key, required this.controller});

  static const maks = 500;

  @override
  Widget build(BuildContext context) {
    return KartuNilai(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Catatan Ulasan',
                  style: LbText.heading(16, weight: FontWeight.w700)),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (_, v, __) => Text('${v.text.length}/$maks',
                    style: LbText.body(12.5, weight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 4,
            maxLength: maks,
            buildCounter: (_,
                    {required currentLength,
                    required isFocused,
                    maxLength}) =>
                null,
            style: LbText.body(14, color: LbColors.forest),
            decoration: InputDecoration(
              hintText: 'Ceritakan pengalamanmu, misalnya isi paket dan rasanya',
              hintStyle: LbText.body(13.5),
              filled: true,
              fillColor: LbColors.sage.withValues(alpha: 0.16),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 16, color: LbColors.textGrey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Ulasan spesifik membantu penyelamat lain memilih paket berikutnya.',
                  style: LbText.body(12, weight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}