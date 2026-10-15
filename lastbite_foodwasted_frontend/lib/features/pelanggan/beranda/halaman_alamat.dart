import 'package:flutter/material.dart';
import 'api_service.dart';
import 'beranda_widgets.dart';
import 'halaman_bantuan.dart';
import 'profil_widgets.dart';

const List<String> _kLabelPilihan = ['Rumah', 'Kantor / Tempat Kerja', 'Lainnya'];

IconData _ikonLabel(String label) {
  final l = label.toLowerCase();
  if (l.contains('rumah')) return Icons.home_rounded;
  if (l.contains('kantor') || l.contains('kerja')) return Icons.work_outline_rounded;
  return Icons.place_outlined;
}

// ============================================================
// ALAMAT & LOKASI FAVORIT
// ============================================================
class AlamatScreen extends StatefulWidget {
  const AlamatScreen({super.key});

  @override
  State<AlamatScreen> createState() => _AlamatScreenState();
}

class _AlamatScreenState extends State<AlamatScreen> {
  List<Map<String, dynamic>> _alamat = [];
  List<Map<String, dynamic>> _favorit = [];
  bool _loading = true;
  String? _error;
  bool _kelola = false;

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
      final hasil = await Future.wait<List<Map<String, dynamic>>>([
        ApiService.getAlamat(),
        ApiService.getMitraFavorit(),
      ]);
      if (!mounted) return;
      setState(() {
        _alamat = hasil[0];
        _favorit = hasil[1];
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (_alamat.isEmpty && _favorit.isEmpty) _error = pkPesanError(e);
      });
      if (senyap) pkSnack(context, pkPesanError(e));
    }
  }

  Future<void> _formAlamat({Map<String, dynamic>? awal}) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FormAlamat(awal: awal, adaAlamat: _alamat.isNotEmpty),
    );
    if (ok == true) {
      if (!mounted) return;
      pkSnack(context, awal == null ? 'Alamat ditambahkan' : 'Alamat diperbarui');
      _muat(senyap: true);
    }
  }

  Future<void> _jadikanUtama(Map<String, dynamic> a) async {
    try {
      await ApiService.jadikanAlamatUtama((a['id'] as num).toInt());
      if (!mounted) return;
      pkSnack(context, '${a['label']} dijadikan alamat utama');
      _muat(senyap: true);
    } catch (e) {
      if (mounted) pkSnack(context, pkPesanError(e));
    }
  }

  Future<void> _hapus(Map<String, dynamic> a) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Hapus alamat?', style: LbText.heading(17)),
        content: Text('Alamat "${a['label']}" akan dihapus dari daftarmu.',
            style: LbText.body(13.5, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: LbText.heading(13.5, color: LbColors.textGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus',
                style: LbText.heading(13.5, color: LbColors.peachDeep)),
          ),
        ],
      ),
    );
    if (yakin != true) return;
    try {
      await ApiService.hapusAlamat((a['id'] as num).toInt());
      if (!mounted) return;
      pkSnack(context, 'Alamat dihapus');
      _muat(senyap: true);
    } catch (e) {
      if (mounted) pkSnack(context, pkPesanError(e));
    }
  }

  Future<void> _hapusFavorit(Map<String, dynamic> m) async {
    try {
      await ApiService.hapusMitraFavorit((m['id_mitra'] as num).toInt());
      if (!mounted) return;
      pkSnack(context, '${m['nama']} dihapus dari favorit');
      _muat(senyap: true);
    } catch (e) {
      if (mounted) pkSnack(context, pkPesanError(e));
    }
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
              title: 'Alamat & Lokasi Favorit',
              trailing: IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BantuanScreen()),
                ),
                icon: const Icon(Icons.help_outline_rounded,
                    color: LbColors.forest, size: 26),
              ),
            ),
            Expanded(child: _isi()),
          ],
        ),
      ),
    );
  }

  Widget _isi() {
    if (_loading) {
      return const Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(strokeWidth: 3, color: LbColors.sageDeep),
        ),
      );
    }
    if (_error != null) return PkError(pesan: _error!, onRetry: _muat);

    return RefreshIndicator(
      color: LbColors.sageDeep,
      onRefresh: () => _muat(senyap: true),
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Alamat Tersimpan',
                  style: LbText.heading(18, weight: FontWeight.w700)),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text('(${_alamat.length} lokasi)',
                    style: LbText.body(12.5)),
              ),
              const Spacer(),
              const Icon(Icons.check_circle_rounded,
                  size: 16, color: LbColors.sageDeep),
              const SizedBox(width: 4),
              Text('Terhubung',
                  style: LbText.heading(12,
                      weight: FontWeight.w700, color: LbColors.sageDeep)),
            ],
          ),
          const SizedBox(height: 12),
          if (_alamat.isEmpty)
            _kosongAlamat()
          else
            for (final a in _alamat) ...[
              _kartuAlamat(a),
              const SizedBox(height: 14),
            ],
          _tombolTambah(),
          const SizedBox(height: 28),
          _headerMitra(),
          const SizedBox(height: 12),
          if (_favorit.isEmpty)
            _kosongFavorit()
          else
            for (final m in _favorit) ...[
              _kartuMitra(m),
              const SizedBox(height: 12),
            ],
          const SizedBox(height: 10),
          _catatan(),
        ],
      ),
    );
  }

  // ---------- alamat ----------
  Widget _kosongAlamat() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: pkKartuDeco(),
      child: Column(
        children: [
          const Icon(Icons.location_off_outlined,
              size: 38, color: LbColors.sageDeep),
          const SizedBox(height: 10),
          Text('Belum ada alamat tersimpan',
              style: LbText.heading(15, weight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Tambahkan alamat supaya titik jemputmu mudah ditemukan.',
              textAlign: TextAlign.center, style: LbText.body(12.5, height: 1.4)),
        ],
      ),
    );
  }

  Widget _kartuAlamat(Map<String, dynamic> a) {
    final utama = a['is_utama'] == true;
    final patokan = '${a['patokan'] ?? ''}'.trim();
    final label = '${a['label'] ?? ''}';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 14),
      decoration: pkKartuDeco(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: utama ? LbColors.sageLight : const Color(0xFFF1EFEA),
              shape: BoxShape.circle,
            ),
            child: Icon(_ikonLabel(label),
                size: 24, color: utama ? LbColors.forest : LbColors.textGrey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LbText.heading(15.5, weight: FontWeight.w600)),
                    ),
                    if (utama) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: LbColors.forest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('Utama',
                            style: LbText.body(11,
                                weight: FontWeight.w800, color: Colors.white)),
                      ),
                    ],
                    const Spacer(),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.more_vert_rounded,
                          color: LbColors.textGrey),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      onSelected: (v) {
                        if (v == 'ubah') _formAlamat(awal: a);
                        if (v == 'utama') _jadikanUtama(a);
                        if (v == 'hapus') _hapus(a);
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                            value: 'ubah',
                            child: Text('Ubah', style: LbText.body(13.5, color: LbColors.forest))),
                        if (!utama)
                          PopupMenuItem(
                              value: 'utama',
                              child: Text('Jadikan Utama',
                                  style: LbText.body(13.5, color: LbColors.forest))),
                        PopupMenuItem(
                            value: 'hapus',
                            child: Text('Hapus',
                                style: LbText.body(13.5, color: LbColors.peachDeep))),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${a['nama_penerima']} • ${a['telepon']}',
                          style: LbText.body(12.5, weight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text('${a['alamat']}',
                          style: LbText.body(14,
                              color: LbColors.forest, height: 1.4)),
                      if (patokan.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: LbColors.offWhite,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline_rounded,
                                  size: 17, color: LbColors.textGrey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('Patokan: $patokan',
                                    style: LbText.body(12.5, height: 1.35)),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (utama)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_outlined,
                                    size: 18, color: LbColors.sageDeep),
                                const SizedBox(width: 5),
                                Text('Alamat Utama',
                                    style: LbText.heading(12.5,
                                        weight: FontWeight.w600,
                                        color: LbColors.sageDeep)),
                              ],
                            )
                          else
                            GestureDetector(
                              onTap: () => _jadikanUtama(a),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 9),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1EFEA),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text('Jadikan Utama',
                                    style: LbText.heading(12.5,
                                        weight: FontWeight.w600,
                                        color: LbColors.forest)),
                              ),
                            ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _formAlamat(awal: a),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Text('Ubah',
                                  style: LbText.heading(14,
                                      weight: FontWeight.w700,
                                      color: LbColors.forest)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tombolTambah() {
    return Material(
      color: const Color(0xFFF1EFEA),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _formAlamat(),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_location_alt_outlined,
                  size: 22, color: LbColors.sageDeep),
              const SizedBox(width: 9),
              Text('Tambah Alamat Baru',
                  style: LbText.heading(14.5,
                      weight: FontWeight.w600, color: LbColors.sageDeep)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- mitra favorit ----------
  Widget _headerMitra() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mitra Ambil Favorit',
                  style: LbText.heading(18, weight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('Titik langganan penyelamatan makananmu',
                  style: LbText.body(12.5)),
            ],
          ),
        ),
        if (_favorit.isNotEmpty)
          GestureDetector(
            onTap: () => setState(() => _kelola = !_kelola),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
              child: Text(_kelola ? 'Selesai' : 'Kelola',
                  style: LbText.heading(13,
                      weight: FontWeight.w700, color: LbColors.forest)),
            ),
          ),
      ],
    );
  }

  Widget _kosongFavorit() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: pkKartuDeco(),
      child: Row(
        children: [
          const Icon(Icons.favorite_border_rounded,
              size: 30, color: LbColors.sageDeep),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Belum ada mitra favorit. Tekan ikon hati di halaman detail paket untuk menyimpannya di sini.',
              style: LbText.body(12.5, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartuMitra(Map<String, dynamic> m) {
    final waktu = '${m['waktu'] ?? ''}'.trim();
    final alamat = '${m['alamat'] ?? ''}'.trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: pkKartuDeco(),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 66,
              height: 66,
              child: LbNetImage(url: '${m['gambar'] ?? ''}'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${m['nama'] ?? ''}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: LbText.heading(14.5, weight: FontWeight.w600, height: 1.25)),
                if (alamat.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(alamat,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LbText.body(12.5,
                          weight: FontWeight.w700, color: LbColors.sageDeep)),
                ],
                if (waktu.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 15, color: LbColors.peachDeep),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text('Biasa ambil jam $waktu',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: LbText.body(11.5, weight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (_kelola)
            GestureDetector(
              onTap: () => _hapusFavorit(m),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: LbColors.peachLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    size: 22, color: LbColors.peachDeep),
              ),
            )
          else
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: LbColors.sageLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_rounded,
                  size: 22, color: LbColors.sageDeep),
            ),
        ],
      ),
    );
  }

  Widget _catatan() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LbColors.sageLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco_outlined, size: 26, color: LbColors.sageDeep),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Menentukan titik jemput tetap membantu menghemat emisi karbon perjalanan di setiap pesanan surplus.',
              style: LbText.body(12.5, color: LbColors.forest, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FORM TAMBAH / UBAH ALAMAT
// ============================================================
class _FormAlamat extends StatefulWidget {
  final Map<String, dynamic>? awal;
  final bool adaAlamat;
  const _FormAlamat({required this.awal, required this.adaAlamat});

  @override
  State<_FormAlamat> createState() => _FormAlamatState();
}

class _FormAlamatState extends State<_FormAlamat> {
  final _nama = TextEditingController();
  final _telepon = TextEditingController();
  final _alamat = TextEditingController();
  final _patokan = TextEditingController();
  final _labelLain = TextEditingController();

  String _label = 'Rumah';
  bool _utama = false;
  bool _saving = false;
  String? _error;

  bool get _ubah => widget.awal != null;

  @override
  void initState() {
    super.initState();
    final a = widget.awal;
    if (a != null) {
      final l = '${a['label'] ?? 'Rumah'}';
      if (_kLabelPilihan.contains(l)) {
        _label = l;
      } else {
        _label = 'Lainnya';
        _labelLain.text = l;
      }
      _nama.text = '${a['nama_penerima'] ?? ''}';
      _telepon.text = '${a['telepon'] ?? ''}';
      _alamat.text = '${a['alamat'] ?? ''}';
      _patokan.text = '${a['patokan'] ?? ''}';
      _utama = a['is_utama'] == true;
    } else {
      _utama = !widget.adaAlamat;
      _isiDariProfil();
    }
  }

  Future<void> _isiDariProfil() async {
    try {
      final p = await ApiService.getProfil();
      if (!mounted) return;
      if (_nama.text.isEmpty) _nama.text = '${p['name'] ?? ''}';
      if (_telepon.text.isEmpty) _telepon.text = '${p['phone'] ?? ''}';
    } catch (_) {}
  }

  @override
  void dispose() {
    _nama.dispose();
    _telepon.dispose();
    _alamat.dispose();
    _patokan.dispose();
    _labelLain.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    final label = _label == 'Lainnya' ? _labelLain.text.trim() : _label;
    if (label.isEmpty) {
      setState(() => _error = 'Isi nama label alamat');
      return;
    }
    if (_nama.text.trim().isEmpty ||
        _telepon.text.trim().isEmpty ||
        _alamat.text.trim().isEmpty) {
      setState(() => _error = 'Nama penerima, nomor HP, dan alamat wajib diisi');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ApiService.simpanAlamat(
        {
          'label': label,
          'nama_penerima': _nama.text.trim(),
          'telepon': _telepon.text.trim(),
          'alamat': _alamat.text.trim(),
          'patokan': _patokan.text.trim(),
          'is_utama': _utama,
        },
        id: _ubah ? (widget.awal!['id'] as num).toInt() : null,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = pkPesanError(e);
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
    final bawah = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      padding: EdgeInsets.fromLTRB(22, 14, 22, 20 + bawah),
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
              Text(_ubah ? 'Ubah Alamat' : 'Tambah Alamat Baru',
                  style: LbText.heading(18, weight: FontWeight.w700)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _kLabelPilihan.map((l) {
                  final sel = _label == l;
                  return GestureDetector(
                    onTap: () => setState(() => _label = l),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: sel ? LbColors.forest : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                            color: sel ? LbColors.forest : LbColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_ikonLabel(l),
                              size: 16,
                              color: sel ? Colors.white : LbColors.forest),
                          const SizedBox(width: 6),
                          Text(l,
                              style: LbText.body(12.5,
                                  weight: FontWeight.w700,
                                  color: sel ? Colors.white : LbColors.forest)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_label == 'Lainnya') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _labelLain,
                  style: LbText.body(14, color: LbColors.forest),
                  decoration: _deco('Nama label (mis. Kos, Rumah Nenek)',
                      Icons.label_outline_rounded),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _nama,
                textCapitalization: TextCapitalization.words,
                style: LbText.body(14, color: LbColors.forest),
                decoration: _deco('Nama penerima', Icons.person_outline_rounded),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _telepon,
                keyboardType: TextInputType.phone,
                style: LbText.body(14, color: LbColors.forest),
                decoration: _deco('Nomor HP', Icons.phone_outlined),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _alamat,
                minLines: 2,
                maxLines: 4,
                style: LbText.body(14, color: LbColors.forest),
                decoration: _deco('Alamat lengkap', Icons.location_on_outlined),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _patokan,
                style: LbText.body(14, color: LbColors.forest),
                decoration: _deco('Patokan (opsional)', Icons.info_outline_rounded),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _utama,
                onChanged: (_ubah && widget.awal!['is_utama'] == true) ||
                        !widget.adaAlamat
                    ? null
                    : (v) => setState(() => _utama = v),
                activeColor: Colors.white,
                activeTrackColor: LbColors.sageDeep,
                title: Text('Jadikan alamat utama',
                    style: LbText.heading(13.5, weight: FontWeight.w600)),
              ),
              if (_error != null) ...[
                Text(_error!,
                    style: LbText.body(12.5,
                        weight: FontWeight.w700, color: LbColors.peachDeep)),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 6),
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
                      : Text('Simpan Alamat',
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