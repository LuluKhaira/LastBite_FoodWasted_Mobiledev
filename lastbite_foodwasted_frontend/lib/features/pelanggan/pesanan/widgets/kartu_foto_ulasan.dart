import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/tema/tema_lb.dart';
import 'kartu_nilai.dart';

/// Bagian "Foto Paket (Bukti Penyelamatan)": maksimal 2 foto.
class KartuFotoUlasan extends StatelessWidget {
  final List<XFile> foto;
  final VoidCallback onTambah;
  final ValueChanged<int> onHapus;

  const KartuFotoUlasan({
    super.key,
    required this.foto,
    required this.onTambah,
    required this.onHapus,
  });

  static const maks = 2;
  static const _ukuran = 96.0;

  @override
  Widget build(BuildContext context) {
    return KartuNilai(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Foto Paket (Bukti Penyelamatan)',
              style: LbText.heading(16, weight: FontWeight.w700, height: 1.25)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (var i = 0; i < foto.length; i++)
                _FotoMini(
                  key: ValueKey(foto[i].path),
                  file: foto[i],
                  onHapus: () => onHapus(i),
                ),
              if (foto.length < maks) _tombolTambah(),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.photo_library_outlined,
                  size: 16, color: LbColors.textGrey),
              const SizedBox(width: 6),
              Text('Maks. $maks foto (${foto.length}/$maks)',
                  style: LbText.body(12, weight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tombolTambah() => GestureDetector(
        onTap: onTambah,
        child: Container(
          width: _ukuran,
          height: _ukuran,
          decoration: BoxDecoration(
            color: LbColors.sage.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_a_photo_outlined,
                  size: 28, color: LbColors.sageDeep),
              const SizedBox(height: 6),
              Text('Unggah Foto',
                  style: LbText.heading(12,
                      weight: FontWeight.w600, color: LbColors.forest)),
            ],
          ),
        ),
      );
}

class _FotoMini extends StatefulWidget {
  final XFile file;
  final VoidCallback onHapus;

  const _FotoMini({super.key, required this.file, required this.onHapus});

  @override
  State<_FotoMini> createState() => _FotoMiniState();
}

class _FotoMiniState extends State<_FotoMini> {
  // readAsBytes dipakai supaya preview jalan di Chrome (web) maupun HP.
  late final Future<Uint8List> _bytes = widget.file.readAsBytes();

  @override
  Widget build(BuildContext context) {
    const u = KartuFotoUlasan._ukuran;
    return SizedBox(
      width: u,
      height: u,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: FutureBuilder<Uint8List>(
                future: _bytes,
                builder: (_, s) => s.hasData
                    ? Image.memory(s.data!, fit: BoxFit.cover)
                    : Container(color: LbColors.offWhite),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: widget.onHapus,
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: Color(0xCC1F2A1F),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.close_rounded, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}