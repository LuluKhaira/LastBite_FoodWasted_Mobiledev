import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'widgets/profil_ui.dart';

class PinSandiScreen extends StatefulWidget {
  const PinSandiScreen({super.key});

  @override
  State<PinSandiScreen> createState() => _PinSandiScreenState();
}

class _PinSandiScreenState extends State<PinSandiScreen> {
  final _form = GlobalKey<FormState>();
  final _lama = TextEditingController();
  final _baru = TextEditingController();
  final _konfirmasi = TextEditingController();
  final List<bool> _lihat = [false, false, false];

  bool _modePin = true;
  bool _menyimpan = false;

  @override
  void dispose() {
    _lama.dispose();
    _baru.dispose();
    _konfirmasi.dispose();
    super.dispose();
  }

  void _ganti(bool pin) {
    if (_modePin == pin) return;
    setState(() {
      _modePin = pin;
      _lama.clear();
      _baru.clear();
      _konfirmasi.clear();
      _lihat.setAll(0, [false, false, false]);
    });
  }

  Future<void> _simpan() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _menyimpan = true);
    // TODO: sambungkan ke API untuk mengubah PIN / kata sandi.
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _menyimpan = false);
    profilSnack(
      context,
      _modePin ? 'PIN berhasil diubah' : 'Kata sandi berhasil diubah',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ProfilSubScaffold(
      title: 'PIN & Kata Sandi',
      bottom: ProfilButton(
        label: _modePin ? 'Simpan PIN Baru' : 'Simpan Kata Sandi Baru',
        icon: Icons.lock_outline_rounded,
        loading: _menyimpan,
        onPressed: _simpan,
      ),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _pilihMode(),
            const SizedBox(height: 20),
            _field(
              i: 0,
              c: _lama,
              label: _modePin ? 'PIN lama' : 'Kata sandi lama',
              validator: (v) =>
                  (v ?? '').isEmpty ? 'Wajib diisi' : null,
            ),
            _field(
              i: 1,
              c: _baru,
              label: _modePin ? 'PIN baru (6 digit)' : 'Kata sandi baru',
              validator: (v) {
                final t = v ?? '';
                if (_modePin) {
                  if (t.length != 6) return 'PIN harus 6 digit';
                } else {
                  if (t.length < 8) return 'Minimal 8 karakter';
                  if (!RegExp(r'[A-Za-z]').hasMatch(t) ||
                      !RegExp(r'\d').hasMatch(t)) {
                    return 'Gunakan kombinasi huruf dan angka';
                  }
                }
                if (t == _lama.text) return 'Tidak boleh sama dengan yang lama';
                return null;
              },
            ),
            _field(
              i: 2,
              c: _konfirmasi,
              label: _modePin ? 'Konfirmasi PIN baru' : 'Konfirmasi kata sandi baru',
              validator: (v) =>
                  (v ?? '') != _baru.text ? 'Konfirmasi tidak cocok' : null,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.hijauMuda,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined,
                      size: 20, color: AppColors.textDark),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _modePin
                          ? 'Jangan bagikan PIN ke siapa pun, termasuk pihak yang mengaku dari Last Bite.'
                          : 'Gunakan kata sandi unik yang tidak dipakai di aplikasi lain.',
                      style: AppColors.body(fontSize: 12.5, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pilihMode() {
    Widget item(String label, bool pin) {
      final aktif = _modePin == pin;
      return Expanded(
        child: GestureDetector(
          onTap: () => _ganti(pin),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: aktif ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: AppColors.body(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: aktif ? AppColors.textDark : ProfilUI.textSoft,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.hijauMuda,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [item('Ubah PIN', true), item('Ubah Kata Sandi', false)]),
    );
  }

  Widget _field({
    required int i,
    required TextEditingController c,
    required String label,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        key: ValueKey('$_modePin-$i'),
        controller: c,
        obscureText: !_lihat[i],
        keyboardType:
            _modePin ? TextInputType.number : TextInputType.visiblePassword,
        inputFormatters: _modePin
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ]
            : null,
        style: AppColors.body(fontSize: 15, fontWeight: FontWeight.w700),
        decoration: profilInput(
          label: label,
          icon: Icons.lock_outline_rounded,
          suffix: IconButton(
            icon: Icon(
              _lihat[i]
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: ProfilUI.textSoft,
            ),
            onPressed: () => setState(() => _lihat[i] = !_lihat[i]),
          ),
        ),
        validator: validator,
      ),
    );
  }
}