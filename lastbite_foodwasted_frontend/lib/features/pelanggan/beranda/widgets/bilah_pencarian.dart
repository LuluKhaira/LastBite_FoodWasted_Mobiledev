import 'package:flutter/material.dart';
import '../../../../core/komponen/animasi_lb.dart';
import '../../../../core/tema/tema_lb.dart';

/// Kolom pencarian. Bercahaya hijau saat diketik.
class LbSearchBar extends StatefulWidget {
  final ValueChanged<String>? onChanged;

  const LbSearchBar({
    super.key,
    this.onChanged,
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
      padding: const EdgeInsets.symmetric(horizontal: 18),
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
        ],
      ),
    );
  }
}