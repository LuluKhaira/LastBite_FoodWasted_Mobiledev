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
  // Index item "Pesanan" di MitraBottomNav.
  static const int _navIndexPesanan = 3;

  final List<String> _tabLabels = ['Semua', 'Baru', 'Siap Diambil', 'Selesai'];

  int _tab = 0;
  bool _loading = true;
  List<Map<String, dynamic>> _data = [];
  Timer? _timer;

  int _jmlBaru = 0;
  int _jmlSiap = 0;
  String? _sedangProses; // kode pesanan yang sedang dikirim aksinya

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

  // Hitung jumlah per fase untuk badge tab & bottom nav.
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

  // POST /mitra/pesanan/{kode}/{aksi}  (aksi: siap | tolak)
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
      if (body is Map && body['message'] != null) msg = body['message'].toString();
    } catch (_) {}
    throw Exception(msg);
  }

  /// Dipakai kartu dan layar detail. Mengembalikan true kalau berhasil.
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
          backgroundColor: error ? AppColors.merah : AppColors.hijauTua,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
  }

  // ───────────────────────── BUILD ─────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false, // tombol back dihapus
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Text('Pesanan Masuk', style: AppColors.heading(fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _refreshSemua,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(child: _buildIsi()),
          ],
        ),
      ),
      bottomNavigationBar: MitraBottomNav(
        currentIndex: _navIndexPesanan,
        onDashboard: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MitraDashboardScreen(phoneNumber: widget.phoneNumber),
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
        onPesanan: () {}, // sudah di halaman ini
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

  // Tab ala Shopee: teks + garis bawah.
  Widget _buildTabBar() {
    final counts = [0, _jmlBaru, _jmlSiap, 0];
    return Container(
      color: Colors.white,
      child: Row(
        children: List.generate(_tabLabels.length, (i) {
          final sel = _tab == i;
          return Expanded(
            child: InkWell(
              onTap: () {
                if (_tab != i) {
                  setState(() => _tab = i);
                  _muatData();
                }
              },
              child: Container(
                padding: const EdgeInsets.only(top: 14, bottom: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: sel ? AppColors.orange : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        _tabLabels[i],
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          color: sel ? AppColors.orange : AppColors.textSoft,
                        ),
                      ),
                    ),
                    if (counts[i] > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${counts[i]}',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
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
    );
  }

  Widget _buildIsi() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshSemua,
      color: AppColors.primary,
      child: _data.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                Icon(Icons.receipt_long_outlined,
                    size: 56, color: AppColors.textSoft.withValues(alpha: 0.5)),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Belum ada pesanan',
                    style: AppColors.body(fontSize: 15, color: AppColors.textSoft),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              itemCount: _data.length,
              itemBuilder: (_, i) => _buildKartuPesanan(_data[i]),
            ),
    );
  }

  // ───────────────────────── KARTU ─────────────────────────

  Widget _buildKartuPesanan(Map<String, dynamic> p) {
    final kode = (p['kode'] ?? '').toString();
    final produk = (p['produk'] ?? 'Produk').toString();
    final qty = p['qty'] ?? 1;
    final pembeli = (p['pembeli_nama'] ?? 'Pembeli').toString();
    final fase = faseDari(p);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _bukaDetail(p),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pembeli + status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$pembeli • #$kode',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Text(
                      fase.label,
                      style: GoogleFonts.nunito(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: fase.warna,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Isi pesanan
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.takeout_dining_rounded,
                          color: AppColors.hijauTua, size: 26),
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
                            style: AppColors.body(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '$qty porsi • ${rp(p['total'] ?? 0)}',
                            style: AppColors.body(
                                fontSize: 13, color: AppColors.textSoft),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textSoft),
                  ],
                ),

                // Garis proses dengan ikon
                if (fase != PesananFase.batal && fase != PesananFase.bayar) ...[
                  const SizedBox(height: 18),
                  OrderStatusTracker(fase: fase),
                ],

                ..._buildAksi(p, fase, kode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAksi(Map<String, dynamic> p, PesananFase fase, String kode) {
    final loading = _sedangProses == kode;

    if (fase == PesananFase.baru) {
      return [
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: loading ? null : () => _tolakDariKartu(kode),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.merah.withValues(alpha: 0.6)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Tolak',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.merah)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: loading ? null : () => _aksi(kode, 'siap'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text('Tandai Siap',
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ];
    }

    if (fase == PesananFase.siap) {
      return [
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => _scan(p),
            icon: const Icon(Icons.qr_code_scanner_rounded,
                color: Colors.white, size: 24),
            label: Text('Scan QR Pengambilan',
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: TextButton(
            onPressed: () => _scan(p, manual: true),
            child: Text('Atau masukkan kode manual',
                style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.hijauTua)),
          ),
        ),
      ];
    }

    return const [];
  }
}
