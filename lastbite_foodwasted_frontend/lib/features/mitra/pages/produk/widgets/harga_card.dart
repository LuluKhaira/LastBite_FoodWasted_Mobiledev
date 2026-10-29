import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'base_card.dart';
import 'warna_lokal.dart';

class HargaCard extends StatelessWidget {
  final TextEditingController asliCtrl;
  final TextEditingController diskonCtrl;
  final int stok;
  final ValueChanged<int> onStokChanged;
  final String satuanLabel;

  const HargaCard({
    super.key,
    required this.asliCtrl,
    required this.diskonCtrl,
    required this.stok,
    required this.onStokChanged,
    this.satuanLabel = 'Satuan: Paket',
  });

  int? get _hematPersen {
    final asli = _angka(asliCtrl.text);
    if (asli <= 0 || diskonCtrl.text.isEmpty) return null;
    final diskon = _angka(diskonCtrl.text);
    if (diskon >= asli) return null;
    return (((asli - diskon) / asli) * 100).round();
  }

  int _angka(String teks) => int.tryParse(teks.replaceAll('.', '')) ?? 0;

  @override
  Widget build(BuildContext context) {
    final hemat = _hematPersen;
    
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('HARGA & PENYELAMATAN', style: AppColors.heading(fontSize: 12, color: WarnaLokal.textSoft)),
              if (hemat != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: WarnaLokal.mintDeep, borderRadius: BorderRadius.circular(8)),
                  child: Text('Diskon $hemat%', style: AppColors.body(fontSize: 11, fontWeight: FontWeight.w700, color: WarnaLokal.primaryDark)),
                )
              else if (_angka(diskonCtrl.text) == 0 && diskonCtrl.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: WarnaLokal.mintDeep, borderRadius: BorderRadius.circular(8)),
                  child: Text('Gratis / Donasi Tani', style: AppColors.body(fontSize: 11, fontWeight: FontWeight.w700, color: WarnaLokal.primaryDark)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nilai Asli Toko', style: AppColors.body(fontSize: 12, color: WarnaLokal.textDark)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: WarnaLokal.border)),
                      child: Row(
                        children: [
                          Text('Rp', style: AppColors.body(fontSize: 14, color: WarnaLokal.textSoft)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: asliCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [_RibuanFormatter()],
                              style: AppColors.heading(fontSize: 16, color: WarnaLokal.textDark),
                              decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: '0'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Harga Rescue', style: AppColors.body(fontSize: 12, fontWeight: FontWeight.w700, color: WarnaLokal.primaryDark)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(color: WarnaLokal.mintDeep.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8), border: Border.all(color: WarnaLokal.primaryDark)),
                      child: Row(
                        children: [
                          Text('Rp', style: AppColors.body(fontSize: 14, color: WarnaLokal.primaryDark)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: diskonCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [_RibuanFormatter()],
                              style: AppColors.heading(fontSize: 16, color: WarnaLokal.primaryDark),
                              decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: '0'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jumlah Kuota', style: AppColors.heading(fontSize: 13, color: WarnaLokal.textDark)),
                  Text(satuanLabel, style: AppColors.body(fontSize: 11, color: WarnaLokal.textSoft)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(color: WarnaLokal.mint, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    InkWell(
                      onTap: stok > 1 ? () => onStokChanged(stok - 1) : null,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(Icons.remove, size: 16, color: WarnaLokal.textDark),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('$stok', style: AppColors.heading(fontSize: 16, color: WarnaLokal.textDark)),
                    ),
                    InkWell(
                      onTap: stok < 999 ? () => onStokChanged(stok + 1) : null,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: WarnaLokal.primaryDark, shape: BoxShape.circle),
                        child: const Icon(Icons.add, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RibuanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 9) digits = digits.substring(0, 9);
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final t = _ribuan(int.parse(digits));
    return TextEditingValue(text: t, selection: TextSelection.collapsed(offset: t.length));
  }
}

String _ribuan(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}
