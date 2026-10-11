import 'package:flutter/material.dart';

const _forest = Color(0xFF2F4F2A);
const _sage = Color(0xFFA7C957);
const _sageLight = Color(0xFFEDF3DC);
const _offWhite = Color(0xFFF8F6F2);
const _grey = Color(0xFF7B8374);

class FilterPreferensiScreen extends StatefulWidget {
  final bool isTernak;
  const FilterPreferensiScreen({super.key, required this.isTernak});

  @override
  State<FilterPreferensiScreen> createState() => _FilterPreferensiScreenState();
}

class _FilterPreferensiScreenState extends State<FilterPreferensiScreen> {
  String urutan = 'Rekomendasi';
  double jarak = 10;
  bool tersedia = false;
  String harga = 'Semua Harga';
  late Set<String> kategori;

  List<String> get pilihanKategori => widget.isTernak
      ? ['Pakan Ternak', 'Bahan Pupuk']
      : ['Roti & Bakery', 'Makanan Siap Saji', 'Sayur & Buah'];

  @override
  void initState() {
    super.initState();
    kategori = {};
  }

  void reset() => setState(() {
    urutan = 'Rekomendasi';
    jarak = 10;
    tersedia = false;
    harga = 'Semua Harga';
    kategori.clear();
  });

  @override
  Widget build(BuildContext context) {
    final title = widget.isTernak ? 'Filter Ternak & Pupuk' : 'Filter Untuk Dimakan';
    return Scaffold(
      backgroundColor: _offWhite,
      appBar: AppBar(
        backgroundColor: _offWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _forest),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: const TextStyle(color: _forest, fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          TextButton(onPressed: reset, child: const Text('Reset', style: TextStyle(color: _forest))),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEAE7E0)),
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(color: _sageLight, shape: BoxShape.circle),
                child: const Icon(Icons.tune_rounded, color: _forest),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Atur preferensimu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _forest)),
                const SizedBox(height: 3),
                Text(widget.isTernak
                    ? 'Temukan bahan pakan dan pupuk sesuai kebutuhan.'
                    : 'Temukan surplus makanan sesuai seleramu.',
                  style: const TextStyle(fontSize: 12, color: _grey)),
              ])),
            ]),
          ),
          const SizedBox(height: 20),
          _heading('Urutkan berdasarkan', 'Pilih satu'),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            'Rekomendasi', 'Jarak Terdekat', 'Harga Terendah'
          ].map((item) => _choice(item, urutan == item, () => setState(() => urutan = item))).toList()),
          const SizedBox(height: 22),
          _heading('Kategori', 'Bisa pilih lebih dari satu'),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: pilihanKategori.map((item) =>
            _choice(item, kategori.contains(item), () => setState(() {
              if (kategori.contains(item)) { kategori.remove(item); } else { kategori.add(item); }
            }), icon: widget.isTernak ? (item == 'Pakan Ternak' ? Icons.agriculture_rounded : Icons.eco_rounded)
                                      : (item == 'Roti & Bakery' ? Icons.bakery_dining_rounded : item == 'Makanan Siap Saji' ? Icons.lunch_dining_rounded : Icons.eco_rounded))
          ).toList()),
          const SizedBox(height: 22),
          _heading('Jarak maksimal', '${jarak.toInt()} km'),
          Slider(
            value: jarak, min: 1, max: 10, divisions: 9,
            activeColor: _forest, inactiveColor: _sageLight,
            label: '${jarak.toInt()} km',
            onChanged: (v) => setState(() => jarak = v),
          ),
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('1 km', style: TextStyle(color: _grey, fontSize: 12)),
            Text('10 km', style: TextStyle(color: _grey, fontSize: 12)),
          ]),
          const SizedBox(height: 20),
          _heading('Rentang harga', 'Pilih satu'),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            'Semua Harga', 'Di bawah Rp25.000', 'Rp25.000–Rp50.000', 'Di atas Rp50.000'
          ].map((item) => _choice(item, harga == item, () => setState(() => harga = item))).toList()),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFEAE7E0))),
            child: SwitchListTile(
              value: tersedia,
              activeColor: _forest,
              onChanged: (v) => setState(() => tersedia = v),
              title: Text(widget.isTernak ? 'Hanya yang masih tersedia' : 'Hanya makanan yang masih tersedia',
                style: const TextStyle(color: _forest, fontWeight: FontWeight.w700, fontSize: 13)),
              subtitle: const Text('Sembunyikan produk yang sudah habis', style: TextStyle(color: _grey, fontSize: 12)),
              secondary: const Icon(Icons.inventory_2_outlined, color: _forest),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _forest, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
              onPressed: () => Navigator.pop(context, {
                'urutan': urutan,
                'jarak': jarak,
                'tersedia': tersedia,
                'harga': harga,
                'kategori': kategori.toList(),
              }),
              child: const Text('Terapkan Filter', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heading(String title, String trailing) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(color: _forest, fontSize: 15, fontWeight: FontWeight.w700)),
      Text(trailing, style: const TextStyle(color: _grey, fontSize: 11)),
    ],
  );

  Widget _choice(String label, bool selected, VoidCallback onTap, {IconData? icon}) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(24),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? _forest : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: selected ? _forest : const Color(0xFFE0DED6)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: 15, color: selected ? Colors.white : _forest),
          const SizedBox(width: 6),
        ],
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : _forest)),
      ]),
    ),
  );
}
