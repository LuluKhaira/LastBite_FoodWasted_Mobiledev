import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';

import 'pesanan_ui.dart';
import 'widgets/order_status_tracker.dart';

/// Detail satu pesanan. Pop dengan `true` kalau ada perubahan (daftar perlu di-refresh).
class MitraPesananDetailScreen extends StatefulWidget {
  final String phoneNumber;
  final Map<String, dynamic> data;

  /// Menjalankan aksi ke server ('siap' / 'tolak'). Mengembalikan true kalau berhasil.
  final Future<bool> Function(String kode, String aksi) onAksi;

  const MitraPesananDetailScreen({
    super.key,
    required this.phoneNumber,
    required this.data,
    required this.onAksi,
  });

  @override
  State<MitraPesananDetailScreen> createState() =>
      _MitraPesananDetailScreenState();
}

class _MitraPesananDetailScreenState extends State<MitraPesananDetailScreen> {
  bool _proses = false;

  Map<String, dynamic> get _p => widget.data;
  String get _kode => (_p['kode'] ?? '').toString();
  String get _pembeli => (_p['pembeli_nama'] ?? 'Pembeli').toString();
  PesananFase get _fase => faseDari(_p);

  Future<void> _aksi(String aksi) async {
    if (aksi == 'tolak' && !await konfirmasiTolak(context, _kode)) return;
    setState(() => _proses = true);
    final ok = await widget.onAksi(_kode, aksi);
    if (!mounted) return;
    setState(() => _proses = false);
    if (ok) Navigator.pop(context, true);
  }

  Future<void> _scan({bool manual = false}) async {
    final ok = await bukaScanAmbil(
      context,
      phone: widget.phoneNumber,
      kode: _kode,
      pembeli: _pembeli,
      manual: manual,
    );
    if (ok && mounted) Navigator.pop(context, true);
  }

  String _statusBayar() {
    switch ((_p['status_bayar'] ?? '').toString()) {
      case 'lunas':
        return 'Lunas';
      case 'menunggu':
        return 'Menunggu pembayaran';
      case 'gagal':
        return 'Gagal';
      case 'refund':
        return 'Dikembalikan';
      case 'belum':
        return 'Belum dibayar';
      default:
        return '-';
    }
  }

  String? _batasAmbil() {
    final raw = _p['batas_ambil'];
    if (raw == null) return null;
    final d = DateTime.tryParse(raw.toString())?.toLocal();
    if (d == null) return null;
    String dua(int n) => n.toString().padLeft(2, '0');
    return '${dua(d.hour)}.${dua(d.minute)} WIB';
  }

  @override
  Widget build(BuildContext context) {
    final fase = _fase;
    final catatan = (_p['catatan'] ?? '').toString().trim();
    final batas = _batasAmbil();
    final hp = (_p['pembeli_hp'] ?? '').toString();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text('Detail Pesanan', style: AppColors.heading(fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // ── Status + garis proses ──
          _kartu(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fase.label,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: fase == PesananFase.baru
                        ? AppColors.orange
                        : (fase == PesananFase.batal
                              ? AppColors.merah
                              : AppColors.hijauTua),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fase.petunjuk,
                  style: AppColors.body(
                    fontSize: 14,
                    color: AppColors.textSoft,
                    height: 1.4,
                  ),
                ),
                if (fase != PesananFase.batal) ...[
                  const SizedBox(height: 20),
                  OrderStatusTracker(fase: fase),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Pembeli ──
          _kartu(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _judul('Pembeli', Icons.person_rounded),
                const SizedBox(height: 10),
                Text(_pembeli, style: AppColors.heading(fontSize: 16)),
                if (hp.isNotEmpty && hp != 'null') ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_rounded,
                        size: 16,
                        color: AppColors.textSoft,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hp,
                        style: AppColors.body(
                          fontSize: 14,
                          color: AppColors.textSoft,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Rincian makanan ──
          _kartu(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _judul('Pesanan', Icons.restaurant_rounded),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        (_p['produk'] ?? 'Produk').toString(),
                        style: AppColors.heading(fontSize: 16),
                      ),
                    ),
                    Text(
                      'x${_p['qty'] ?? 1}',
                      style: AppColors.heading(
                        fontSize: 16,
                        color: AppColors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${rp(_p['harga_satuan'] ?? 0)} per paket kejutan',
                  style: AppColors.body(
                    fontSize: 13,
                    color: AppColors.textSoft,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF0EDE6)),
                ),
                _baris('Biaya layanan', rp(_p['biaya_layanan'] ?? 0)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: AppColors.heading(fontSize: 15)),
                    Text(
                      rp(_p['total'] ?? 0),
                      style: AppColors.heading(
                        fontSize: 18,
                        color: AppColors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Info lain ──
          _kartu(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _judul('Informasi', Icons.info_outline_rounded),
                const SizedBox(height: 10),
                _baris('Kode pesanan', '#$_kode'),
                const SizedBox(height: 8),
                _baris(
                  'Waktu pesan',
                  '${_p['tanggal'] ?? '-'}, ${_p['jam'] ?? '-'}',
                ),
                const SizedBox(height: 8),
                _baris(
                  'Pembayaran',
                  '${_p['metode'] ?? '-'} • ${_statusBayar()}',
                ),
                if (_p['estimasi_waktu'] != null) ...[
                  const SizedBox(height: 8),
                  _baris('Estimasi siap', _p['estimasi_waktu'].toString()),
                ],
                if (batas != null) ...[
                  const SizedBox(height: 8),
                  _baris('Batas ambil', batas),
                ],
                if (catatan.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catatan pembeli',
                          style: AppColors.body(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSoft,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(catatan, style: AppColors.body(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bawah(fase),
    );
  }

  // ── Tombol bawah (Gaya Clean: Menyatu di atas putih) ──
  Widget? _bawah(PesananFase fase) {
    if (fase != PesananFase.baru && fase != PesananFase.siap) return null;

    Widget isi;
    if (fase == PesananFase.baru) {
      isi = Row(
        children: [
          // Tombol Tolak
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: _proses ? null : () => _aksi('tolak'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Tolak',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Tombol Tandai Siap
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _proses ? null : () => _aksi('siap'),
                icon: _proses
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.shopping_bag_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                label: Text(
                  'Tandai Siap',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // ── DESAIN CLEAN UNTUK TOMBOL SCAN & MANUAL ──
      isi = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _scan(),
              icon: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 22,
              ),
              label: Text(
                'Scan QR Pengambilan',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton(
              onPressed: () => _scan(manual: true),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Atau masukkan kode manual',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSoft,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Kotak Putih pembungkus yang membentang penuh (seperti form draf)
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(top: false, child: isi),
    );
  }

  // ── Komponen kecil ──
  Widget _kartu({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _judul(String teks, IconData ikon) {
    return Row(
      children: [
        Icon(ikon, size: 18, color: AppColors.hijauTua),
        const SizedBox(width: 8),
        Text(
          teks.toUpperCase(),
          style: AppColors.body(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.textSoft,
          ),
        ),
      ],
    );
  }

  Widget _baris(String label, String nilai) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppColors.body(fontSize: 14, color: AppColors.textSoft),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            nilai,
            textAlign: TextAlign.right,
            style: AppColors.body(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}