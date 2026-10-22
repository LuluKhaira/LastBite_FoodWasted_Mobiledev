import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/produk/models/surplus_draft.dart';
import 'base_card.dart';
import 'warna_lokal.dart';

class FotoInformasiCard extends StatelessWidget {
  final TextEditingController namaCtrl;
  final TextEditingController catatanCtrl;
  final TargetSurplus target;
  final Uint8List? fotoBytes;
  final String? gambarLamaUrl;
  final VoidCallback onPickFoto;

  const FotoInformasiCard({
    super.key,
    required this.namaCtrl,
    required this.catatanCtrl,
    required this.target,
    required this.fotoBytes,
    this.gambarLamaUrl,
    required this.onPickFoto,
  });

  @override
  Widget build(BuildContext context) {
    final adaFoto = fotoBytes != null || gambarLamaUrl != null;
    final overlayText = target == TargetSurplus.manusia ? 'Foto Sampul Otomatis' : 'Foto Sampul Bawaan: Kompos & Pupuk Organik';

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('FOTO & INFORMASI', style: AppColors.heading(fontSize: 12, color: WarnaLokal.textSoft)),
              GestureDetector(
                onTap: onPickFoto,
                child: Row(
                  children: [
                    Icon(Icons.edit_square, size: 16, color: WarnaLokal.primaryDark),
                    const SizedBox(width: 4),
                    Text('Ubah Foto', style: AppColors.body(fontSize: 12, fontWeight: FontWeight.w700, color: WarnaLokal.primaryDark)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onPickFoto,
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: WarnaLokal.mintDeep,
                borderRadius: BorderRadius.circular(12),
                image: adaFoto 
                    ? DecorationImage(
                        image: fotoBytes != null ? MemoryImage(fotoBytes!) : NetworkImage(gambarLamaUrl!) as ImageProvider,
                        fit: BoxFit.cover,
                      ) 
                    : null,
              ),
              child: Stack(
                children: [
                  if (!adaFoto) Center(child: Icon(Icons.add_a_photo_outlined, size: 40, color: WarnaLokal.textSoft)),
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)]),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.camera_alt_outlined, size: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              adaFoto ? 'Foto berhasil diunggah' : overlayText,
                              style: AppColors.body(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('JUDUL PENAWARAN', style: AppColors.body(fontSize: 11, fontWeight: FontWeight.w700, color: WarnaLokal.textSoft)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: WarnaLokal.border)),
            child: TextField(
              controller: namaCtrl,
              maxLength: 50,
              style: AppColors.body(fontSize: 14, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                border: InputBorder.none,
                counterText: '',
                hintText: 'Contoh: Karung Sisa Sayur & Bahan Pupuk Organik (15 kg)',
                hintStyle: AppColors.body(fontSize: 13, color: WarnaLokal.textSoft),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('CATATAN & ALERGEN', style: AppColors.body(fontSize: 11, fontWeight: FontWeight.w700, color: WarnaLokal.textSoft)),
              Text('Opsional', style: AppColors.body(fontSize: 11, color: WarnaLokal.textSoft)),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: WarnaLokal.border)),
            child: TextField(
              controller: catatanCtrl,
              maxLines: 3,
              style: AppColors.body(fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Contoh: Mengandung gluten, telur, kacang. Kondisi segar hari ini.',
                hintStyle: AppColors.body(fontSize: 13, color: WarnaLokal.textSoft),
              ),
            ),
          ),
        ],
      ),
    );
  }
}