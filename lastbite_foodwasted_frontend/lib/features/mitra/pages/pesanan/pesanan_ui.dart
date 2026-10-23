import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'scan_ambil_pesanan_screen.dart';

/// Fase pesanan yang disederhanakan agar mudah dibaca.
enum PesananFase { bayar, baru, siap, selesai, batal }

/// Tentukan fase dari data API.
/// Backend (Pesanan::toApi) mengirim `status_enum`; kalau tidak ada, pakai `status` teks.
PesananFase faseDari(Map<String, dynamic> p) {
  switch ((p['status_enum'] ?? '').toString()) {
    case 'PENDING_PAYMENT':
      return PesananFase.bayar;
    case 'WAITING_PREPARATION':
      return PesananFase.baru;
    case 'READY_FOR_PICKUP':
      return PesananFase.siap;
    case 'COMPLETED':
      return PesananFase.selesai;
    case 'CANCELLED':
      return PesananFase.batal;
  }
  switch ((p['status'] ?? '').toString().toLowerCase()) {
    case 'siap':
    case 'siap diambil':
    case 'siap_diambil':
      return PesananFase.siap;
    case 'selesai':
      return PesananFase.selesai;
    case 'dibatalkan':
    case 'ditolak':
    case 'batal':
      return PesananFase.batal;
  }
  return PesananFase.baru;
}

extension PesananFaseX on PesananFase {
  String get label => switch (this) {
        PesananFase.bayar => 'Menunggu pembayaran',
        PesananFase.baru => 'Perlu disiapkan',
        PesananFase.siap => 'Siap diambil',
        PesananFase.selesai => 'Selesai',
        PesananFase.batal => 'Dibatalkan',
      };

  /// Kalimat petunjuk singkat untuk mitra.
  String get petunjuk => switch (this) {
        PesananFase.bayar => 'Pembeli belum membayar. Tunggu sampai lunas.',
        PesananFase.baru =>
          'Pesanan baru! Siapkan makanannya, lalu tekan "Tandai Siap".',
        PesananFase.siap =>
          'Pembeli akan datang. Scan QR di HP pembeli saat makanan diserahkan.',
        PesananFase.selesai => 'Pesanan sudah diambil pembeli.',
        PesananFase.batal => 'Pesanan ini dibatalkan.',
      };

  Color get warna => switch (this) {
        PesananFase.bayar => AppColors.textSoft,
        PesananFase.baru => AppColors.orange,
        PesananFase.siap => AppColors.primary,
        PesananFase.selesai => AppColors.primary,
        PesananFase.batal => AppColors.merah,
      };
}

/// Format rupiah: 12500 -> Rp12.500
String rp(dynamic v) {
  final n = (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
  final s = n.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return 'Rp$b';
}

/// Dialog konfirmasi sebelum menolak pesanan.
Future<bool> konfirmasiTolak(BuildContext context, String kode) async {
  final ya = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Tolak pesanan ini?', style: AppColors.heading(fontSize: 17)),
      content: Text(
        'Pesanan #$kode akan dibatalkan.',
        style: AppColors.body(fontSize: 14, color: AppColors.textSoft),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('Tidak',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, color: AppColors.textSoft)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text('Ya, Tolak',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, color: AppColors.merah)),
        ),
      ],
    ),
  );
  return ya == true;
}

/// Buka layar scan QR / kode manual. Mengembalikan true kalau pengambilan berhasil.
Future<bool> bukaScanAmbil(
  BuildContext context, {
  required String phone,
  String? kode,
  String? pembeli,
  bool manual = false,
}) async {
  final r = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => ScanAmbilPesananScreen(
        phoneNumber: phone,
        kodePesanan: kode,
        namaPembeli: pembeli,
        mulaiManual: manual,
      ),
    ),
  );
  return r == true;
}
