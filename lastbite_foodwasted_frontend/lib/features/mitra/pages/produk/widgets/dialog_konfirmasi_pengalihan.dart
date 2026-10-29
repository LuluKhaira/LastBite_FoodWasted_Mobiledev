import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/produk/models/produk_model.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';
import 'warna_lokal.dart';

class DialogKonfirmasiPengalihan extends StatefulWidget {
  final Produk produk;
  final String phoneNumber;
  final VoidCallback onBerhasil;

  const DialogKonfirmasiPengalihan({
    super.key,
    required this.produk,
    required this.phoneNumber,
    required this.onBerhasil,
  });

  static Future<void> show(
    BuildContext context, {
    required Produk produk,
    required String phoneNumber,
    required VoidCallback onBerhasil,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DialogKonfirmasiPengalihan(
        produk: produk,
        phoneNumber: phoneNumber,
        onBerhasil: onBerhasil,
      ),
    );
  }

  @override
  State<DialogKonfirmasiPengalihan> createState() => _DialogKonfirmasiPengalihanState();
}

class _DialogKonfirmasiPengalihanState extends State<DialogKonfirmasiPengalihan> {
  late TextEditingController _beratAktualCtrl;
  final TextEditingController _catatanCtrl = TextEditingController();
  String? _targetKategori;
  bool _loading = false;
  List<Map<String, dynamic>> _opsiTujuan = [];

  @override
  void initState() {
    super.initState();
    // Pre-fill kategori tujuan dari konfigurasi awal produk
    _targetKategori = widget.produk.targetKategoriPengalihan ?? 'Pakan Ternak & Ikan';

    // Pre-fill estimasi berat jika ada
    final est = widget.produk.totalPerkiraanBerat;
    _beratAktualCtrl = TextEditingController(
      text: est > 0 ? est.toStringAsFixed(1) : '',
    );

    _muatOpsiKategori();
  }

  Future<void> _muatOpsiKategori() async {
    final data = await ApiService.getOpsiPengalihan();
    if (data != null && mounted) {
      final list = (data['opsi_tujuan'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [];
      setState(() {
        _opsiTujuan = list;
        if (_targetKategori == null && list.isNotEmpty) {
          _targetKategori = list.first['kategori'];
        }
      });
    }
  }

  @override
  void dispose() {
    _beratAktualCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  void _snack(String pesan, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan, style: AppColors.body(color: Colors.white)),
        backgroundColor: error ? Colors.redAccent : AppColors.textDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _prosesKonfirmasi(String aksi) async {
    if (aksi == 'alihkan') {
      final beratStr = _beratAktualCtrl.text.trim().replaceAll(',', '.');
      final berat = double.tryParse(beratStr);

      if (berat == null || berat <= 0) {
        _snack('Masukkan berat aktual yang valid (harus lebih dari 0 kg).', error: true);
        return;
      }

      if (_targetKategori == null || _targetKategori!.isEmpty) {
        _snack('Pilih kategori tujuan akhir pengalihan.', error: true);
        return;
      }

      setState(() => _loading = true);

      final res = await ApiService.konfirmasiPengalihan(
        phoneNumber: widget.phoneNumber,
        idProduk: widget.produk.id,
        aksi: 'alihkan',
        beratAktual: berat,
        targetKategori: _targetKategori,
        catatan: _catatanCtrl.text.trim().isEmpty ? null : _catatanCtrl.text.trim(),
      );

      if (!mounted) return;
      setState(() => _loading = false);

      if (res['ok'] == true) {
        Navigator.pop(context);
        widget.onBerhasil();
        _snack(res['message'] ?? 'Produk surplus berhasil dialihkan!');
      } else {
        _snack(res['message'] ?? 'Gagal mengalihkan produk.', error: true);
      }
    } else {
      // AKSI: BUANG / TIDAK LAYAK
      final yakin = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Konfirmasi Pembuangan', style: AppColors.heading(fontSize: 16)),
          content: Text(
            'Apakah Anda yakin sisa produk ini tidak layak dialihkan dan akan dibuang?\n\nProduk TIDAK akan diterbitkan ke Pakan/Kompos.',
            style: AppColors.body(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Batal', style: AppColors.body(color: WarnaLokal.textSoft)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Ya, Buang', style: AppColors.body(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );

      if (yakin != true) return;

      setState(() => _loading = true);

      final res = await ApiService.konfirmasiPengalihan(
        phoneNumber: widget.phoneNumber,
        idProduk: widget.produk.id,
        aksi: 'buang',
        catatan: _catatanCtrl.text.trim().isEmpty ? 'Dinilai tidak layak oleh mitra' : _catatanCtrl.text.trim(),
      );

      if (!mounted) return;
      setState(() => _loading = false);

      if (res['ok'] == true) {
        Navigator.pop(context);
        widget.onBerhasil();
        _snack(res['message'] ?? 'Produk ditandai dibuang.');
      } else {
        _snack(res['message'] ?? 'Gagal memproses.', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final p = widget.produk;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Judul
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.autorenew_rounded, color: AppColors.orange, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Konfirmasi Pengalihan Sisa', style: AppColors.heading(fontSize: 16)),
                      Text(
                        'Timbang sisa stok sebelum dialihkan ke Pakan/Kompos',
                        style: AppColors.body(fontSize: 11, color: WarnaLokal.textSoft),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ringkasan Data Produk Awal
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: WarnaLokal.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.nama, style: AppColors.heading(fontSize: 14)),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  _rowInfo('Jumlah Paket Tersisa', '${p.stok} paket'),
                  _rowInfo('Perkiraan Berat / Paket', '${p.perkiraanBeratPerPaket} kg'),
                  _rowInfo('Total Perkiraan Sisa', '${p.totalPerkiraanBerat} kg', isBold: true),
                  _rowInfo(
                    'Kategori Pilihan Awal',
                    p.targetKategoriPengalihan ?? 'Pakan Ternak & Ikan',
                    textColor: WarnaLokal.primaryDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Peringatan Kelayakan
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 18, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Periksa kondisi fisik makanan. Pastikan sisa produk belum basi atau berjamur sebelum dialihkan. Jika tidak layak, tekan "Buang / Tidak Layak".',
                      style: AppColors.body(fontSize: 11, color: Colors.brown, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Form Kategori Tujuan Akhir
            Text(
              'KATEGORI TUJUAN AKHIR',
              style: AppColors.body(fontSize: 11, fontWeight: FontWeight.w800, color: WarnaLokal.textSoft),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: WarnaLokal.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _targetKategori,
                  hint: Text('Pilih Kategori Tujuan', style: AppColors.body(fontSize: 12)),
                  items: (_opsiTujuan.isNotEmpty
                          ? _opsiTujuan
                          : [
                              {'kategori': 'Pakan Ternak & Ikan', 'harga_per_kg': 5000},
                              {'kategori': 'Bahan Kompos & Pupuk', 'harga_per_kg': 3000},
                              {'kategori': 'Ampas Kelapa & Kopi', 'harga_per_kg': 2500},
                              {'kategori': 'Limbah Organik', 'harga_per_kg': 2000},
                            ])
                      .map((opt) {
                    final nama = '${opt['kategori']}';
                    final harga = opt['harga_per_kg'] != null && opt['harga_per_kg'] > 0
                        ? ' • Rp ${opt['harga_per_kg']}/kg'
                        : '';
                    return DropdownMenuItem<String>(
                      value: nama,
                      child: Text(
                        '$nama$harga',
                        style: AppColors.body(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _targetKategori = val),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Form Input Berat Aktual (kg)
            Text(
              'BERAT AKTUAL SISA PRODUK (KG) *',
              style: AppColors.body(fontSize: 11, fontWeight: FontWeight.w800, color: WarnaLokal.textSoft),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _beratAktualCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppColors.heading(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Contoh: 1.3',
                suffixText: 'kg',
                suffixStyle: AppColors.heading(fontSize: 16, color: WarnaLokal.primaryDark),
                filled: true,
                fillColor: WarnaLokal.mint.withValues(alpha: 0.3),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: WarnaLokal.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: WarnaLokal.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hasil timbangan riil sisa produk. Nilai ini menjadi stok resmi produk Pakan/Kompos.',
              style: AppColors.body(fontSize: 10.5, color: WarnaLokal.textSoft),
            ),
            const SizedBox(height: 14),

            // Form Catatan (opsional)
            Text(
              'CATATAN KONDISI (OPSIONAL)',
              style: AppColors.body(fontSize: 11, fontWeight: FontWeight.w800, color: WarnaLokal.textSoft),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _catatanCtrl,
              maxLines: 2,
              style: AppColors.body(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Contoh: Sisa roti masih bagus dan kering, tidak berjamur.',
                hintStyle: AppColors.body(fontSize: 12, color: WarnaLokal.textSoft),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: WarnaLokal.border),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WarnaLokal.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: () => _prosesKonfirmasi('alihkan'),
                      child: Text(
                        'Alihkan Produk ke Pakan/Kompos',
                        style: AppColors.body(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => _prosesKonfirmasi('buang'),
                      child: Text(
                        'Buang / Tidak Layak Dialihkan',
                        style: AppColors.body(color: Colors.redAccent, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _rowInfo(String label, String value, {bool isBold = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppColors.body(fontSize: 12, color: WarnaLokal.textSoft)),
          Text(
            value,
            style: AppColors.body(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: textColor ?? WarnaLokal.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

