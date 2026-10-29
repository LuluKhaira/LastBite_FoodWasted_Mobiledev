import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';

import 'models/surplus_draft.dart';
import 'widgets/target_kategori_card.dart';
import 'widgets/foto_informasi_card.dart';
import 'widgets/harga_card.dart';
import 'widgets/jadwal_card.dart';
import 'widgets/bottom_action_bar.dart';
import 'widgets/warna_lokal.dart';
import 'widgets/pengalihan_section_card.dart';

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
  String _skemaHarga = 'diskon'; // 'diskon' | 'sedekah'

  int _stok = 3;
  TimeOfDay _mulaiAmbil = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay _batasMaksimal = const TimeOfDay(hour: 21, minute: 30);
  DateTime _kadaluarsa = DateTime.now().add(const Duration(hours: 4));

  // Jam operasional hari ini (dari menu Jam Buka). null = belum diatur.
  TimeOfDay? _jamTutupToko;
  bool _tokoLibur = false;

  Uint8List? _fotoBytes;
  String? _fotoNama;
  String? _gambarLamaUrl;

  bool _saving = false;

  // Konfigurasi Pengalihan Sisa ke Pakan/Kompos (Default NONAKTIF)
  bool _bersediaDialihkan = false;
  String? _targetKategoriPengalihan;
  List<Map<String, dynamic>> _opsiPengalihan = [];

  @override
  void initState() {
    super.initState();
    _asliCtrl.addListener(() => setState(() {}));
    _diskonCtrl.addListener(() => setState(() {}));
    _muatJamToko();
    _muatOpsiPengalihan();
  }

  Future<void> _muatOpsiPengalihan() async {
    final res = await ApiService.getOpsiPengalihan();
    if (res != null && mounted) {
      final list = (res['opsi_tujuan'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [];
      setState(() {
        _opsiPengalihan = list;
        if (_targetKategoriPengalihan == null && list.isNotEmpty) {
          _targetKategoriPengalihan = list.first['kategori'];
        }
      });
    }
  }

  int _menit(TimeOfDay t) => t.hour * 60 + t.minute;

  String _fmtJam(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  TimeOfDay? _parseJam(String s) {
    final p = s.split(':');
    if (p.length < 2) return null;
    final h = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  Future<void> _muatJamToko() async {
    final data = await ApiService.getJamOperasional(widget.phoneNumber);
    if (!mounted || data == null) return;

    final hariIni = DateTime.now().weekday; // 1 = Senin ... 7 = Minggu
    for (final d in data) {
      if ((int.tryParse('${d['hari']}') ?? 0) != hariIni) continue;
      final buka = d['buka'] == true || d['buka'] == 1;
      final tutup = _parseJam('${d['tutup']}');
      setState(() {
        _tokoLibur = !buka;
        _jamTutupToko = buka ? tutup : null;
        // Default batas pengambilan jangan melewati jam tutup toko
        if (buka && tutup != null && _menit(_batasMaksimal) > _menit(tutup)) {
          _batasMaksimal = tutup;
        }
      });
      break;
    }
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
    if (t == null) return;

    final tutup = _jamTutupToko;
    if (!isMulai && tutup != null && _menit(t) > _menit(tutup)) {
      _snack(
        'Batas pengambilan (${_fmtJam(t)}) melewati jam tutup toko (${_fmtJam(tutup)}). '
        'Pilih jam yang lebih awal, atau ubah jam tutup di menu Jam Buka.',
      );
      return;
    }

    setState(() {
      if (isMulai) {
        _mulaiAmbil = t;
      } else {
        _batasMaksimal = t;
      }
    });
  }

  Future<void> _pilihKadaluarsa() async {
    final sekarang = DateTime.now();
    final awal = _kadaluarsa.isBefore(sekarang) ? sekarang : _kadaluarsa;
    final tgl = await showDatePicker(
      context: context,
      initialDate: awal,
      firstDate: DateTime(sekarang.year, sekarang.month, sekarang.day),
      lastDate: sekarang.add(const Duration(days: 30)),
    );
    if (tgl == null || !mounted) return;
    final jam = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(awal),
    );
    if (jam == null) return;
    setState(() {
      _kadaluarsa = DateTime(tgl.year, tgl.month, tgl.day, jam.hour, jam.minute);
    });
  }

  void _snack(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _kirim(bool terbit) async {
    if (_namaCtrl.text.trim().isEmpty) {
      return _snack('Nama produk wajib diisi.');
    }
    if (_kategori == null) return _snack('Pilih kategori produk.');
    if (_asliCtrl.text.isEmpty) return _snack('Harga asli wajib diisi.');
    final hargaAsliInt = int.tryParse(_asliCtrl.text.replaceAll('.', '')) ?? 0;
    if (hargaAsliInt <= 0) return _snack('Harga asli harus lebih dari Rp 0.');

    int hargaDiskonInt = 0;
    if (_skemaHarga == 'sedekah') {
      hargaDiskonInt = 0;
    } else {
      if (_diskonCtrl.text.isEmpty) return _snack('Harga diskon wajib diisi.');
      hargaDiskonInt = int.tryParse(_diskonCtrl.text.replaceAll('.', '')) ?? 0;
      if (hargaDiskonInt <= 0) return _snack('Harga diskon harus lebih dari Rp 0.');
      if (hargaDiskonInt >= hargaAsliInt) {
        return _snack('Harga diskon harus lebih hemat dari harga normal toko.');
      }
    }
    if (terbit &&
        _target == TargetSurplus.manusia &&
        _kadaluarsa.isBefore(DateTime.now())) {
      return _snack('Waktu kadaluarsa harus setelah sekarang.');
    }

    if (terbit && _tokoLibur) {
      return _snack('Toko kamu diatur libur hari ini. Ubah di menu Jam Buka untuk menerbitkan produk.');
    }
    if (terbit) {
      final sekarang = TimeOfDay.now();
      final tutup = _jamTutupToko;
      if (tutup != null && _menit(sekarang) >= _menit(tutup)) {
        return _snack(
          'Toko sudah tutup (jam tutup ${_fmtJam(tutup)}). Pilih jam setelah sekarang, '
          'atau ubah jam tutup di menu Jam Buka.',
        );
      }
      if (_menit(_batasMaksimal) <= _menit(sekarang)) {
        return _snack(
          'Batas pengambilan (${_fmtJam(_batasMaksimal)}) sudah lewat. '
          'Pilih jam setelah sekarang (${_fmtJam(sekarang)}).',
        );
      }
      if (_menit(_mulaiAmbil) >= _menit(_batasMaksimal)) {
        return _snack('Jam mulai ambil harus lebih awal dari batas pengambilan.');
      }
    }

    final tutupToko = _jamTutupToko;
    if (terbit && tutupToko != null && _menit(_batasMaksimal) > _menit(tutupToko)) {
      return _snack(
        'Batas pengambilan (${_fmtJam(_batasMaksimal)}) melewati jam tutup toko (${_fmtJam(tutupToko)}).',
      );
    }

    if (_target == TargetSurplus.manusia && _bersediaDialihkan) {
      if (_targetKategoriPengalihan == null || _targetKategoriPengalihan!.isEmpty) {
        return _snack('Pilih kategori tujuan pengalihan Pakan/Kompos.');
      }
    }

    setState(() => _saving = true);

    // Panggil API Asli
    final hasil = await ApiService.tambahProdukLengkap(
      phoneNumber: widget.phoneNumber,
      nama: _namaCtrl.text.trim(),
      deskripsi: _catatanCtrl.text.trim(),
      tipe: _target == TargetSurplus.manusia ? 'dimakan' : 'kompos',
      kategori: _kategori!,
      skemaHarga: _skemaHarga,
      hargaAsli: hargaAsliInt,
      harga: hargaDiskonInt,
      stok: _stok,
      waktuMulai:
          '${_mulaiAmbil.hour.toString().padLeft(2, '0')}:${_mulaiAmbil.minute.toString().padLeft(2, '0')}',
      waktuSelesai:
          '${_batasMaksimal.hour.toString().padLeft(2, '0')}:${_batasMaksimal.minute.toString().padLeft(2, '0')}',
      kadaluarsa: _target == TargetSurplus.manusia
          ? _kadaluarsa.toIso8601String()
          : '',
      terbit: terbit,
      bersediaDialihkan: _target == TargetSurplus.manusia && _bersediaDialihkan,
      targetKategoriPengalihan: _target == TargetSurplus.manusia && _bersediaDialihkan
          ? _targetKategoriPengalihan
          : null,
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
                      skemaHarga: _skemaHarga,
                      onSkemaHargaChanged: (val) => setState(() {
                        _skemaHarga = val;
                        if (_skemaHarga == 'sedekah') {
                          _diskonCtrl.text = '0';
                        } else if (_diskonCtrl.text == '0') {
                          _diskonCtrl.clear();
                        }
                      }),
                      stok: _stok,
                      satuanLabel: _target == TargetSurplus.manusia
                          ? 'Satuan: Paket'
                          : 'Satuan: Karung (15 Kg)',
                      onStokChanged: (val) => setState(() => _stok = val),
                    ),
                    const SizedBox(height: 16),
                    JadwalCard(
                      mulaiAmbil: _mulaiAmbil,
                      batasMaksimal: _batasMaksimal,
                      kadaluarsa: _kadaluarsa,
                      tampilKadaluarsa: _target == TargetSurplus.manusia,
                      jamTutupToko: _jamTutupToko,
                      tokoLibur: _tokoLibur,
                      onPilihMulai: () => _pilihWaktu(true),
                      onPilihBatas: () => _pilihWaktu(false),
                      onPilihKadaluarsa: _pilihKadaluarsa,
                    ),
                    if (_target == TargetSurplus.manusia) ...[
                      const SizedBox(height: 16),
                      PengalihanSectionCard(
                        bersedia: _bersediaDialihkan,
                        onBersediaChanged: (val) =>
                            setState(() => _bersediaDialihkan = val),
                        targetKategori: _targetKategoriPengalihan,
                        onTargetKategoriChanged: (val) =>
                            setState(() => _targetKategoriPengalihan = val),
                        opsiKategori: _opsiPengalihan,
                      ),
                    ],
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