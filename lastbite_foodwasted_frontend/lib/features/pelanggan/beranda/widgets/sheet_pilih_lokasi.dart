import 'package:flutter/material.dart';
import '../../../../core/komponen/animasi_lb.dart';
import '../../../../core/tema/tema_lb.dart';

class LokasiBatamItem {
  final String nama;
  final String subLokasi;
  final String deskripsi;
  final double lat;
  final double lng;

  const LokasiBatamItem({
    required this.nama,
    required this.subLokasi,
    required this.deskripsi,
    required this.lat,
    required this.lng,
  });

  String get judulLengkap => '$nama • $subLokasi';
}

/// Bottom sheet pemilihan lokasi presisi sesuai desain mockup LastBite
class SheetPilihLokasi extends StatelessWidget {
  final String lokasiTerpilih;
  final ValueChanged<LokasiBatamItem> onPilih;

  const SheetPilihLokasi({
    super.key,
    required this.lokasiTerpilih,
    required this.onPilih,
  });

  static const List<LokasiBatamItem> daftarLokasi = [
    LokasiBatamItem(
      nama: 'Batam Center',
      subLokasi: 'Jl. Ahmad Yani',
      deskripsi: 'Dekat Mega Mall & Engku Putri',
      lat: 1.1300,
      lng: 104.0500,
    ),
    LokasiBatamItem(
      nama: 'Nagoya Hill',
      subLokasi: 'Lubuk Baja',
      deskripsi: 'Kawasan Kuliner & Nagoya Citywalk',
      lat: 1.1440,
      lng: 104.0150,
    ),
    LokasiBatamItem(
      nama: 'Harbour Bay',
      subLokasi: 'Batu Ampar',
      deskripsi: 'Area Ferry Terminal & Seafood',
      lat: 1.1550,
      lng: 103.9980,
    ),
    LokasiBatamItem(
      nama: 'Tiban Indah',
      subLokasi: 'Sekupang',
      deskripsi: 'Tiban Center & Pasar Cipta Puri',
      lat: 1.1120,
      lng: 103.9680,
    ),
  ];

  static Future<LokasiBatamItem?> tampilkan(
    BuildContext context, {
    required String lokasiSaatIni,
  }) {
    return showModalBottomSheet<LokasiBatamItem>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SheetPilihLokasi(
        lokasiTerpilih: lokasiSaatIni,
        onPilih: (item) => Navigator.pop(ctx, item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle pill di bagian atas
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6D6D6),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // Baris Judul & Tombol Tutup (X)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Pilih Lokasi di Batam',
                      style: LbText.heading(
                        16.5,
                        weight: FontWeight.w700,
                        color: const Color(0xFF212B27),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('📍', style: TextStyle(fontSize: 16)),
                  ],
                ),
                LbTekan(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F3F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFF495057),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Daftar Kartu Lokasi
            ...daftarLokasi.map((item) {
              final isAktif = lokasiTerpilih.trim().toLowerCase() ==
                      item.judulLengkap.trim().toLowerCase() ||
                  lokasiTerpilih.toLowerCase().contains(item.nama.toLowerCase());

              return Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: LbTekan(
                  onTap: () => onPilih(item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      color: isAktif
                          ? const Color(0xFFF1F8F1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isAktif
                            ? const Color(0xFF81C784)
                            : const Color(0xFFECECEC),
                        width: isAktif ? 1.3 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isAktif
                              ? const Color(0xFF81C784).withValues(alpha: 0.15)
                              : Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.judulLengkap,
                                style: LbText.heading(
                                  13.5,
                                  weight: FontWeight.w700,
                                  color: isAktif
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.deskripsi,
                                style: LbText.body(
                                  11.5,
                                  weight: FontWeight.w500,
                                  color: const Color(0xFF757575),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isAktif)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF2E7D32),
                            size: 22,
                          )
                        else
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFFB0B0B0),
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
