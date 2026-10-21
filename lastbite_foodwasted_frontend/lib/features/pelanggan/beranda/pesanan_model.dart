// ============================================================
// MODEL PESANAN (dari API Laravel: GET /api/pesanan)
// ============================================================

String lbRp(int v) {
  final s = v.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return 'Rp$b';
}

class Pesanan {
  final String kode;
  final String tanggal; // "Hari ini" / "18 Sep 2026"
  final String jam; // "19.12"
  final String penjual;
  final String inisial;
  final String alamat;
  final String produk;
  final String gambar;
  final String metode; // QRIS / GoPay / DANA ...
  final int qty;
  final int hargaSatuan; // harga di aplikasi Lastbite
  final int hargaAsliSatuan; // harga asli toko
  final int biaya; // biaya layanan (0 kalau produk gratis)
  final double co2; // kg CO2e dicegah
  final double makanan; // kg makanan diselamatkan
  final String status; // menunggu | selesai | dibatalkan
  final bool baru; // selesai tapi belum dinilai
  final int? rating;

  const Pesanan({
    required this.kode,
    required this.tanggal,
    required this.jam,
    required this.penjual,
    required this.inisial,
    required this.alamat,
    required this.produk,
    required this.gambar,
    required this.metode,
    required this.qty,
    required this.hargaSatuan,
    required this.hargaAsliSatuan,
    required this.biaya,
    required this.co2,
    required this.makanan,
    this.status = 'selesai',
    this.baru = false,
    this.rating,
  });

  factory Pesanan.fromJson(Map<String, dynamic> j) {
    // MySQL decimal sering dikirim Laravel sebagai string -> aman untuk keduanya
    num? n(dynamic v) => v is num ? v : num.tryParse('${v ?? ''}');
    int i(dynamic v) => n(v)?.toInt() ?? 0;
    double d(dynamic v) => n(v)?.toDouble() ?? 0;

    final penjual = '${j['penjual'] ?? ''}';
    var inisial = '${j['inisial'] ?? ''}';
    if (inisial.isEmpty && penjual.isNotEmpty) {
      inisial = penjual
          .split(' ')
          .where((w) => w.isNotEmpty)
          .take(2)
          .map((w) => w[0].toUpperCase())
          .join();
    }

    final satuan = i(j['harga_satuan']);
    return Pesanan(
      kode: '${j['kode'] ?? ''}',
      tanggal: '${j['tanggal'] ?? ''}',
      jam: '${j['jam'] ?? ''}',
      penjual: penjual,
      inisial: inisial,
      alamat: '${j['alamat'] ?? ''}',
      produk: '${j['produk'] ?? ''}',
      gambar: '${j['gambar'] ?? ''}',
      metode: '${j['metode'] ?? ''}',
      qty: i(j['qty']) == 0 ? 1 : i(j['qty']),
      hargaSatuan: satuan,
      hargaAsliSatuan: i(j['harga_asli_satuan']),
      biaya: j['biaya_layanan'] == null
          ? (satuan > 0 ? 1000 : 0)
          : i(j['biaya_layanan']),
      co2: d(j['co2']),
      makanan: d(j['makanan']),
      status: '${j['status'] ?? 'selesai'}',
      baru: j['baru'] == true,

      rating: j['rating'] == null
    ? null
    : (j['rating'] is num
        ? (j['rating'] as num).toInt()
        : int.tryParse('${j['rating']}')),
    );
  }

  /// Pesanan yang belum diambil -> tampil di tab "Aktif".
  bool get aktif => status == 'menunggu';

  int get hargaAsli => hargaAsliSatuan * qty;
  int get subtotal => hargaSatuan * qty;
  int get diskon => hargaAsli > subtotal ? hargaAsli - subtotal : 0;
  int get total => subtotal + biaya;

  String get waktuLengkap => '$tanggal, $jam WIB';
}