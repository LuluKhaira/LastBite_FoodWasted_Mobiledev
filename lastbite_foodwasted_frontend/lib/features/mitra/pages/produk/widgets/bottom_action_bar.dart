import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'warna_lokal.dart';

class BottomActionBar extends StatelessWidget {
  final bool saving;
  final VoidCallback onSimpanDraf;
  final VoidCallback onTayangkan;

  const BottomActionBar({
    super.key,
    required this.saving,
    required this.onSimpanDraf,
    required this.onTayangkan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: WarnaLokal.border)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: saving ? null : onSimpanDraf,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                side: BorderSide(color: WarnaLokal.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Simpan Draf',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppColors.heading(fontSize: 13, color: WarnaLokal.textDark),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: saving ? null : onTayangkan,
              icon: saving 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send_outlined, size: 16),
              label: Text(
                'Tayangkan',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppColors.heading(fontSize: 13, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: WarnaLokal.primaryDark,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}