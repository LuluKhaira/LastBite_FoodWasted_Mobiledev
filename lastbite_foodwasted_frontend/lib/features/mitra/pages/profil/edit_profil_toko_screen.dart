import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'widgets/profil_ui.dart';

class EditProfilTokoScreen extends StatefulWidget {
  final String namaToko;
  final String alamat;
  final String phoneNumber;

  const EditProfilTokoScreen({
    super.key,
    required this.namaToko,
    required this.alamat,
    required this.phoneNumber,
  });

  @override
  State<EditProfilTokoScreen> createState() => _EditProfilTokoScreenState();
}

class _EditProfilTokoScreenState extends State<EditProfilTokoScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _nama;
  late final TextEditingController _alamat;
  late final TextEditingController _telepon;
  final _deskripsi = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nama = TextEditingController(text: widget.namaToko);
    _alamat = TextEditingController(text: widget.alamat);
    _telepon = TextEditingController(text: widget.phoneNumber);
  }

  @override
  void dispose() {
    _nama.dispose();
    _alamat.dispose();
    _telepon.dispose();
    _deskripsi.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!(_form.currentState?.validate() ?? false)) return;
    // TODO: kirim perubahan ke API. Saat ini hanya memperbarui tampilan Profil.
    profilSnack(context, 'Profil toko diperbarui');
    Navigator.pop<Map<String, String>>(context, {
      'nama': _nama.text.trim(),
      'alamat': _alamat.text.trim(),
    });
  }

  Widget _jarak(Widget w) =>
      Padding(padding: const EdgeInsets.only(bottom: 14), child: w);

  @override
  Widget build(BuildContext context) {
    return ProfilSubScaffold(
      title: 'Edit Profil Toko',
      bottom: ProfilButton(
        label: 'Simpan Perubahan',
        icon: Icons.check_rounded,
        onPressed: _simpan,
      ),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: () =>
                    profilSnack(context, 'Ubah foto toko segera hadir'),
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: ProfilUI.border),
                      ),
                      child: const CircleAvatar(
                        radius: 46,
                        backgroundColor: AppColors.hijauMuda,
                        child: Icon(
                          Icons.storefront_rounded,
                          size: 44,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Ketuk untuk mengubah foto',
                style: AppColors.body(fontSize: 12, color: ProfilUI.textSoft),
              ),
            ),
            const SizedBox(height: 20),
            _jarak(
              TextFormField(
                controller: _nama,
                textCapitalization: TextCapitalization.words,
                style: AppColors.body(fontSize: 15, fontWeight: FontWeight.w700),
                decoration: profilInput(
                  label: 'Nama toko',
                  icon: Icons.storefront_outlined,
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Nama toko wajib diisi' : null,
              ),
            ),
            _jarak(
              TextFormField(
                controller: _alamat,
                maxLines: 2,
                style: AppColors.body(fontSize: 15, fontWeight: FontWeight.w700),
                decoration: profilInput(
                  label: 'Alamat toko',
                  icon: Icons.location_on_outlined,
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Alamat wajib diisi' : null,
              ),
            ),
            _jarak(
              TextFormField(
                controller: _telepon,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                ],
                style: AppColors.body(fontSize: 15, fontWeight: FontWeight.w700),
                decoration: profilInput(
                  label: 'Nomor telepon / WhatsApp',
                  icon: Icons.phone_outlined,
                ),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'Nomor telepon wajib diisi';
                  if (t.length < 9) return 'Nomor telepon terlalu pendek';
                  return null;
                },
              ),
            ),
            _jarak(
              TextFormField(
                controller: _deskripsi,
                maxLines: 4,
                maxLength: 200,
                style: AppColors.body(fontSize: 14),
                decoration: profilInput(
                  label: 'Deskripsi toko (opsional)',
                  hint: 'Ceritakan singkat tentang tokomu',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}