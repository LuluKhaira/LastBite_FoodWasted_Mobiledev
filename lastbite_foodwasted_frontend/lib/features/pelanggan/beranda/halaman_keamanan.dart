import 'package:flutter/material.dart';
import 'api_service.dart';
import 'beranda_widgets.dart';

// ============================================================
// LAYAR KEAMANAN AKUN
// Data dari GET /api/profil (email, phone, email_terverifikasi,
// punya_password, password_diubah_hari).
// ============================================================
class KeamananAkunScreen extends StatefulWidget {
  const KeamananAkunScreen({super.key});

  @override
  State<KeamananAkunScreen> createState() => _KeamananAkunScreenState();
}

class _KeamananAkunScreenState extends State<KeamananAkunScreen> {
  Map<String, dynamic>? _d;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat({bool senyap = false}) async {
    if (!senyap) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final j = await ApiService.getProfil();
      if (!mounted) return;
      setState(() {
        _d = j;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _loading = false;
        if (_d == null) _error = msg;
      });
      if (_d != null) _snack(msg);
    }
  }

  // ---------- data turunan ----------
  String get _email => '${_d?['email'] ?? ''}';
  String get _phone => '${_d?['phone'] ?? ''}';
  bool get _emailOk => _d?['email_terverifikasi'] == true;
  bool get _punyaPassword => _d?['punya_password'] != false;
  int? get _hariPassword => (_d?['password_diubah_hari'] as num?)?.toInt();

  bool get _terlindungi => _phone.isNotEmpty || _emailOk;

  String get _subSandi {
    if (!_punyaPassword) return 'Belum ada kata sandi';
    final h = _hariPassword;
    if (h == null) return 'Belum pernah diubah';
    if (h == 0) return 'Terakhir diubah hari ini';
    return 'Terakhir diubah $h hari lalu';
  }

  /// 6281261976531 / 0812... -> +62 812-6197-6531
  String _formatHp(String raw) {
    var d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.startsWith('0')) d = '62${d.substring(1)}';
    if (!d.startsWith('62') || d.length < 10) return raw;
    final n = d.substring(2);
    final a = n.substring(0, 3);
    final rest = n.substring(3);
    if (rest.length <= 4) return '+62 $a-$rest';
    return '+62 $a-${rest.substring(0, 4)}-${rest.substring(4)}';
  }

  // ---------- aksi ----------
  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg, style: LbText.body(13, color: Colors.white)),
        backgroundColor: LbColors.forest,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ));
  }

  Future<void> _ubahSandi() async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SandiSheet(punyaPassword: _punyaPassword),
    );
    if (ok == true) {
      _snack('Kata sandi berhasil disimpan');
      _muat(senyap: true);
    }
  }

  Future<void> _keluarPerangkatLain() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Keluar dari perangkat lain?', style: LbText.heading(17)),
        content: Text(
          'Semua perangkat lain yang sedang masuk ke akunmu akan dikeluarkan. '
          'Perangkat ini tetap masuk.',
          style: LbText.body(13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: LbText.heading(13.5, color: LbColors.textGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Keluarkan',
                style: LbText.heading(13.5, color: LbColors.peachDeep)),
          ),
        ],
      ),
    );
    if (yakin != true) return;

    try {
      await ApiService.keluarPerangkatLain();
      if (!mounted) return;
      _snack('Semua perangkat lain sudah dikeluarkan');
    } catch (e) {
      if (!mounted) return;
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LbColors.offWhite,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(child: _isi()),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded,
                color: LbColors.forest, size: 26),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Text('Keamanan Akun',
                style: LbText.heading(20, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _isi() {
    if (_loading && _d == null) {
      return const Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child:
              CircularProgressIndicator(strokeWidth: 3, color: LbColors.sageDeep),
        ),
      );
    }
    if (_d == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 44, color: LbColors.sageDeep),
              const SizedBox(height: 12),
              Text(
                (_error ?? '').contains('Unauthenticated')
                    ? 'Masuk dulu ya untuk melihat keamanan akunmu.'
                    : (_error ?? 'Terjadi kesalahan'),
                textAlign: TextAlign.center,
                style: LbText.body(13),
              ),
              const SizedBox(height: 14),
              TextButton.icon(
                onPressed: _muat,
                icon: const Icon(Icons.refresh_rounded, color: LbColors.forest),
                label: Text('Coba lagi',
                    style: LbText.heading(13, weight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: LbColors.sageDeep,
      onRefresh: () => _muat(senyap: true),
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _bannerStatus(),
          const _Label('PENGATURAN KEAMANAN'),
          _Group(children: [
            _Baris(
              icon: Icons.password_rounded,
              title: _punyaPassword ? 'Ubah Kata Sandi' : 'Buat Kata Sandi',
              subtitle: _subSandi,
              trailingText: _punyaPassword ? 'Ubah' : 'Buat',
              onTap: _ubahSandi,
            ),
          ]),
          const _Label('INFORMASI AKUN'),
          _Group(children: [
            _BarisInfo(
              icon: Icons.mail_outline_rounded,
              label: 'Surel',
              value: _email.isEmpty ? 'Belum ditambahkan' : _email,
              status: _email.isEmpty
                  ? null
                  : (_emailOk ? 'Terverifikasi' : 'Belum diverifikasi'),
              statusOk: _emailOk,
            ),
            _BarisInfo(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Nomor WhatsApp',
              value: _phone.isEmpty ? 'Belum ditambahkan' : _formatHp(_phone),
              status: _phone.isEmpty ? null : 'Terverifikasi',
              statusOk: true,
            ),
          ]),
          const SizedBox(height: 18),
          _tombolKeluarPerangkat(),
        ],
      ),
    );
  }

  Widget _bannerStatus() {
    final ok = _terlindungi;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _kartuDeco(),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: ok ? LbColors.sageLight : LbColors.peachLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              ok ? Icons.verified_user_rounded : Icons.shield_outlined,
              size: 28,
              color: ok ? LbColors.sageDeep : LbColors.peachDeep,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ok ? 'Akun Anda Terlindungi' : 'Lengkapi Keamanan Akun',
                  style: LbText.heading(16.5, weight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  ok
                      ? 'Pengamanan akun aktif dan terverifikasi'
                      : 'Tambahkan nomor WhatsApp atau verifikasi surelmu',
                  style: LbText.body(12.5, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tombolKeluarPerangkat() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: _keluarPerangkatLain,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: LbColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phonelink_erase_rounded,
                  size: 21, color: LbColors.peachDeep),
              const SizedBox(width: 9),
              Text('Keluar dari Semua Perangkat Lain',
                  style: LbText.heading(14,
                      weight: FontWeight.w600, color: LbColors.peachDeep)),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// KOMPONEN
// ============================================================
BoxDecoration _kartuDeco() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: LbColors.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.035),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    );

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 22, 0, 10),
      child: Text(
        text,
        style: LbText.heading(12,
            weight: FontWeight.w700,
            color: LbColors.textGrey,
            letterSpacing: 0.8),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final List<Widget> children;
  const _Group({required this.children});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i != children.length - 1) {
        rows.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(height: 1, thickness: 1, color: LbColors.border),
        ));
      }
    }
    return Container(
      decoration: _kartuDeco(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: Column(children: rows),
        ),
      ),
    );
  }
}

Widget _ikon(IconData icon) => Container(
      width: 46,
      height: 46,
      decoration: const BoxDecoration(
        color: LbColors.sageLight,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 22, color: LbColors.forest),
    );

/// Baris pengaturan: judul + subjudul, lalu teks aksi / chip / saklar di kanan.
class _Baris extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailingText; // mis. "Ubah"
  final String? chip; // mis. "Segera"
  final bool? switchValue; // non-null -> tampil saklar
  final VoidCallback onTap;

  const _Baris({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailingText,
    this.chip,
    this.switchValue,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _ikon(icon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(title,
                          style: LbText.heading(14.5, weight: FontWeight.w600)),
                      if (chip != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: LbColors.peachLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(chip!,
                              style: LbText.body(10.5,
                                  weight: FontWeight.w800,
                                  color: LbColors.peachDeep)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: LbText.body(12.5, height: 1.3)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (switchValue != null)
              IgnorePointer(
                child: Switch(
                  value: switchValue!,
                  onChanged: (_) {},
                  activeColor: Colors.white,
                  activeTrackColor: LbColors.sageDeep,
                ),
              )
            else if (trailingText != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(trailingText!,
                      style: LbText.heading(14,
                          weight: FontWeight.w700, color: LbColors.sageDeep)),
                  const Icon(Icons.chevron_right_rounded,
                      size: 22, color: LbColors.textGrey),
                ],
              )
            else
              const Icon(Icons.chevron_right_rounded,
                  size: 22, color: LbColors.textGrey),
          ],
        ),
      ),
    );
  }
}

class _BarisInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? status;
  final bool statusOk;

  const _BarisInfo({
    required this.icon,
    required this.label,
    required this.value,
    required this.status,
    required this.statusOk,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _ikon(icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: LbText.body(12.5)),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LbText.heading(14,
                      weight: FontWeight.w600, color: LbColors.sageDeep),
                ),
              ],
            ),
          ),
          if (status != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: statusOk ? LbColors.sageLight : LbColors.peachLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                status!,
                style: LbText.body(11.5,
                    weight: FontWeight.w800,
                    color: statusOk ? LbColors.forest : LbColors.peachDeep),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// SHEET UBAH / BUAT KATA SANDI
// ============================================================
class _SandiSheet extends StatefulWidget {
  final bool punyaPassword;
  const _SandiSheet({required this.punyaPassword});

  @override
  State<_SandiSheet> createState() => _SandiSheetState();
}

class _SandiSheetState extends State<_SandiSheet> {
  final TextEditingController _lama = TextEditingController();
  final TextEditingController _baru = TextEditingController();
  final TextEditingController _ulang = TextEditingController();
  bool _lihat = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _lama.dispose();
    _baru.dispose();
    _ulang.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (widget.punyaPassword && _lama.text.isEmpty) {
      setState(() => _error = 'Isi kata sandi lama');
      return;
    }
    if (_baru.text.length < 8) {
      setState(() => _error = 'Kata sandi baru minimal 8 karakter');
      return;
    }
    if (_baru.text != _ulang.text) {
      setState(() => _error = 'Konfirmasi kata sandi tidak sama');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ApiService.ubahPassword(
        lama: widget.punyaPassword ? _lama.text : null,
        baru: _baru.text,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  InputDecoration _deco(String label) => InputDecoration(
        labelText: label,
        labelStyle: LbText.body(13),
        prefixIcon: const Icon(Icons.lock_outline_rounded,
            color: LbColors.sageDeep, size: 21),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _lihat = !_lihat),
          icon: Icon(
            _lihat ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
            color: LbColors.textGrey,
          ),
        ),
        filled: true,
        fillColor: LbColors.offWhite,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          borderSide: const BorderSide(color: LbColors.sageDeep, width: 1.6),
        ),
      );

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
              Text(
                widget.punyaPassword ? 'Ubah Kata Sandi' : 'Buat Kata Sandi',
                style: LbText.heading(18, weight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Gunakan minimal 8 karakter. Perangkat lain akan dikeluarkan '
                'setelah kata sandi diubah.',
                style: LbText.body(12.5, height: 1.4),
              ),
              const SizedBox(height: 16),
              if (widget.punyaPassword) ...[
                TextField(
                  controller: _lama,
                  obscureText: !_lihat,
                  style: LbText.body(14, color: LbColors.forest),
                  decoration: _deco('Kata sandi lama'),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _baru,
                obscureText: !_lihat,
                style: LbText.body(14, color: LbColors.forest),
                decoration: _deco('Kata sandi baru'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ulang,
                obscureText: !_lihat,
                style: LbText.body(14, color: LbColors.forest),
                decoration: _deco('Ulangi kata sandi baru'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style: LbText.body(12.5,
                        weight: FontWeight.w700, color: LbColors.peachDeep)),
              ],
              const SizedBox(height: 18),
              GestureDetector(
                onTap: _saving ? null : _simpan,
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      colors: [LbColors.sage, LbColors.sageDeep],
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4, color: Colors.white),
                        )
                      : Text('Simpan',
                          style: LbText.heading(15,
                              weight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}