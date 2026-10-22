import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class _UI {
  static Color get primary => AppColors.primary;
  static Color get primaryText => HSLColor.fromColor(AppColors.primary).withLightness(0.28).toColor();
  static Color get primaryBg => AppColors.primary.withValues(alpha: 0.1);
  static Color get textSoft => const Color(0xFF6B6B6B);
  static Color get border => AppColors.textSoft.withValues(alpha: 0.15);
}

class ScanPesananBottomSheet extends StatefulWidget {
  final String phoneNumber;
  const ScanPesananBottomSheet({super.key, required this.phoneNumber});

  @override
  State<ScanPesananBottomSheet> createState() => _ScanPesananBottomSheetState();
}

class _ScanPesananBottomSheetState extends State<ScanPesananBottomSheet> {
  final _kodeCtrl = TextEditingController();
  bool _isScanning = true;
  bool _isProcessing = false;

  @override
  void dispose() {
    _kodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _verifikasiPesanan(String kode) async {
    if (kode.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kode pesanan harus 6 digit angka!', style: AppColors.body(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // TODO: Panggil API Laravel untuk cek kode pesanan
    await Future.delayed(const Duration(seconds: 2)); // Simulasi Loading

    if (!mounted) return;
    setState(() => _isProcessing = false);

    // Tampilkan Dialog Sukses
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: _UI.primaryBg, shape: BoxShape.circle),
              child: Icon(Icons.check_circle_rounded, color: _UI.primaryText, size: 48),
            ),
            const SizedBox(height: 16),
            Text('Pesanan Valid!', style: AppColors.heading(fontSize: 20)),
            const SizedBox(height: 8),
            Text(
              'Kode $kode berhasil diverifikasi.',
              textAlign: TextAlign.center,
              style: AppColors.body(fontSize: 14, color: _UI.textSoft),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Tutup Dialog
                Navigator.pop(context); // Tutup Bottom Sheet
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _UI.primaryText,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Selesai', style: AppColors.heading(fontSize: 14, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // Tinggi 75% layar
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _UI.textSoft.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Scan Pesanan', style: AppColors.heading(fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textDark),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Toggle Tab
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.bg,
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
                          color: _isScanning ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _isScanning ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_scanner_rounded, size: 18, color: _isScanning ? _UI.primaryText : _UI.textSoft),
                            const SizedBox(width: 8),
                            Text('Scan QR', style: AppColors.heading(fontSize: 13, color: _isScanning ? _UI.primaryText : _UI.textSoft)),
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
                          color: !_isScanning ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: !_isScanning ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.dialpad_rounded, size: 18, color: !_isScanning ? _UI.primaryText : _UI.textSoft),
                            const SizedBox(width: 8),
                            Text('Kode Manual', style: AppColors.heading(fontSize: 13, color: !_isScanning ? _UI.primaryText : _UI.textSoft)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Area Konten
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _isScanning 
                ? _buildScannerArea() 
                : _buildManualInputArea(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerArea() {
    return Column(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _UI.primary, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null) {
                        _verifikasiPesanan(barcode.rawValue!);
                        break;
                      }
                    }
                  },
                ),
                Center(
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: _UI.primary, width: 3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Arahkan kamera ke QR Code pelanggan',
          style: AppColors.body(fontSize: 13, color: _UI.textSoft),
        ),
      ],
    );
  }

  Widget _buildManualInputArea() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _UI.border),
          ),
          child: Column(
            children: [
              Text('Masukkan Kode Pesanan', style: AppColors.heading(fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                'Minta pelanggan menyebutkan 6 digit kode unik.',
                textAlign: TextAlign.center,
                style: AppColors.body(fontSize: 12, color: _UI.textSoft),
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
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _UI.primaryText, width: 2)),
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
                      : Text('Verifikasi', style: AppColors.heading(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}