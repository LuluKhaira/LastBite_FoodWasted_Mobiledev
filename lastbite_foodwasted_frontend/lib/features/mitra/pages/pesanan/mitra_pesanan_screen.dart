import 'dart:async';
import 'package:flutter/material.dart';
import 'mitra_pesanan_api.dart';

class _C {
  static const bg = Color(0xFFF1F7EC);
  static const card = Colors.white;
  static const ink = Color(0xFF1B2A1B);
  static const sub = Color(0xFF5B6B5B);
  static const green = Color(0xFF1B7A35);
  static const greenDark = Color(0xFF0F5A24);
  static const greenSoft = Color(0xFFDDF0D5);
  static const orange = Color(0xFFE65100);
  static const orangeSoft = Color(0xFFFFE3CC);
  static const red = Color(0xFFC62828);
  static const redSoft = Color(0xFFFBDADA);
  static const grey = Color(0xFF546E7A);
  static const greySoft = Color(0xFFE3EAEE);
  static const border = Color(0xFFD5DFD0);
}

String _rp(int v) {
  final s = v.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return 'Rp$b';
}

class MitraPesananScreen extends StatefulWidget {
  final String phoneNumber;
  final int initialTab; // 0 semua, 1 baru, 2 siap, 3 selesai/riwayat
  const MitraPesananScreen({super.key, required this.phoneNumber, this.initialTab = 0});
  @override
  State<MitraPesananScreen> createState() => _MitraPesananScreenState();
}

class _MitraPesananScreenState extends State<MitraPesananScreen> {
  List<Map<String, dynamic>> _all = [];
  bool _loading = true;
  static const _tabKeys = ['semua', 'baru', 'siap', 'selesai'];
  late String _tab = _tabKeys[widget.initialTab.clamp(0, 3)]; // semua | baru | siap | selesai
  String? _sibuk;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _muat();
    _timer = Timer.periodic(const Duration(seconds: 8), (_) => _muat(diam: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _muat({bool diam = false}) async {
    try {
      final d = await MitraPesananApi.daftar(widget.phoneNumber);
      if (mounted) setState(() { _all = d; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        if (!diam) _snack(e.toString().replaceFirst('Exception: ', ''), error: true);
      }
    }
  }

  void _snack(String t, {bool error = false}) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? _C.red : _C.greenDark,
        content: Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))));

  List<Map<String, dynamic>> _by(String tab) {
    switch (tab) {
      case 'baru':
        return _all.where((p) => p['status'] == 'menunggu').toList();
      case 'siap':
        return _all.where((p) => p['status'] == 'siap').toList();
      case 'selesai':
        return _all.where((p) => p['status'] == 'selesai' || p['status'] == 'dibatalkan').toList();
      default:
        return _all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _by(_tab);
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(children: [
              const Expanded(
                  child: Text('Pesanan Masuk',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _C.ink))),
              IconButton(onPressed: () => _muat(), icon: const Icon(Icons.refresh_rounded, color: _C.green)),
            ]),
          ),
          _tabs(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: _C.green))
                : RefreshIndicator(
                    color: _C.green,
                    onRefresh: _muat,
                    child: list.isEmpty
                        ? ListView(children: const [
                            SizedBox(height: 120),
                            Center(child: Text('Belum ada pesanan', style: TextStyle(color: _C.sub, fontSize: 15))),
                          ])
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: list.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (_, i) => _kartu(list[i]),
                          ),
                  ),
          ),
        ]),
      ),
    );
  }

  Widget _tabs() {
    Widget chip(String key, String label, Color warna) {
      final sel = _tab == key;
      final n = _by(key).length;
      return GestureDetector(
        onTap: () => setState(() => _tab = key),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
              color: sel ? _C.greenDark : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: sel ? _C.greenDark : _C.border, width: 1.4)),
          child: Row(children: [
            Text(label,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: sel ? Colors.white : _C.ink)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: sel ? Colors.white : warna, borderRadius: BorderRadius.circular(10)),
              child: Text('$n',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: sel ? _C.greenDark : Colors.white)),
            ),
          ]),
        ),
      );
    }

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
        children: [
          chip('semua', 'Semua', _C.green),
          chip('baru', 'Baru', _C.orange),
          chip('siap', 'Siap Diambil', _C.green),
          chip('selesai', 'Selesai', _C.grey),
        ],
      ),
    );
  }

  Widget _kartu(Map<String, dynamic> p) {
    final status = '${p['status']}';
    final baru = status == 'menunggu';
    final siap = status == 'siap';
    final batal = status == 'dibatalkan';
    final nama = '${p['pembeli_nama'] ?? 'Pelanggan'}';
    final inisial = nama.trim().isEmpty ? '?' : nama.trim().substring(0, 1).toUpperCase();
    final catatan = '${p['catatan'] ?? ''}'.trim();
    final sibuk = _sibuk == p['kode'];
    final lunas = p['status_bayar'] == 'lunas';

    final (String label, Color bg, Color fg) badge = baru
        ? ('PESANAN BARU', _C.orangeSoft, _C.orange)
        : siap
            ? ('SIAP DIAMBIL', _C.greenSoft, _C.greenDark)
            : batal
                ? ('DIBATALKAN', _C.redSoft, _C.red)
                : ('SELESAI', _C.greySoft, _C.grey);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(22),
        border: Border(left: BorderSide(color: badge.$3, width: 6)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: _C.greenSoft,
            child: Text(inisial, style: const TextStyle(fontWeight: FontWeight.w900, color: _C.greenDark, fontSize: 17)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(nama,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: _C.ink)),
              const SizedBox(height: 2),
              Text('#${p['kode']}  •  Pukul ${p['jam']} WIB',
                  style: const TextStyle(fontSize: 12.5, color: _C.sub, fontWeight: FontWeight.w600)),
            ]),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: badge.$2, borderRadius: BorderRadius.circular(10)),
            child: Text(badge.$1,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: badge.$3, letterSpacing: 0.3)),
          ),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: _C.bg, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 56, height: 56,
                child: ('${p['gambar'] ?? ''}').startsWith('http')
                    ? Image.network('${p['gambar']}', fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fotoKosong())
                    : _fotoKosong(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${p['qty']}x ${p['produk']}',
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: _C.ink)),
                const SizedBox(height: 4),
                Row(children: [
                  Text(_rp(((p['qty'] as int) * (p['harga_satuan'] as int))),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _C.greenDark)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: lunas ? _C.greenSoft : _C.orangeSoft,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(lunas ? Icons.check_circle : Icons.schedule,
                          size: 14, color: lunas ? _C.greenDark : _C.orange),
                      const SizedBox(width: 4),
                      Text(lunas ? 'Lunas via ${p['metode']}' : 'Belum lunas',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w800,
                              color: lunas ? _C.greenDark : _C.orange)),
                    ]),
                  ),
                ]),
              ]),
            ),
          ]),
        ),
        if (catatan.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFB74D))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.warning_amber_rounded, color: _C.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(TextSpan(children: [
                  const TextSpan(
                      text: 'Catatan pembeli: ',
                      style: TextStyle(fontWeight: FontWeight.w900, color: _C.orange)),
                  TextSpan(text: catatan, style: const TextStyle(color: _C.ink, fontWeight: FontWeight.w600)),
                ]), style: const TextStyle(fontSize: 13, height: 1.4)),
              ),
            ]),
          ),
        ],
        if (baru) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              flex: 3,
              child: _tombol(Icons.check_rounded, sibuk ? 'Memproses...' : 'Siap Diambil',
                  _C.greenDark, Colors.white, (sibuk || !lunas) ? null : () => _siap(p)),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: _tombol(Icons.close_rounded, 'Tolak', _C.redSoft, _C.red,
                  sibuk ? null : () => _tolak(p), border: _C.red),
            ),
          ]),
        ],
        if (siap) ...[
          const SizedBox(height: 12),
          _tombol(Icons.qr_code_scanner_rounded, 'Verifikasi Pengambilan',
              _C.green, Colors.white, sibuk ? null : () => _verifikasi(p)),
          const SizedBox(height: 6),
          const Text('Minta pelanggan menunjukkan QR atau kode LB-xxxxxx',
              style: TextStyle(fontSize: 11.5, color: _C.sub)),
        ],
      ]),
    );
  }

  Widget _fotoKosong() => Container(
      color: _C.greenSoft, child: const Icon(Icons.bakery_dining_rounded, color: _C.greenDark, size: 28));

  Widget _tombol(IconData icon, String label, Color bg, Color fg, VoidCallback? onTap, {Color? border}) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.6 : 1,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: border != null ? Border.all(color: border, width: 1.4) : null),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: fg, size: 20),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 14)),
          ]),
        ),
      ),
    );
  }

  Future<void> _aksi(Map p, String aksi, String sukses, {String? kodeAmbil}) async {
    setState(() => _sibuk = '${p['kode']}');
    try {
      await MitraPesananApi.aksi(widget.phoneNumber, '${p['kode']}', aksi, kodeAmbil: kodeAmbil);
      _snack(sukses);
      await _muat();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''), error: true);
    } finally {
      if (mounted) setState(() => _sibuk = null);
    }
  }

  Future<void> _siap(Map p) => _aksi(p, 'siap', 'Pesanan ditandai siap. Pelanggan sudah mendapat QR.');

  Future<void> _tolak(Map p) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak pesanan?'),
        content: const Text('Stok akan dikembalikan dan dana pelanggan di-refund.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Tidak')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Ya, tolak', style: TextStyle(color: _C.red, fontWeight: FontWeight.w800))),
        ],
      ),
    );
    if (ya == true) await _aksi(p, 'tolak', 'Pesanan ditolak.');
  }

  Future<void> _verifikasi(Map p) async {
    final c = TextEditingController();
    final kode = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verifikasi Pengambilan'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Pesanan #${p['kode']}', style: const TextStyle(color: _C.sub)),
          const SizedBox(height: 12),
          TextField(
            controller: c,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
                labelText: 'Kode pengambilan', hintText: 'LB-123456', border: OutlineInputBorder()),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, c.text),
              child: const Text('Verifikasi', style: TextStyle(color: _C.green, fontWeight: FontWeight.w800))),
        ],
      ),
    );
    if (kode == null || kode.trim().isEmpty) return;
    final bersih = kode.contains('|') ? kode.split('|').last : kode;
    await _aksi(p, 'ambil', 'Pesanan selesai. Saldo bertambah.', kodeAmbil: bersih.trim().toUpperCase());
  }
}