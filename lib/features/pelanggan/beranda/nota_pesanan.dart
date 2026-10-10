import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'beranda_widgets.dart';
import 'pesanan_model.dart';

/// Tampilkan nota sebagai bottom sheet.
Future<void> showNotaPesanan(
  BuildContext context,
  Pesanan p, {
  VoidCallback? onPesanLagi,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _NotaSheet(p: p, onPesanLagi: onPesanLagi),
  );
}

class _NotaSheet extends StatefulWidget {
  final Pesanan p;
  final VoidCallback? onPesanLagi;
  const _NotaSheet({required this.p, this.onPesanLagi});

  @override
  State<_NotaSheet> createState() => _NotaSheetState();
}

class _NotaSheetState extends State<_NotaSheet> {
  bool _copied = false;

  Pesanan get p => widget.p;

  Future<void> _salin() async {
    await Clipboard.setData(ClipboardData(text: p.kode));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future.delayed(const Duration(milliseconds: 1600));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.93,
      minChildSize: 0.6,
      maxChildSize: 0.97,
      expand: false,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: LbColors.offWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // handle + judul
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D5CB),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Nota Pesanan',
                        style: LbText.heading(19, weight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: LbColors.forest,
                      ),
                    ),
                  ],
                ),
              ),

              // isi
              Expanded(
                child: ListView(
                  controller: controller,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  children: [
                    _ticket(),
                    const SizedBox(height: 14),
                    _impactCard(),
                  ],
                ),
              ),

              // aksi bawah
              _footer(),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // TIKET NOTA
  // ============================================================
  Widget _ticket() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: LbColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _ticketHeader(),
          _perforation(),
          _ticketBody(),
          _perforation(),
          _qrSection(),
        ],
      ),
    );
  }

  // ---------- header hijau ----------
  Widget _ticketHeader() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(27)),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [LbColors.sage, LbColors.sageDeep],
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 32,
                    color: LbColors.sageDeep,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pembayaran Berhasil',
                  style: LbText.heading(
                    15,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lbRp(p.total),
                  style: LbText.heading(
                    32,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  p.waktuLengkap,
                  style: LbText.body(
                    13,
                    weight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -26,
            top: -30,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: LbColors.peach.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- garis sobekan tiket ----------
  Widget _perforation() {
    Widget notch() => Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: LbColors.offWhite,
            shape: BoxShape.circle,
          ),
        );

    return SizedBox(
      height: 26,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _Dash(),
          ),
          Positioned(left: -13, child: notch()),
          Positioned(right: -13, child: notch()),
        ],
      ),
    );
  }

  // ---------- badan nota ----------
  Widget _ticketBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Penjual
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: LbColors.peach,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  p.inisial,
                  style: LbText.heading(
                    13,
                    weight: FontWeight.w700,
                    color: LbColors.forest,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.penjual,
                      style: LbText.heading(
                        15,
                        weight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: LbColors.sageDeep,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            p.alamat,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: LbText.body(12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // No pesanan + metode
          Row(
            children: [
              Expanded(
                child: _infoTile(
                  label: 'No. Pesanan',
                  value: p.kode,
                  trailing: GestureDetector(
                    onTap: _salin,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _copied
                            ? Icons.check_circle_rounded
                            : Icons.copy_rounded,
                        key: ValueKey(_copied),
                        size: 17,
                        color: LbColors.sageDeep,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _infoTile(
                  label: 'Pembayaran',
                  value: '${p.metode} • Lunas',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Text(
            'Rincian Pesanan',
            style: LbText.heading(14, weight: FontWeight.w600),
          ),
          const SizedBox(height: 10),

          // Item
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: LbColors.sageLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${p.qty}x',
                  style: LbText.body(
                    12,
                    weight: FontWeight.w900,
                    color: LbColors.forest,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  p.produk,
                  style: LbText.body(
                    13.5,
                    weight: FontWeight.w700,
                    color: LbColors.forest,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                lbRp(p.subtotal),
                style: LbText.body(
                  13.5,
                  weight: FontWeight.w800,
                  color: LbColors.forest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _Dash(),
          const SizedBox(height: 10),

          _line('Harga Asli Toko', lbRp(p.hargaAsli),
              strike: true, valueColor: LbColors.textGrey),
          if (p.diskon > 0)
            _line(
              'Diskon Food Rescue',
              '-${lbRp(p.diskon)}',
              labelColor: LbColors.peachDeep,
              valueColor: LbColors.peachDeep,
            ),
          _line('Harga Aplikasi Lastbite', lbRp(p.subtotal)),
          _line('Biaya Layanan & Admin', lbRp(Pesanan.biayaLayanan)),
          const SizedBox(height: 8),
          const _Dash(),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Text(
                  'Total Dibayar',
                  style: LbText.heading(16, weight: FontWeight.w700),
                ),
              ),
              Text(
                lbRp(p.total),
                style: LbText.heading(
                  20,
                  weight: FontWeight.w700,
                  color: LbColors.sageDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Hemat
          if (p.diskon > 0)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: LbColors.peachLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.savings_outlined,
                    size: 19,
                    color: LbColors.peachDeep,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Kamu hemat ${lbRp(p.diskon)} dari pesanan ini!',
                      style: LbText.body(
                        12.5,
                        weight: FontWeight.w800,
                        color: LbColors.peachDeep,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _infoTile({
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8EA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: LbText.body(11, weight: FontWeight.w700)),
          const SizedBox(height: 3),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LbText.heading(
                    12,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 4),
                trailing,
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _line(
    String label,
    String value, {
    bool strike = false,
    Color? labelColor,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: LbText.body(
                13.5,
                weight: FontWeight.w600,
                color: labelColor ?? LbColors.forest,
              ),
            ),
          ),
          Text(
            value,
            style: LbText.body(
              13.5,
              weight: FontWeight.w800,
              color: valueColor ?? LbColors.forest,
            ).copyWith(
              decoration: strike ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- QR ----------
  Widget _qrSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
      child: Column(
        children: [
          Text(
            'Kode Verifikasi Nota',
            style: LbText.heading(14, weight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Tunjukkan ke penjual bila ada kendala pesanan.',
            textAlign: TextAlign.center,
            style: LbText.body(12),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LbColors.sageLight,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: SizedBox(
                width: 132,
                height: 132,
                // GANTI dengan QrImageView(data: p.kode) dari package
                // qr_flutter kalau mau QR yang benar-benar bisa di-scan.
                child: CustomPaint(painter: _QrPainter(p.kode)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            p.kode,
            style: LbText.heading(
              12.5,
              weight: FontWeight.w600,
              color: LbColors.textGrey,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DAMPAK
  // ============================================================
  Widget _impactCard() {
    Widget tile(IconData icon, String value, String label) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: LbColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, size: 26, color: LbColors.sageDeep),
              const SizedBox(height: 6),
              Text(
                value,
                style: LbText.heading(17, weight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: LbText.body(11.5, weight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5E2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LbColors.sage.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: LbColors.sage,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Dampak Kebaikanmu',
                  style: LbText.heading(15, weight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              tile(Icons.cloud_outlined, '${p.co2} kg', 'CO₂e dicegah'),
              const SizedBox(width: 10),
              tile(
                Icons.restaurant_rounded,
                '${p.makanan} kg',
                'Makanan diselamatkan',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Terima kasih sudah ikut mengurangi food waste di Batam!',
            style: LbText.body(12.5, color: LbColors.forest, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================
  Widget _footer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: LbColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    widget.onPesanLagi?.call();
                  },
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: LbColors.sage.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.replay_rounded,
                          size: 19,
                          color: LbColors.forest,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'Pesan Lagi',
                          style: LbText.heading(14, weight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [LbColors.sage, LbColors.sageDeep],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: LbColors.sage.withValues(alpha: 0.45),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      'Selesai',
                      style: LbText.heading(
                        14,
                        weight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
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

// ============================================================
// GARIS PUTUS-PUTUS
// ============================================================
class _Dash extends StatelessWidget {
  const _Dash();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final n = (c.maxWidth / 8).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            n,
            (_) => Container(
              width: 4,
              height: 1.5,
              color: const Color(0xFFD5D1C7),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// QR (tampilan saja, dibuat dari kode pesanan)
// ============================================================
class _QrPainter extends CustomPainter {
  final String seed;
  const _QrPainter(this.seed);

  static const int _n = 25;

  bool _inFinder(int r, int c) {
    return (r < 8 && c < 8) ||
        (r < 8 && c >= _n - 8) ||
        (r >= _n - 8 && c < 8);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / _n;
    final dark = Paint()..color = LbColors.forest;
    final light = Paint()..color = Colors.white;

    var s = seed.codeUnits.fold<int>(7, (a, b) => (a * 31 + b) & 0x7fffffff);

    for (var r = 0; r < _n; r++) {
      for (var c = 0; c < _n; c++) {
        s = (s * 1103515245 + 12345) & 0x7fffffff;
        if (_inFinder(r, c)) continue;
        if (((s >> 16) & 3) != 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(c * cell, r * cell, cell, cell).deflate(0.15),
              Radius.circular(cell * 0.2),
            ),
            dark,
          );
        }
      }
    }

    void finder(int r0, int c0) {
      final x = c0 * cell;
      final y = r0 * cell;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, cell * 7, cell * 7),
          Radius.circular(cell * 1.2),
        ),
        dark,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + cell, y + cell, cell * 5, cell * 5),
          Radius.circular(cell * 0.8),
        ),
        light,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + cell * 2, y + cell * 2, cell * 3, cell * 3),
          Radius.circular(cell * 0.6),
        ),
        dark,
      );
    }

    finder(0, 0);
    finder(0, _n - 7);
    finder(_n - 7, 0);
  }

  @override
  bool shouldRepaint(covariant _QrPainter old) => old.seed != seed;
}