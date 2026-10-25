import 'package:flutter/material.dart';
import '../beranda/api_service.dart';
import '../beranda/beranda_widgets.dart';
import 'halaman_alamat.dart';
import 'halaman_bantuan.dart';
import 'halaman_keamanan.dart';
import 'halaman_tentang.dart';
import 'halaman_ulasan.dart';
import '../beranda/lb_nav.dart';
import '../pesanan/pesanan_model.dart' show lbRp;

const String kVersiAplikasi = 'v2.4.1';

class ProfilData {
  final String name;
  final String email;
  final String phone;
  final String inisial;
  final bool isVip;
  final int level;
  final double kg;
  final int paket;
  final int hemat;
  final int voucher;
  final String metodeBayar;

  const ProfilData({
    required this.name,
    required this.email,
    required this.phone,
    required this.inisial,
    required this.isVip,
    required this.level,
    required this.kg,
    required this.paket,
    required this.hemat,
    required this.voucher,
    required this.metodeBayar,
  });

  factory ProfilData.fromJson(Map<String, dynamic> j) {
    final nama = (j['name'] ?? '').toString();
    final inisial = (j['inisial'] ?? '').toString();
    return ProfilData(
      name: nama,
      email: (j['email'] ?? '').toString(),
      phone: (j['phone'] ?? '').toString(),
      inisial: inisial.isNotEmpty
          ? inisial
          : (nama.isNotEmpty ? nama.substring(0, 1).toUpperCase() : '?'),
      isVip: j['is_vip'] == true || j['is_vip'] == 1,
      level: (j['level'] as num?)?.toInt() ?? 1,
      kg: (j['kg_diselamatkan'] as num?)?.toDouble() ?? 0,
      paket: (j['paket_diselamatkan'] as num?)?.toInt() ?? 0,
      hemat: (j['hemat_rupiah'] as num?)?.toInt() ?? 0,
      voucher: (j['voucher_tersedia'] as num?)?.toInt() ?? 0,
      metodeBayar: (j['metode_bayar'] ?? '').toString(),
    );
  }

  String get kgText => kg == kg.roundToDouble()
      ? kg.toInt().toString()
      : kg.toStringAsFixed(1).replaceAll('.', ',');
}

class ProfilScreen extends StatefulWidget {
  final VoidCallback? onLoggedOut;
  const ProfilScreen({super.key, this.onLoggedOut});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  ProfilData? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final j = await ApiService.getProfil();
      if (!mounted) return;
      setState(() {
        _data = ProfilData.fromJson(j);
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (_data == null || !silent) {
          _error = e.toString().replaceFirst('Exception: ', '');
        }
      });
      if (silent) _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

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

  void _detailLevel(ProfilData d) {
    const int perLevel = 5;
    final sisa = d.paket % perLevel;
    final menujuNext = perLevel - sisa;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
              const SizedBox(height: 20),
              Text('Penyelamat Aktif • Lv.${d.level}',
                  style: LbText.heading(19, weight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                'Tambah $menujuNext paket lagi yang sudah diambil untuk naik ke Lv.${d.level + 1}.',
                textAlign: TextAlign.center,
                style: LbText.body(13, height: 1.4),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: sisa / perLevel,
                  minHeight: 10,
                  backgroundColor: LbColors.sageLight,
                  color: LbColors.sageDeep,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  for (final t in [
                    ('${d.paket}', 'Paket diselamatkan'),
                    (d.kgText, 'kg makanan'),
                    (lbRp(d.hemat), 'Total hemat'),
                  ])
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: LbColors.border),
                        ),
                        child: Column(
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(t.$1,
                                  style: LbText.heading(16, weight: FontWeight.w700)),
                            ),
                            const SizedBox(height: 3),
                            Text(t.$2,
                                textAlign: TextAlign.center,
                                style: LbText.body(11, height: 1.25)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _edit() async {
    final d = _data;
    if (d == null) return;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfilSheet(nama: d.name, phone: d.phone),
    );
    if (ok == true) {
      _snack('Profil berhasil diperbarui');
      _muat(silent: true);
    }
  }

  Future<void> _keluar() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Keluar dari akun?', style: LbText.heading(17)),
        content: Text('Kamu perlu masuk lagi untuk menyelamatkan makanan.',
            style: LbText.body(13.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: LbText.heading(13.5, color: LbColors.textGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Keluar',
                style: LbText.heading(13.5, color: LbColors.peachDeep)),
          ),
        ],
      ),
    );
    if (yakin != true) return;

    try {
      await ApiService.logout();
    } catch (_) {}
    if (!mounted) return;

    if (widget.onLoggedOut != null) {
      widget.onLoggedOut!();
      return;
    }
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LbColors.offWhite,
      bottomNavigationBar: LbBottomNav(
        currentIndex: 3,
        onTap: (i) => LbNav.go(context, from: 3, to: i),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ---------- HEADER HIJAU PROFIL (TANPA TOMBOL NOTIFIKASI TAMBAHAN) ----------
            LbHeaderHijau(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profil Saya',
                      style: LbText.heading(22, weight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kelola akun dan preferensi LastBite kamu',
                      style: LbText.body(13, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
            
            // ---------- KONTEN PROFIL ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: _isiKonten(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _isiKonten() {
    if (_loading && _data == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(strokeWidth: 3, color: LbColors.sageDeep),
          ),
        ),
      );
    }
    if (_data == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 44, color: LbColors.sageDeep),
            const SizedBox(height: 12),
            Text(_error ?? 'Terjadi kesalahan',
                textAlign: TextAlign.center, style: LbText.body(13)),
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: _muat,
              icon: const Icon(Icons.refresh_rounded, color: LbColors.forest),
              label: Text('Coba lagi',
                  style: LbText.heading(13, weight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }

    final d = _data!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _KartuProfil(
          data: d,
          onEdit: _edit,
          onLevelTap: () => _detailLevel(d),
        ),
        const _SectionLabel('PREFERENSI'),
        _MenuGroup(children: [
          _MenuTile(
            icon: Icons.shield_outlined,
            title: 'Keamanan akun',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KeamananAkunScreen()),
            ),
          ),
          _MenuTile(
            icon: Icons.location_on_outlined,
            title: 'Alamat & Lokasi Ambil Favorit',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AlamatScreen()),
            ),
          ),
        ]),

        const _SectionLabel('AKTIVITAS PENYELAMATAN'),
        _MenuGroup(children: [
          _MenuTile(
            icon: Icons.star_border_rounded,
            title: 'Ulasan & Penilaian Resto',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UlasanScreen()),
            ),
          ),
        ]),

        const _SectionLabel('PENGATURAN APLIKASI'),
        _MenuGroup(children: [
          _MenuTile(
            icon: Icons.help_outline_rounded,
            title: 'Pusat Bantuan & FAQ',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BantuanScreen()),
            ),
          ),
          _MenuTile(
            icon: Icons.info_outline_rounded,
            title: 'Tentang Lastbite',
            trailingText: kVersiAplikasi,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TentangLastbiteScreen()),
            ),
          ),
        ]),

        const SizedBox(height: 18),
        _TombolKeluar(onTap: _keluar),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                '“Setiap butir terselamatkan adalah senyuman untuk bumi.”',
                textAlign: TextAlign.center,
                style: LbText.body(12, height: 1.4),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.eco_rounded, size: 16, color: LbColors.sageDeep),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

// ============================================================
// KARTU PROFIL & KOMPONEN PENDUKUNG
// ============================================================
class _KartuProfil extends StatelessWidget {
  final ProfilData data;
  final VoidCallback onEdit;
  final VoidCallback onLevelTap;

  const _KartuProfil({
    required this.data,
    required this.onEdit,
    required this.onLevelTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _kartuDeco(),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 78,
                height: 78,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 78,
                      height: 78,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [LbColors.sage, LbColors.sageDeep],
                        ),
                      ),
                      child: Text(
                        data.inisial,
                        style: LbText.heading(26,
                            weight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: LbColors.forest,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                        child: const Icon(Icons.eco_rounded,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: LbText.heading(18, weight: FontWeight.w700, height: 1.2)),
                    const SizedBox(height: 3),
                    Text(data.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LbText.body(12.5)),
                    if (data.phone.isNotEmpty)
                      Text(data.phone,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LbText.body(12.5)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: LbColors.sageLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_outlined,
                      size: 21, color: LbColors.sageDeep),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onLevelTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: LbColors.sageLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium_outlined,
                      size: 24, color: LbColors.sageDeep),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PENYELAMAT AKTIF • LV.${data.level}',
                          style: LbText.heading(11,
                              weight: FontWeight.w700,
                              color: LbColors.sageDeep,
                              letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Telah menyelamatkan ${data.kgText} kg makanan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LbText.body(12.5,
                              weight: FontWeight.w700, color: LbColors.forest),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 22, color: LbColors.textGrey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _kartuDeco() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: LbColors.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

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

class _MenuGroup extends StatelessWidget {
  final List<Widget> children;
  const _MenuGroup({required this.children});

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

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.trailingText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: LbColors.sageLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 23, color: LbColors.forest),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: LbText.heading(14.5, weight: FontWeight.w600, height: 1.25),
              ),
            ),
            if (trailingText != null) ...[
              const SizedBox(width: 8),
              Text(
                trailingText!,
                style: LbText.body(12, weight: FontWeight.w600, color: LbColors.textGrey),
              ),
            ],
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 22, color: LbColors.textGrey),
          ],
        ),
      ),
    );
  }
}

class _TombolKeluar extends StatelessWidget {
  final VoidCallback onTap;
  const _TombolKeluar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: LbColors.peachLight,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: LbColors.peach.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout_rounded, size: 22, color: LbColors.peachDeep),
            const SizedBox(width: 8),
            Text('Keluar dari Akun',
                style: LbText.heading(15,
                    weight: FontWeight.w600, color: LbColors.peachDeep)),
          ],
        ),
      ),
    );
  }
}

class _EditProfilSheet extends StatefulWidget {
  final String nama;
  final String phone;
  const _EditProfilSheet({required this.nama, required this.phone});

  @override
  State<_EditProfilSheet> createState() => _EditProfilSheetState();
}

class _EditProfilSheetState extends State<_EditProfilSheet> {
  late final TextEditingController _nama = TextEditingController(text: widget.nama);
  late final TextEditingController _phone = TextEditingController(text: widget.phone);
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nama.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (_nama.text.trim().isEmpty) {
      setState(() => _error = 'Nama tidak boleh kosong');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final phone = _phone.text.trim();
      await ApiService.updateProfil(
        name: _nama.text.trim(),
        phone: phone.isEmpty ? null : phone,
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

  InputDecoration _deco(String label, IconData icon) => InputDecoration(
        labelText: label,
        labelStyle: LbText.body(13),
        prefixIcon: Icon(icon, color: LbColors.sageDeep, size: 21),
        filled: true,
        fillColor: LbColors.offWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: LbColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Edit Profil', style: LbText.heading(18, weight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: _nama,
                textCapitalization: TextCapitalization.words,
                cursorColor: LbColors.sageDeep,
                style: LbText.body(14, color: LbColors.forest),
                decoration: _deco('Nama lengkap', Icons.person_outline_rounded),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                cursorColor: LbColors.sageDeep,
                style: LbText.body(14, color: LbColors.forest),
                decoration: _deco('Nomor HP (+62...)', Icons.phone_outlined),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style: LbText.body(12.5, color: LbColors.peachDeep)),
              ],
              const SizedBox(height: 18),
              GestureDetector(
                onTap: _saving ? null : _simpan,
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      colors: [LbColors.sage, LbColors.sageDeep],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: LbColors.sage.withValues(alpha: 0.45),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
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