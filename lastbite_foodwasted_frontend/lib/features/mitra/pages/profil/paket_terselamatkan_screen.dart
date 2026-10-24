import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'widgets/profil_ui.dart';

class PaketTerselamatkanScreen extends StatelessWidget {
  final int total;

  const PaketTerselamatkanScreen({super.key, required this.total});

  // Data tren & produk di bawah ini contoh (diskalakan ke total).
  // TODO: ganti dengan data asli dari API.
  static const _bulan = ['Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt'];
  static const _dasar = [12, 18, 22, 27, 31, 32];

  List<int> get _perBulan {
    final skala = total / 142;
    final hasil = _dasar.map((v) => (v * skala).round()).toList();
    final sisa = total - hasil.take(5).fold<int>(0, (a, b) => a + b);
    hasil[5] = sisa < 0 ? 0 : sisa;
    return hasil;
  }

  List<MapEntry<String, int>> get _produk {
    final a = (total * 0.48).round();
    final b = (total * 0.32).round();
    final c = total - a - b;
    return [
      MapEntry('Paket Roti Manis', a),
      MapEntry('Bakery & Pastry Box', b),
      MapEntry('Paket Hemat Sore', c < 0 ? 0 : c),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final kg = total * 0.4; // estimasi 0,4 kg makanan per paket
    final co2 = kg * 2.5; // estimasi 2,5 kg CO2e per kg makanan

    return ProfilSubScaffold(
      title: 'Paket Terselamatkan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _hero(),
          const SizedBox(height: 22),
          const ProfilSectionLabel('Dampak lingkungan'),
          Row(
            children: [
              Expanded(
                child: _dampak(
                  Icons.restaurant_rounded,
                  '${kg.toStringAsFixed(0)} kg',
                  'Makanan diselamatkan',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dampak(
                  Icons.cloud_outlined,
                  '${co2.toStringAsFixed(0)} kg',
                  'CO₂ tidak terlepas',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const ProfilSectionLabel('Tren 6 bulan terakhir'),
          ProfilCard(child: _grafik()),
          const SizedBox(height: 22),
          const ProfilSectionLabel('Paling banyak diselamatkan'),
          ProfilCard(child: _daftarProduk()),
          const SizedBox(height: 14),
          Text(
            'Angka dampak adalah estimasi: rata-rata 0,4 kg makanan per paket '
            'dan 2,5 kg CO₂ per kg makanan yang terbuang.',
            style: AppColors.body(
              fontSize: 11.5,
              color: ProfilUI.textSoft,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 30,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total paket terselamatkan',
                      style: AppColors.body(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$total',
                          style: AppColors.heading(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'paket',
                          style: AppColors.heading(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Terima kasih sudah ikut mengurangi sampah makanan!',
                      style: AppColors.body(fontSize: 12, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dampak(IconData ikon, String nilai, String label) {
    return ProfilCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.hijauMuda,
              shape: BoxShape.circle,
            ),
            child: Icon(ikon, size: 19, color: AppColors.textDark),
          ),
          const SizedBox(height: 12),
          Text(nilai, style: AppColors.heading(fontSize: 20)),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppColors.body(fontSize: 12, color: ProfilUI.textSoft),
          ),
        ],
      ),
    );
  }

  Widget _grafik() {
    final data = _perBulan;
    final maks = data.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (i) {
          final terakhir = i == data.length - 1;
          final tinggi = maks == 0 ? 4.0 : 100.0 * data[i] / maks;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${data[i]}',
                  style: AppColors.body(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: tinggi < 4 ? 4 : tinggi,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: terakhir
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _bulan[i],
                  style: AppColors.body(
                    fontSize: 11.5,
                    fontWeight: terakhir ? FontWeight.w800 : FontWeight.w600,
                    color: terakhir ? AppColors.textDark : ProfilUI.textSoft,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _daftarProduk() {
    final items = _produk;
    return Column(
      children: List.generate(items.length, (i) {
        final e = items[i];
        final frac = total == 0 ? 0.0 : e.value / total;
        return Padding(
          padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 14),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      e.key,
                      style: AppColors.body(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${e.value} paket',
                    style: AppColors.body(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: frac,
                  minHeight: 7,
                  backgroundColor: AppColors.hijauMuda,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}