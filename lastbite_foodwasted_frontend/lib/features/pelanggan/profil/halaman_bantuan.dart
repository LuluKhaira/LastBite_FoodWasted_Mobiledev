import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../beranda/api_service.dart';
import '../beranda/beranda_widgets.dart';
import 'profil_widgets.dart';

// ============================================================
// PUSAT BANTUAN & FAQ
// ============================================================
class BantuanScreen extends StatefulWidget {
  const BantuanScreen({super.key});

  @override
  State<BantuanScreen> createState() => _BantuanScreenState();
}

class _BantuanScreenState extends State<BantuanScreen> {
  final TextEditingController _cari = TextEditingController();
  final FocusNode _fokus = FocusNode();
  Timer? _debounce;

  List _faq = [];
  List _kategori = [];
  Map _kontak = {};
  String? _pilih;
  String _q = '';
  int _buka = 0;
  bool _loading = true;
  String? _error;
  int _reqId = 0;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cari.dispose();
    _fokus.dispose();
    super.dispose();
  }

  Future<void> _muat({bool senyap = false}) async {
    final id = ++_reqId;
    if (!senyap) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final j = await ApiService.getFaq(q: _q, kategori: _pilih);
      if (!mounted || id != _reqId) return;
      setState(() {
        _faq = List.from(j['data'] ?? const []);
        _kategori = List.from((j['kategori'] ?? const []).map((e) => '$e'));
        _kontak = Map.from(j['kontak'] ?? const {});
        _loading = false;
        _error = null;
        _buka = _faq.isEmpty ? -1 : 0;
      });
    } catch (e) {
      if (!mounted || id != _reqId) return;
      setState(() {
        _loading = false;
        _error = pkPesanError(e);
      });
    }
  }

  void _ketik(String v) {
    _q = v.trim();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _muat);
  }

  String get _jamText => '${_kontak['jam'] ?? 'Setiap hari, 08.00 – 22.00 WIB'}';

  Future<void> _salin(String teks, String label) async {
    await Clipboard.setData(ClipboardData(text: teks));
    if (!mounted) return;
    pkSnack(context, '$label disalin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LbColors.offWhite,
      body: SafeArea(
        child: Column(
          children: [
            PkHeader(
              title: 'Pusat Bantuan & FAQ',
              trailing: IconButton(
                onPressed: () => _fokus.requestFocus(),
                icon: const Icon(Icons.search_rounded,
                    color: LbColors.forest, size: 26),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: LbColors.sageDeep,
                onRefresh: () => _muat(senyap: true),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                  children: [
                    _hero(),
                    const SizedBox(height: 22),
                    _chipKategori(),
                    const SizedBox(height: 14),
                    _daftarFaq(),
                    const SizedBox(height: 22),
                    _kartuKontak(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6E6),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: LbColors.sage.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco_rounded, size: 18, color: LbColors.sageDeep),
              const SizedBox(width: 7),
              Text('PUSAT INFORMASI LASTBITE',
                  style: LbText.heading(11.5,
                      weight: FontWeight.w700,
                      color: LbColors.sageDeep,
                      letterSpacing: 0.7)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Ada yang Bisa Kami Bantu?',
              style: LbText.heading(22, weight: FontWeight.w700, height: 1.2)),
          const SizedBox(height: 8),
          Text(
            'Temukan jawaban cepat seputar pemesanan paket kejutan, pengambilan di toko, pembayaran, dan akun.',
            style: LbText.body(13.5, height: 1.45),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: LbColors.border),
            ),
            child: TextField(
              controller: _cari,
              focusNode: _fokus,
              onChanged: (v) {
                setState(() {});
                _ketik(v);
              },
              textInputAction: TextInputAction.search,
              style: LbText.body(14, color: LbColors.forest),
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search_rounded,
                    color: LbColors.sageDeep, size: 24),
                suffixIcon: _cari.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _cari.clear();
                          _ketik('');
                          setState(() {});
                        },
                        icon: const Icon(Icons.close_rounded,
                            size: 20, color: LbColors.textGrey),
                      ),
                hintText: 'Ketik kata kunci… (mis: cara ambil)',
                hintStyle: LbText.body(13.5),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipKategori() {
    Widget chip(String label, bool sel, VoidCallback onTap) => GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              color: sel ? LbColors.forest : Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: sel ? LbColors.forest : LbColors.border),
            ),
            child: Text(label,
                style: LbText.heading(12.5,
                    weight: FontWeight.w600,
                    color: sel ? Colors.white : LbColors.forest)),
          ),
        );

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          chip('Semua Topik', _pilih == null, () {
            setState(() => _pilih = null);
            _muat();
          }),
          for (final k in _kategori)
            chip(k, _pilih == k, () {
              setState(() => _pilih = k);
              _muat();
            }),
        ],
      ),
    );
  }

  Widget _daftarFaq() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
                strokeWidth: 3, color: LbColors.sageDeep),
          ),
        ),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: PkError(pesan: _error!, onRetry: _muat),
      );
    }
    if (_faq.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: pkKartuDeco(),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded,
                size: 38, color: LbColors.sageDeep),
            const SizedBox(height: 10),
            Text('Belum ada jawaban yang cocok',
                style: LbText.heading(15, weight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Coba kata kunci lain, atau tanyakan langsung ke tim kami.',
                textAlign: TextAlign.center,
                style: LbText.body(12.5, height: 1.4)),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < _faq.length; i++) ...[
          _itemFaq(i, _faq[i]),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _itemFaq(int i, dynamic f) {
    final open = _buka == i;
    final tip = '${f['tip'] ?? ''}'.trim();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => setState(() => _buka = open ? -1 : i),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
          decoration: pkKartuDeco(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text('${f['pertanyaan']}',
                        style: LbText.heading(15,
                            weight: FontWeight.w600, height: 1.35)),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: LbColors.forest, size: 26),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: open
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12, right: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${f['jawaban']}',
                                style: LbText.body(14,
                                    color: LbColors.forest, height: 1.55)),
                            if (tip.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: LbColors.sageLight,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.shopping_bag_outlined,
                                        size: 19, color: LbColors.forest),
                                    const SizedBox(width: 9),
                                    Expanded(
                                      child: Text(tip,
                                          style: LbText.body(12.5,
                                              color: LbColors.forest,
                                              height: 1.4)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kartuKontak() {
    final email = '${_kontak['email'] ?? ''}'.trim();
    final telp = '${_kontak['telepon'] ?? ''}'.trim();

    Widget baris(IconData icon, String label, String nilai, VoidCallback? onTap) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              Icon(icon, size: 20, color: LbColors.forest),
              const SizedBox(width: 10),
              Text('$label ', style: LbText.body(13, weight: FontWeight.w700)),
              Expanded(
                child: Text(nilai,
                    style: LbText.body(13,
                        weight: FontWeight.w700,
                        color: onTap == null
                            ? LbColors.textGrey
                            : LbColors.sageDeep)),
              ),
              if (onTap != null)
                const Icon(Icons.copy_rounded,
                    size: 16, color: LbColors.textGrey),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EFEA),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [LbColors.sage, LbColors.sageDeep],
                  ),
                ),
                child: const Icon(Icons.help_outline_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Masih belum menemukan jawaban?',
                        style: LbText.heading(16,
                            weight: FontWeight.w700, height: 1.25)),
                    const SizedBox(height: 3),
                    Text(
                        'Tim kami siap mendengar dan membantu mencarikan solusi terbaik untukmu.',
                        style: LbText.body(12.5, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                if (email.isNotEmpty)
                  baris(Icons.mail_outline_rounded, 'Email:', email,
                      () => _salin(email, 'Email')),
                if (telp.isNotEmpty)
                  baris(Icons.call_outlined, 'Telepon:', telp,
                      () => _salin(telp, 'Nomor telepon')),
                baris(Icons.schedule_rounded, 'Jam Operasional:', _jamText, null),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '“Setiap pertanyaan yang terjawab mempercepat langkah penyelamatan makanan untuk bumi.”',
              textAlign: TextAlign.center,
              style: LbText.body(13, color: LbColors.forest, height: 1.5)
                  .copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}