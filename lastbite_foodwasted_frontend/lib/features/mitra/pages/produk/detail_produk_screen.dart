import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';
import 'models/produk_model.dart';

class _UI {
  static Color get primary => AppColors.primary;
  static Color get orange => AppColors.orange;
  static Color get primaryText =>
      HSLColor.fromColor(AppColors.primary).withLightness(0.28).toColor();
  static Color get orangeText =>
      HSLColor.fromColor(AppColors.orange).withLightness(0.35).toColor();
  static Color get primaryBg => AppColors.primary.withValues(alpha: 0.1);
  static Color get orangeBg => AppColors.orange.withValues(alpha: 0.1);
  static Color get textSoft => const Color(0xFF6B6B6B);
  static Color get border => AppColors.textSoft.withValues(alpha: 0.15);
}

class DetailProdukScreen extends StatefulWidget {
  final Produk produk;
  final String phoneNumber;

  const DetailProdukScreen({
    super.key,
    required this.produk,
    required this.phoneNumber,
  });

  @override
  State<DetailProdukScreen> createState() => _DetailProdukScreenState();
}

class _DetailProdukScreenState extends State<DetailProdukScreen> {
  bool _isEditMode = false;
  bool _isSaving = false;

  Produk? _dataProduk;

  late TextEditingController _namaCtrl;
  late TextEditingController _deskripsiCtrl;
  late TextEditingController _hargaCtrl;
  late TextEditingController _hargaAsliCtrl;
  late TextEditingController _stokCtrl;

  @override
  void initState() {
    super.initState();
    _dataProduk = widget.produk;
    _namaCtrl = TextEditingController(text: _dataProduk!.nama);
    _deskripsiCtrl = TextEditingController(text: _dataProduk!.deskripsi);
    _hargaCtrl = TextEditingController(text: _dataProduk!.harga.toString());
    _hargaAsliCtrl =
        TextEditingController(text: _dataProduk!.hargaAsli.toString());
    _stokCtrl = TextEditingController(text: _dataProduk!.stok.toString());
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _deskripsiCtrl.dispose();
    _hargaCtrl.dispose();
    _hargaAsliCtrl.dispose();
    _stokCtrl.dispose();
    super.dispose();
  }

  String _rp(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp $buf';
  }

  Future<void> _simpanPerubahan() async {
    if (_namaCtrl.text.trim().isEmpty) {
      _tampilkanPesan('Nama produk tidak boleh kosong!', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    final hasil = await ApiService.updateProdukLengkap(
      phoneNumber: widget.phoneNumber,
      idProduk: _dataProduk!.id,
      nama: _namaCtrl.text.trim(),
      deskripsi: _deskripsiCtrl.text.trim(),
      hargaAsli: int.tryParse(_hargaAsliCtrl.text) ?? 0,
      harga: int.tryParse(_hargaCtrl.text) ?? 0,
      stok: int.tryParse(_stokCtrl.text) ?? 0,
    );

    if (!mounted) return;

    if (hasil['ok'] == true) {
      setState(() {
        _isSaving = false;
        _isEditMode = false;
        _dataProduk = Produk(
          id: _dataProduk!.id,
          nama: _namaCtrl.text,
          deskripsi: _deskripsiCtrl.text,
          harga: int.tryParse(_hargaCtrl.text) ?? _dataProduk!.harga,
          hargaAsli:
              int.tryParse(_hargaAsliCtrl.text) ?? _dataProduk!.hargaAsli,
          stok: int.tryParse(_stokCtrl.text) ?? _dataProduk!.stok,
          tipe: _dataProduk!.tipe,
          kategori: _dataProduk!.kategori,
          gambar: _dataProduk!.gambar,
          satuan: _dataProduk!.satuan,
          kuota: _dataProduk!.kuota,
          waktuMulai: _dataProduk!.waktuMulai,
          waktuSelesai: _dataProduk!.waktuSelesai,
          rating: _dataProduk!.rating,
          aktif: _dataProduk!.aktif,
        );
      });
      _tampilkanPesan('Produk berhasil diperbarui!');
    } else {
      setState(() => _isSaving = false);
      _tampilkanPesan('Gagal: ${hasil['message']}', isError: true);
    }
  }

  void _tampilkanPesan(String pesan, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan, style: AppColors.body(color: Colors.white)),
        backgroundColor: isError ? Colors.redAccent : AppColors.textDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _konfirmasiHapus() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle),
              child: const Icon(Icons.delete_outline,
                  color: Colors.redAccent, size: 32),
            ),
            const SizedBox(height: 16),
            Text('Hapus Produk Ini?', style: AppColors.heading(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              'Produk "${_dataProduk!.nama}" akan dihapus permanen.',
              textAlign: TextAlign.center,
              style: AppColors.body(fontSize: 14, color: _UI.textSoft),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: _UI.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Batal',
                        style: AppColors.heading(
                            fontSize: 14, color: AppColors.textDark)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              const Center(child: CircularProgressIndicator()));
                      await Future.delayed(const Duration(seconds: 1));
                      if (context.mounted) {
                        Navigator.pop(context);
                        Navigator.pop(context, true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Ya, Hapus',
                        style: AppColors.heading(
                            fontSize: 14, color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_dataProduk == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isWarning = _dataProduk!.cepatHabis;
    final progressColor = isWarning ? _UI.orangeText : _UI.primaryText;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: _isEditMode
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                onPressed: () => Navigator.pop(context, true),
              ),
        title: Text(
          _isEditMode ? 'Edit Produk' : 'Detail Produk',
          style: AppColors.heading(fontSize: 18),
        ),
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _konfirmasiHapus,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 250,
              color: _UI.primaryBg,
              child: _dataProduk!.gambar != null
                  ? Image.network(
                      _dataProduk!.gambar!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fotoKosong(),
                    )
                  : _fotoKosong(),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildBadge(
                        _dataProduk!.tipe == 'dimakan'
                            ? 'Konsumsi Manusia'
                            : 'Pakan / Kompos',
                        _dataProduk!.tipe == 'dimakan'
                            ? _UI.primaryText
                            : _UI.orangeText,
                        _dataProduk!.tipe == 'dimakan'
                            ? _UI.primaryBg
                            : _UI.orangeBg,
                      ),
                      const SizedBox(width: 8),
                      _buildBadge(
                          _dataProduk!.kategori, _UI.textSoft, AppColors.bg),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isEditMode)
                    _buildTextField(_namaCtrl, 'Nama Produk')
                  else
                    Text(_dataProduk!.nama,
                        style: AppColors.heading(fontSize: 24)),
                  const SizedBox(height: 8),
                  if (_isEditMode)
                    _buildTextField(_deskripsiCtrl, 'Deskripsi', maxLines: 3)
                  else
                    Text(_dataProduk!.deskripsi,
                        style: AppColors.body(
                            fontSize: 14, color: _UI.textSoft, height: 1.5)),
                  const SizedBox(height: 20),
                  if (_isEditMode) ...[
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextField(
                                _hargaAsliCtrl, 'Harga Asli',
                                isNumber: true)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _buildTextField(
                                _hargaCtrl, 'Harga Rescue',
                                isNumber: true, textColor: _UI.primaryText)),
                      ],
                    ),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(_rp(_dataProduk!.harga),
                            style: AppColors.heading(
                                fontSize: 28, color: _UI.primaryText)),
                        const SizedBox(width: 10),
                        if (_dataProduk!.adaDiskon) ...[
                          Text(_rp(_dataProduk!.hargaAsli),
                              style: AppColors.body(
                                      fontSize: 16, color: _UI.textSoft)
                                  .copyWith(
                                      decoration:
                                          TextDecoration.lineThrough)),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: _UI.orangeBg,
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                                'Hemat ${_dataProduk!.diskon}%',
                                style: AppColors.body(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _UI.orangeText)),
                          ),
                        ]
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _UI.border)),
                    child: Column(
                      children: [
                        if (_isEditMode)
                          _buildTextField(_stokCtrl, 'Jumlah Stok',
                              isNumber: true)
                        else
                          _buildInfoRow(
                              Icons.inventory_2_outlined,
                              'Kuota Tersedia',
                              '${_dataProduk!.stok} ${_dataProduk!.satuan.replaceAll('/', '')}'),
                        const Divider(height: 24),
                        _buildInfoRow(Icons.access_time, 'Jadwal Ambil',
                            _dataProduk!.jamAmbil),
                        const Divider(height: 24),
                        _buildInfoRow(Icons.star_outline, 'Rating Produk',
                            '${_dataProduk!.rating} / 5.0'),
                        const Divider(height: 24),
                        _buildInfoRow(
                            Icons.circle,
                            'Status',
                            _dataProduk!.aktif
                                ? 'Aktif (Tayang)'
                                : 'Nonaktif',
                            iconColor: _dataProduk!.aktif
                                ? _UI.primaryText
                                : Colors.grey),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Sisa Kuota', style: AppColors.heading(fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'Tersisa ${_dataProduk!.stok} dari ${_dataProduk!.kuota}',
                          style: AppColors.body(
                              fontSize: 13,
                              color: progressColor,
                              fontWeight: FontWeight.bold)),
                      Text('${_dataProduk!.persen}%',
                          style: AppColors.body(
                              fontSize: 13,
                              color: progressColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _dataProduk!.rasio.clamp(0.0, 1.0),
                      minHeight: 10,
                      backgroundColor: _UI.textSoft.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(progressColor),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: _UI.border))),
        child: Row(
          children: [
            if (_isEditMode) ...[
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      _namaCtrl.text = _dataProduk!.nama;
                      _deskripsiCtrl.text = _dataProduk!.deskripsi;
                      _hargaCtrl.text = _dataProduk!.harga.toString();
                      _hargaAsliCtrl.text = _dataProduk!.hargaAsli.toString();
                      _stokCtrl.text = _dataProduk!.stok.toString();
                      setState(() => _isEditMode = false);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _UI.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Batal',
                        style: AppColors.heading(
                            fontSize: 16, color: _UI.textSoft)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: _isEditMode ? 2 : 1,
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving
                      ? null
                      : (_isEditMode
                          ? _simpanPerubahan
                          : () => setState(() => _isEditMode = true)),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Icon(_isEditMode
                          ? Icons.save_outlined
                          : Icons.edit_document),
                  label: Text(
                    _isSaving
                        ? 'Menyimpan...'
                        : (_isEditMode
                            ? 'Simpan Perubahan'
                            : 'Edit Detail Produk'),
                    style: AppColors.heading(
                        fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _UI.primaryText,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {int maxLines = 1, bool isNumber = false, Color? textColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _UI.border),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters:
            isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
        style: AppColors.body(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor ?? AppColors.textDark),
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: AppColors.body(fontSize: 13, color: _UI.textSoft),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration:
          BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: AppColors.body(
              fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? iconColor}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor ?? _UI.textSoft),
        const SizedBox(width: 12),
        Expanded(
            child: Text(label,
                style: AppColors.body(fontSize: 14, color: _UI.textSoft))),
        Text(value,
            style: AppColors.body(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark)),
      ],
    );
  }

  Widget _fotoKosong() {
    return Center(
        child: Icon(Icons.fastfood,
            size: 80, color: _UI.primaryText.withValues(alpha: 0.5)));
  }
}