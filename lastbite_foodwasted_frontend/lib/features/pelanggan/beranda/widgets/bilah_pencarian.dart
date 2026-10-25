import 'package:flutter/material.dart';
import '../../../../core/komponen/animasi_lb.dart';
import '../../../../core/tema/tema_lb.dart';

/// Kolom pencarian. Bercahaya hijau saat diketik.
class LbSearchBar extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilter; // dipanggil saat tombol filter ditekan
  final bool filterAktif; // true = tampilkan titik penanda

  const LbSearchBar({
    super.key,
    this.onChanged,
    this.onFilter,
    this.filterAktif = false,
  });

  @override
  State<LbSearchBar> createState() => _LbSearchBarState();
}

class _LbSearchBarState extends State<LbSearchBar> {
  final FocusNode _fokus = FocusNode();
  bool _f = false;

  @override
  void initState() {
    super.initState();
    _fokus.addListener(() {
      if (mounted) setState(() => _f = _fokus.hasFocus);
    });
  }

  @override
  void dispose() {
    _fokus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      height: 56,
      padding: const EdgeInsets.only(left: 18, right: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _f ? LbColors.sageDeep : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _f
                ? LbColors.sageDeep.withValues(alpha: 0.35)
                : Colors.black.withValues(alpha: 0.10),
            blurRadius: _f ? 22 : 14,
            offset: Offset(0, _f ? 8 : 6),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedScale(
            scale: _f ? 1.12 : 1,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutBack,
            child: Icon(
              Icons.search_rounded,
              color: _f ? LbColors.sageDeep : LbColors.forest,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              focusNode: _fokus,
              onChanged: widget.onChanged,
              cursorColor: LbColors.sageDeep,
              style: LbText.body(14, color: LbColors.forest),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Cari makanan, resto, atau pakan ternak...',
                hintStyle: LbText.body(14, color: LbColors.textGrey),
              ),
            ),
          ),
          LbTekan(
            onTap: widget.onFilter,
            skala: 0.9,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: widget.filterAktif ? LbColors.sage : LbColors.sageLight,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 22,
                    color: widget.filterAktif ? Colors.white : LbColors.forest,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: AnimatedScale(
                      scale: widget.filterAktif ? 1 : 0,
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutBack,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: LbColors.peach,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
