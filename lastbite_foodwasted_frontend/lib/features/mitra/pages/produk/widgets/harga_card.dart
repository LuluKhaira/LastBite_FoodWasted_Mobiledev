import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lastbite_foodwasted_mobiledev/core/theme/app_colors.dart';
import 'base_card.dart';
import 'warna_lokal.dart';

class HargaCard extends StatelessWidget {
  final TextEditingController asliCtrl;
  final TextEditingController diskonCtrl;
  final String skemaHarga; // 'diskon' | 'sedekah'
  final ValueChanged<String> onSkemaHargaChanged;
  final int stok;
  final ValueChanged<int> onStokChanged;
  final String satuanLabel;

  const HargaCard({
    super.key,
    required this.asliCtrl,
    required this.diskonCtrl,
    this.skemaHarga = 'diskon',
    required this.onSkemaHargaChanged,
    required this.stok,
    required this.onStokChanged,
    this.satuanLabel = 'Satuan: Paket',
  });

  bool get _isSedekah => skemaHarga == 'sedekah';

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
              Text(
                'SKEMA & HARGA PRODUK',
                style: AppColors.heading(fontSize: 12, color: WarnaLokal.textSoft),
              ),
              if (_isSedekah)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF6EE7B7)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.volunteer_activism_rounded, size: 13, color: Color(0xFF047857)),
                      const SizedBox(width: 4),
                      Text(
                        'Sedekah • Rp 0',
                        style: AppColors.body(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                )
              else if (hemat != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: WarnaLokal.mintDeep,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Diskon $hemat%',
                    style: AppColors.body(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: WarnaLokal.primaryDark,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSkemaTab(
                    label: 'Harga Diskon',
                    icon: Icons.local_offer_outlined,
                    isSelected: !_isSedekah,
                    activeColor: WarnaLokal.primaryDark,
                    onTap: () {
                      onSkemaHargaChanged('diskon');
                      if (diskonCtrl.text == '0') {
                        diskonCtrl.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildSkemaTab(
                    label: 'Sedekah (Rp 0)',
                    icon: Icons.volunteer_activism_rounded,
                    isSelected: _isSedekah,
                    activeColor: const Color(0xFF059669),
                    onTap: () {
                      onSkemaHargaChanged('sedekah');
                      diskonCtrl.text = '0';
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (_isSedekah)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.favorite_rounded, color: Color(0xFF059669), size: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Produk ini disalurkan secara cuma-cuma (Rp 0) untuk yang membutuhkan. Nilai asli toko tetap dicatat sebagai kontribusi kebaikan tokomu.',
                      style: GoogleFonts.nunito(
                        fontSize: 11.5,
                        color: const Color(0xFF065F46),
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: WarnaLokal.border),
                      ),
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
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                hintText: '0',
                              ),
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
                    Text(
                      _isSedekah ? 'Harga Penyaluran' : 'Harga Rescue',
                      style: AppColors.body(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _isSedekah ? const Color(0xFF059669) : WarnaLokal.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: _isSedekah
                            ? const Color(0xFFD1FAE5).withValues(alpha: 0.5)
                            : WarnaLokal.mintDeep.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isSedekah ? const Color(0xFF059669) : WarnaLokal.primaryDark,
                          width: _isSedekah ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Rp',
                            style: AppColors.body(
                              fontSize: 14,
                              color: _isSedekah ? const Color(0xFF059669) : WarnaLokal.primaryDark,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: diskonCtrl,
                              enabled: !_isSedekah,
                              keyboardType: TextInputType.number,
                              inputFormatters: [_RibuanFormatter()],
                              style: AppColors.heading(
                                fontSize: 16,
                                color: _isSedekah ? const Color(0xFF059669) : WarnaLokal.primaryDark,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                hintText: _isSedekah ? '0 (Gratis)' : '0',
                              ),
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
        ],
      ),
    );
  }

  Widget _buildSkemaTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? activeColor : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RibuanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final angka = newValue.text.replaceAll('.', '');
    if (int.tryParse(angka) == null) return oldValue;
    final s = int.parse(angka).toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return TextEditingValue(text: buf.toString(), selection: TextSelection.collapsed(offset: buf.length));
  }
}