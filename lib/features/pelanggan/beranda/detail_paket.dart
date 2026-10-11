import 'package:flutter/material.dart';
import 'beranda_widgets.dart';

// ============================================================
// HELPER
// ============================================================
int _num(String s) => int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

String _rp(int v) {
  final s = v.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return 'Rp$b';
}

class _PayOpt {
  final String id;
  final String name;
  final String sub;
  final IconData icon;
  final String? tag;
  const _PayOpt(this.id, this.name, this.sub, this.icon, {this.tag});
}

class _PayGroup {
  final String title;
  final String badge;
  final IconData icon;
  final List<_PayOpt> opts;
  const _PayGroup(this.title, this.badge, this.icon, this.opts);
}

const List<_PayGroup> _payGroups = [
  _PayGroup(
    'REKOMENDASI MAHASISWA',
    'Terpopuler',
    Icons.verified_rounded,
    [
      _PayOpt(
        'qris',
        'QRIS Instan',
        'GoPay, OVO, DANA, ShopeePay, BCA Mobile',
        Icons.qr_code_2_rounded,
        tag: 'BEBAS BIAYA',
      ),
    ],
  ),
  _PayGroup(
    'DOMPET DIGITAL / E-WALLET',
    '3 Pilihan',
    Icons.account_balance_wallet_outlined,
    [
      _PayOpt('gopay', 'GoPay', 'Bayar lewat aplikasi Gojek',
          Icons.account_balance_wallet_rounded),
      _PayOpt('ovo', 'OVO', 'Bayar lewat aplikasi OVO',
          Icons.account_balance_wallet_rounded),
      _PayOpt('dana', 'DANA', 'Bayar lewat aplikasi DANA',
          Icons.account_balance_wallet_rounded),
    ],
  ),
  _PayGroup(
    'TRANSFER BANK (VIRTUAL ACCOUNT)',
    '3 Bank',
    Icons.account_balance_rounded,
    [
      _PayOpt('bca', 'BCA Virtual Account', 'Konfirmasi otomatis',
          Icons.account_balance_rounded),
      _PayOpt('mandiri', 'Mandiri Virtual Account', 'Konfirmasi otomatis',
          Icons.account_balance_rounded),
      _PayOpt('bni', 'BNI Virtual Account', 'Konfirmasi otomatis',
          Icons.account_balance_rounded),
    ],
  ),
];

// ============================================================
// HALAMAN DETAIL
// ============================================================
class DetailPaketScreen extends StatefulWidget {
  final BahanItem item;
  const DetailPaketScreen({super.key, required this.item});

  @override
  State<DetailPaketScreen> createState() => _DetailPaketScreenState();
}

class _DetailPaketScreenState extends State<DetailPaketScreen> {
  int _pickup = 0;
  int _openGroup = 0;
  String _payId = 'qris';
  bool _fav = false;
  final TextEditingController _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  // ---------- data turunan ----------
  BahanItem get it => widget.item;
  bool get _ternak => it.untukTernak;
  int get _harga => _num(it.harga);
  int get _asli => it.hargaAsli != null ? _num(it.hargaAsli!) : _harga;
  int get _diskon => _asli > _harga ? _asli - _harga : 0;
  int get _fee => _harga == 0 ? 0 : 1000;
  int get _total => _harga + _fee;
  int get _hematPct => _asli == 0 ? 0 : (_diskon * 100 / _asli).round();

  List<int>? get _range {
    final m = RegExp(r'(\d{1,2}):(\d{2})\s*-\s*(\d{1,2}):(\d{2})')
        .firstMatch(it.waktu);
    if (m == null) return null;
    return [
      int.parse(m[1]!) * 60 + int.parse(m[2]!),
      int.parse(m[3]!) * 60 + int.parse(m[4]!),
    ];
  }

  ({String label, Color bg, Color fg}) get _status {
    final r = _range;
    if (r != null) {
      final now = DateTime.now();
      final m = now.hour * 60 + now.minute;
      if (m < r[0]) {
        return (
          label: 'Buka Nanti',
          bg: LbColors.peachLight,
          fg: LbColors.peachDeep,
        );
      }
      if (m <= r[1]) {
        return (
          label: 'Sedang Buka',
          bg: LbColors.sage.withValues(alpha: 0.35),
          fg: LbColors.forest,
        );
      }
    }
    return (
      label: 'Sudah Tutup',
      bg: const Color(0xFFEDEBE6),
      fg: LbColors.textGrey,
    );
  }

  String get _estimasi {
    final km =
        double.tryParse(it.jarak.replaceAll(',', '.').split(' ').first) ?? 1;
    if (km <= 1.5) return 'Est. ${(km * 12).round()} menit jalan kaki';
    return 'Est. ${(km * 3).round()} menit berkendara';
  }

  // ---------- util UI ----------
  List<BoxShadow> get _shadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.035),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ];

  Widget _card({
    required Widget child,
    Color? color,
    Color? borderColor,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor ?? LbColors.border),
        boxShadow: _shadow,
      ),
      child: child,
    );
  }

  Widget _iconBubble(IconData icon, {double size = 36, Color? bg}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg ?? LbColors.sageLight,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: size * 0.55, color: LbColors.sageDeep),
    );
  }

  Widget _sectionHeader(IconData icon, String title, {Widget? trailing}) {
    return Row(
      children: [
        _iconBubble(icon, size: 34),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: LbText.heading(16, weight: FontWeight.w600),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _pill(
    String text, {
    IconData? icon,
    required Color bg,
    required Color fg,
    double size = 11.5,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: LbText.body(size, weight: FontWeight.w800, color: fg),
          ),
        ],
      ),
    );
  }

  Widget _radio(bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? LbColors.sageDeep : const Color(0xFFCFCBC0),
          width: 2,
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? LbColors.sageDeep : Colors.transparent,
        ),
      ),
    );
  }

  Widget _roundBtn(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: LbColors.border),
        ),
        child: Icon(icon, size: 21, color: color ?? LbColors.forest),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LbColors.offWhite,
      bottomNavigationBar: _bottomBar(),
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              _topBar(),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    _labelRow(),
                    const SizedBox(height: 14),
                    _hero(),
                    const SizedBox(height: 14),
                    _infoCard(),
                    const SizedBox(height: 14),
                    _pickupCard(),
                    const SizedBox(height: 14),
                    _aboutCard(),
                    if (_total > 0) ...[
                      const SizedBox(height: 22),
                      _paymentSection(),
                    ],
                    const SizedBox(height: 14),
                    _summaryCard(),
                    const SizedBox(height: 14),
                    _notesCard(),
                    const SizedBox(height: 14),
                    _safetyBox(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================
  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: LbColors.forest,
              size: 26,
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [LbColors.sage, LbColors.sageDeep],
              ),
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _ternak ? 'Detail Pasokan' : 'Detail Paket',
              style: LbText.heading(19, weight: FontWeight.w700),
            ),
          ),
          Container(
            width: 42,
            height: 42,
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [LbColors.sage, LbColors.sageDeep],
              ),
            ),
            child: const ClipOval(
              child: LbNetImage(
                url: 'https://i.pravatar.cc/150?img=32',
                fallbackIcon: Icons.person_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _labelRow() {
    return Row(
      children: [
        _iconBubble(Icons.eco_rounded, size: 34),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            _ternak ? 'PENYELAMATAN BAHAN ORGANIK' : 'PENYELAMATAN MAKANAN',
            style: LbText.body(
              12.5,
              weight: FontWeight.w800,
              color: LbColors.forest,
            ).copyWith(letterSpacing: 0.6),
          ),
        ),
        _roundBtn(Icons.share_outlined, () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                'Fitur bagikan segera hadir',
                style: LbText.body(13, color: Colors.white),
              ),
            ),
          );
        }),
        const SizedBox(width: 8),
        _roundBtn(
          _fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          () => setState(() => _fav = !_fav),
          color: _fav ? LbColors.peach : LbColors.forest,
        ),
      ],
    );
  }

  // ============================================================
  // HERO
  // ============================================================
  Widget _hero() {
    final String badge1 = it.gratis
        ? 'Gratis'
        : (_hematPct > 0 ? 'Hemat $_hematPct%' : 'Harga Terjangkau');
    final String stok = _ternak
        ? 'Tersedia ${it.badge}'
        : 'Tersisa ${_num(it.badge)} paket lagi!';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: AspectRatio(
          aspectRatio: 1.42,
          child: Stack(
            fit: StackFit.expand,
            children: [
              LbNetImage(url: it.gambar),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.18),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.22),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _pill(
                      badge1,
                      icon: Icons.local_fire_department_rounded,
                      bg: LbColors.peach,
                      fg: LbColors.forest,
                    ),
                    _pill(
                      _ternak ? 'Bahan Organik Terpilih' : '100% Layak Santap',
                      icon: _ternak
                          ? Icons.eco_rounded
                          : Icons.verified_rounded,
                      bg: Colors.white.withValues(alpha: 0.95),
                      fg: LbColors.forest,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: LbColors.peachDeep,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        stok,
                        style: LbText.body(
                          12,
                          weight: FontWeight.w800,
                          color: LbColors.peachDeep,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: LbColors.sageDeep,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${it.rating} (180+)',
                        style: LbText.body(
                          12,
                          weight: FontWeight.w800,
                          color: LbColors.forest,
                        ),
                      ),
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

  // ============================================================
  // INFO TOKO + JADWAL
  // ============================================================
  Widget _infoCard() {
    final st = _status;

    return _card(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            it.nama,
            style: LbText.heading(19, weight: FontWeight.w700, height: 1.25),
          ),
          const SizedBox(height: 10),

          // Penjual
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: LbColors.sageDeep,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  it.inisial,
                  style: LbText.heading(
                    9,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  it.penjual,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LbText.body(
                    13.5,
                    weight: FontWeight.w700,
                    color: LbColors.forest,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Alamat
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.location_on_outlined,
                  size: 19,
                  color: LbColors.sageDeep,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${it.alamat} (${it.jarak})',
                  style: LbText.body(13, height: 1.35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Chip petunjuk
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _pill(
                'Petunjuk Arah / Peta',
                icon: Icons.directions_rounded,
                bg: LbColors.sageLight,
                fg: LbColors.forest,
                size: 12,
              ),
              _pill(
                _estimasi,
                bg: const Color(0xFFF1EFEA),
                fg: LbColors.textGrey,
                size: 12,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Jadwal
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F6E6),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [LbColors.sage, LbColors.sageDeep],
                    ),
                  ),
                  child: const Icon(
                    Icons.schedule_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jadwal Pengambilan Mandiri',
                        style: LbText.body(
                          11.5,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Hari ini, ${it.waktu.replaceAll(':', '.')}',
                        style: LbText.heading(
                          14.5,
                          weight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _pill(
                  st.label,
                  bg: st.bg,
                  fg: st.fg,
                  size: 11,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // METODE PENGAMBILAN
  // ============================================================
  Widget _pickupCard() {
    return _card(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.storefront_rounded, 'Metode Pengambilan Pesanan'),
          const SizedBox(height: 14),

          // Peringatan
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LbColors.peachLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 20,
                  color: LbColors.peachDeep,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: LbText.body(
                        12,
                        color: LbColors.forest,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: 'Penting: ',
                          style: LbText.body(
                            12,
                            weight: FontWeight.w800,
                            color: LbColors.peachDeep,
                          ),
                        ),
                        const TextSpan(
                          text:
                              'Lastbite tidak menyediakan kurir antar. Anda wajib mengambil langsung ke toko atau memesan ojol mandiri secara terpisah.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          _pickupOption(
            index: 0,
            icon: Icons.storefront_outlined,
            title: 'Ambil Sendiri ke Toko',
            tag: 'Rekomendasi',
            tagBg: LbColors.sage.withValues(alpha: 0.35),
            tagFg: LbColors.forest,
            desc:
                'Datang langsung ke kasir toko dan tunjukkan bukti QR pesanan Anda saat jam pengambilan.',
          ),
          const SizedBox(height: 10),
          _pickupOption(
            index: 1,
            icon: Icons.two_wheeler_rounded,
            title: 'Kirim via Ojol Mandiri',
            tag: 'Luar Aplikasi',
            tagBg: const Color(0xFFEDEBE6),
            tagFg: LbColors.textGrey,
            desc:
                'Pesan GoSend / GrabExpress secara mandiri di aplikasi Gojek / Grab Anda.',
          ),
        ],
      ),
    );
  }

  Widget _pickupOption({
    required int index,
    required IconData icon,
    required String title,
    required String tag,
    required Color tagBg,
    required Color tagFg,
    required String desc,
  }) {
    final sel = _pickup == index;

    return GestureDetector(
      onTap: () => setState(() => _pickup = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFFF1F6E6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: sel ? LbColors.sage : LbColors.border,
            width: sel ? 1.6 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: _radio(sel),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 19, color: LbColors.sageDeep),
                          const SizedBox(width: 6),
                          Text(
                            title,
                            style: LbText.heading(
                              13.5,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: tagBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: LbText.body(
                            10.5,
                            weight: FontWeight.w800,
                            color: tagFg,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(desc, style: LbText.body(12, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TENTANG PAKET / BAHAN
  // ============================================================
  Widget _aboutCard() {
    final isPupuk = it.kategori == 'Bahan Pupuk';

    final List<(IconData, String, String)> tiles = _ternak
        ? [
            (Icons.eco_rounded, 'Organik', 'Tanpa bahan kimia'),
            (
              Icons.savings_outlined,
              it.gratis ? 'Gratis' : 'Super Hemat',
              it.gratis ? 'Tanpa biaya bahan' : 'Harga ramah kantong'
            ),
            (Icons.recycling_rounded, 'Bebas Limbah', 'Kurangi sampah kota'),
          ]
        : [
            (Icons.wb_sunny_outlined, 'Fresh Daily', 'Produksi pagi tadi'),
            (
              Icons.savings_outlined,
              'Super Hemat',
              _hematPct > 0 ? 'Potongan s/d $_hematPct%' : 'Harga spesial'
            ),
            (Icons.recycling_rounded, 'Bebas Limbah', 'Selamatkan bumi'),
          ];

    return _card(
      color: const Color(0xFFF1F6E6),
      borderColor: LbColors.sage.withValues(alpha: 0.35),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [LbColors.sage, LbColors.sageDeep],
                  ),
                ),
                child: Icon(
                  _ternak ? Icons.recycling_rounded : Icons.card_giftcard_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _ternak ? 'Tentang Bahan Ini' : 'Apa itu Paket Kejutan?',
                      style: LbText.heading(16, weight: FontWeight.w700),
                    ),
                    Text(
                      _ternak
                          ? 'Pasokan Sisa Organik Lastbite'
                          : 'Surprise Food Rescue Box',
                      style: LbText.body(
                        12,
                        weight: FontWeight.w800,
                        color: LbColors.sageDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_ternak)
            Text(
              isPupuk
                  ? 'Sisa sayur, buah, dan bahan organik ini cocok diolah menjadi kompos atau pupuk cair. Membantu mengurangi sampah dan menyuburkan tanah kebunmu.'
                  : 'Bahan ini berupa sisa makanan organik yang masih layak dimanfaatkan sebagai pakan ternak. Cek kondisi saat pengambilan dan sesuaikan dengan jenis ternakmu.',
              style: LbText.body(13.5, color: LbColors.forest, height: 1.5),
            )
          else
            Text.rich(
              TextSpan(
                style: LbText.body(13.5, color: LbColors.forest, height: 1.5),
                children: [
                  const TextSpan(text: 'Isi paket adalah kombinasi acak sekitar '),
                  TextSpan(
                    text: '3–4 produk roti segar',
                    style: LbText.body(
                      13.5,
                      weight: FontWeight.w800,
                      color: LbColors.forest,
                      height: 1.5,
                    ),
                  ),
                  const TextSpan(
                    text:
                        ' yang tidak habis terjual hari ini. Kondisi 100% higienis, lezat, dan aman dikonsumsi. Membantu mengurangi food waste!',
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: LbColors.border),
                    ),
                    child: Column(
                      children: [
                        Icon(tiles[i].$1, size: 22, color: LbColors.sageDeep),
                        const SizedBox(height: 6),
                        Text(
                          tiles[i].$2,
                          textAlign: TextAlign.center,
                          style: LbText.heading(
                            11.5,
                            weight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tiles[i].$3,
                          textAlign: TextAlign.center,
                          style: LbText.body(10, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // METODE PEMBAYARAN
  // ============================================================
  Widget _paymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Metode Pembayaran',
                  style: LbText.heading(16, weight: FontWeight.w600),
                ),
              ),
              const Icon(
                Icons.lock_outline_rounded,
                size: 14,
                color: LbColors.textGrey,
              ),
              const SizedBox(width: 4),
              Text(
                'Aman & Terenkripsi',
                style: LbText.body(11.5, weight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < _payGroups.length; i++) _payGroup(i, _payGroups[i]),
      ],
    );
  }

  Widget _payGroup(int gi, _PayGroup g) {
    final open = _openGroup == gi;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _openGroup = open ? -1 : gi),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F6E6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: LbColors.sage.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(g.icon, size: 18, color: LbColors.sageDeep),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      g.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LbText.heading(
                        11,
                        weight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: gi == 0
                          ? LbColors.peachLight
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      g.badge,
                      style: LbText.body(
                        11,
                        weight: FontWeight.w800,
                        color: gi == 0
                            ? LbColors.peachDeep
                            : LbColors.textGrey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: LbColors.forest,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: open
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: g.opts.map(_payOption).toList(),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _payOption(_PayOpt o) {
    final sel = _payId == o.id;

    return GestureDetector(
      onTap: () => setState(() => _payId = o.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: sel ? LbColors.sage : LbColors.border,
            width: sel ? 1.6 : 1,
          ),
          boxShadow: sel
              ? [
                  BoxShadow(
                    color: LbColors.sage.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: LbColors.sageLight,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(o.icon, size: 25, color: LbColors.sageDeep),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          o.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LbText.heading(14, weight: FontWeight.w600),
                        ),
                      ),
                      if (o.tag != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: LbColors.sageDeep,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            o.tag!,
                            style: LbText.body(
                              9,
                              weight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    o.sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LbText.body(11.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _radio(sel),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RINCIAN PEMBAYARAN
  // ============================================================
  Widget _row(
    String label,
    String value, {
    Color? labelColor,
    Color? valueColor,
    bool strike = false,
    Widget? leading,
  }) {
    final labelStyle = LbText.body(
      14,
      weight: FontWeight.w600,
      color: labelColor ?? LbColors.forest,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (leading != null) ...[leading, const SizedBox(width: 6)],
          Expanded(child: Text(label, style: labelStyle)),
          Text(
            value,
            style: LbText.body(
              14.5,
              weight: FontWeight.w700,
              color: valueColor ?? LbColors.forest,
            ).copyWith(
              decoration: strike ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return _card(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Rincian Pembayaran',
                  style: LbText.heading(16, weight: FontWeight.w600),
                ),
              ),
              _pill(
                'Pasti Hemat',
                bg: LbColors.sageLight,
                fg: LbColors.sageDeep,
                size: 11,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (it.hargaAsli != null) ...[
            _row(
              'Harga Asli Toko',
              _rp(_asli),
              strike: true,
              valueColor: LbColors.textGrey,
            ),
            _row(
              'Diskon Food Rescue',
              '-${_rp(_diskon)}',
              labelColor: LbColors.peachDeep,
              valueColor: LbColors.peachDeep,
              leading: const Icon(
                Icons.local_offer_outlined,
                size: 16,
                color: LbColors.peachDeep,
              ),
            ),
          ],
          _row(
            _ternak ? 'Harga Pasokan' : 'Harga Aplikasi Lastbite',
            _harga == 0 ? 'Gratis' : _rp(_harga),
          ),
          _row(
            'Biaya Layanan & Admin',
            _fee == 0 ? 'Gratis' : _rp(_fee),
          ),
          const SizedBox(height: 8),
          const _DashedLine(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total Pembayaran',
                  style: LbText.heading(16, weight: FontWeight.w700),
                ),
              ),
              Text(
                _total == 0 ? 'Gratis' : _rp(_total),
                style: LbText.heading(
                  19,
                  weight: FontWeight.w700,
                  color: LbColors.sageDeep,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATATAN
  // ============================================================
  Widget _notesCard() {
    final chips = _ternak
        ? const [
            '+ Bawa karung sendiri',
            '+ Ambil lebih awal',
            '+ Butuh jumlah lebih',
          ]
        : const [
            '+ Bebas kacang',
            '+ Bawa kantong sendiri',
            '+ Suka rasa manis',
          ];

    return _card(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            Icons.edit_note_rounded,
            _ternak ? 'Catatan untuk penjual' : 'Catatan alergi / permintaan khusus',
            trailing: Text(
              'Opsional',
              style: LbText.body(11.5, weight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _ternak
                ? 'Penjual akan berusaha menyesuaikan dengan ketersediaan stok.'
                : 'Merchant akan berusaha menyesuaikan isi paket kejutan dengan ketersediaan stok.',
            style: LbText.body(12, height: 1.4),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8EA),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: LbColors.sage.withValues(alpha: 0.25)),
            ),
            child: TextField(
              controller: _notes,
              minLines: 2,
              maxLines: 4,
              cursorColor: LbColors.sageDeep,
              style: LbText.body(13.5, color: LbColors.forest),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: _ternak
                    ? 'Contoh: Saya bawa karung sendiri...'
                    : 'Contoh: Tidak ada kacang tanah / bawa kantong belanja sendiri...',
                hintStyle: LbText.body(13.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips.map((c) {
              return GestureDetector(
                onTap: () {
                  final text = c.replaceFirst('+ ', '');
                  final cur = _notes.text.trim();
                  if (cur.toLowerCase().contains(text.toLowerCase())) return;
                  _notes.text = cur.isEmpty ? text : '$cur, $text';
                  _notes.selection = TextSelection.collapsed(
                    offset: _notes.text.length,
                  );
                  setState(() {});
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: LbColors.sageLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    c,
                    style: LbText.body(
                      12,
                      weight: FontWeight.w800,
                      color: LbColors.forest,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO KEAMANAN
  // ============================================================
  Widget _safetyBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LbColors.sage.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 26,
            color: LbColors.sageDeep,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _ternak
                  ? 'Cek kondisi bahan saat pengambilan di lokasi. Sampaikan ke penjual jika ada masalah sebelum meninggalkan lokasi.'
                  : 'Cek kondisi paket saat pengambilan di gerai. Sampaikan ke penjual jika ada masalah sebelum meninggalkan lokasi.',
              style: LbText.body(12, color: LbColors.forest, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM BAR
  // ============================================================
  Widget _bottomBar() {
    final String sub = _diskon > 0
        ? 'Hemat ${_rp(_diskon)} hari ini'
        : (it.gratis ? 'Pasokan gratis' : 'Sudah termasuk biaya layanan');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: LbColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _total == 0 ? 'Gratis' : _rp(_total),
                      style: LbText.heading(22, weight: FontWeight.w700),
                    ),
                    Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LbText.body(
                        11.5,
                        weight: FontWeight.w700,
                        color: _diskon > 0
                            ? LbColors.peachDeep
                            : LbColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _konfirmasi,
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [LbColors.sage, LbColors.sageDeep],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: LbColors.sage.withValues(alpha: 0.5),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _total == 0 ? 'Ambil Gratis' : 'Pesan & Bayar',
                        style: LbText.heading(
                          15,
                          weight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
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

  void _konfirmasi() {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
          decoration: const BoxDecoration(
            color: LbColors.offWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: LbColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [LbColors.sage, LbColors.sageDeep],
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pesanan Berhasil Dibuat!',
                  style: LbText.heading(18, weight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tunjukkan bukti QR pesananmu ke kasir pada ${it.waktu.replaceAll(':', '.')}.',
                  textAlign: TextAlign.center,
                  style: LbText.body(13, height: 1.4),
                ),
                const SizedBox(height: 22),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [LbColors.sage, LbColors.sageDeep],
                      ),
                    ),
                    child: Text(
                      'Selesai',
                      style: LbText.heading(
                        15,
                        weight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// GARIS PUTUS-PUTUS
// ============================================================
class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final n = (c.maxWidth / 8).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            n,
            (_) => Container(
              width: 4,
              height: 1.5,
              color: const Color(0xFFD5D1C7),
            ),
          ),
        );
      },
    );
  }
}