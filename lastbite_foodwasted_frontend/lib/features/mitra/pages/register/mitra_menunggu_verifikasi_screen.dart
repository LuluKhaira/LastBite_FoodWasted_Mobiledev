import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';
import 'mitra_disetujui_screen.dart';
import 'mitra_session.dart';

class MitraMenungguVerifikasiScreen extends StatefulWidget {
  final String phoneNumber;
  final String namaToko;
  final String kategori;
  final String regId;
  final String waktuPengajuan;

  const MitraMenungguVerifikasiScreen({
    super.key,
    required this.phoneNumber,
    this.namaToko = '-',
    this.kategori = '-',
    this.regId = '-',
    this.waktuPengajuan = '-',
  });

  @override
  State<MitraMenungguVerifikasiScreen> createState() =>
      _MitraMenungguVerifikasiScreenState();
}

class _MitraMenungguVerifikasiScreenState
    extends State<MitraMenungguVerifikasiScreen> {
  bool _isLoading = false;
  Timer? _poller;

  late String _namaToko = widget.namaToko;
  late String _kategori = widget.kategori;
  late String _regId = widget.regId;
  late String _waktu = widget.waktuPengajuan;
  String _status = 'menunggu_verifikasi';
  String? _alasan;

  bool get _ditolak => _status == 'ditolak';
  bool get _disetujui => _status == 'disetujui';

  Color get _statusBgColor {
    if (_ditolak) return AppColors.merahMuda;
    if (_disetujui) return AppColors.hijauMuda;
    return AppColors.orange.withValues(alpha: 0.15);
  }

  Color get _statusDotColor {
    if (_ditolak) return AppColors.merah;
    if (_disetujui) return AppColors.primary;
    return AppColors.orange;
  }

  Color get _statusTextColor {
    if (_ditolak) return AppColors.merah;
    if (_disetujui) return AppColors.hijauTua;
    return AppColors.orange;
  }

  String get _statusLabel {
    if (_ditolak) return 'Ditolak';
    if (_disetujui) return 'Disetujui';
    return 'Sedang Diverifikasi';
  }

  @override
  void initState() {
    super.initState();
    // Ingat pendaftaran ini, supaya saat aplikasi dibuka lagi mitra langsung kembali ke layar ini
    if (widget.phoneNumber.isNotEmpty) {
      MitraSession.savePendingPhone(widget.phoneNumber);
    }

    // Ambil data & status terbaru dari server begitu layar dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) => _cekStatus(silent: true));

    // Selama layar terbuka, periksa otomatis tiap 30 detik
    _poller = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _cekStatus(silent: true),
    );
  }

  @override
  void dispose() {
    _poller?.cancel();
    super.dispose();
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: AppColors.body(color: Colors.white)),
        backgroundColor: AppColors.textDark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _cekStatus({bool silent = false}) async {
    if (widget.phoneNumber.isEmpty) {
      if (!silent) _snack('Nomor WhatsApp tidak tersedia.');
      return;
    }

    if (!silent) setState(() => _isLoading = true);
    final data = await ApiService.checkStatus(widget.phoneNumber);
    if (!mounted) return;
    if (!silent) setState(() => _isLoading = false);

    if (data == null) {
      if (!silent) _snack('Gagal memeriksa status. Coba lagi.');
      return;
    }

    setState(() {
      _status = (data['status'] ?? _status).toString();
      _alasan = data['alasan_penolakan']?.toString();
      if ((data['nama_usaha'] ?? '').toString().isNotEmpty) {
        _namaToko = data['nama_usaha'].toString();
      }
      if ((data['kategori'] ?? '').toString().isNotEmpty) {
        _kategori = data['kategori'].toString();
      }
      if (data['id'] != null) {
        _regId = '#LB-${data['id'].toString().padLeft(5, '0')}';
      }
      if ((data['diajukan'] ?? '').toString().isNotEmpty) {
        _waktu = data['diajukan'].toString();
      }
    });

    if (_status == 'disetujui') {
      _poller?.cancel();
      await MitraSession.clear();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MitraDisetujuiScreen()),
      );
    } else if (!silent) {
      _snack(_ditolak
          ? 'Pendaftaran ditolak oleh admin.'
          : 'Pendaftaran masih ditinjau tim Lastbite.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _ditolak ? AppColors.merah : AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const _Header(title: 'Daftar Mitra', subtitle: 'Status Pendaftaran'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // ---- Main White Card ----
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: _ditolak
                                      ? AppColors.merahMuda
                                      : AppColors.hijauMuda,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _ditolak
                                      ? Icons.cancel_outlined
                                      : Icons.hourglass_top_rounded,
                                  size: 48,
                                  color: _ditolak
                                      ? AppColors.merah
                                      : AppColors.hijauTua,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _ditolak
                                      ? Icons.close
                                      : Icons.access_time_filled,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Text(
                            _ditolak
                                ? 'Pendaftaran\nDitolak'
                                : 'Pendaftaran Sedang\nDitinjau',
                            textAlign: TextAlign.center,
                            style: AppColors.heading(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _ditolak
                                ? ((_alasan != null && _alasan!.isNotEmpty)
                                    ? 'Alasan: $_alasan'
                                    : 'Data usahamu belum memenuhi syarat. '
                                        'Silakan periksa kembali dan daftar ulang.')
                                : 'Tim Lastbite sedang meninjau data usahamu.\n'
                                    'Biasanya selesai dalam 1x24 jam. Kami akan\n'
                                    'kabari lewat WhatsApp begitu disetujui.',
                            textAlign: TextAlign.center,
                            style: AppColors.body(
                              fontSize: 13.5,
                              height: 1.5,
                              color: AppColors.textSoft,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Banner Jaminan Keamanan Data
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.hijauMuda,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: AppColors.hijauTua,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.verified_user_outlined,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Jaminan Keamanan Data',
                                        style: AppColors.heading(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        'Informasi tokomu tersimpan rahasia & terenkripsi.',
                                        style: AppColors.body(
                                          fontSize: 12,
                                          color: AppColors.textSoft,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Ringkasan Pendaftaran Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.latar,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'RINGKASAN PENDAFTARAN',
                                      style: AppColors.heading(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textSoft,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      'ID: $_regId',
                                      style: AppColors.heading(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.hijauTua,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  height: 20,
                                  color: AppColors.textSoft.withValues(alpha: 0.2),
                                ),
                                _SummaryRow(
                                  icon: Icons.storefront_outlined,
                                  label: 'Nama Toko',
                                  value: _namaToko,
                                  boldValue: true,
                                ),
                                const SizedBox(height: 12),
                                _SummaryRow(
                                  icon: Icons.bakery_dining_outlined,
                                  label: 'Kategori',
                                  value: _kategori,
                                  boldValue: true,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.autorenew,
                                          size: 18,
                                          color: AppColors.textSoft,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Status',
                                          style: AppColors.body(
                                            fontSize: 13,
                                            color: AppColors.textSoft,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _statusBgColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: _statusDotColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _statusLabel,
                                            style: AppColors.heading(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: _statusTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _SummaryRow(
                                  icon: Icons.calendar_today_outlined,
                                  label: 'Diajukan pada',
                                  value: _waktu,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ---- Konfirmasi Melalui WhatsApp Card ----
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.hijauMuda,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.chat_outlined,
                              color: AppColors.hijauTua,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Konfirmasi Melalui WhatsApp',
                                  style: AppColors.heading(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Pastikan nomor ponsel yang didaftarkan aktif untuk menerima tautan aktivasi akun dan panduan onboarding perdana.',
                                  style: AppColors.body(
                                    fontSize: 12,
                                    height: 1.4,
                                    color: AppColors.textSoft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ---- Bottom Buttons ----
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _cekStatus(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.refresh, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Cek Status',
                                  style: AppColors.heading(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      // Pendaftaran ditolak: hapus ingatan agar bisa daftar ulang
                      if (_ditolak) await MitraSession.clear();
                      if (!context.mounted) return;
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_back, size: 16, color: AppColors.textSoft),
                        const SizedBox(width: 6),
                        Text(
                          'Kembali ke Beranda Awal',
                          style: AppColors.heading(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      color: AppColors.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool boldValue;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.boldValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSoft),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppColors.body(
                fontSize: 13,
                color: AppColors.textSoft,
              ),
            ),
          ],
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: AppColors.heading(
              fontSize: 13.5,
              fontWeight: boldValue ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
