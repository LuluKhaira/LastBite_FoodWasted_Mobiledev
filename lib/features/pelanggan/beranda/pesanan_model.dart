// ============================================================
// MODEL PESANAN + DATA CONTOH
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
  final double co2; // kg CO2e dicegah
  final double makanan; // kg makanan diselamatkan
  final bool baru;

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
    required this.co2,
    required this.makanan,
    this.baru = false,
  });

  static const int biayaLayanan = 1000;

  int get hargaAsli => hargaAsliSatuan * qty;
  int get subtotal => hargaSatuan * qty;
  int get diskon => hargaAsli > subtotal ? hargaAsli - subtotal : 0;
  int get total => subtotal + biayaLayanan;

  String get waktuLengkap => '$tanggal, $jam WIB';
}

const List<Pesanan> daftarPesanan = [
  Pesanan(
    kode: 'LB-260930-0412',
    tanggal: 'Hari ini',
    jam: '19.12',
    penjual: 'Holland Bakery – Batam Center',
    inisial: 'HB',
    alamat: 'Jl. Engku Putri No. 8, Batam Center',
    produk: 'Paket Kejutan Roti Manis & Pastry Segar',
    gambar:
        'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400&q=80',
    metode: 'QRIS',
    qty: 1,
    hargaSatuan: 15000,
    hargaAsliSatuan: 30000,
    co2: 2.1,
    makanan: 0.8,
    baru: true,
  ),
  Pesanan(
    kode: 'LB-260918-0231',
    tanggal: '18 Sep 2026',
    jam: '18.45',
    penjual: 'Morning Bakery – Windsor',
    inisial: 'MB',
    alamat: 'Windsor Plaza, Batam Center',
    produk: 'Surprise Bakery Box',
    gambar:
        'https://images.unsplash.com/photo-1517433670267-08bbd4be890f?w=400&q=80',
    metode: 'GoPay',
    qty: 1,
    hargaSatuan: 17000,
    hargaAsliSatuan: 40000,
    co2: 1.7,
    makanan: 0.6,
  ),
  Pesanan(
    kode: 'LB-260914-0198',
    tanggal: '14 Sep 2026',
    jam: '21.00',
    penjual: 'Grand Duck Restaurant',
    inisial: 'GD',
    alamat: 'Jl. Raja Isa, Batam Center',
    produk: 'Paket Lauk Malam Lezat',
    gambar:
        'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&q=80',
    metode: 'QRIS',
    qty: 1,
    hargaSatuan: 24000,
    hargaAsliSatuan: 55000,
    co2: 3.4,
    makanan: 1.2,
  ),
  Pesanan(
    kode: 'LB-260909-0074',
    tanggal: '09 Sep 2026',
    jam: '17.30',
    penjual: 'Fresh Mart Mega Mall',
    inisial: 'FM',
    alamat: 'Mega Mall Batam Center, Lt. 1',
    produk: 'Paket Buah Potong Segar',
    gambar:
        'https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea?w=400&q=80',
    metode: 'DANA',
    qty: 2,
    hargaSatuan: 7000,
    hargaAsliSatuan: 16000,
    co2: 1.9,
    makanan: 1.0,
  ),
];