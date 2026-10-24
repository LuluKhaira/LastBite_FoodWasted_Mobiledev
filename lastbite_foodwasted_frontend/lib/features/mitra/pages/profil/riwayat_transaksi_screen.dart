import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'widgets/profil_ui.dart';

class _Trx {
  final String kode;
  final String produk;
  final int qty;
  final int total;
  final String tanggal;
  final bool selesai;

  const _Trx(this.kode, this.produk, this.qty, this.total, this.tanggal, this.selesai);
}

// Data contoh. TODO: ganti dengan data riwayat dari API.
const List<_Trx> _semuaTrx = [
  _Trx('LB-2410-0087', 'Paket Roti Manis', 2, 30000, '24 Okt 2026 • 16:42', true),
  _Trx('LB-2410-0085', 'Bakery & Pastry Box', 1, 25000, '24 Okt 2026 • 14:10', true),
  _Trx('LB-2410-0079', 'Paket Hemat Sore', 3, 45000, '23 Okt 2026 • 18:05', true),
  _Trx('LB-2410-0074', 'Paket Roti Manis', 1, 15000, '23 Okt 2026 • 11:30', false),
  _Trx('LB-2410-0068', 'Bakery & Pastry Box', 2, 50000, '22 Okt 2026 • 17:20', true),
  _Trx('LB-2410-0061', 'Paket Hemat Sore', 1, 15000, '21 Okt 2026 • 19:48', false),
  _Trx('LB-2410-0055', 'Paket Roti Manis', 4, 60000, '20 Okt 2026 • 15:02', true),
];

class RiwayatTransaksiScreen extends StatefulWidget {
  const RiwayatTransaksiScreen({super.key});

  @override
  State<RiwayatTransaksiScreen> createState() => _RiwayatTransaksiScreenState();
}

class _RiwayatTransaksiScreenState extends State<RiwayatTransaksiScreen> {
  String _filter = 'Semua';
  static const _filters = ['Semua', 'Selesai', 'Dibatalkan'];

  List<_Trx> get _tampil {
    switch (_filter) {
      case 'Selesai':
        return _semuaTrx.where((t) => t.selesai).toList();
      case 'Dibatalkan':
        return _semuaTrx.where((t) => !t.selesai).toList();
      default:
        return _semuaTrx;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selesai = _semuaTrx.where((t) => t.selesai).toList();
    final pendapatan = selesai.fold<int>(0, (a, t) => a + t.total);
    final daftar = _tampil;

    return ProfilSubScaffold(
      title: 'Riwayat Transaksi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pendapatan bulan ini',
                        style: AppColors.body(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profilRp(pendapatan),
                        style: AppColors.heading(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${selesai.length}',
                        style: AppColors.heading(fontSize: 18),
                      ),
                      Text(
                        'Selesai',
                        style: AppColors.body(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => ProfilChip(
                label: _filters[i],
                active: _filter == _filters[i],
                onTap: () => setState(() => _filter = _filters[i]),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (daftar.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'Belum ada transaksi',
                  style: AppColors.body(color: ProfilUI.textSoft),
                ),
              ),
            )
          else
            ...daftar.map(_kartu),
        ],
      ),
    );
  }

  Widget _kartu(_Trx t) {
    return ProfilCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${t.kode}',
                style: AppColors.body(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ProfilUI.textSoft,
                ),
              ),
              ProfilPill(
                text: t.selesai ? 'Selesai' : 'Dibatalkan',
                background: t.selesai
                    ? AppColors.primary.withValues(alpha: 0.25)
                    : AppColors.merahMuda,
                foreground: t.selesai ? AppColors.textDark : AppColors.merah,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.hijauMuda,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.takeout_dining_rounded,
                  size: 24,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.produk, style: AppColors.heading(fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                      '${t.qty} porsi',
                      style: AppColors.body(
                        fontSize: 12,
                        color: ProfilUI.textSoft,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                profilRp(t.total),
                style: AppColors.heading(
                  fontSize: 14,
                  color: t.selesai ? AppColors.textDark : ProfilUI.textSoft,
                ).copyWith(
                  decoration:
                      t.selesai ? null : TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 13, color: ProfilUI.textSoft),
              const SizedBox(width: 4),
              Text(
                t.tanggal,
                style: AppColors.body(fontSize: 11.5, color: ProfilUI.textSoft),
              ),
            ],
          ),
        ],
      ),
    );
  }
}