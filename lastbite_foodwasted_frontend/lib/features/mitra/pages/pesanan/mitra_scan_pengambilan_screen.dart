import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';

class MitraScanPengambilanScreen extends StatefulWidget {
  final String phoneNumber;
  final String? initialCode;

  const MitraScanPengambilanScreen({
    super.key,
    required this.phoneNumber,
    this.initialCode,
  });

  @override
  State<MitraScanPengambilanScreen> createState() => _MitraScanPengambilanScreenState();
}

class _MitraScanPengambilanScreenState extends State<MitraScanPengambilanScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animController;
  List<Map<String, dynamic>> _antreanSiap = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialCode != null) {
      _codeController.text = widget.initialCode!;
    }
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _muatAntrean();
  }

  @override
  void dispose() {
    _animController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _muatAntrean() async {
    final res = await ApiService.getMitraPesanan(widget.phoneNumber, tab: 'siap');
    if (mounted && res['ok'] == true) {
      setState(() {
        _antreanSiap = List<Map<String, dynamic>>.from(res['data'] ?? []);
      });
    }
  }

  String _formatRp(int v) {
    final s = v.abs().toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return 'Rp$b';
  }

  Future<void> _prosesVerifikasi({String? kodeManual}) async {
    final code = (kodeManual ?? _codeController.text).trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan kode pengambilan manual atau scan QR.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final res = await ApiService.verifikasiPengambilan(widget.phoneNumber, code);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['ok'] == true) {
      final p = res['data'] ?? {};
      final pendapatan = res['pendapatan'] ?? 0;
      final saldo = res['saldo_terbaru'];

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 48),
              ),
              const SizedBox(height: 16),
              Text(
                'Pengambilan Berhasil!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Text(
                'Pesanan #${p['kode'] ?? ''} telah diserahkan ke ${p['pembeli_nama'] ?? 'Pembeli'}.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 13.5, color: AppColors.textSoft),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Pendapatan Masuk ke Saldo:',
                      style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+ ${_formatRp(pendapatan is int ? pendapatan : int.tryParse('$pendapatan') ?? 0)}',
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF2E7D32)),
                    ),
                    if (saldo != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Saldo Toko Sekarang: ${_formatRp((saldo as num).toInt())}',
                        style: GoogleFonts.nunito(fontSize: 11.5, color: AppColors.textSoft),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context, true); // kembali ke halaman sebelumnya dengan refresh
                  },
                  child: Text('Selesai', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Verifikasi pengambilan gagal.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: AppColors.textDark,
        title: Text(
          'Verifikasi Pengambilan',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Frame Scanner QR Interaktif
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Scan QR Code Pembeli',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Arahkan kamera ke QR Code di aplikasi pembeli',
                    style: GoogleFonts.nunito(fontSize: 12.5, color: AppColors.textSoft),
                  ),
                  const SizedBox(height: 20),
                  // Simulasi Kamera Scanner Viewfinder
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E242B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary, width: 2.5),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 110,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                      // Animated scanning line
                      AnimatedBuilder(
                        animation: _animController,
                        builder: (ctx, child) {
                          return Positioned(
                            top: 20 + (_animController.value * 180),
                            child: Container(
                              width: 190,
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppColors.orange,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.orange.withValues(alpha: 0.8),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F6E6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 15, color: Color(0xFF4A6B35)),
                        const SizedBox(width: 6),
                        Text(
                          'Kamera otomatis membaca kode LB-XXXXXX',
                          style: GoogleFonts.nunito(fontSize: 11.5, color: const Color(0xFF4A6B35), fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form Input Manual Kode LB-XXXXXX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Input Manual Kode Pengambilan',
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tanyakan 6 digit kode dari layar HP pembeli jika tidak bisa scan QR',
                    style: GoogleFonts.nunito(fontSize: 12.5, color: AppColors.textSoft),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 2),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.pin_rounded, color: AppColors.primary),
                      hintText: 'Contoh: LB-749201',
                      hintStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0, color: Colors.grey.shade400),
                      filled: true,
                      fillColor: AppColors.bg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      onPressed: _isLoading ? null : () => _prosesVerifikasi(),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Konfirmasi Pengambilan',
                                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Antrean Paket Siap Diambil Saat Ini
            if (_antreanSiap.isNotEmpty) ...[
              Text(
                'Paket Siap Diambil (${_antreanSiap.length})',
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              const SizedBox(height: 10),
              for (final item in _antreanSiap)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.takeout_dining_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item['pembeli_nama'] ?? 'Pembeli'} • #${item['kode'] ?? ''}',
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '${item['qty']}x ${item['produk']}',
                              style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textSoft),
                            ),
                            Text(
                              'Kode: ${item['kode_ambil_display'] ?? item['kode_ambil'] ?? '-'}',
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.orange),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          final c = '${item['kode_ambil_display'] ?? item['kode_ambil'] ?? ''}';
                          _codeController.text = c;
                          _prosesVerifikasi(kodeManual: c);
                        },
                        child: Text(
                          'Pilih & Selesai',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
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

