import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';

import 'models/surplus_draft.dart';
import 'widgets/top_toggle_widget.dart';
import 'widgets/target_kategori_card.dart';
import 'widgets/foto_informasi_card.dart';
import 'widgets/harga_card.dart';
import 'widgets/jadwal_card.dart';
import 'widgets/bottom_action_bar.dart';
import 'widgets/warna_lokal.dart';

class TambahProdukScreen extends StatefulWidget {
  final String phoneNumber;
  const TambahProdukScreen({super.key, required this.phoneNumber});

  @override
  State<TambahProdukScreen> createState() => _TambahProdukScreenState();
}

class _TambahProdukScreenState extends State<TambahProdukScreen> {
  final _namaCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();
  final _asliCtrl = TextEditingController();
  final _diskonCtrl = TextEditingController();

  TipeProduk _tipe = TipeProduk.paketKejutan;
  TargetSurplus _target = TargetSurplus.manusia;
  String? _kategori;

  int _stok = 3;
  TimeOfDay _mulaiAmbil = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay _batasMaksimal = const TimeOfDay(hour: 21, minute: 30);
  bool _tutupOtomatis = true;

  Uint8List? _fotoBytes;
  String? _fotoNama;
  String? _gambarLamaUrl;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _asliCtrl.addListener(() => setState(() {}));
    _diskonCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _catatanCtrl.dispose();
    _asliCtrl.dispose();
    _diskonCtrl.dispose();
    super.dispose();
  }

  // --- ACTIONS ---
  Future<void> _pilihFoto() async {
    final sumber = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(
                Icons.photo_camera_outlined,
                color: WarnaLokal.primaryDark,
              ),
              title: Text(
                'Ambil foto dengan kamera',
                style: AppColors.body(fontWeight: FontWeight.w700),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library_outlined,
                color: WarnaLokal.primaryDark,
              ),
              title: Text(
                'Pilih dari galeri',
                style: AppColors.body(fontWeight: FontWeight.w700),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (sumber == null) return;

    try {
      final x = await ImagePicker().pickImage(
        source: sumber,
        imageQuality: 80,
        maxWidth: 1600,
      );
      if (x == null) return;
      final bytes = await x.readAsBytes();
      if (!mounted) return;
      setState(() {
        _fotoBytes = bytes;
        _fotoNama = x.name.isEmpty ? 'foto.jpg' : x.name;
        _gambarLamaUrl = null;
      });
    } catch (e) {
      _snack('Tidak bisa membuka foto: $e');
    }
  }

  Future<void> _pilihWaktu(bool isMulai) async {
    final t = await showTimePicker(
      context: context,
      initialTime: isMulai ? _mulaiAmbil : _batasMaksimal,
    );
    if (t != null) {
      setState(() {
        if (isMulai) {
          _mulaiAmbil = t;
        } else {
          _batasMaksimal = t;
        }
      });
    }
  }

  void _snack(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _kirim(bool terbit) async {
    if (_namaCtrl.text.trim().isEmpty)
      return _snack('Nama produk wajib diisi.');
    if (_kategori == null) return _snack('Pilih kategori produk.');
    if (_asliCtrl.text.isEmpty) return _snack('Harga asli wajib diisi.');
    if (_diskonCtrl.text.isEmpty) return _snack('Harga diskon wajib diisi.');

    setState(() => _saving = true);

    // Panggil API Asli
    final hasil = await ApiService.tambahProdukLengkap(
      phoneNumber: widget.phoneNumber,
      nama: _namaCtrl.text.trim(),
      deskripsi: _catatanCtrl.text.trim(),
      tipe: _target == TargetSurplus.manusia ? 'dimakan' : 'kompos',
      kategori: _kategori!,
      hargaAsli: int.tryParse(_asliCtrl.text.replaceAll('.', '')) ?? 0,
      harga: int.tryParse(_diskonCtrl.text.replaceAll('.', '')) ?? 0,
      stok: _stok,
      waktuMulai:
          '${_mulaiAmbil.hour.toString().padLeft(2, '0')}:${_mulaiAmbil.minute.toString().padLeft(2, '0')}',
      waktuSelesai:
          '${_batasMaksimal.hour.toString().padLeft(2, '0')}:${_batasMaksimal.minute.toString().padLeft(2, '0')}',
      terbit: terbit,
      fotoBytes: _fotoBytes,
      fotoNama: _fotoNama,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (hasil['ok'] == true) {
      _snack('${hasil['message']}');
      Navigator.pop(context, true); // Berhasil, kembali ke list produk
    } else {
      _snack('${hasil['message']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarnaLokal.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          // Hapus const di sini karena WarnaLokal.textDark adalah getter dinamis
          icon: Icon(Icons.arrow_back, color: WarnaLokal.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Unggah Surplus', style: AppColors.heading(fontSize: 18)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    TopToggleWidget(
                      current: _tipe,
                      onChanged: (val) => setState(() => _tipe = val),
                    ),
                    const SizedBox(height: 16),
                    TargetKategoriCard(
                      target: _target,
                      kategori: _kategori,
                      onTargetChanged: (val) => setState(() {
                        _target = val;
                        _kategori = null;
                      }),
                      onKategoriChanged: (val) =>
                          setState(() => _kategori = val),
                    ),
                    const SizedBox(height: 16),
                    FotoInformasiCard(
                      namaCtrl: _namaCtrl,
                      catatanCtrl: _catatanCtrl,
                      target: _target,
                      fotoBytes: _fotoBytes,
                      gambarLamaUrl: _gambarLamaUrl,
                      onPickFoto: _pilihFoto,
                    ),
                    const SizedBox(height: 16),
                    HargaCard(
                      asliCtrl: _asliCtrl,
                      diskonCtrl: _diskonCtrl,
                      stok: _stok,
                      tutupOtomatis: _tutupOtomatis,
                      onStokChanged: (val) => setState(() => _stok = val),
                      onTutupOtomatisChanged: (val) =>
                          setState(() => _tutupOtomatis = val),
                    ),
                    const SizedBox(height: 16),
                    JadwalCard(
                      mulaiAmbil: _mulaiAmbil,
                      batasMaksimal: _batasMaksimal,
                      onPilihMulai: () => _pilihWaktu(true),
                      onPilihBatas: () => _pilihWaktu(false),
                    ),
                  ],
                ),
              ),
            ),
            BottomActionBar(
              saving: _saving,
              onSimpanDraf: () => _kirim(false),
              onTayangkan: () => _kirim(true),
            ),
          ],
        ),
      ),
    );
  }
}
