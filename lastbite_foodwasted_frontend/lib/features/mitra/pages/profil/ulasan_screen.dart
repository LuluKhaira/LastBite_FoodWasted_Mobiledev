import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'widgets/profil_ui.dart';

class _Ulasan {
  final String nama;
  final int bintang;
  final String tanggal;
  final String produk;
  final String komentar;

  const _Ulasan(this.nama, this.bintang, this.tanggal, this.produk, this.komentar);
}

// Data contoh. TODO: ganti dengan data ulasan dari API.
const List<_Ulasan> _semuaUlasan = [
  _Ulasan('Rina A.', 5, '2 hari lalu', 'Paket Roti Manis',
      'Rotinya masih lembut dan porsinya banyak. Harganya murah banget!'),
  _Ulasan('Budi S.', 5, '3 hari lalu', 'Bakery & Pastry Box',
      'Pengambilan cepat, penjualnya ramah. Pasti beli lagi.'),
  _Ulasan('Dewi K.', 4, '5 hari lalu', 'Paket Roti Manis',
      'Enak, tapi pas saya ambil pilihan rotinya sudah agak sedikit.'),
  _Ulasan('Andi P.', 5, '1 minggu lalu', 'Paket Hemat Sore',
      'Worth it. Ikut menyelamatkan makanan sekaligus hemat.'),
  _Ulasan('Siska M.', 3, '1 minggu lalu', 'Bakery & Pastry Box',
      'Rasa oke, hanya antrean pengambilan agak lama.'),
  _Ulasan('Fajar R.', 4, '2 minggu lalu', 'Paket Hemat Sore',
      'Kemasannya rapi dan isinya sesuai deskripsi.'),
];

class UlasanScreen extends StatefulWidget {
  final String rating;
  final String jumlahUlasan;

  const UlasanScreen({
    super.key,
    this.rating = '4.9',
    this.jumlahUlasan = '180+ Ulasan',
  });

  @override
  State<UlasanScreen> createState() => _UlasanScreenState();
}

class _UlasanScreenState extends State<UlasanScreen> {
  String _filter = 'Semua';
  static const _filters = ['Semua', '5 ★', '4 ★', '3 ★ ke bawah'];

  List<_Ulasan> get _tampil {
    switch (_filter) {
      case '5 ★':
        return _semuaUlasan.where((u) => u.bintang == 5).toList();
      case '4 ★':
        return _semuaUlasan.where((u) => u.bintang == 4).toList();
      case '3 ★ ke bawah':
        return _semuaUlasan.where((u) => u.bintang <= 3).toList();
      default:
        return _semuaUlasan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final daftar = _tampil;
    return ProfilSubScaffold(
      title: 'Ulasan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ringkasan(),
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
                  'Belum ada ulasan untuk filter ini',
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

  Widget _bintang(int n, {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < n ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: AppColors.orange,
        ),
      ),
    );
  }

  Widget _ringkasan() {
    const dist = [128, 36, 10, 4, 2]; // jumlah bintang 5 sampai 1 (contoh)
    final total = dist.reduce((a, b) => a + b);
    final rataBulat = (double.tryParse(widget.rating) ?? 5).round();

    return ProfilCard(
      child: Row(
        children: [
          Column(
            children: [
              Text(
                widget.rating,
                style: AppColors.heading(fontSize: 38, fontWeight: FontWeight.w800),
              ),
              _bintang(rataBulat),
              const SizedBox(height: 6),
              Text(
                widget.jumlahUlasan,
                style: AppColors.body(fontSize: 11.5, color: ProfilUI.textSoft),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final bintang = 5 - i;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Text(
                        '$bintang',
                        style: AppColors.body(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded,
                          size: 12, color: AppColors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: dist[i] / total,
                            minHeight: 6,
                            backgroundColor: AppColors.hijauMuda,
                            valueColor: const AlwaysStoppedAnimation(
                                AppColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartu(_Ulasan u) {
    return ProfilCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.hijauMuda,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  u.nama.substring(0, 1),
                  style: AppColors.heading(fontSize: 15),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.nama, style: AppColors.heading(fontSize: 14)),
                    const SizedBox(height: 2),
                    _bintang(u.bintang, size: 14),
                  ],
                ),
              ),
              Text(
                u.tanggal,
                style: AppColors.body(fontSize: 11, color: ProfilUI.textSoft),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ProfilPill(
            text: u.produk,
            background: AppColors.hijauMuda,
            foreground: AppColors.textDark,
          ),
          const SizedBox(height: 8),
          Text(
            u.komentar,
            style: AppColors.body(fontSize: 13, height: 1.45),
          ),
        ],
      ),
    );
  }
}