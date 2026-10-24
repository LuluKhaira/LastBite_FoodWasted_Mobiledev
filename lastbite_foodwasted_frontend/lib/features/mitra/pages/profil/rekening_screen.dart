import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'widgets/profil_ui.dart';

class _Rek {
  final String bank;
  final String nomor;
  final String nama;
  bool utama;

  _Rek({
    required this.bank,
    required this.nomor,
    required this.nama,
    this.utama = false,
  });
}

const List<String> _daftarBank = [
  'BCA',
  'BRI',
  'BNI',
  'Mandiri',
  'BSI',
  'CIMB Niaga',
  'Permata',
  'Jago',
];

String _mask(String n) =>
    n.length <= 4 ? n : '•••• •••• ${n.substring(n.length - 4)}';

class RekeningScreen extends StatefulWidget {
  final String namaToko;
  const RekeningScreen({super.key, this.namaToko = 'Toko Saya'});

  @override
  State<RekeningScreen> createState() => _RekeningScreenState();
}

class _RekeningScreenState extends State<RekeningScreen> {
  final List<_Rek> _daftar = [];

  @override
  void initState() {
    super.initState();
    // Data contoh. TODO: ganti dengan data dari API.
    _daftar.add(_Rek(
      bank: 'BCA',
      nomor: '1234567890',
      nama: widget.namaToko,
      utama: true,
    ));
  }

  void _jadikanUtama(_Rek r) {
    setState(() {
      for (final x in _daftar) {
        x.utama = identical(x, r);
      }
    });
    profilSnack(context, 'Rekening ${r.bank} dijadikan utama');
  }

  Future<void> _hapus(_Rek r) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus rekening?', style: AppColors.heading(fontSize: 16)),
        content: Text(
          'Rekening ${r.bank} ${_mask(r.nomor)} akan dihapus.',
          style: AppColors.body(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: AppColors.body(
                fontWeight: FontWeight.w700,
                color: ProfilUI.textSoft,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Hapus',
              style: AppColors.body(
                fontWeight: FontWeight.w800,
                color: AppColors.merah,
              ),
            ),
          ),
        ],
      ),
    );
    if (ya != true || !mounted) return;
    setState(() {
      _daftar.remove(r);
      if (_daftar.isNotEmpty && !_daftar.any((x) => x.utama)) {
        _daftar.first.utama = true;
      }
    });
    profilSnack(context, 'Rekening dihapus');
  }

  void _tambah() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FormRekening(
        onSimpan: (r) {
          setState(() {
            if (_daftar.isEmpty) r.utama = true;
            _daftar.add(r);
          });
          profilSnack(context, 'Rekening berhasil ditambahkan');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfilSubScaffold(
      title: 'Rekening',
      bottom: ProfilButton(
        label: 'Tambah Rekening',
        icon: Icons.add_rounded,
        onPressed: _tambah,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rekening ini dipakai untuk pencairan pendapatan toko.',
            style: AppColors.body(fontSize: 12.5, color: ProfilUI.textSoft),
          ),
          const SizedBox(height: 16),
          if (_daftar.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        color: AppColors.hijauMuda,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_outlined,
                        size: 44,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Belum ada rekening',
                      style: AppColors.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ProfilUI.textSoft,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._daftar.map(_kartu),
        ],
      ),
    );
  }

  Widget _kartu(_Rek r) {
    final inisial =
        r.bank.length <= 3 ? r.bank : r.bank.substring(0, 3);
    return ProfilCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.hijauMuda,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  inisial.toUpperCase(),
                  style: AppColors.heading(fontSize: 12),
                ),
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
                            'Bank ${r.bank}',
                            style: AppColors.heading(fontSize: 14),
                          ),
                        ),
                        if (r.utama) ...[
                          const SizedBox(width: 8),
                          ProfilPill(
                            text: 'Utama',
                            background:
                                AppColors.primary.withValues(alpha: 0.25),
                            foreground: AppColors.textDark,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _mask(r.nomor),
                      style: AppColors.body(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      r.nama,
                      style: AppColors.body(
                        fontSize: 12,
                        color: ProfilUI.textSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (!r.utama)
                GestureDetector(
                  onTap: () => _jadikanUtama(r),
                  child: Text(
                    'Jadikan utama',
                    style: AppColors.body(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ).copyWith(decoration: TextDecoration.underline),
                  ),
                ),
              const Spacer(),
              GestureDetector(
                onTap: () => _hapus(r),
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded,
                        size: 18, color: AppColors.merah),
                    const SizedBox(width: 4),
                    Text(
                      'Hapus',
                      style: AppColors.body(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.merah,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormRekening extends StatefulWidget {
  final void Function(_Rek) onSimpan;
  const _FormRekening({required this.onSimpan});

  @override
  State<_FormRekening> createState() => _FormRekeningState();
}

class _FormRekeningState extends State<_FormRekening> {
  final _form = GlobalKey<FormState>();
  final _nomor = TextEditingController();
  final _nama = TextEditingController();
  String _bank = _daftarBank.first;

  @override
  void dispose() {
    _nomor.dispose();
    _nama.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!(_form.currentState?.validate() ?? false)) return;
    final rek = _Rek(
      bank: _bank,
      nomor: _nomor.text.trim(),
      nama: _nama.text.trim(),
    );
    Navigator.pop(context);
    widget.onSimpan(rek);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSoft.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Tambah Rekening', style: AppColors.heading(fontSize: 18)),
              const SizedBox(height: 16),
              const ProfilSectionLabel('Pilih bank'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _daftarBank
                    .map((b) => ProfilChip(
                          label: b,
                          active: b == _bank,
                          onTap: () => setState(() => _bank = b),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _nomor,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: AppColors.body(fontSize: 15, fontWeight: FontWeight.w700),
                decoration: profilInput(
                  label: 'Nomor rekening',
                  icon: Icons.credit_card_rounded,
                ),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'Nomor rekening wajib diisi';
                  if (t.length < 8 || t.length > 20) {
                    return 'Nomor rekening harus 8–20 digit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nama,
                textCapitalization: TextCapitalization.words,
                style: AppColors.body(fontSize: 15, fontWeight: FontWeight.w700),
                decoration: profilInput(
                  label: 'Nama pemilik rekening',
                  icon: Icons.person_outline_rounded,
                ),
                validator: (v) => (v ?? '').trim().isEmpty
                    ? 'Nama pemilik wajib diisi'
                    : null,
              ),
              const SizedBox(height: 20),
              ProfilButton(label: 'Simpan Rekening', onPressed: _simpan),
            ],
          ),
        ),
      ),
    );
  }
}