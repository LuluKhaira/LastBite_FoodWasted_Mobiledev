import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api_service.dart';
import 'beranda_widgets.dart';
import 'profil_widgets.dart';

// ============================================================
// PUSAT BANTUAN & FAQ
// FAQ dari database (GET /api/faq). Pesan ke CS dikirim lewat backend
// ke WhatsApp tim CS via Fonnte (POST /api/bantuan/pesan).
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

  List<Map<String, dynamic>> _faq = [];
  List<String> _kategori = [];
  Map<String, dynamic> _kontak = {};
  String? _pilih; // null = Semua Topik
  String _q = '';
  int _buka = 0; // index FAQ yang terbuka
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
        _faq = List<Map<String, dynamic>>.from(j['data'] ?? const []);
        _kategori = List<String>.from((j['kategori'] ?? const []).map((e) => '$e'));
        _kontak = Map<String, dynamic>.from(j['kontak'] ?? const {});
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

  bool get _csBuka => _kontak['buka'] == true;
  String get _jamText => '${_kontak['jam'] ?? 'Setiap hari, 08.00 – 22.00 WIB'}';

  Future<void> _salin(String teks, String label) async {
    await Clipboard.setData(ClipboardData(text: teks));
    if (!mounted) return;
    pkSnack(context, '$label disalin');
  }

  Future<void> _kirimWhatsApp() async {
    final hasil = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _KirimPesanSheet(),
    );
    if (hasil != null && mounted) pkSnack(context, hasil);
  }

  void _mulaiLiveChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _LiveChatScreen()),
    );
  }

  // ============================================================
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
                    _bantuanLangsung(),
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

  // ---------- hero + pencarian ----------
  Widget _hero() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
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

  // ---------- bantuan langsung ----------
  Widget _bantuanLangsung() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Bantuan Langsung',
                  style: LbText.heading(16, weight: FontWeight.w600)),
            ),
            Text('Layanan Prioritas', style: LbText.body(12)),
          ],
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _kartuLayanan(
                  icon: Icons.chat_rounded,
                  chip: 'Cepat',
                  chipOk: true,
                  judul: 'Chat WhatsApp',
                  sub: 'Pesanmu diteruskan ke tim CS',
                  aksi: 'Kirim Pesan',
                  onTap: _kirimWhatsApp,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _kartuLayanan(
                  icon: Icons.headset_mic_outlined,
                  chip: _csBuka ? 'Aktif' : 'Offline',
                  chipOk: _csBuka,
                  judul: 'Live Chat CS',
                  sub: 'Riwayat percakapan & balasan CS',
                  aksi: 'Mulai Chat',
                  onTap: _mulaiLiveChat,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _kartuLayanan({
    required IconData icon,
    required String chip,
    required bool chipOk,
    required String judul,
    required String sub,
    required String aksi,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: pkKartuDeco(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: LbColors.sageLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 21, color: LbColors.forest),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: chipOk ? LbColors.sageLight : const Color(0xFFEDEBE6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (chip == 'Aktif' || chip == 'Offline') ...[
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: chipOk
                                  ? LbColors.sageDeep
                                  : LbColors.textGrey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],
                        Text(chip,
                            style: LbText.body(11,
                                weight: FontWeight.w800,
                                color: chipOk
                                    ? LbColors.forest
                                    : LbColors.textGrey)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(judul, style: LbText.heading(15, weight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(sub, style: LbText.body(12, height: 1.35)),
              const Spacer(),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(aksi,
                      style: LbText.heading(13,
                          weight: FontWeight.w700, color: LbColors.sageDeep)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 17, color: LbColors.sageDeep),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- kategori ----------
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

  // ---------- daftar FAQ ----------
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

  Widget _itemFaq(int i, Map<String, dynamic> f) {
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

  // ---------- kontak ----------
  Widget _kartuKontak() {
    final email = '${_kontak['email'] ?? 'bantuan@lastbite.id'}';
    final telp = '${_kontak['telepon'] ?? '021-5099-LAST'}';

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
                baris(Icons.mail_outline_rounded, 'Email:', email,
                    () => _salin(email, 'Email')),
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

// ============================================================
// SHEET KIRIM PESAN KE CS (WhatsApp via Fonnte)
// ============================================================
class _KirimPesanSheet extends StatefulWidget {
  const _KirimPesanSheet();

  @override
  State<_KirimPesanSheet> createState() => _KirimPesanSheetState();
}

class _KirimPesanSheetState extends State<_KirimPesanSheet> {
  final TextEditingController _pesan = TextEditingController();
  bool _kirim = false;
  String? _error;

  @override
  void dispose() {
    _pesan.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = _pesan.text.trim();
    if (t.length < 5) {
      setState(() => _error = 'Tulis pesan minimal 5 karakter');
      return;
    }
    setState(() {
      _kirim = true;
      _error = null;
    });
    try {
      final j = await ApiService.kirimBantuan(t, kanal: 'whatsapp');
      if (!mounted) return;
      Navigator.pop(context, '${j['message'] ?? 'Pesan terkirim'}');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _kirim = false;
        _error = pkPesanError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bawah = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(22, 14, 22, 22 + bawah),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: LbColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: LbColors.sageLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chat_rounded,
                        size: 21, color: LbColors.forest),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Chat WhatsApp CS',
                        style: LbText.heading(18, weight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Pesanmu diteruskan ke WhatsApp tim CS beserta nama dan nomor akunmu, sehingga mereka bisa menghubungimu kembali.',
                style: LbText.body(12.5, height: 1.45),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _pesan,
                minLines: 4,
                maxLines: 6,
                maxLength: 1000,
                style: LbText.body(14, color: LbColors.forest),
                decoration: InputDecoration(
                  hintText: 'Tulis pertanyaan atau kendalamu… (sertakan nomor pesanan bila ada)',
                  hintStyle: LbText.body(13.5),
                  filled: true,
                  fillColor: LbColors.offWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: LbColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: LbColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide:
                        const BorderSide(color: LbColors.sageDeep, width: 1.6),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 4),
                Text(_error!,
                    style: LbText.body(12.5,
                        weight: FontWeight.w700, color: LbColors.peachDeep)),
              ],
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _kirim ? null : _submit,
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      colors: [LbColors.sage, LbColors.sageDeep],
                    ),
                  ),
                  child: _kirim
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4, color: Colors.white),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Kirim Pesan',
                                style: LbText.heading(15,
                                    weight: FontWeight.w600,
                                    color: Colors.white)),
                            const SizedBox(width: 8),
                            const Icon(Icons.send_rounded,
                                size: 18, color: Colors.white),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LIVE CHAT CS — riwayat pesan + balasan CS (dari database)
// ============================================================
class _LiveChatScreen extends StatefulWidget {
  const _LiveChatScreen();

  @override
  State<_LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<_LiveChatScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  List<Map<String, dynamic>> _pesan = [];
  bool _loading = true;
  bool _kirim = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _muat({bool senyap = false}) async {
    if (!senyap) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final d = await ApiService.getPesanBantuan();
      if (!mounted) return;
      setState(() {
        _pesan = d;
        _loading = false;
        _error = null;
      });
      _keBawah();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (_pesan.isEmpty) _error = pkPesanError(e);
      });
      if (senyap) pkSnack(context, pkPesanError(e));
    }
  }

  void _keBawah() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _kirimPesan() async {
    final t = _input.text.trim();
    if (t.isEmpty || _kirim) return;
    setState(() => _kirim = true);
    try {
      final j = await ApiService.kirimBantuan(t, kanal: 'live');
      if (!mounted) return;
      _input.clear();
      setState(() => _kirim = false);
      pkSnack(context, '${j['message'] ?? 'Pesan terkirim'}');
      _muat(senyap: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _kirim = false);
      pkSnack(context, pkPesanError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LbColors.offWhite,
      body: SafeArea(
        child: Column(
          children: [
            PkHeader(
              title: 'Live Chat CS',
              trailing: IconButton(
                onPressed: () => _muat(senyap: true),
                icon: const Icon(Icons.refresh_rounded,
                    color: LbColors.forest, size: 24),
              ),
            ),
            Expanded(child: _isi()),
            _kolomInput(),
          ],
        ),
      ),
    );
  }

  Widget _isi() {
    if (_loading) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
              strokeWidth: 3, color: LbColors.sageDeep),
        ),
      );
    }
    if (_error != null) return PkError(pesan: _error!, onRetry: _muat);

    return RefreshIndicator(
      color: LbColors.sageDeep,
      onRefresh: () => _muat(senyap: true),
      child: ListView(
        controller: _scroll,
        physics:
            const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          _sapaan(),
          const SizedBox(height: 14),
          for (final p in _pesan) ...[
            _gelembungUser(p),
            if ('${p['balasan'] ?? ''}'.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              _gelembungCs(p),
            ],
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _sapaan() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LbColors.sageLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.headset_mic_outlined,
              size: 22, color: LbColors.sageDeep),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Halo! Tulis pertanyaanmu di bawah. Tim CS membalas pada jam operasional, dan balasannya akan muncul di sini (tarik layar ke bawah untuk memuat ulang).',
              style: LbText.body(12.5, color: LbColors.forest, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gelembungUser(Map<String, dynamic> p) {
    final status = '${p['status'] ?? ''}';
    final info = status == 'terkirim'
        ? 'Terkirim ke CS'
        : (status == 'gagal'
            ? 'Tersimpan, belum terteruskan ke WhatsApp CS'
            : 'Tersimpan');
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [LbColors.sage, LbColors.sageDeep],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: Text('${p['pesan']}',
                  style: LbText.body(14, color: Colors.white, height: 1.4)),
            ),
            const SizedBox(height: 4),
            Text('${p['waktu'] ?? ''} • $info', style: LbText.body(10.5)),
          ],
        ),
      ),
    );
  }

  Widget _gelembungCs(Map<String, dynamic> p) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: LbColors.border),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Text('${p['balasan']}',
                  style: LbText.body(14, color: LbColors.forest, height: 1.4)),
            ),
            const SizedBox(height: 4),
            Text('Tim CS Lastbite ${p['dibalas'] ?? ''}'.trim(),
                style: LbText.body(10.5)),
          ],
        ),
      ),
    );
  }

  Widget _kolomInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: LbColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: LbColors.offWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: LbColors.border),
              ),
              child: TextField(
                controller: _input,
                minLines: 1,
                maxLines: 4,
                maxLength: 1000,
                textInputAction: TextInputAction.newline,
                style: LbText.body(14, color: LbColors.forest),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  hintText: 'Tulis pesan untuk CS…',
                  hintStyle: LbText.body(13.5),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _kirimPesan,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [LbColors.sage, LbColors.sageDeep],
                ),
              ),
              child: _kirim
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(
                          strokeWidth: 2.4, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded,
                      color: Colors.white, size: 21),
            ),
          ),
        ],
      ),
    );
  }
}