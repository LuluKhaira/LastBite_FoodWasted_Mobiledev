import 'package:flutter/material.dart';
import '../../../../core/komponen/animasi_lb.dart';
import '../../../../core/tema/tema_lb.dart';

/// Baris informasi lokasi pengguna:
/// [📍 Batam Center • Jl. Ahmad Yani               Ubah Lokasi]
class BarisAlamatPengguna extends StatelessWidget {
  final String? alamat;
  final VoidCallback? onUbahLokasi;

  const BarisAlamatPengguna({
    super.key,
    this.alamat,
    this.onUbahLokasi,
  });

  @override
  Widget build(BuildContext context) {
    final teksLokasi = (alamat == null || alamat!.trim().isEmpty)
        ? 'Batam Center • Jl. Ahmad Yani'
        : alamat!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Kiri: Ikon pin hijau + Nama lokasi
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 17,
                  color: Color(0xFF2E7D32),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    teksLokasi,
                    style: LbText.heading(
                      12.5,
                      weight: FontWeight.w600,
                      color: const Color(0xFF2D3748),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Kanan: Tombol "Ubah Lokasi"
          LbTekan(
            onTap: onUbahLokasi,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Ubah Lokasi',
                style: LbText.heading(
                  12.5,
                  weight: FontWeight.w600,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
