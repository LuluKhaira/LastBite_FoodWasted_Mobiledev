import 'package:flutter/material.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'package:lastbite_foodwasted_mobiledev/features/mitra/pages/produk/models/surplus_draft.dart';
import 'warna_lokal.dart';

class TopToggleWidget extends StatelessWidget {
  final TipeProduk current;
  final ValueChanged<TipeProduk> onChanged;

  const TopToggleWidget({super.key, required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WarnaLokal.border),
      ),
      child: Row(
        children: [
          _buildTab(context, 'Paket Kejutan', Icons.auto_awesome, TipeProduk.paketKejutan),
          _buildTab(context, 'Produk Satuan', Icons.inventory_2_outlined, TipeProduk.satuan),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String text, IconData icon, TipeProduk type) {
    final isSelected = current == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(type),
        child: AnimatedContainer( // Gunakan AnimatedContainer untuk transisi halus
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? WarnaLokal.mintDeep : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? WarnaLokal.primaryDark : AppColors.textSoft),
              const SizedBox(width: 8),
              Text(
                text, 
                style: AppColors.heading(
                  fontSize: 14, 
                  color: isSelected ? WarnaLokal.primaryDark : AppColors.textSoft
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}