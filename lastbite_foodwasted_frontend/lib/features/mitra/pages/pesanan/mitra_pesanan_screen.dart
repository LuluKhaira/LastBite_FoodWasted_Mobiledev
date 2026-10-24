import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lastbite_foodwasted_mobiledev/core/config/api_config.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/dashboard/mitra_dashboard_screen.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/produk/mitra_produk_screen.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/profil/mitra_profil_screen.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/dashboard/widgets/mitra_bottom_nav.dart';

import 'mitra_pesanan_detail_screen.dart';
import 'pesanan_ui.dart';
import 'widgets/order_status_tracker.dart';

class _UI {
  static Color get primary => AppColors.primary;
  static Color get orange => AppColors.orange;
  static Color get primaryText => AppColors.zaitun;
  static Color get orangeText =>
      HSLColor.fromColor(AppColors.orange).withLightness(0.35).toColor();
  static Color get primaryBg => AppColors.hijauMuda;
  static Color get orangeBg => AppColors.orange.withValues(alpha: 0.1);
  static Color get textSoft => const Color(0xFF6B6B6B);
  static Color get border => AppColors.textSoft.withValues(alpha: 0.15);
}

class MitraPesananScreen extends StatefulWidget {
  final String phoneNumber;
  final int initialTab;
  final String namaToko;

  const MitraPesananScreen({
    super.key,
    required this.phoneNumber,
    this.initialTab = 0,
    this.namaToko = 'Toko Saya',
  });

  @override
  State<MitraPesananScreen> createState() => _MitraPesananScreenState();
}

class _MitraPesananScreenState extends State<MitraPesananScreen> {
  static const int _navIndexPesanan = 3;

  final List<String> _tabLabels = ['Semua', 'Baru', 'Siap Diambil', 'Selesai'];

  int _tab = 0;
  bool _loading = true;
  List<Map<String, dynamic>> _data = [];
  Timer? _timer;

  int _jmlBaru = 0;
  int _jmlSiap = 0;
  String? _sedangProses;

  String get _namaToko => widget.namaToko;
  int get _pesananAktif => _jmlBaru + _jmlSiap;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    _muatData();
    _muatBadge();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      _muatData(diam: true);
      _muatBadge();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _tabParam {
    switch (_tab) {
      case 1:
        return 'baru';
      case 2:
        return 'siap';
      case 3:
        return 'riwayat';
      default:
        return 'semua';
    }
  }

  Future<void> _muatData({bool diam = false}) async {
    if (!diam && mounted) setState(() => _loading = true);

    final res = await ApiService.getMitraPesanan(
      widget.phoneNumber,
      tab: _tabParam,
    );
    if (!mounted) return;

    if (res['ok'] == true) {
      setState(() {
        _data = List<Map<String, dynamic>>.from(res['data'] ?? []);
        _loading = false;
      });
    } else if (!diam) {
      setState(() => _loading = false);
      _snack(res['message'] ?? 'Gagal memuat pesanan', error: true);
    }
  }

  Future<void> _muatBadge() async {
    final res = await ApiService.getMitraPesanan(
      widget.phoneNumber,
      tab: 'semua',
    );
    if (!mounted || res['ok'] != true) return;

    final list = List<Map<String, dynamic>>.from(res['data'] ?? []);
    final baru = list.where((p) => faseDari(p) == PesananFase.baru).length;
    final siap = list.where((p) => faseDari(p) == PesananFase.siap).length;

    if (baru != _jmlBaru || siap != _jmlSiap) {
      setState(() {
        _jmlBaru = baru;
        _jmlSiap = siap;
      });
    }
  }

  Future<void> _refreshSemua() async {
    await Future.wait([_muatData(diam: true), _muatBadge()]);
  }

  Future<void> _kirimAksi(String kode, String aksi) async {
    final r = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/mitra/pesanan/$kode/$aksi'),
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'phone': widget.phoneNumber}),
        )
        .timeout(const Duration(seconds: 12));

    if (r.statusCode >= 200 && r.statusCode < 300) return;

    String msg = 'Terjadi kesalahan (${r.statusCode})';
    try {
      final body = jsonDecode(r.body);
      if (body is Map && body['message'] != null) {
        msg = body['message'].toString();
      }
    } catch (_) {}
    throw Exception(msg);
  }

  Future<bool> _aksi(String kode, String aksi) async {
    setState(() => _sedangProses = kode);
    try {
      await _kirimAksi(kode, aksi);
      if (!mounted) return false;
      _snack(aksi == 'siap' ? 'Pesanan siap diambil' : 'Pesanan ditolak');
      await _refreshSemua();
      return true;
    } catch (e) {
      if (mounted) {
        _snack(e.toString().replaceFirst('Exception: ', ''), error: true);
      }
      return false;
    } finally {
      if (mounted) setState(() => _sedangProses = null);
    }
  }

  Future<void> _tolakDariKartu(String kode) async {
    if (await konfirmasiTolak(context, kode)) _aksi(kode, 'tolak');
  }

  Future<void> _bukaDetail(Map<String, dynamic> p) async {
    final berubah = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MitraPesananDetailScreen(
          phoneNumber: widget.phoneNumber,
          data: p,
          onAksi: _aksi,
        ),
      ),
    );
    if (berubah == true) _refreshSemua();
  }

  Future<void> _scan(Map<String, dynamic>? p, {bool manual = false}) async {
    final ok = await bukaScanAmbil(
      context,
      phone: widget.phoneNumber,
      kode: p == null ? null : (p['kode'] ?? '').toString(),
      pembeli: p == null ? null : (p['pembeli_nama'] ?? '').toString(),
      manual: manual,
    );
    if (ok) _refreshSemua();
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg, style: AppColors.body(color: Colors.white)),
          backgroundColor: error ? AppColors.merah : AppColors.textDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  String _formatRupiah(dynamic value) {
    final v = int.tryParse('$value') ?? 0;
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp $buf';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // HEADER DENGAN TAB
            _buildHeaderTabs(),

            // LIST PESANAN
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshSemua,
                color: _UI.primaryText,
                child: _buildIsi(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MitraBottomNav(
        currentIndex: _navIndexPesanan,
        onDashboard: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                MitraDashboardScreen(phoneNumber: widget.phoneNumber),
          ),
        ),
        onProduk: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MitraProdukScreen(
              phoneNumber: widget.phoneNumber,
              namaToko: _namaToko,
            ),
          ),
        ),
        onScan: () => _scan(null),
        onPesanan: () {},
        onProfil: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MitraProfilScreen(phoneNumber: widget.phoneNumber),
          ),
        ),
        pesananBadge: _pesananAktif,
      ),
    );
  }

  // --- HEADER: blok hijau segar (primary) + tab pill ---
  Widget _buildHeaderTabs() {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 0),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Pesanan Masuk',
                style: AppColors.heading(
                  fontSize: 18,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: List.generate(_tabLabels.length, (i) {
                final isActive = _tab == i;
                final count = i == 1
                    ? _jmlBaru
                    : i == 2
                    ? _jmlSiap
                    : 0;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_tab != i) {
                        setState(() => _tab = i);
                        _muatData();
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              _tabLabels[i],
                              overflow: TextOverflow.ellipsis,
                              style: AppColors.body(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: isActive
                                    ? AppColors.textDark
                                    : AppColors.textDark.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                          if (count > 0) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.orange
                                    : Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$count',
                                style: AppColors.body(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _buildIsi() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return _data.isEmpty
        ? ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              Icon(
                Icons.receipt_long_outlined,
                size: 56,
                color: AppColors.textSoft.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Belum ada pesanan',
                  style: AppColors.body(
                    fontSize: 15,
                    color: AppColors.textSoft,
                  ),
                ),
              ),
            ],
          )
        : ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: _data.length,
            itemBuilder: (_, i) => _buildKartuPesanan(_data[i]),
          );
  }

  Widget _buildKartuPesanan(Map<String, dynamic> p) {
    final kode = (p['kode'] ?? '').toString();
    final produk = (p['produk'] ?? 'Produk').toString();
    final qty = p['qty'] ?? 1;
    final pembeli = (p['pembeli_nama'] ?? 'Pembeli').toString();
    final fase = faseDari(p);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _UI.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _bukaDetail(p),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris Atas: ID & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#$kode',
                    style: AppColors.body(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _UI.textSoft,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: fase.warna.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      fase.label,
                      style: AppColors.body(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: fase.warna,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Isi Pesanan
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _UI.primaryBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.takeout_dining_rounded,
                      color: AppColors.textDark,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          produk,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppColors.heading(fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$qty porsi • ${_formatRupiah(p['total'] ?? 0)}',
                          style: AppColors.body(
                            fontSize: 12,
                            color: _UI.textSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: _UI.textSoft),
                ],
              ),

              // Pembeli
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: _UI.textSoft),
                  const SizedBox(width: 6),
                  Text(
                    pembeli,
                    style: AppColors.body(fontSize: 12, color: _UI.textSoft),
                  ),
                ],
              ),

              // Status tracker pesanan
              if (fase != PesananFase.batal && fase != PesananFase.bayar) ...[
                const SizedBox(height: 18),
                OrderStatusTracker(fase: fase),
              ],

              // Tombol Aksi
              ..._buildAksi(p, fase, kode),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── TATA LETAK TOMBOL BARU (CLEAN) ─────────────────────────
  List<Widget> _buildAksi(
    Map<String, dynamic> p,
    PesananFase fase,
    String kode,
  ) {
    final loading = _sedangProses == kode;

    if (fase == PesananFase.baru) {
      return [
        const SizedBox(height: 16),
        Row(
          children: [
            // Tombol Tolak (Outline / Clean)
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: loading ? null : () => _tolakDariKartu(kode),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.grey.shade300, // Abu-abu halus
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    'Tolak',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _UI.textSoft,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Tombol Tandai Siap (Solid Hijau / Clean)
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: loading ? null : () => _aksi(kode, 'siap'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Tandai Siap',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white, // Teks Putih
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ];
    }

    if (fase == PesananFase.siap) {
      return [
        const SizedBox(height: 14),
        Row(
          children: [
            // Tombol kode manual di sebelah kiri
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _scan(p, manual: true),
                  icon: const Icon(Icons.keyboard_alt_outlined, size: 19),
                  label: Text(
                    'Kode Manual',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.55),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Tombol QR berbentuk ikon di sebelah kanan
            SizedBox(
              width: 50,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _scan(p),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 23,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ];
    }

    return const [];
  }
}