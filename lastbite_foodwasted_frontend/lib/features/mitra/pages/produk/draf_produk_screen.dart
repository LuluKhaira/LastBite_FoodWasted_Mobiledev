import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';
import 'package:lastbite_foodwasted_mobiledev/core/widgets/shimmer_loading/app_shimmer_loading.dart';
import 'detail_produk_screen.dart';
import 'models/produk_model.dart';
import 'tambah_produk_screen.dart';
import 'widgets/warna_lokal.dart';

class DrafProdukScreen extends StatefulWidget {
  final String phoneNumber;
  final String? namaToko;

  const DrafProdukScreen({
    super.key,
    required this.phoneNumber,
    this.namaToko,
  });

  @override
  State<DrafProdukScreen> createState() => _DrafProdukScreenState();
}

class _DrafProdukScreenState extends State<DrafProdukScreen> {
  bool _isLoading = true;
  List<Produk> _drafList = [];
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _muatDraf();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _muatDraf() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getMitraProduk(widget.phoneNumber);
    if (!mounted) return;

    if (data == null) {
      setState(() => _isLoading = false);
      _snack('Gagal memuat daftar draf produk.', error: true);
      return;
    }

    final all = data.map(Produk.fromJson).toList();
    final drafs = all.where((p) => p.draf || p.statusUI == StatusProduk.draf).toList();

    setState(() {
      _isLoading = false;
      _drafList = drafs;
    });
  }

  void _snack(String pesan, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan, style: AppColors.body(color: Colors.white)),
        backgroundColor: error ? Colors.redAccent : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  List<Produk> get _tampilDraf {
    if (_query.trim().isEmpty) return _drafList;
    final q = _query.trim().toLowerCase();
    return _drafList.where((p) => p.nama.toLowerCase().contains(q) || p.kategori.toLowerCase().contains(q)).toList();
  }

  String _rp(int v) {
    if (v == 0) return 'Gratis';
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp $buf';
  }

  Future<void> _tayangkan(Produk p) async {
    final res = await ApiService.setProdukAktif(widget.phoneNumber, p.id, true);
    if (!mounted) return;

    if (res['ok'] == true) {
      _snack(res['message'] ?? 'Produk berhasil ditayangkan!');
      _muatDraf();
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
              const SizedBox(width: 8),
              Text('Belum Bisa Ditayangkan', style: AppColors.heading(fontSize: 15)),
            ],
          ),
          content: Text(
            res['message'] ?? 'Produk draf belum memenuhi syarat untuk ditayangkan.',
            style: AppColors.body(fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Tutup', style: AppColors.body(color: WarnaLokal.textSoft)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _bukaDetailEdit(p);
              },
              child: Text(
                'Lengkapi Sekarang',
                style: AppColors.body(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _bukaDetailEdit(Produk p) async {
    final refreshed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DetailProdukScreen(produk: p, phoneNumber: widget.phoneNumber),
      ),
    );
    if (refreshed == true && mounted) {
      _muatDraf();
    }
  }

  Future<void> _bukaTambahProduk() async {
    final hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahProdukScreen(phoneNumber: widget.phoneNumber),
      ),
    );
    if (hasil == true && mounted) {
      _muatDraf();
    }
  }

  @override
  Widget build(BuildContext context) {
    final daftar = _tampilDraf;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Draf Produk',
          style: AppColors.heading(fontSize: 17, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
            tooltip: 'Tambah Produk Baru',
            onPressed: _bukaTambahProduk,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Banner Info Ringkas
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Produk Belum Diterbitkan',
                        style: AppColors.body(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_drafList.length} Draf',
                          style: AppColors.body(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Kolom Pencarian
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (val) => setState(() => _query = val),
                      style: AppColors.body(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Cari produk draf...',
                        hintStyle: AppColors.body(fontSize: 12, color: WarnaLokal.textSoft),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Colors.grey),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Konten List Draf
            Expanded(
              child: RefreshIndicator(
                onRefresh: _muatDraf,
                color: AppColors.primary,
                child: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: ListShimmerLoading(count: 3),
                      )
                    : daftar.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                            itemCount: daftar.length,
                            itemBuilder: (context, i) {
                              return _buildCardDraf(daftar[i]);
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDraf(Produk p) {
    final bool tanpaFoto = p.gambar == null || p.gambar!.isEmpty;
    final bool kadaluarsaLewat = p.kadaluarsa != null && p.kadaluarsa!.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WarnaLokal.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar / Placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: tanpaFoto
                      ? Container(
                          color: AppColors.hijauMuda,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 24, color: AppColors.primary),
                              const SizedBox(height: 2),
                              Text(
                                'Foto',
                                style: AppColors.body(fontSize: 10, color: AppColors.textDark, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        )
                      : Image.network(
                          p.gambar!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.hijauMuda,
                            child: const Icon(Icons.fastfood_rounded, color: Colors.grey),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Detail Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: AppColors.hijauMuda,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#${p.id} • ${p.kategori}',
                            style: AppColors.body(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Draf',
                            style: AppColors.body(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppColors.heading(fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (p.harga == 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF81C784)),
                            ),
                            child: Text(
                              'Gratis',
                              style: AppColors.heading(fontSize: 13, color: const Color(0xFF2E7D32)),
                            ),
                          )
                        else
                          Text(
                            _rp(p.harga),
                            style: AppColors.heading(fontSize: 14, color: AppColors.primary),
                          ),
                        const SizedBox(width: 6),
                        if (p.adaDiskon)
                          Text(
                            _rp(p.hargaAsli),
                            style: AppColors.body(
                              fontSize: 11,
                              color: WarnaLokal.textSoft,
                            ).copyWith(decoration: TextDecoration.lineThrough),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Baris Jadwal & Kuota
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 14, color: WarnaLokal.textSoft),
              const SizedBox(width: 4),
              Text(
                'Ambil: ${p.jamAmbil}',
                style: AppColors.body(fontSize: 11, color: WarnaLokal.textSoft),
              ),
              const Spacer(),
              Icon(Icons.inventory_2_outlined, size: 14, color: WarnaLokal.textSoft),
              const SizedBox(width: 4),
              Text(
                'Stok: ${p.stok} paket',
                style: AppColors.body(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),

          // Peringatan Kelengkapan Sebelum Tayang
          if (tanpaFoto || kadaluarsaLewat) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: kadaluarsaLewat
                    ? Colors.redAccent.withValues(alpha: 0.08)
                    : Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: kadaluarsaLewat ? Colors.redAccent : Colors.orange.shade800,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      kadaluarsaLewat
                          ? 'Waktu kedaluwarsa sudah lewat. Edit draf sebelum ditayangkan.'
                          : 'Foto produk belum diunggah.',
                      style: AppColors.body(
                        fontSize: 10.5,
                        color: kadaluarsaLewat ? Colors.redAccent : Colors.orange.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Tombol Aksi
          Row(
            children: [
              Expanded(
                flex: 4,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    side: BorderSide(color: WarnaLokal.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.edit_note_rounded, size: 17, color: AppColors.textDark),
                  label: Text(
                    'Edit Draf',
                    style: AppColors.body(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                  onPressed: () => _bukaDetailEdit(p),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 5,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.rocket_launch_rounded, size: 16, color: Colors.white),
                  label: Text(
                    'Tayangkan',
                    style: AppColors.body(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  onPressed: () => _tayangkan(p),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.hijauMuda,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.drafts_outlined, size: 52, color: AppColors.primary),
            ),
            const SizedBox(height: 18),
            Text(
              _query.isEmpty ? 'Tidak Ada Draf Produk' : 'Draf Tidak Ditemukan',
              style: AppColors.heading(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              _query.isEmpty
                  ? 'Semua produk toko Anda sudah tayang atau habis. Produk yang disimpan untuk diselesaikan nanti akan tampil di halaman ini.'
                  : 'Tidak ada produk draf yang sesuai dengan kata kunci "$_query".',
              textAlign: TextAlign.center,
              style: AppColors.body(fontSize: 12, color: WarnaLokal.textSoft, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              label: Text(
                'Buat Produk Baru',
                style: AppColors.body(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
              ),
              onPressed: _bukaTambahProduk,
            ),
          ],
        ),
      ),
    );
  }
}

