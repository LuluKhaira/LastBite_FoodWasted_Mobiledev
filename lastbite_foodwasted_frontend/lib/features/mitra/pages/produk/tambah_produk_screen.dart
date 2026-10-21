import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';

/// Warna khusus layar ini. Semuanya diturunkan dari AppColors milik tim,
/// jadi kalau AppColors.primary / orange diganti, layar ini ikut berubah.
class _Warna {
  /// Hijau tua untuk tombol utama & chip terpilih (turunan dari primary).
  /// Mau lebih gelap/terang? ubah angka 0.25 (0.0 = hitam, 1.0 = putih).
  static Color get primaryDark =>
      HSLColor.fromColor(AppColors.primary).withLightness(0.25).toColor();

  /// Latar layar: primary yang sangat pucat.
  static Color get mint =>
      Color.alphaBlend(AppColors.primary.withValues(alpha: 0.10), Colors.white);

  /// Isi kolom input & chip: primary pucat.
  static Color get mintDeep =>
      Color.alphaBlend(AppColors.primary.withValues(alpha: 0.28), Colors.white);

  /// Badge "Hemat" & tanda wajib: orange versi gelap.
  static Color get danger =>
      HSLColor.fromColor(AppColors.orange).withLightness(0.32).toColor();
}

class _Kategori {
  final String nama;
  final IconData ikon;
  const _Kategori(this.nama, this.ikon);
}

const _daftarKategori = [
  _Kategori('Roti & Bakery', Icons.bakery_dining),
  _Kategori('Dessert', Icons.icecream_outlined),
  _Kategori('Makanan Berat', Icons.ramen_dining_outlined),
  _Kategori('Bahan Olahan', Icons.blender_outlined),
  _Kategori('Pakan Ternak', Icons.agriculture_outlined),
];

/// Mengubah input angka menjadi format ribuan: 45000 -> 45.000
class _RibuanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 9) digits = digits.substring(0, 9);
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final t = _ribuan(int.parse(digits));
    return TextEditingValue(
      text: t,
      selection: TextSelection.collapsed(offset: t.length),
    );
  }
}

String _ribuan(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}

int _angka(String teks) => int.tryParse(teks.replaceAll('.', '')) ?? 0;

class TambahProdukScreen extends StatefulWidget {
  final String phoneNumber;

  const TambahProdukScreen({super.key, required this.phoneNumber});

  @override
  State<TambahProdukScreen> createState() => _TambahProdukScreenState();
}

class _TambahProdukScreenState extends State<TambahProdukScreen> {
  final _namaCtrl = TextEditingController();
  final _asliCtrl = TextEditingController();
  final _diskonCtrl = TextEditingController();

  String? _kategori;
  int _stok = 1;
  TimeOfDay _waktu = const TimeOfDay(hour: 20, minute: 0);

  Uint8List? _fotoBytes;
  String? _fotoNama;
  String? _gambarLama; // path foto dari template (di server)
  String? _gambarLamaUrl; // url untuk menampilkan

  Map<String, dynamic>? _template;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _asliCtrl.addListener(() => setState(() {}));
    _diskonCtrl.addListener(() => setState(() {}));
    _muatTemplate();
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _asliCtrl.dispose();
    _diskonCtrl.dispose();
    super.dispose();
  }

  Future<void> _muatTemplate() async {
    final t = await ApiService.getTemplateProduk(widget.phoneNumber);
    if (!mounted) return;
    setState(() => _template = t);
  }

  void _pakaiTemplate() {
    final t = _template;
    if (t == null) return;
    final asli = int.tryParse('${t['harga_asli']}') ?? 0;
    final diskon = int.tryParse('${t['harga']}') ?? 0;
    final stok = int.tryParse('${t['stok']}') ?? 1;

    setState(() {
      _namaCtrl.text = '${t['nama'] ?? ''}';
      _kategori = _daftarKategori.any((k) => k.nama == t['kategori'])
          ? '${t['kategori']}'
          : null;
      _asliCtrl.text = asli > 0 ? _ribuan(asli) : '';
      _diskonCtrl.text = _ribuan(diskon);
      _stok = stok.clamp(1, 999);
      if (t['gambar'] != null && '${t['gambar']}'.isNotEmpty) {
        _gambarLama = '${t['gambar']}';
        _gambarLamaUrl = t['gambar_url']?.toString();
        _fotoBytes = null;
        _fotoNama = null;
      }
    });
  }

  int? get _hematPersen {
    final asli = _angka(_asliCtrl.text);
    if (asli <= 0 || _diskonCtrl.text.isEmpty) return null;
    final diskon = _angka(_diskonCtrl.text);
    if (diskon >= asli) return null;
    return (((asli - diskon) / asli) * 100).round();
  }

  String _formatJam(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';

  String _jamUntukServer(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // ---------------------------------------------------------------- aksi

  Future<void> _pilihFoto() async {
    final sumber = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.photo_camera_outlined,
                  color: _Warna.primaryDark),
              title: Text('Ambil foto dengan kamera',
                  style: AppColors.body(fontWeight: FontWeight.w700)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined,
                  color: _Warna.primaryDark),
              title: Text('Pilih dari galeri',
                  style: AppColors.body(fontWeight: FontWeight.w700)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (sumber == null) return;

    try {
      final x = await ImagePicker()
          .pickImage(source: sumber, imageQuality: 80, maxWidth: 1600);
      if (x == null) return;
      final bytes = await x.readAsBytes();
      if (!mounted) return;
      setState(() {
        _fotoBytes = bytes;
        _fotoNama = x.name.isEmpty ? 'foto.jpg' : x.name;
        _gambarLama = null;
        _gambarLamaUrl = null;
      });
    } catch (e) {
      _snack('Tidak bisa membuka foto: $e');
    }
  }

  Future<void> _pilihWaktu() async {
    final t = await showTimePicker(context: context, initialTime: _waktu);
    if (t != null) setState(() => _waktu = t);
  }

  void _snack(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _kirim(bool terbit) async {
    final nama = _namaCtrl.text.trim();
    final asli = _angka(_asliCtrl.text);
    final diskon = _angka(_diskonCtrl.text);

    if (nama.isEmpty) return _snack('Nama produk wajib diisi.');
    if (_kategori == null) return _snack('Pilih kategori produk.');
    if (asli <= 0) return _snack('Harga asli wajib diisi.');
    if (_diskonCtrl.text.isEmpty) {
      return _snack('Harga diskon wajib diisi (boleh Rp 0 untuk donasi).');
    }
    if (diskon >= asli) {
      return _snack('Harga Lastbite harus lebih hemat dari harga asli.');
    }
    if (terbit && _fotoBytes == null && _gambarLama == null) {
      return _snack('Foto makanan wajib diunggah.');
    }

    setState(() => _saving = true);
    final hasil = await ApiService.tambahProduk(
      phoneNumber: widget.phoneNumber,
      nama: nama,
      kategori: _kategori!,
      hargaAsli: asli,
      harga: diskon,
      stok: _stok,
      waktuSelesai: _jamUntukServer(_waktu),
      terbit: terbit,
      fotoBytes: _fotoBytes,
      fotoNama: _fotoNama,
      gambarLama: _gambarLama,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (hasil['ok'] == true) {
      _snack('${hasil['message']}');
      Navigator.pop(context, true);
    } else {
      _snack('${hasil['message']}');
    }
  }

  // ---------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Warna.mint,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    if (_template != null) ...[
                      _bannerTemplate(),
                      const SizedBox(height: 14),
                    ],
                    _kartuFoto(),
                    const SizedBox(height: 14),
                    _kartuNama(),
                    const SizedBox(height: 14),
                    _kartuKategori(),
                    const SizedBox(height: 14),
                    _kartuHarga(),
                    const SizedBox(height: 14),
                    _kartuStok(),
                    const SizedBox(height: 14),
                    _kartuBatas(),
                    const SizedBox(height: 14),
                    _kartuJaminan(),
                  ],
                ),
              ),
            ),
            _barBawah(),
          ],
        ),
      ),
    );
  }

  Widget _kartu({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _judul(String teks, {String? sub, Widget? kanan, bool wajib = true}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: teks, style: AppColors.heading(fontSize: 15)),
                    if (wajib)
                      TextSpan(
                        text: ' *',
                        style: AppColors.heading(
                            fontSize: 15, color: _Warna.danger),
                      ),
                  ],
                ),
              ),
              if (sub != null)
                Text(sub,
                    style: AppColors.body(fontSize: 12, color: AppColors.textSoft)),
            ],
          ),
        ),
        if (kanan != null) kanan,
      ],
    );
  }

  Widget _pill(String teks, {Color? bg, Color? fg, IconData? ikon}) {
    final warnaTeks = fg ?? AppColors.textDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg ?? _Warna.mintDeep,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ikon != null) ...[
            Icon(ikon, size: 13, color: warnaTeks),
            const SizedBox(width: 4),
          ],
          Text(
            teks,
            style: AppColors.body(
                fontSize: 11, fontWeight: FontWeight.w800, color: warnaTeks),
          ),
        ],
      ),
    );
  }

  Widget _bannerTemplate() {
    return InkWell(
      onTap: _pakaiTemplate,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _Warna.primaryDark,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_fix_high,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('GUNAKAN TEMPLATE',
                      style: AppColors.body(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: _Warna.primaryDark)),
                  Text(
                    'Salin dari: ${_template!['nama'] ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppColors.heading(fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(Icons.bolt, color: _Warna.primaryDark),
          ],
        ),
      ),
    );
  }

  Widget _previewFoto() {
    if (_fotoBytes != null) {
      return Image.memory(_fotoBytes!, fit: BoxFit.cover);
    }
    if (_gambarLamaUrl != null) {
      return Image.network(
        _gambarLamaUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined,
            color: AppColors.textSoft),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _kartuFoto() {
    final adaFoto = _fotoBytes != null || _gambarLamaUrl != null;
    final namaFile = _fotoNama ?? (_gambarLama?.split('/').last ?? '');

    return _kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _judul('1. Foto Makanan / Paket',
              kanan: _pill('Wajib Foto Asli')),
          const SizedBox(height: 12),
          InkWell(
            onTap: _saving ? null : _pilihFoto,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _Warna.mintDeep,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.photo_camera_outlined,
                        size: 32, color: _Warna.primaryDark),
                  ),
                  const SizedBox(height: 10),
                  Text('Ketuk untuk Ambil Foto',
                      style: AppColors.heading(fontSize: 15)),
                  Text('atau pilih foto dari galeri',
                      style: AppColors.body(
                          fontSize: 12, color: AppColors.textSoft)),
                  if (adaFoto) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                              width: 80, height: 80, child: _previewFoto()),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _pill('Foto Terpasang',
                                  bg: AppColors.primary.withValues(alpha: 0.4),
                                  fg: _Warna.primaryDark,
                                  ikon: Icons.check),
                              const SizedBox(height: 4),
                              Text(namaFile,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppColors.heading(fontSize: 13)),
                              Text('Ketuk untuk ganti foto lain',
                                  style: AppColors.body(
                                      fontSize: 11.5,
                                      color: AppColors.textSoft)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartuNama() {
    return _kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _judul('2. Nama Produk / Paket',
              kanan: Text('Maks. 50 Karakter',
                  style: AppColors.body(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSoft))),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _Warna.mintDeep,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _namaCtrl,
              maxLength: 50,
              style: AppColors.body(fontSize: 15, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                border: InputBorder.none,
                counterText: '',
                hintText: 'Contoh: Paket Kejutan Aneka Roti Manis',
                hintStyle: AppColors.body(
                    fontSize: 14, color: AppColors.textSoft),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Gunakan kata "Paket Kejutan" bila isi menu bervariasi.',
              style: AppColors.body(fontSize: 12, color: AppColors.textSoft)),
        ],
      ),
    );
  }

  Widget _kartuKategori() {
    return _kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _judul('3. Kategori Produk'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _daftarKategori.map((k) {
              final dipilih = _kategori == k.nama;
              return InkWell(
                onTap: () => setState(() => _kategori = k.nama),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: dipilih ? _Warna.primaryDark : _Warna.mintDeep,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(k.ikon,
                          size: 18,
                          color: dipilih ? Colors.white : AppColors.textDark),
                      const SizedBox(width: 8),
                      Text(
                        k.nama,
                        style: AppColors.body(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: dipilih ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _kotakRupiah(TextEditingController c, {Color? warna}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _Warna.mintDeep,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text('Rp',
              style: AppColors.heading(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: warna ?? AppColors.textSoft)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: c,
              keyboardType: TextInputType.number,
              inputFormatters: [_RibuanFormatter()],
              style: AppColors.heading(fontSize: 22, color: warna ?? AppColors.textDark),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0',
                hintStyle: AppColors.heading(
                    fontSize: 22, color: AppColors.textSoft.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartuHarga() {
    final hemat = _hematPersen;
    return _kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _judul('4. Harga Penyelamatan',
              kanan: hemat == null
                  ? null
                  : _pill('Hemat $hemat%',
                      bg: _Warna.danger, fg: Colors.white)),
          const SizedBox(height: 12),
          Text('Harga Asli Toko',
              style: AppColors.body(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 6),
          _kotakRupiah(_asliCtrl),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Harga Diskon Lastbite',
                  style: AppColors.body(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: _Warna.primaryDark)),
              GestureDetector(
                onTap: () => _diskonCtrl.text = '0',
                child: Text('Set Gratis (Rp 0)',
                    style: AppColors.body(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _Warna.primaryDark)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _kotakRupiah(_diskonCtrl, warna: _Warna.primaryDark),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _Warna.mintDeep,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline,
                    size: 18, color: _Warna.danger),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: AppColors.body(fontSize: 12, color: AppColors.textDark),
                      children: [
                        TextSpan(
                          text: 'Wajib: ',
                          style: AppColors.body(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _Warna.danger),
                        ),
                        const TextSpan(
                            text:
                                'Harga Lastbite harus lebih hemat dibanding harga asli. Anda boleh memasukkan Rp 0 untuk donasi panti atau pakan ternak.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tombolStok(IconData ikon, VoidCallback? onTap, {required bool utama}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: utama ? _Warna.primaryDark : _Warna.mintDeep,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(ikon,
            color: utama ? Colors.white : AppColors.textDark, size: 24),
      ),
    );
  }

  Widget _kartuStok() {
    return _kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _judul('5. Jumlah Stok',
              sub: 'Berapa porsi/paket yang diselamatkan?',
              kanan: _pill('Paket')),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: _Warna.mintDeep.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _tombolStok(Icons.remove,
                    _stok > 1 ? () => setState(() => _stok--) : null,
                    utama: false),
                Text('$_stok',
                    style: AppColors.heading(
                        fontSize: 32, color: _Warna.primaryDark)),
                _tombolStok(Icons.add,
                    _stok < 999 ? () => setState(() => _stok++) : null,
                    utama: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartuBatas() {
    final sekarang = DateTime.now();
    final satuJam = TimeOfDay.fromDateTime(sekarang.add(const Duration(hours: 1)));
    const jam20 = TimeOfDay(hour: 20, minute: 0);
    const jam2130 = TimeOfDay(hour: 21, minute: 30);

    Widget pilihan(String label, TimeOfDay t) {
      final dipilih = _waktu.hour == t.hour && _waktu.minute == t.minute;
      return Expanded(
        child: InkWell(
          onTap: () => setState(() => _waktu = t),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: dipilih ? _Warna.primaryDark : _Warna.mintDeep,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                label,
                style: AppColors.body(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: dipilih ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return _kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _judul('6. Batas Pengambilan',
              kanan: Text('Sebelum Tutup Toko',
                  style: AppColors.body(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _Warna.danger))),
          const SizedBox(height: 10),
          InkWell(
            onTap: _pilihWaktu,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _Warna.mintDeep,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time,
                      color: _Warna.primaryDark, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Hari Ini, Pukul ${_formatJam(_waktu)} WIB',
                        style: AppColors.heading(fontSize: 15)),
                  ),
                  const Icon(Icons.edit_calendar_outlined,
                      color: AppColors.textSoft, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              pilihan('1 Jam Lagi', satuJam),
              const SizedBox(width: 8),
              pilihan('Jam 20.00', jam20),
              const SizedBox(width: 8),
              pilihan('Jam 21.30', jam2130),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kartuJaminan() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _Warna.mintDeep.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.verified_outlined,
                color: _Warna.primaryDark, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jaminan Kualitas Lastbite',
                    style: AppColors.heading(fontSize: 13)),
                Text('Makanan masih higienis, layak konsumsi, dan dikemas rapi.',
                    style: AppColors.body(fontSize: 12, color: AppColors.textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _barBawah() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      decoration: BoxDecoration(
        color: _Warna.mint,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : () => _kirim(true),
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.rocket_launch_outlined, size: 20),
              label: Text('Simpan & Terbitkan Produk',
                  style: AppColors.heading(
                      fontSize: 15, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _Warna.primaryDark,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          TextButton(
            onPressed: _saving ? null : () => _kirim(false),
            child: Text('Simpan sebagai Draf Toko',
                style: AppColors.body(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }
}