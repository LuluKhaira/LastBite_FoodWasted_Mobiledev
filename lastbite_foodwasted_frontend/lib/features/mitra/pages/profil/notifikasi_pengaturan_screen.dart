import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'widgets/profil_ui.dart';

class _Opsi {
  final String kunci;
  final String judul;
  final String sub;
  final IconData ikon;

  const _Opsi(this.kunci, this.judul, this.sub, this.ikon);
}

class NotifikasiPengaturanScreen extends StatefulWidget {
  const NotifikasiPengaturanScreen({super.key});

  @override
  State<NotifikasiPengaturanScreen> createState() =>
      _NotifikasiPengaturanScreenState();
}

class _NotifikasiPengaturanScreenState
    extends State<NotifikasiPengaturanScreen> {
  // TODO: simpan pengaturan ke API / penyimpanan lokal.
  final Map<String, bool> _nilai = {
    'pesanan_baru': true,
    'pesanan_diambil': true,
    'pesanan_batal': true,
    'stok_menipis': true,
    'produk_tayang': true,
    'jam_tutup': false,
    'promo': false,
    'suara': true,
    'getar': true,
  };

  static const _aktivitas = [
    _Opsi('pesanan_baru', 'Pesanan baru masuk',
        'Beri tahu saat ada pembeli memesan', Icons.shopping_bag_outlined),
    _Opsi('pesanan_diambil', 'Pesanan sudah diambil',
        'Konfirmasi saat pembeli selesai mengambil', Icons.task_alt_rounded),
    _Opsi('pesanan_batal', 'Pesanan dibatalkan',
        'Beri tahu jika pembeli membatalkan', Icons.cancel_outlined),
  ];

  static const _pengingat = [
    _Opsi('stok_menipis', 'Stok hampir habis',
        'Pengingat saat sisa stok produk menipis', Icons.inventory_2_outlined),
    _Opsi('produk_tayang', 'Produk mulai tayang',
        'Saat produk terjadwal sudah tayang', Icons.event_available_outlined),
    _Opsi('jam_tutup', 'Pengingat jam tutup',
        '30 menit sebelum toko tutup', Icons.access_time_rounded),
  ];

  static const _umum = [
    _Opsi('promo', 'Promo & tips mitra',
        'Info program dan tips meningkatkan penjualan', Icons.campaign_outlined),
    _Opsi('suara', 'Suara notifikasi', 'Bunyikan nada saat notifikasi masuk',
        Icons.volume_up_outlined),
    _Opsi('getar', 'Getar', 'Getarkan perangkat saat notifikasi masuk',
        Icons.vibration_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return ProfilSubScaffold(
      title: 'Notifikasi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _seksi('Aktivitas toko', _aktivitas),
          const SizedBox(height: 20),
          _seksi('Pengingat', _pengingat),
          const SizedBox(height: 20),
          _seksi('Umum', _umum),
        ],
      ),
    );
  }

  Widget _seksi(String judul, List<_Opsi> items) {
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      rows.add(_baris(items[i]));
      if (i < items.length - 1) {
        rows.add(const Divider(
          height: 1,
          thickness: 1,
          indent: 66,
          endIndent: 16,
          color: AppColors.bg,
        ));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfilSectionLabel(judul),
        ProfilCard(
          padding: EdgeInsets.zero,
          child: Column(children: rows),
        ),
      ],
    );
  }

  Widget _baris(_Opsi o) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.hijauMuda,
              shape: BoxShape.circle,
            ),
            child: Icon(o.ikon, size: 19, color: AppColors.textDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  o.judul,
                  style: AppColors.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  o.sub,
                  style: AppColors.body(
                    fontSize: 11.5,
                    color: ProfilUI.textSoft,
                  ),
                ),
              ],
            ),
          ),
          ProfilSwitch(
            value: _nilai[o.kunci] ?? false,
            onChanged: (v) => setState(() => _nilai[o.kunci] = v),
          ),
        ],
      ),
    );
  }
}