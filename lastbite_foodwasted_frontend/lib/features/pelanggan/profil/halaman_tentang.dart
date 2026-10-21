import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../beranda/beranda_widgets.dart';
import 'halaman_profil.dart' show kVersiAplikasi;


const String _kBuild = '2409';
const String _kEmailKemitraan = 'partnership@lastbite.id';

// ============================================================
// LAYAR TENTANG LASTBITE
// ============================================================
class TentangLastbiteScreen extends StatelessWidget {
  const TentangLastbiteScreen({super.key});

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg, style: LbText.body(13, color: Colors.white)),
        backgroundColor: LbColors.forest,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ));
  }

  Future<void> _salin(BuildContext context, String teks, String label) async {
    await Clipboard.setData(ClipboardData(text: teks));
    if (!context.mounted) return;
    _snack(context, '$label disalin');
  }

  @override
  Widget build(BuildContext context) {
    final versi = kVersiAplikasi.replaceFirst('v', '');

    return Scaffold(
      backgroundColor: LbColors.offWhite,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                children: [
                  _logo(versi),
                  const SizedBox(height: 22),
                  _misi(),
                  const _Label('INFORMASI & LEGALITAS'),
                  _Group(children: [
                    _Menu(
                      icon: Icons.shield_outlined,
                      title: 'Kebijakan Privasi',
                      subtitle: 'Perlindungan data pribadi & akun',
                      onTap: () => _snack(context, 'Kebijakan Privasi segera hadir'),
                    ),
                    _Menu(
                      icon: Icons.gavel_rounded,
                      title: 'Syarat & Ketentuan Layanan',
                      subtitle: 'Panduan pembelian paket kejutan',
                      onTap: () =>
                          _snack(context, 'Syarat & Ketentuan segera hadir'),
                    ),
                    _Menu(
                      icon: Icons.code_rounded,
                      title: 'Lisensi Sumber Terbuka',
                      subtitle: 'Pustaka & aset pihak ketiga',
                      onTap: () => showLicensePage(
                        context: context,
                        applicationName: 'Lastbite',
                        applicationVersion: kVersiAplikasi,
                      ),
                    ),
                    _Menu(
                      icon: Icons.verified_outlined,
                      title: 'Pedoman Keamanan & Mutu Pangan',
                      subtitle: 'Standar kelayakan konsumsi mitra',
                      onTap: () =>
                          _snack(context, 'Pedoman Mutu Pangan segera hadir'),
                    ),
                    _Menu(
                      icon: Icons.star_rounded,
                      title: 'Beri Nilai Aplikasi',
                      subtitle: 'Dukung kami di Play Store & App Store',
                      external: true,
                      onTap: () => _snack(context, 'Halaman toko aplikasi segera hadir'),
                    ),
                  ]),
                  const _Label('TERHUBUNG BERSAMA KAMI'),
                  _sosial(context),
                  const SizedBox(height: 18),
                  _penutup(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded,
                color: LbColors.forest, size: 26),
          ),
          const LbLogoMark(size: 36, circle: true),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Tentang Lastbite',
                style: LbText.heading(19, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ---------- logo + versi ----------
  Widget _logo(String versi) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 104,
              height: 104,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: LbColors.border),
                boxShadow: [
                  BoxShadow(
                    color: LbColors.sage.withValues(alpha: 0.3),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/logo_mark.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [LbColors.sage, LbColors.sageDeep],
                    ),
                  ),
                  child:
                      const Icon(Icons.eco_rounded, color: Colors.white, size: 44),
                ),
              ),
            ),
            Positioned(
              right: -8,
              bottom: -8,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: LbColors.sageDeep,
                  border: Border.all(color: LbColors.offWhite, width: 3),
                ),
                child:
                    const Icon(Icons.eco_rounded, color: Colors.white, size: 19),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text('Lastbite', style: LbText.heading(27, weight: FontWeight.w700)),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            Text('Versi $versi (Build $_kBuild)',
                style: LbText.body(13, weight: FontWeight.w600)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: LbColors.sageLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: LbColors.sageDeep,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('Versi Terbaru',
                      style: LbText.body(11.5,
                          weight: FontWeight.w800, color: LbColors.forest)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                'Makan Enak, Hemat Kantong, Selamatkan Bumi',
                textAlign: TextAlign.center,
                style: LbText.body(13.5, color: LbColors.forest),
              ),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.eco_rounded, size: 16, color: LbColors.sageDeep),
          ],
        ),
      ],
    );
  }

  // ---------- misi ----------
  Widget _misi() {
    Widget tile(IconData icon, String teks) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
            decoration: BoxDecoration(
              color: LbColors.sageLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Icon(icon, size: 24, color: LbColors.sageDeep),
                const SizedBox(height: 6),
                Text(teks,
                    textAlign: TextAlign.center,
                    style: LbText.heading(11.5,
                        weight: FontWeight.w600, height: 1.25)),
              ],
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _kartuDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.spa_rounded, size: 20, color: LbColors.sageDeep),
              const SizedBox(width: 8),
              Text('MISI & KOMITMEN',
                  style: LbText.heading(12.5,
                      weight: FontWeight.w700,
                      color: LbColors.sageDeep,
                      letterSpacing: 0.8)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '“Lastbite hadir untuk menjembatani surplus makanan berkualitas '
            'dari restoran, bakery, dan toko kelontong kepada para pahlawan '
            'pangan lokal dengan harga terjangkau.”',
            style: LbText.heading(16,
                weight: FontWeight.w600, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              tile(Icons.recycling_rounded, 'Zero Food\nWaste'),
              const SizedBox(width: 8),
              tile(Icons.storefront_rounded, 'Dukungan\nUMKM'),
              const SizedBox(width: 8),
              tile(Icons.cloud_outlined, 'Kurangi\nKarbon'),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- sosial ----------
  Widget _sosial(BuildContext context) {
    Widget tile(IconData icon, String judul, String sub) => Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _salin(context, sub, judul),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: LbColors.offWhite,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 22, color: LbColors.forest),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(judul,
                            style: LbText.heading(12.5,
                                weight: FontWeight.w600)),
                        Text(sub,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: LbText.body(11.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _kartuDeco(),
      child: Column(
        children: [
          Row(children: [
            tile(Icons.camera_alt_outlined, 'Instagram', '@lastbite.id'),
            const SizedBox(width: 10),
            tile(Icons.music_note_rounded, 'TikTok', '@lastbite.id'),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            tile(Icons.work_outline_rounded, 'LinkedIn', 'PT LastBite'),
            const SizedBox(width: 10),
            tile(Icons.language_rounded, 'Website', 'lastbite.id'),
          ]),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _salin(context, _kEmailKemitraan, 'Email kemitraan'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [LbColors.sage, LbColors.sageDeep],
                ),
                boxShadow: [
                  BoxShadow(
                    color: LbColors.sage.withValues(alpha: 0.45),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.mail_outline_rounded,
                      color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('KEMITRAAN RESTO & BAKERY',
                            style: LbText.body(10.5,
                                weight: FontWeight.w800,
                                color: Colors.white.withValues(alpha: 0.9))),
                        Text(_kEmailKemitraan,
                            style: LbText.heading(15,
                                weight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                  ),
                  const Icon(Icons.copy_rounded, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- penutup ----------
  Widget _penutup() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: LbColors.sageLight,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              const Icon(Icons.favorite_border_rounded,
                  size: 20, color: LbColors.sageDeep),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Setiap butir terselamatkan adalah senyuman untuk bumi.',
                  style: LbText.body(12.5,
                      color: LbColors.forest, height: 1.4)
                      .copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '© 2026 PT LastBite Pangan Indonesia.\nSeluruh hak cipta dilindungi.',
          textAlign: TextAlign.center,
          style: LbText.body(12, height: 1.45),
        ),
      ],
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
      padding: const EdgeInsets.fromLTRB(6, 24, 0, 10),
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

class _Menu extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool external;
  final VoidCallback onTap;

  const _Menu({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.external = false,
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: LbColors.sageLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 22, color: LbColors.forest),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LbText.heading(14, weight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: LbText.body(12.5, height: 1.3)),
                ],
              ),
            ),
            Icon(
              external ? Icons.open_in_new_rounded : Icons.chevron_right_rounded,
              size: external ? 20 : 22,
              color: LbColors.textGrey,
            ),
          ],
        ),
      ),
    );
  }
}