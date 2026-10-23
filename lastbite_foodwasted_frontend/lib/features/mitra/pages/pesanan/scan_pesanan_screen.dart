import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Layar scan QR pengambilan (kamera sungguhan) + input kode manual.
/// Terhubung ke ApiService.verifikasiPengambilan -> POST /mitra/pesanan/verify-pickup.
/// Mengembalikan `true` lewat Navigator.pop kalau pengambilan berhasil.
class ScanAmbilPesananScreen extends StatefulWidget {
  final String phoneNumber;
  final String? kodePesanan; // hanya untuk ditampilkan di header
  final String? namaPembeli;
  final bool mulaiManual;

  const ScanAmbilPesananScreen({
    super.key,
    required this.phoneNumber,
    this.kodePesanan,
    this.namaPembeli,
    this.mulaiManual = false,
  });

  @override
  State<ScanAmbilPesananScreen> createState() => _ScanAmbilPesananScreenState();
}

class _ScanAmbilPesananScreenState extends State<ScanAmbilPesananScreen> {
  final _kodeCtrl = TextEditingController();
  late bool _modeScan = !widget.mulaiManual;
  bool _proses = false;

  // Cegah QR yang sama diproses berulang-ulang saat kamera masih mengarah ke sana.
  String? _kodeTerakhir;
  DateTime? _waktuTerakhir;

  @override
  void dispose() {
    _kodeCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg, style: AppColors.body(color: Colors.white)),
          backgroundColor: error ? AppColors.merah : AppColors.hijauTua,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
  }

  Future<void> _verifikasi(String raw) async {
    if (_proses) return;
    final kode = raw.trim().toUpperCase();
    if (kode.isEmpty) {
      _snack('Masukkan kode pengambilan dulu ya.', error: true);
      return;
    }

    setState(() => _proses = true);
    dynamic res;
    try {
      res = await ApiService.verifikasiPengambilan(widget.phoneNumber, kode);
    } catch (_) {
      res = null;
    }
    if (!mounted) return;
    setState(() => _proses = false);

    if (res is Map && res['ok'] == true) {
      await _dialogBerhasil(res);
    } else {
      _snack(
        res is Map
            ? (res['message'] ?? 'Kode tidak cocok atau pesanan belum siap.').toString()
            : 'Tidak bisa terhubung ke server. Coba lagi.',
        error: true,
      );
    }
  }

  void _onDeteksi(BarcodeCapture capture) {
    if (_proses) return;
    for (final b in capture.barcodes) {
      final v = b.rawValue;
      if (v == null || v.trim().isEmpty) continue;

      final sekarang = DateTime.now();
      if (_kodeTerakhir == v &&
          _waktuTerakhir != null &&
          sekarang.difference(_waktuTerakhir!).inSeconds < 4) {
        return;
      }
      _kodeTerakhir = v;
      _waktuTerakhir = sekarang;
      _verifikasi(v);
      return;
    }
  }

  Future<void> _dialogBerhasil(Map res) async {
    final p = (res['data'] is Map) ? res['data'] as Map : {};
    final pendapatan = res['pendapatan'] ?? 0;
    final saldo = res['saldo_terbaru'];

    String rpTxt(dynamic v) {
      final n = (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
      final s = n.abs().toString();
      final b = StringBuffer();
      for (var i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
        b.write(s[i]);
      }
      return 'Rp$b';
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.hijauTua, size: 52),
            ),
            const SizedBox(height: 16),
            Text('Pengambilan Berhasil!',
                textAlign: TextAlign.center,
                style: AppColors.heading(fontSize: 19)),
            const SizedBox(height: 8),
            Text(
              'Pesanan #${p['kode'] ?? widget.kodePesanan ?? ''} sudah diserahkan ke ${p['pembeli_nama'] ?? widget.namaPembeli ?? 'pembeli'}.',
              textAlign: TextAlign.center,
              style: AppColors.body(fontSize: 14, color: AppColors.textSoft),
            ),
            if (pendapatan != 0) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.hijauMuda,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text('Pendapatan masuk ke saldo',
                        style: AppColors.body(
                            fontSize: 12.5, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('+ ${rpTxt(pendapatan)}',
                        style: AppColors.heading(
                            fontSize: 22, color: AppColors.hijauTua)),
                    if (saldo != null) ...[
                      const SizedBox(height: 4),
                      Text('Saldo toko: ${rpTxt(saldo)}',
                          style: AppColors.body(
                              fontSize: 12, color: AppColors.textSoft)),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context, true);
                },
                child: Text('Selesai',
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── UI ─────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text('Ambil Pesanan', style: AppColors.heading(fontSize: 18)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (widget.kodePesanan != null) _headerPesanan(),
              _pilihMode(),
              const SizedBox(height: 16),
              if (_modeScan) _areaScan() else _areaManual(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerPesanan() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_bag_rounded,
              color: AppColors.hijauTua, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pesanan #${widget.kodePesanan}',
                    style: AppColors.heading(fontSize: 14)),
                if (widget.namaPembeli != null)
                  Text('Pembeli: ${widget.namaPembeli}',
                      style: AppColors.body(
                          fontSize: 13, color: AppColors.textSoft)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pilihMode() {
    Widget tab(String teks, IconData ikon, bool aktif, VoidCallback onTap) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: aktif ? AppColors.orange : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(ikon,
                    size: 20, color: aktif ? Colors.white : AppColors.textSoft),
                const SizedBox(width: 8),
                Text(teks,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: aktif ? Colors.white : AppColors.textSoft)),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textSoft.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          tab('Scan QR', Icons.qr_code_scanner_rounded, _modeScan,
              () => setState(() => _modeScan = true)),
          tab('Kode Manual', Icons.keyboard_rounded, !_modeScan,
              () => setState(() => _modeScan = false)),
        ],
      ),
    );
  }

  Widget _areaScan() {
    return Column(
      children: [
        Container(
          height: 340,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                MobileScanner(onDetect: _onDeteksi),
                Center(
                  child: Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.orange, width: 3),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
                if (_proses)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Arahkan kamera ke QR di HP pembeli',
          textAlign: TextAlign.center,
          style: AppColors.heading(fontSize: 15),
        ),
        const SizedBox(height: 4),
        Text(
          'Pastikan cahaya cukup. Kalau tidak bisa, pakai "Kode Manual".',
          textAlign: TextAlign.center,
          style: AppColors.body(fontSize: 13, color: AppColors.textSoft),
        ),
      ],
    );
  }

  Widget _areaManual() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.textSoft.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pin_rounded,
                color: AppColors.orange, size: 30),
          ),
          const SizedBox(height: 14),
          Text('Masukkan Kode Pengambilan',
              style: AppColors.heading(fontSize: 17)),
          const SizedBox(height: 6),
          Text(
            'Minta pembeli menyebutkan kode yang tampil di HP mereka.',
            textAlign: TextAlign.center,
            style: AppColors.body(
                fontSize: 13, color: AppColors.textSoft, height: 1.4),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _kodeCtrl,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            enabled: !_proses,
            style: AppColors.heading(fontSize: 26, letterSpacing: 3),
            decoration: InputDecoration(
              hintText: 'LB-123456',
              hintStyle: AppColors.heading(
                fontSize: 22,
                letterSpacing: 2,
                color: AppColors.textSoft.withValues(alpha: 0.4),
              ),
              filled: true,
              fillColor: AppColors.bg,
              suffixIcon: _kodeCtrl.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => setState(_kodeCtrl.clear),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.orange, width: 2),
              ),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: _verifikasi,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _proses ? null : () => _verifikasi(_kodeCtrl.text),
              icon: _proses
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline_rounded,
                      color: Colors.white),
              label: Text(
                _proses ? 'Memeriksa...' : 'Konfirmasi Pengambilan',
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}