import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';
import 'widgets/profil_ui.dart';

class _Hari {
  final String nama;
  bool buka;
  TimeOfDay mulai;
  TimeOfDay tutup;

  _Hari(this.nama)
      : buka = true,
        mulai = const TimeOfDay(hour: 8, minute: 0),
        tutup = const TimeOfDay(hour: 21, minute: 0);
}

class JamBukaScreen extends StatefulWidget {
  final String phoneNumber;
  const JamBukaScreen({super.key, required this.phoneNumber});

  @override
  State<JamBukaScreen> createState() => _JamBukaScreenState();
}

class _JamBukaScreenState extends State<JamBukaScreen> {
  final List<_Hari> _hari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ].map(_Hari.new).toList();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  TimeOfDay _parse(String s, TimeOfDay cadangan) {
    final p = s.split(':');
    if (p.length < 2) return cadangan;
    final h = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    if (h == null || m == null) return cadangan;
    return TimeOfDay(hour: h, minute: m);
  }

  Future<void> _muat() async {
    final data = await ApiService.getJamOperasional(widget.phoneNumber);
    if (!mounted) return;

    if (data == null) {
      profilSnack(context, 'Gagal memuat jam buka, menampilkan nilai awal', error: true);
    } else {
      for (final d in data) {
        final i = (int.tryParse('${d['hari']}') ?? 0) - 1; // 1 = Senin
        if (i < 0 || i >= _hari.length) continue;
        final h = _hari[i];
        h.buka = d['buka'] == true || d['buka'] == 1;
        h.mulai = _parse('${d['mulai']}', h.mulai);
        h.tutup = _parse('${d['tutup']}', h.tutup);
      }
    }
    setState(() => _loading = false);
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  int _menit(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> _pilih(_Hari h, bool mulai) async {
    final hasil = await showTimePicker(
      context: context,
      initialTime: mulai ? h.mulai : h.tutup,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.textDark,
            surface: Colors.white,
            onSurface: AppColors.textDark,
          ),
        ),
        child: child!,
      ),
    );
    if (hasil == null || !mounted) return;

    final baruMulai = mulai ? hasil : h.mulai;
    final baruTutup = mulai ? h.tutup : hasil;
    if (_menit(baruTutup) <= _menit(baruMulai)) {
      profilSnack(context, 'Jam tutup harus setelah jam buka', error: true);
      return;
    }
    setState(() {
      h.mulai = baruMulai;
      h.tutup = baruTutup;
    });
  }

  void _samakanSemua() {
    final acuan = _hari.first;
    setState(() {
      for (final h in _hari) {
        h.buka = acuan.buka;
        h.mulai = acuan.mulai;
        h.tutup = acuan.tutup;
      }
    });
    profilSnack(context, 'Semua hari disamakan dengan hari Senin');
  }

  Future<void> _simpan() async {
    if (_loading || _saving) return;
    if (_hari.every((h) => !h.buka)) {
      profilSnack(context, 'Minimal satu hari harus buka', error: true);
      return;
    }

    setState(() => _saving = true);
    final hasil = await ApiService.simpanJamOperasional(
      phoneNumber: widget.phoneNumber,
      jam: [
        for (var i = 0; i < _hari.length; i++)
          {
            'hari': i + 1, // 1 = Senin ... 7 = Minggu
            'buka': _hari[i].buka,
            'mulai': _fmt(_hari[i].mulai),
            'tutup': _fmt(_hari[i].tutup),
          },
      ],
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (hasil['ok'] == true) {
      profilSnack(context, 'Jam operasional disimpan');
      Navigator.pop(context, true);
    } else {
      profilSnack(context, '${hasil['message']}', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfilSubScaffold(
      title: 'Jam Buka',
      bottom: ProfilButton(
        label: 'Simpan Jam Operasional',
        icon: Icons.check_rounded,
        onPressed: _simpan,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.hijauMuda,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 20, color: AppColors.textDark),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Batas pengambilan pesanan tidak akan melewati jam tutup toko.',
                        style: AppColors.body(fontSize: 12.5, height: 1.4),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _samakanSemua,
                        child: Text(
                          'Samakan semua hari dengan Senin',
                          style: AppColors.body(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ).copyWith(decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else
            ..._hari.map(_kartuHari),
        ],
      ),
    );
  }

  Widget _kartuHari(_Hari h) {
    return ProfilCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(h.nama, style: AppColors.heading(fontSize: 14)),
              ),
              Text(
                h.buka ? 'Buka' : 'Tutup',
                style: AppColors.body(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: h.buka ? AppColors.textDark : ProfilUI.textSoft,
                ),
              ),
              const SizedBox(width: 6),
              ProfilSwitch(
                value: h.buka,
                onChanged: (v) => setState(() => h.buka = v),
              ),
            ],
          ),
          if (h.buka) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _kotakWaktu('Jam buka', _fmt(h.mulai),
                      () => _pilih(h, true)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _kotakWaktu('Jam tutup', _fmt(h.tutup),
                      () => _pilih(h, false)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _kotakWaktu(String label, String waktu, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.hijauMuda,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded,
                size: 18, color: AppColors.textDark),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppColors.body(
                    fontSize: 10.5,
                    color: ProfilUI.textSoft,
                  ),
                ),
                Text(waktu, style: AppColors.heading(fontSize: 15)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}