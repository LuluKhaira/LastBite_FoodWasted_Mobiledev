import 'dart:async';
import 'package:flutter/material.dart';

// ============================================================
// KUMPULAN ANIMASI LASTBITE (tanpa package tambahan)
// ============================================================

/// Muncul pelan: fade + geser. Pakai [urutan] untuk efek berurutan.
class LbMuncul extends StatefulWidget {
  final Widget child;
  final int urutan;
  final Duration jeda;
  final Duration durasi;
  final Offset dari; // posisi awal (selisih piksel)
  final bool aktif; // false = langsung tampil tanpa animasi

  const LbMuncul({
    super.key,
    required this.child,
    this.urutan = 0,
    this.jeda = const Duration(milliseconds: 80),
    this.durasi = const Duration(milliseconds: 560),
    this.dari = const Offset(0, 26),
    this.aktif = true,
  });

  @override
  State<LbMuncul> createState() => _LbMunculState();
}

class _LbMunculState extends State<LbMuncul>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.durasi);
    _a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    if (!widget.aktif) {
      _c.value = 1;
    } else if (widget.urutan == 0) {
      _c.forward();
    } else {
      _t = Timer(widget.jeda * widget.urutan, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _t?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _a,
      child: AnimatedBuilder(
        animation: _a,
        child: widget.child,
        builder: (context, child) => Transform.translate(
          offset: Offset(
            widget.dari.dx * (1 - _a.value),
            widget.dari.dy * (1 - _a.value),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Mengecil sedikit saat ditekan, lalu kembali (terasa "empuk").
class LbTekan extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double skala;

  const LbTekan({
    super.key,
    required this.child,
    this.onTap,
    this.skala = 0.96,
  });

  @override
  State<LbTekan> createState() => _LbTekanState();
}

class _LbTekanState extends State<LbTekan> {
  bool _turun = false;

  void _set(bool v) {
    if (_turun != v) setState(() => _turun = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _turun ? widget.skala : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Melayang naik-turun pelan (dan sedikit bergoyang).
class LbMelayang extends StatefulWidget {
  final Widget child;
  final double jarak;
  final double putar; // goyangan (radian)
  final double sudutAwal; // kemiringan dasar (radian)
  final Duration durasi;

  const LbMelayang({
    super.key,
    required this.child,
    this.jarak = 5,
    this.putar = 0.02,
    this.sudutAwal = 0,
    this.durasi = const Duration(milliseconds: 2800),
  });

  @override
  State<LbMelayang> createState() => _LbMelayangState();
}

class _LbMelayangState extends State<LbMelayang>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.durasi)
        ..repeat(reverse: true);
  late final Animation<double> _a =
      CurvedAnimation(parent: _c, curve: Curves.easeInOut);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      child: widget.child,
      builder: (context, child) {
        final v = _a.value;
        return Transform.translate(
          offset: Offset(0, -widget.jarak + 2 * widget.jarak * v),
          child: Transform.rotate(
            angle: widget.sudutAwal + widget.putar * (2 * v - 1),
            child: child,
          ),
        );
      },
    );
  }
}

/// Titik penanda dengan cincin yang membesar & memudar (notifikasi baru).
class LbTitikDenyut extends StatefulWidget {
  final double ukuran;
  final Color warna;
  final Color tepi;

  const LbTitikDenyut({
    super.key,
    this.ukuran = 10,
    this.warna = const Color(0xFFFFB07C),
    this.tepi = Colors.white,
  });

  @override
  State<LbTitikDenyut> createState() => _LbTitikDenyutState();
}

class _LbTitikDenyutState extends State<LbTitikDenyut>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.ukuran;
    return SizedBox(
      width: u * 2.4,
      height: u * 2.4,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final v = _c.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: u * (1 + 1.4 * v),
                height: u * (1 + 1.4 * v),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.warna.withValues(alpha: 0.45 * (1 - v)),
                ),
              ),
              Container(
                width: u,
                height: u,
                decoration: BoxDecoration(
                  color: widget.warna,
                  shape: BoxShape.circle,
                  border: Border.all(color: widget.tepi, width: 1.8),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Berkedip pelan (untuk kerangka loading).
class LbBerkedip extends StatefulWidget {
  final Widget child;
  const LbBerkedip({super.key, required this.child});

  @override
  State<LbBerkedip> createState() => _LbBerkedipState();
}

class _LbBerkedipState extends State<LbBerkedip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);
  late final Animation<double> _a =
      Tween<double>(begin: 0.45, end: 1).animate(
    CurvedAnimation(parent: _c, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _a, child: widget.child);
}
