<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Produk;
use Illuminate\Http\Request;

class ProdukController extends Controller
{
    public function index(Request $r)
    {
        $q = Produk::with('mitra')->where('aktif', true);

        if ($r->filled('tipe')) {
            $q->where('tipe', $r->tipe);
        }

        $kategori = array_values(array_filter((array) $r->input('kategori', [])));
        if (!empty($kategori)) {
            $q->whereIn('kategori', $kategori);
        }

        if ($r->filled('q')) {
            $s = '%' . $r->q . '%';
            $q->where(fn($w) => $w->where('nama', 'like', $s)
                ->orWhereHas('mitra', fn($m) => $m->where('nama_usaha', 'like', $s)));
        }

        if ($r->boolean('tersedia')) {
            $q->where('stok', '>', 0);
        }

        if ($r->filled('harga_min')) {
            $q->where('harga', '>=', (int) $r->harga_min);
        }
        if ($r->filled('harga_max')) {
            $q->where('harga', '<=', (int) $r->harga_max);
        }

        // Urutan di level database (jarak diurutkan setelah dihitung di bawah)
        if ($r->urutan === 'Harga Terendah') {
            $q->orderBy('harga')->orderByDesc('rating');
        } else {
            $q->orderByDesc('rating')->orderByDesc('id'); // Rekomendasi
        }

        $lat = $r->filled('lat') ? (float) $r->lat : null;
        $lng = $r->filled('lng') ? (float) $r->lng : null;

        $items = $q->get()->map(fn($p) => $p->toApi($lat, $lng));

        if ($lat !== null && $lng !== null && $r->filled('jarak')) {
            $max = (float) $r->jarak;
            // 10 km = batas slider paling jauh -> anggap "tanpa batas"
            if ($max < 10) {
                $items = $items->filter(fn($i) => $i['jarak_km'] === null || $i['jarak_km'] <= $max);
            }
        }

        if ($r->urutan === 'Jarak Terdekat') {
            $items = $items->sortBy(fn($i) => $i['jarak_km'] ?? 9999);
        }

        return response()->json(['data' => $items->values()]);
    }

    public function show(Produk $produk)
    {
        return response()->json(['data' => $produk->load('mitra')->toApi()]);
    }

    // --- FUNGSI TAMBAH PRODUK (Dari Flutter) ---
    public function tambah(Request $request)
    {
        $request->validate([
            'phone' => 'required',
            'nama' => 'required|string',
            'kategori' => 'required|string',
            'harga'      => 'required|numeric|min:0|lte:harga_asli',
            'harga_asli' => 'required|numeric|min:0',
            'stok' => 'required|numeric',
        ]);

        // Cari Mitra berdasarkan nomor HP
        $mitra = \App\Models\Mitra::where('no_whatsapp', $request->phone)->first();
        if (!$mitra) {
            return response()->json(['message' => 'Mitra tidak ditemukan'], 404);
        }

        // Proses Upload Gambar (Opsional)
        $gambarPath = null;
        if ($request->hasFile('foto')) {
            $file = $request->file('foto');
            $namaFile = time() . '_' . $file->getClientOriginalName();
            $file->move(public_path('storage/produk'), $namaFile);
            $gambarPath = 'produk/' . $namaFile;
        }

        // Simpan ke database
        $produk = \App\Models\Produk::create([
            'id_mitra' => $mitra->id_mitra,
            'nama' => $request->nama,
            'deskripsi' => $request->deskripsi ?? '-',
            'tipe' => $request->tipe ?? 'dimakan',
            'kategori' => $request->kategori,
            'gambar' => $gambarPath,
            'harga' => $request->harga,
            'harga_asli' => $request->harga_asli,
            'stok' => $request->stok,
            'kuota' => $request->kuota ?? $request->stok,
            'waktu_mulai' => $request->waktu_mulai ?? '00:00',
            'waktu_selesai' => $request->waktu_selesai ?? '23:59',
            'aktif' => $request->terbit ?? 1,
        ]);

        return response()->json(['message' => 'Produk berhasil ditambahkan', 'data' => $produk], 201);
    }

    // --- FUNGSI EDIT PRODUK (Dari Flutter) ---
    public function update(Request $request)
    {
        $request->validate([
            'id' => 'required|numeric',
            'nama' => 'required|string',
            'harga'      => 'required|numeric|min:0|lte:harga_asli',
            'harga_asli' => 'required|numeric|min:0',
            'stok' => 'required|numeric',
        ]);

        $produk = \App\Models\Produk::find($request->id);

        if (!$produk) {
            return response()->json(['message' => 'Produk tidak ditemukan'], 404);
        }

        $produk->update([
            'nama' => $request->nama,
            'deskripsi' => $request->deskripsi ?? $produk->deskripsi,
            'harga_asli' => $request->harga_asli,
            'harga' => $request->harga,
            'stok' => $request->stok,
        ]);

        return response()->json(['message' => 'Produk berhasil diperbarui'], 200);
    }
}
