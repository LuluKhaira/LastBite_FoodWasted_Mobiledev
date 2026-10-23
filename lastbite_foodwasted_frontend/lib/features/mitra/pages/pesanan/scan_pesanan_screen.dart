import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class _UI {
  static Color get primary => AppColors.primary;
  static Color get primaryText => HSLColor.fromColor(AppColors.primary).withLightness(0.28).toColor();
  static Color get orangeText => HSLColor.fromColor(AppColors.orange).withLightness(0.35).toColor();
  static Color get primaryBg => AppColors.primary.withValues(alpha: 0.1);
  static Color get textSoft => const Color(0xFF6B6B6B);
  static Color get border => AppColors.textSoft.withValues(alpha: 0.15);
}

class ScanPesananScreen extends StatefulWidget {
  final String phoneNumber;
  const ScanPesananScreen({super.key, required this.phoneNumber});

  @override
  State<ScanPesananScreen> createState() => _ScanPesananScreenState();
}

class _ScanPesananScreenState extends State<ScanPesananScreen> {
  final _kodeCtrl = TextEditingController();
  bool _isScanning = true;
  bool _isProcessing = false;

  @override
  void dispose() {
    _kodeCtrl.dispose();
    super.dispose();
  }

  // --- FUNGSI VERIFIKASI (Nanti disambungkan ke API Laravel) ---
  Future<void> _verifikasiPesanan(String kode) async {
    if (kode.trim().length != 6) {
      _tampilkanPesan('Kode pesanan harus 6 digit angka!', isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    // TODO: Panggil API Laravel untuk cek kode pesanan
    // final hasil = await ApiService.verifikasiPesanan(widget.phoneNumber, kode);
    await Future.delayed(const Duration(seconds: 2)); // Simulasi Loading

    if (!mounted) return;
    setState(() => _isProcessing = false);

    // Simulasi Sukses
    _tampilkanBottomSheetSukses(kode);
  }

  void _tampilkanPesan(String pesan, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan, style: AppColors.body(color: Colors.white)),
        backgroundColor: isError ? Colors.redAccent : _UI.primaryText,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _tampilkanBottomSheetSukses(String kode) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: _UI.primaryBg, shape: BoxShape.circle),
              child: Icon(Icons.check_circle_rounded, color: _UI.primaryText, size: 48),
            ),
            const SizedBox(height: 16),
            Text('Pesanan Valid!', style: AppColors.heading(fontSize: 22)),
            const SizedBox(height: 8),
            Text(
              'Kode $kode berhasil diverifikasi. Silakan serahkan paket makanan kepada pelanggan.',
              textAlign: TextAlign.center,
              style: AppColors.body(fontSize: 14, color: _UI.textSoft, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup bottom sheet
                  Navigator.pop(context, true); // Kembali ke halaman pesanan dengan status sukses
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _UI.primaryText,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text('Selesai', style: AppColors.heading(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Scan Pesanan', style: AppColors.heading(fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- TAB SWITCH ---
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _UI.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isScanning = true),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isScanning ? _UI.primaryBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_scanner_rounded, size: 18, color: _isScanning ? _UI.primaryText : _UI.textSoft),
                            const SizedBox(width: 8),
                            Text('Scan QR', style: AppColors.heading(fontSize: 14, color: _isScanning ? _UI.primaryText : _UI.textSoft)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isScanning = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isScanning ? _UI.primaryBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.dialpad_rounded, size: 18, color: !_isScanning ? _UI.primaryText : _UI.textSoft),
                            const SizedBox(width: 8),
                            Text('Kode Manual', style: AppColors.heading(fontSize: 14, color: !_isScanning ? _UI.primaryText : _UI.textSoft)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- KONTEN: SCAN KAMERA ATAU INPUT MANUAL ---
            if (_isScanning) ...[
              // TAMPILAN KAMERA SCAN
              Container(
                height: 350,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _UI.primary, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    children: [
                      // Widget Kamera dari mobile_scanner
                      MobileScanner(
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                            if (barcode.rawValue != null) {
                              // Jika QR terdeteksi, langsung verifikasi
                              _verifikasiPesanan(barcode.rawValue!);
                              break;
                            }
                          }
                        },
                      ),
                      // Overlay Kotak Pemindai
                      Center(
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: _UI.primary, width: 3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      // Teks Panduan
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Arahkan kamera ke QR Pelanggan',
                              style: AppColors.body(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pastikan pencahayaan cukup dan QR Code terlihat jelas.',
                textAlign: TextAlign.center,
                style: AppColors.body(fontSize: 13, color: _UI.textSoft),
              ),
            ] else ...[
              // TAMPILAN INPUT MANUAL
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _UI.border),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: _UI.primaryBg, shape: BoxShape.circle),
                      child: Icon(Icons.pin_rounded, color: _UI.primaryText, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text('Masukkan Kode Pesanan', style: AppColors.heading(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(
                      'Minta pelanggan menyebutkan 6 digit kode pesanan yang ada di layar HP mereka.',
                      textAlign: TextAlign.center,
                      style: AppColors.body(fontSize: 13, color: _UI.textSoft, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _kodeCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: AppColors.heading(fontSize: 32, letterSpacing: 8),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '000000',
                        hintStyle: AppColors.heading(fontSize: 32, letterSpacing: 8, color: _UI.textSoft.withValues(alpha: 0.3)),
                        filled: true,
                        fillColor: AppColors.bg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: _UI.primaryText, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : () => _verifikasiPesanan(_kodeCtrl.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _UI.primaryText,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _isProcessing
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Verifikasi Kode', style: AppColors.heading(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}