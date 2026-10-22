import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/dashboard/mitra_dashboard_screen.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/produk/tambah_produk_screen.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/dashboard/widgets/mitra_bottom_nav.dart';
import 'package:lastbite_foodwasted_mobiledev/core/widgets/shimmer_loading/app_shimmer_loading.dart';

enum _Status { tayang, terjadwal, habis }

class _Produk {
  _Produk({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.hargaAsli,
    required this.stok,
    required this.kuota,
    required this.hari,
    required this.jam,
    required this.status,
    this.aktif = true,
    this.imageUrl,
  });

  final int id;
  String nama;
  String kategori;
  int harga;
  int hargaAsli;
  int stok;
  int kuota;
  String hari;
  String jam;
  _Status status;
  bool aktif;
  String? imageUrl;

  factory _Produk.fromJson(Map<String, dynamic> j) {
    int i(dynamic v) => int.tryParse('$v') ?? 0;
    final status = switch ('${j['status']}') {
      'tayang' => _Status.tayang,
      'terjadwal' => _Status.terjadwal,
      _ => _Status.habis,
    };
    return _Produk(
      id: i(j['id']),
      nama: '${j['nama'] ?? '-'}',
      kategori: '${j['kategori'] ?? '-'}',
      harga: i(j['harga']),
      hargaAsli: i(j['harga_asli']),
      stok: i(j['stok']),
      kuota: i(j['kuota']),
      hari: '${j['hari'] ?? 'Hari ini'}',
      jam: '${j['jam'] ?? '-'}',
      status: status,
      aktif: j['aktif'] == true || j['aktif'] == 1,
      imageUrl: j['image_url']?.toString(),
    );
  }

  bool get adaDiskon => hargaAsli > harga && hargaAsli > 0;
  int get diskon => adaDiskon ? ((1 - harga / hargaAsli) * 100).round() : 0;
  double get rasio => kuota == 0 ? 0 : stok / kuota;
  int get persen => (rasio * 100).toInt();
  bool get cepatHabis => status == _Status.tayang && rasio <= 0.3;
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

class MitraProdukScreen extends StatefulWidget {
  final String phoneNumber;
  final String? namaToko;

  const MitraProdukScreen({
    super.key,
    required this.phoneNumber,
    this.namaToko,
  });

  @override
  State<MitraProdukScreen> createState() => _MitraProdukScreenState();
}

class _MitraProdukScreenState extends State<MitraProdukScreen> {
  _Status _tab = _Status.tayang;
  String _kategori = 'Semua Kategori';
  String _query = '';
  final _searchFocus = FocusNode();

  bool _isLoading = true;
  List<_Produk> _produk = [];
  String _namaToko = 'Mitra Dashboard';

  List<String> get _kategoriList => [
    'Semua Kategori',
    ...{for (final p in _produk) p.kategori},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.namaToko != null) {
      _namaToko = widget.namaToko!;
    } else {
      _muatNamaToko();
    }
    _muatProduk();
  }

  Future<void> _muatNamaToko() async {
    final data = await ApiService.getMitraDashboard(widget.phoneNumber);
    if (!mounted || data == null) return;
    final toko = Map<String, dynamic>.from(data['toko'] ?? {});
    setState(() => _namaToko = (toko['nama'] ?? 'Mitra Dashboard').toString());
  }

  Future<void> _muatProduk() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getMitraProduk(widget.phoneNumber);
    if (!mounted) return;

    if (data == null) {
      setState(() => _isLoading = false);
      _info('Gagal memuat produk. Tarik layar ke bawah untuk mencoba lagi.');
      return;
    }
    setState(() {
      _isLoading = false;
      _produk = data.map(_Produk.fromJson).toList();
      if (!_kategoriList.contains(_kategori)) _kategori = 'Semua Kategori';
    });
  }

  Future<void> _ubahAktif(_Produk p, bool v) async {
    setState(() => p.aktif = v);
    final ok = await ApiService.setProdukAktif(widget.phoneNumber, p.id, v);
    if (!mounted) return;
    if (!ok) {
      setState(() => p.aktif = !v);
      _info('Gagal mengubah status produk. Coba lagi.');
      return;
    }
    await _muatProduk();
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  int _hitung(_Status s) => _produk.where((p) => p.status == s).length;

  List<_Produk> get _tampil {
    return _produk.where((p) {
      final cocokTab = p.status == _tab;
      final cocokKategori =
          _kategori == 'Semua Kategori' || p.kategori == _kategori;
      final cocokCari = p.nama.toLowerCase().contains(
        _query.trim().toLowerCase(),
      );
      return cocokTab && cocokKategori && cocokCari;
    }).toList();
  }

  int get _totalKuota => _produk
      .where((p) => p.status == _Status.tayang)
      .fold(0, (a, p) => a + p.stok);

  void _info(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _ubahStok(_Produk p) async {
    int stok = p.stok;
    final hasil = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Ubah Stok',
            style: AppColors.heading(fontSize: 18, color: AppColors.textDark),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                p.nama,
                textAlign: TextAlign.center,
                style: AppColors.body(fontSize: 13, color: AppColors.textSoft),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    onPressed: stok > 0 ? () => setD(() => stok--) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      '$stok',
                      textAlign: TextAlign.center,
                      style: AppColors.heading(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: stok < p.kuota ? () => setD(() => stok++) : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'dari ${p.kuota} paket',
                style: AppColors.body(fontSize: 12, color: AppColors.textSoft),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Batal',
                style: AppColors.body(color: AppColors.textSoft),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, stok),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textDark,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    if (hasil != null && hasil != p.stok) {
      final ok = await ApiService.updateStokProduk(
        widget.phoneNumber,
        p.id,
        hasil,
      );
      if (!mounted) return;
      if (!ok) {
        _info('Gagal menyimpan stok. Coba lagi.');
        return;
      }
      await _muatProduk();
    }
  }

  Future<void> _bukaTambahProduk() async {
    final berhasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahProdukScreen(phoneNumber: widget.phoneNumber),
      ),
    );
    if (berhasil == true && mounted) {
      await _muatProduk();
      _info('Produk berhasil ditambahkan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final daftar = _tampil;

    return Scaffold(
      backgroundColor: AppColors.bg,
      floatingActionButton: FloatingActionButton(
        onPressed: _bukaTambahProduk,
        backgroundColor: AppColors.primary,
        elevation: 3,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: MitraBottomNav(
        currentIndex: 1,
        onDashboard: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                MitraDashboardScreen(phoneNumber: widget.phoneNumber),
          ),
        ),
        onProduk: () {},
        onScan: () => _info('Pindai QR pengambilan pesanan'),
        onPesanan: () => _info('Halaman Pesanan belum dibuat'),
        onProfil: () => _info('Halaman Profil belum dibuat'),
        pesananBadge: 3,
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _muatProduk,
          color: AppColors.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _buildHeader(),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Produk Saya',
                      style: AppColors.heading(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _searchFocus.requestFocus(),
                    icon: const Icon(Icons.search, color: AppColors.textDark),
                  ),
                  IconButton(
                    onPressed: () => _info('Filter belum tersedia'),
                    icon: const Icon(
                      Icons.filter_list,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.storefront_rounded,
                          color: AppColors.textDark,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Status Etalase Toko',
                            style: AppColors.heading(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        _Pill(
                          label: 'Live di Aplikasi',
                          bg: AppColors.primary.withValues(alpha: 0.45),
                          fg: AppColors.textDark,
                          dot: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatBox(
                            judul: 'Produk Aktif',
                            angka: '${_hitung(_Status.tayang)}',
                            satuan: 'Paket Tayang',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatBox(
                            judul: 'Total Kuota Hari Ini',
                            angka: '$_totalKuota',
                            satuan: 'Porsi Tersisa',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    _tabItem('Tayang', _Status.tayang),
                    _tabItem('Terjadwal', _Status.terjadwal),
                    _tabItem('Habis', _Status.habis),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                focusNode: _searchFocus,
                onChanged: (v) => setState(() => _query = v),
                style: AppColors.body(
                  fontSize: 14.5,
                  color: AppColors.textDark,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSoft,
                  ),
                  hintText: 'Cari nama paket surplus...',
                  hintStyle: AppColors.body(
                    fontSize: 14.5,
                    color: AppColors.textSoft.withValues(alpha: 0.7),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _kategoriList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final k = _kategoriList[i];
                    final aktif = k == _kategori;
                    return GestureDetector(
                      onTap: () => setState(() => _kategori = k),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: aktif ? AppColors.textDark : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          k,
                          style: AppColors.body(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: aktif ? Colors.white : AppColors.textDark,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // LOGIKA SHIMMER LOADING DI SINI
              if (_isLoading)
                const ListShimmerLoading(count: 3)
              else if (daftar.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: AppColors.textSoft.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Belum ada produk di sini',
                        style: AppColors.body(color: AppColors.textSoft),
                      ),
                    ],
                  ),
                )
              else
                for (final p in daftar)
                  _ProdukCard(
                    produk: p,
                    onToggle: (v) => _ubahAktif(p, v),
                    onUbahStok: () => _ubahStok(p),
                    onEdit: () => _info('Edit rincian: ${p.nama}'),
                  ),

              const SizedBox(height: 4),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.recycling,
                        color: AppColors.textDark,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Misi Bebas Mubazir',
                            style: AppColors.heading(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Punya surplus yang tidak terjual hari ini? Kamu bisa relist sebagai Pakan Ternak atau Bahan Kompos agar tidak terbuang percuma.',
                            style: AppColors.body(
                              fontSize: 12.5,
                              color: AppColors.textSoft,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => setState(() => _tab = _Status.habis),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Lihat Produk Nonaktif',
                                  style: AppColors.body(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                  color: AppColors.textDark,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'LastBite',
                      style: AppColors.heading(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Mitra Toko',
                        style: AppColors.body(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  _namaToko,
                  style: AppColors.body(
                    fontSize: 12,
                    color: AppColors.textSoft,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none,
                  color: AppColors.textDark,
                  size: 26,
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabItem(String label, _Status s) {
    final aktif = _tab == s;
    final n = _hitung(s);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = s),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: aktif ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppColors.body(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: aktif ? AppColors.textDark : AppColors.textSoft,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                constraints: const BoxConstraints(minWidth: 20),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: aktif
                      ? AppColors.textDark
                      : AppColors.textSoft.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$n',
                  textAlign: TextAlign.center,
                  style: AppColors.body(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: aktif ? Colors.white : AppColors.textSoft,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final bool dot;

  const _Pill({
    required this.label,
    required this.bg,
    required this.fg,
    this.dot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: AppColors.body(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String judul;
  final String angka;
  final String satuan;

  const _StatBox({
    required this.judul,
    required this.angka,
    required this.satuan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            style: AppColors.body(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                angka,
                style: AppColors.heading(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  satuan,
                  overflow: TextOverflow.ellipsis,
                  style: AppColors.body(
                    fontSize: 13,
                    color: AppColors.textSoft,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProdukCard extends StatelessWidget {
  final _Produk produk;
  final ValueChanged<bool> onToggle;
  final VoidCallback onUbahStok;
  final VoidCallback onEdit;

  const _ProdukCard({
    required this.produk,
    required this.onToggle,
    required this.onUbahStok,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final p = produk;
    final habis = p.status == _Status.habis;
    final warnaBar = p.cepatHabis ? AppColors.orange : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 96,
                      height: 96,
                      child: p.imageUrl != null
                          ? Image.network(
                              p.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _fotoKosong(),
                            )
                          : _fotoKosong(),
                    ),
                  ),
                  if (p.adaDiskon)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.orange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${p.diskon}%',
                          style: AppColors.body(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (p.status == _Status.tayang)
                          _Pill(
                            label: 'Tayang',
                            bg: AppColors.primary.withValues(alpha: 0.4),
                            fg: AppColors.textDark,
                            dot: true,
                          ),
                        if (p.status == _Status.terjadwal)
                          _Pill(
                            label: 'Terjadwal',
                            bg: AppColors.orange.withValues(alpha: 0.3),
                            fg: AppColors.textDark,
                          ),
                        if (habis)
                          _Pill(
                            label: 'Habis',
                            bg: AppColors.textSoft.withValues(alpha: 0.18),
                            fg: AppColors.textSoft,
                          ),
                        if (p.cepatHabis)
                          _Pill(
                            label: 'Cepat Habis',
                            bg: AppColors.orange.withValues(alpha: 0.3),
                            fg: AppColors.textDark,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppColors.heading(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Kategori: ${p.kategori}',
                      style: AppColors.body(
                        fontSize: 12,
                        color: AppColors.textSoft,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _rp(p.harga),
                          style: AppColors.heading(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (p.adaDiskon)
                          Text(
                            _rp(p.hargaAsli),
                            style: AppColors.body(
                              fontSize: 12,
                              color: AppColors.textSoft,
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

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      p.cepatHabis
                          ? Icons.local_fire_department_outlined
                          : Icons.event_available_outlined,
                      size: 18,
                      color: p.cepatHabis
                          ? AppColors.orange
                          : AppColors.textDark,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Sisa ${p.stok} dari ${p.kuota} paket',
                        style: AppColors.body(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: p.cepatHabis
                              ? AppColors.orange
                              : AppColors.textDark,
                        ),
                      ),
                    ),
                    Text(
                      '${p.persen}% tersisa',
                      style: AppColors.body(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: p.rasio.clamp(0.0, 1.0),
                    minHeight: 7,
                    backgroundColor: AppColors.textSoft.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation(warnaBar),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 20,
                color: AppColors.textDark,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Ambil ${p.hari}: ',
                        style: AppColors.body(
                          fontSize: 13,
                          color: AppColors.textSoft,
                        ),
                      ),
                      TextSpan(
                        text: p.jam,
                        style: AppColors.body(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Switch(
                value: p.aktif,
                onChanged: p.stok == 0 ? null : onToggle,
                activeColor: Colors.white,
                activeTrackColor: AppColors.textDark,
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _AksiButton(
                  icon: Icons.tune,
                  label: 'Ubah Stok',
                  onTap: onUbahStok,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AksiButton(
                  icon: Icons.edit_note,
                  label: 'Edit Rincian',
                  onTap: onEdit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fotoKosong() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.2),
      child: const Icon(
        Icons.fastfood_outlined,
        color: AppColors.textDark,
        size: 34,
      ),
    );
  }
}

class _AksiButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AksiButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.textDark),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppColors.body(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}