import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';
import 'beranda_widgets.dart';

String _rp(int v) {
  final s = v.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return 'Rp$b';
}

class PesananScreen extends StatefulWidget {
  const PesananScreen({super.key});
  @override
  State<PesananScreen> createState() => _PesananScreenState();
}

class _PesananScreenState extends State<PesananScreen> {
  List<Map<String, dynamic>> _data = [];
  bool _loading = true;
  int _tab = 0; // 0 aktif, 1 riwayat
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _muat();
    // Polling status tiap 6 detik agar update dari Mitra langsung terefleksi
    _timer = Timer.periodic(const Duration(seconds: 6), (_) => _muat(diam: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _muat({bool diam = false}) async {
    try {
      final d = await ApiService.getPesanan();
      if (mounted) {
        setState(() {
          _data = d;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted && !diam) {
        setState(() => _loading = false);
        _snack(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  void _snack(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: LbColors.forest,
          content: Text(t, style: LbText.body(13, color: Colors.white))));
  }

  bool _aktif(Map p) =>
      (p['status'] == 'menunggu' ||
          p['status'] == 'siap' ||
          p['status'] == 'WAITING_PREPARATION' ||
          p['status'] == 'READY_FOR_PICKUP') &&
      (p['status_bayar'] == 'lunas' ||
          p['status_bayar'] == 'menunggu' ||
          p['status_bayar'] == 'belum');

  List<Map<String, dynamic>> get _aktifList => _data.where(_aktif).toList();
  List<Map<String, dynamic>> get _riwayatList => _data.where((p) => !_aktif(p)).toList();

  @override
  Widget build(BuildContext context) {
    final list = _tab == 0 ? _aktifList : _riwayatList;
    return Scaffold(
      backgroundColor: LbColors.offWhite,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _muat(),
          color: LbColors.forest,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Text('Pesanan Saya', style: LbText.heading(24, weight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('Pantau status dan pengambilan paket makananmu', style: LbText.body(13)),
              const SizedBox(height: 16),
              _tabs(),
              const SizedBox(height: 16),
              if (_loading)
                const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator(color: LbColors.forest)))
              else if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          _tab == 0 ? Icons.takeout_dining_outlined : Icons.history_rounded,
                          size: 48,
                          color: LbColors.textGrey.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _tab == 0 ? 'Belum ada pesanan aktif' : 'Belum ada riwayat pesanan',
                          style: LbText.body(14),
                        ),
                      ],
                    ),
                  ),
                )
              else
                for (final p in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _tab == 0 ? _kartuAktif(p) : _kartuRiwayat(p),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabs() {
    Widget item(int i, String label, int n) {
      final sel = _tab == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _tab = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: sel ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              boxShadow: sel
                  ? [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ]
                  : null,
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(label,
                  style: LbText.heading(14,
                      weight: FontWeight.w600,
                      color: sel ? LbColors.forest : LbColors.textGrey)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: sel ? LbColors.forest : const Color(0xFFE3E8D8),
                    borderRadius: BorderRadius.circular(10)),
                child: Text('$n',
                    style: LbText.body(11,
                        weight: FontWeight.w800,
                        color: sel ? Colors.white : LbColors.textGrey)),
              ),
            ]),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: LbColors.sageLight, borderRadius: BorderRadius.circular(28)),
      child: Row(children: [
        item(0, 'Aktif', _aktifList.length),
        item(1, 'Riwayat', _riwayatList.length),
      ]),
    );
  }

  // ---------------- KARTU AKTIF ----------------
  Widget _kartuAktif(Map<String, dynamic> p) {
    final statusStr = '${p['status']}'.toLowerCase();
    final siap = statusStr == 'siap' || statusStr == 'ready_for_pickup';
    final belumBayar = p['status_bayar'] != 'lunas' && (p['total'] as int? ?? 0) > 0;
    final step = siap ? 1 : 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: LbColors.sageLight, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.bakery_dining_rounded, color: LbColors.sageDeep, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${p['penjual']}', style: LbText.heading(16, weight: FontWeight.w700)),
              Text('${p['qty']}x ${p['produk']}',
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: LbText.body(13)),
              Text('Kode: #${p['kode']}',
                  style: LbText.body(11.5, weight: FontWeight.w800, color: LbColors.sageDeep)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        _stepper(step),
        const SizedBox(height: 16),
        if (belumBayar)
          _kotakBelumBayar(p)
        else if (siap)
          _kotakSiap(p)
        else
          _kotakMenunggu(p),
        const SizedBox(height: 16),
        Row(children: [
          const Icon(Icons.location_on_outlined, size: 20, color: LbColors.sageDeep),
          const SizedBox(width: 6),
          Text('Lokasi Pengambilan', style: LbText.heading(14, weight: FontWeight.w700)),
        ]),
        const SizedBox(height: 4),
        Text('${p['alamat'] ?? '-'}', style: LbText.body(12.5, height: 1.4)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _tombolSoft(Icons.near_me_outlined, 'Buka Maps', () => _bukaMaps(p))),
          const SizedBox(width: 10),
          Expanded(
              child: _tombolSoft(Icons.chat_outlined, 'Hubungi Toko', () => _hubungi(p),
                  kuat: true)),
        ]),
        // Tombol Batalkan: hanya jika masih Menunggu & belum siap
        if (!siap && !belumBayar) ...[
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => _konfirmasiBatal(p),
            child: Container(
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4F2),
                border: Border.all(color: const Color(0xFFF2C4BC)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.cancel_outlined, size: 18, color: Color(0xFFD64933)),
                const SizedBox(width: 6),
                Text(
                  'Batalkan Pesanan',
                  style: LbText.heading(13.5,
                      weight: FontWeight.w600, color: const Color(0xFFD64933)),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Pembatalan & pengembalian dana penuh tersedia sebelum paket siap diambil',
              textAlign: TextAlign.center,
              style: LbText.body(11, color: LbColors.textGrey),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _stepper(int step) {
    Widget dot(int i, IconData icon, String label) {
      final done = i < step;
      final now = i == step;
      final active = done || now;

      return Column(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? LbColors.sageDeep : LbColors.sageLight,
            border: now
                ? Border.all(color: LbColors.forest.withValues(alpha: 0.35), width: 4)
                : null,
          ),
          child: Icon(
            done ? Icons.check_rounded : icon,
            size: 20,
            color: active ? Colors.white : LbColors.textGrey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: LbText.body(
            11,
            weight: now ? FontWeight.w800 : FontWeight.w600,
            color: active ? LbColors.forest : LbColors.textGrey,
          ),
        ),
      ]);
    }

    Widget garis(bool aktif) => Expanded(
          child: Container(
            height: 3,
            margin: const EdgeInsets.only(bottom: 18),
            color: aktif ? LbColors.sageDeep : LbColors.sageLight,
          ),
        );

    return Row(children: [
      dot(0, Icons.payments_outlined, 'Dibayar'),
      garis(step >= 1),
      dot(1, Icons.storefront_outlined, 'Siap Diambil'),
      garis(step >= 2),
      dot(2, Icons.done_all_rounded, 'Selesai'),
    ]);
  }

  // Status: Menunggu Konfirmasi & Penyiapan
  Widget _kotakMenunggu(Map p) {
    final estWaktu = p['estimasi_waktu'] ?? '18.45 WIB';
    final estMin = p['estimasi_menit'] ?? 20;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6E6),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LbColors.sage.withValues(alpha: 0.35)),
      ),
      child: Column(children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(color: LbColors.sageLight, shape: BoxShape.circle),
          child: const Icon(Icons.hourglass_bottom_rounded, color: LbColors.sageDeep, size: 30),
        ),
        const SizedBox(height: 12),
        Text(
          'Menunggu Konfirmasi & Penyiapan',
          textAlign: TextAlign.center,
          style: LbText.heading(16, weight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Toko sedang mengemas paket kejutanmu. QR pengambilan akan otomatis aktif setelah pesanan siap.',
          textAlign: TextAlign.center,
          style: LbText.body(12.5, height: 1.45),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.schedule_rounded, size: 16, color: LbColors.sageDeep),
            const SizedBox(width: 6),
            Text(
              'Estimasi siap: $estWaktu (± $estMin mnt)',
              style: LbText.body(12, weight: FontWeight.w800, color: LbColors.forest),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _kotakBelumBayar(Map p) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LbColors.peachLight,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFF2C4BC).withValues(alpha: 0.5)),
        ),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.payment_rounded, color: Color(0xFFD64933), size: 22),
            const SizedBox(width: 6),
            Text('Menunggu Pembayaran',
                style: LbText.heading(15,
                    weight: FontWeight.w700, color: const Color(0xFF9A2B1A))),
          ]),
          const SizedBox(height: 6),
          Text(
            'Total ${_rp(p['total'] as int)}. Selesaikan pembayaran via Midtrans agar toko segera menyiapkan paketmu.',
            textAlign: TextAlign.center,
            style: LbText.body(12.5),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: _tombolSoft(Icons.credit_card_rounded, 'Bayar Sekarang', () => _bayar(p),
                    kuat: true)),
            const SizedBox(width: 8),
            Expanded(child: _tombolSoft(Icons.refresh_rounded, 'Cek Status', () => _cekBayar(p))),
          ]),
        ]),
      );

  // Status: Siap Diambil
  Widget _kotakSiap(Map p) {
    final kode = '${p['kode_ambil'] ?? 'LB-749201'}';
    final batas = DateTime.tryParse('${p['batas_ambil']}')?.toLocal();
    String sisa = '';
    if (batas != null) {
      final d = batas.difference(DateTime.now());
      if (d.isNegative) {
        sisa = 'Batas pengambilan sudah lewat';
      } else {
        final j = d.inHours, m = d.inMinutes % 60;
        final jam =
            '${batas.hour.toString().padLeft(2, '0')}.${batas.minute.toString().padLeft(2, '0')}';
        sisa = 'Ambil sebelum $jam WIB (Sisa ${j > 0 ? '$j jam ' : ''}$m mnt)';
      }
    } else {
      sisa = 'Ambil hari ini sebelum jam tutup toko';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6E6),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LbColors.sage.withValues(alpha: 0.35)),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.qr_code_scanner_rounded, size: 20, color: LbColors.forest),
          const SizedBox(width: 6),
          Text(
            'Tunjukkan QR ini ke kasir saat mengambil',
            style: LbText.body(12.5, weight: FontWeight.w800, color: LbColors.forest),
          ),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: QrImageView(
            data: '${p['kode']}|$kode', // Format: KodePesanan|KodeAmbil
            size: 190,
            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: LbColors.forest),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: LbColors.forest,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'KODE PENGAMBILAN MANUAL',
          style: LbText.body(11, weight: FontWeight.w800, color: LbColors.forest),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: LbColors.sage.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            Expanded(
              child: Text(
                kode,
                style: LbText.heading(22, weight: FontWeight.w700, color: LbColors.sageDeep)
                    .copyWith(letterSpacing: 2),
              ),
            ),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: kode));
                _snack('Kode pengambilan $kode berhasil disalin');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: LbColors.sageLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  const Icon(Icons.copy_rounded, size: 16, color: LbColors.forest),
                  const SizedBox(width: 4),
                  Text('Salin',
                      style: LbText.body(12, weight: FontWeight.w700, color: LbColors.forest)),
                ]),
              ),
            ),
          ]),
        ),
        if (sisa.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
                color: const Color(0xFFFFDDD3), borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.timer_outlined, size: 17, color: Color(0xFFD64933)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  sisa,
                  textAlign: TextAlign.center,
                  style: LbText.body(12,
                      weight: FontWeight.w700, color: const Color(0xFF9A2B1A)),
                ),
              ),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _tombolSoft(IconData icon, String label, VoidCallback onTap, {bool kuat = false}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: kuat ? LbColors.sage.withValues(alpha: 0.55) : LbColors.sageLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 18, color: LbColors.forest),
            const SizedBox(width: 6),
            Text(label,
                style: LbText.heading(13.5, weight: FontWeight.w600, color: LbColors.forest)),
          ]),
        ),
      );

  // ---------------- KARTU RIWAYAT ----------------
  Widget _kartuRiwayat(Map<String, dynamic> p) {
    final statusStr = '${p['status']}'.toLowerCase();
    final selesai = statusStr == 'selesai' || statusStr == 'completed';
    final dibatalkan = statusStr == 'dibatalkan' || statusStr == 'cancelled';
    final label = selesai
        ? (p['baru'] == true ? 'Baru Selesai' : 'Selesai')
        : (dibatalkan ? 'Dibatalkan' : 'Gagal');
    final metode = (p['metode'] ?? 'QRIS').toString().toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 64,
              height: 64,
              child: LbNetImage(
                  url: '${p['gambar'] ?? ''}', fallbackIcon: Icons.fastfood_rounded),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text('${p['tanggal']}, ${p['jam']} WIB',
                        style: LbText.body(12, weight: FontWeight.w700))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: selesai ? LbColors.sageLight : const Color(0xFFFBE3DE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    label,
                    style: LbText.body(11,
                        weight: FontWeight.w800,
                        color: selesai ? LbColors.sageDeep : const Color(0xFFD64933)),
                  ),
                ),
              ]),
              const SizedBox(height: 2),
              Text('${p['penjual']}', style: LbText.heading(15.5, weight: FontWeight.w700)),
              Text('${p['qty']}x ${p['produk']}',
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: LbText.body(12.5)),
            ]),
          ),
        ]),
        // Rincian Dampak Lingkungan
        if (selesai) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5DC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: LbColors.sage.withValues(alpha: 0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.eco_rounded, size: 18, color: LbColors.sageDeep),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Cegah ${p['co2'] ?? '1.25'} kg CO₂e • ${p['makanan'] ?? '0.5'} kg Makanan',
                  style: LbText.body(12, weight: FontWeight.w700, color: LbColors.forest),
                ),
              ),
            ]),
          ),
        ],
        // Indikator Refund Dibatalkan
        if (dibatalkan) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0ED),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF2C4BC)),
            ),
            child: Row(children: [
              const Icon(Icons.replay_circle_filled_rounded,
                  size: 18, color: Color(0xFFD64933)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  p['status_bayar'] == 'refund'
                      ? 'Dana ${_rp(p['total'] as int)} berhasil dikembalikan penuh (Refund Selesai).'
                      : 'Pengembalian dana ${_rp(p['total'] as int)} sedang diproses via $metode.',
                  style: LbText.body(11.5,
                      weight: FontWeight.w700, color: const Color(0xFF9A2B1A)),
                ),
              ),
            ]),
          ),
        ],
        const SizedBox(height: 12),
        // Total & Tombol Aksi (Nota, Beri Nilai)
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Total Pembayaran', style: LbText.body(11, color: LbColors.textGrey)),
              Text(
                '${_rp(p['total'] as int)} ($metode)',
                style: LbText.heading(16,
                    weight: FontWeight.w700,
                    color: selesai ? LbColors.sageDeep : LbColors.forest),
              ),
            ]),
          ),
          if (selesai) ...[
            GestureDetector(
              onTap: () => _bukaNota(p),
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LbColors.sageLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: LbColors.sage.withValues(alpha: 0.4)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.receipt_long_rounded, size: 16, color: LbColors.forest),
                  const SizedBox(width: 4),
                  Text('Nota',
                      style: LbText.heading(12,
                          weight: FontWeight.w700, color: LbColors.forest)),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            if (p['rating'] == null)
              GestureDetector(
                onTap: () => _beriNilai(p),
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: LbColors.sageDeep,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.star_rounded, color: Colors.white, size: 17),
                    const SizedBox(width: 4),
                    Text('Beri Nilai',
                        style: LbText.heading(12,
                            weight: FontWeight.w600, color: Colors.white)),
                  ]),
                ),
              )
            else
              Row(children: [
                const Icon(Icons.star_rounded, color: Color(0xFFF2A93B), size: 18),
                const SizedBox(width: 3),
                Text('${p['rating']}', style: LbText.body(13, weight: FontWeight.w800)),
              ]),
          ],
        ]),
      ]),
    );
  }

  // ---------------- AKSI PENGGUNA ----------------
  Future<void> _bayar(Map p) async {
    try {
      final url = await ApiService.buatPembayaran('${p['kode']}');
      await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _cekBayar(Map p) async {
    try {
      final s = await ApiService.cekBayar('${p['kode']}');
      _snack(s == 'lunas'
          ? 'Pembayaran lunas! Toko segera menyiapkan pesanan.'
          : 'Status pembayaran: $s');
      _muat();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _bukaMaps(Map p) async {
    final lat = p['lat'], lng = p['lng'];
    final uri = (lat != null && lng != null)
        ? Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng')
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('${p['alamat']}')}');
    await launchUrl(uri, webOnlyWindowName: '_blank');
  }

  Future<void> _hubungi(Map p) async {
    var no = '${p['telp_toko'] ?? ''}'.replaceAll(RegExp(r'[^0-9]'), '');
    if (no.isEmpty) return _snack('Nomor telepon toko belum tersedia');
    if (no.startsWith('0')) no = '62${no.substring(1)}';
    await launchUrl(Uri.parse('https://wa.me/$no'), webOnlyWindowName: '_blank');
  }

  Future<void> _konfirmasiBatal(Map p) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Batalkan pesanan?', style: LbText.heading(18, weight: FontWeight.w700)),
        content: Text(
          'Dana sebesar ${_rp(p['total'] as int)} akan dikembalikan penuh karena paket belum disiapkan oleh toko.',
          style: LbText.body(13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Kembali', style: LbText.body(13.5, color: LbColors.textGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD64933),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Batalkan',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (ya != true) return;
    try {
      await ApiService.batalPesanan('${p['kode']}');
      _snack('Pesanan berhasil dibatalkan. Dana dikembalikan penuh.');
      _muat();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _beriNilai(Map p) async {
    int n = 5;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text('Beri Nilai & Ulasan', style: LbText.heading(18, weight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Bagaimana kualitas makanan dari ${p['penjual']}?',
                  style: LbText.body(13)),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    onPressed: () => setS(() => n = i),
                    icon: Icon(
                      i <= n ? Icons.star_rounded : Icons.star_border_rounded,
                      color: const Color(0xFFF2A93B),
                      size: 34,
                    ),
                  ),
              ]),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: LbColors.forest,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Kirim Nilai', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      await ApiService.beriNilai('${p['kode']}', n);
      _snack('Terima kasih atas ulasanmu!');
      _muat();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // Nota Pembayaran Digital (Modal Sheet)
  void _bukaNota(Map p) {
    final metode = (p['metode'] ?? 'QRIS').toString().toUpperCase();
    final hargaSatuan = (p['harga_satuan'] as int? ?? 0);
    final qty = (p['qty'] as int? ?? 1);
    final subtotal = hargaSatuan * qty;
    final layanan = (p['biaya_layanan'] as int? ?? 1000);
    final total = (p['total'] as int? ?? subtotal + layanan);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Row(children: [
              const Icon(Icons.receipt_long_rounded, color: LbColors.forest, size: 28),
              const SizedBox(width: 8),
              Text('Struk Pembelian Digital',
                  style: LbText.heading(18, weight: FontWeight.w700)),
            ]),
            const SizedBox(height: 4),
            Text('No. Pesanan: #${p['kode']}',
                style: LbText.body(12, color: LbColors.textGrey, weight: FontWeight.w600)),
            const Divider(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Waktu Transaksi', style: LbText.body(13)),
              Text('${p['tanggal']}, ${p['jam']} WIB',
                  style: LbText.body(13, weight: FontWeight.w700)),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Nama Toko', style: LbText.body(13)),
              Flexible(
                  child: Text('${p['penjual']}',
                      textAlign: TextAlign.end,
                      style: LbText.body(13, weight: FontWeight.w700))),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Metode Pembayaran', style: LbText.body(13)),
              Text(metode,
                  style: LbText.body(13, weight: FontWeight.w700, color: LbColors.forest)),
            ]),
            const Divider(height: 24),
            Text('Rincian Item', style: LbText.heading(14, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                  child: Text('${p['produk']} ($qty x ${_rp(hargaSatuan)})',
                      style: LbText.body(13))),
              Text(_rp(subtotal), style: LbText.body(13, weight: FontWeight.w600)),
            ]),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Biaya Layanan LastBite', style: LbText.body(13)),
              Text(_rp(layanan), style: LbText.body(13, weight: FontWeight.w600)),
            ]),
            const Divider(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Total Lunas', style: LbText.heading(16, weight: FontWeight.w700)),
              Text(_rp(total),
                  style: LbText.heading(18, weight: FontWeight.w800, color: LbColors.forest)),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFFE8F5DC), borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                const Icon(Icons.eco_rounded, color: LbColors.sageDeep, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Penyelamatan pangan ini mencegah ${p['co2'] ?? '1.25'} kg CO₂e terbuang ke atmosfer.',
                    style: LbText.body(11.5, weight: FontWeight.w600, color: LbColors.forest),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: LbColors.forest,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup Nota',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}