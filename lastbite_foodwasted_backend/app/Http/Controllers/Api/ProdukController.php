<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PengalihanKategori;
use App\Models\Produk;
use Illuminate\Http\Request;

class ProdukController extends Controller
{
    public function index(Request $r)
    {
        $q = Produk::with('mitra')->where('aktif', true);

        // Produk konsumsi manusia yang sudah lewat kadaluarsa tidak ditampilkan.
        $q->where(function ($w) {
            $w->where('tipe', '!=', Produk::TIPE_DIMAKAN)
                ->orWhereNull('kadaluarsa')
                ->orWhere('kadaluarsa', '>', now('Asia/Jakarta'));
        });

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

        if ($r->urutan === 'Harga Terendah') {
            $q->orderBy('harga')->orderByDesc('rating');
        } else {
            $q->orderByDesc('rating')->orderByDesc('id');
        }

        $lat = $r->filled('lat') ? (float) $r->lat : null;
        $lng = $r->filled('lng') ? (float) $r->lng : null;

        $items = $q->get()->map(fn($p) => $p->toApi($lat, $lng));

        if ($lat !== null && $lng !== null && $r->filled('jarak')) {
            $max = (float) $r->jarak;
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

    /**
     * GET /api/produk/opsi-pengalihan?kategori=Roti%20%26%20Pastry
     */
    public function opsiPengalihan(Request $request)
    {
        $kategori = (string) $request->input('kategori', '');

        return response()->json([
            'default_untuk_kategori' => $kategori
                ? PengalihanKategori::cariTujuan($kategori)
                : null,
            'opsi_tujuan' => PengalihanKategori::semuaTujuan(),
        ]);
    }

    /**
     * POST /api/mitra/produk/alihkan
     */
    public function alihkanManual(Request $request)
    {
        $request->validate([
            'id'                         => 'required|numeric',
            'target_kategori_pengalihan' => 'required|string',
            'tipe_tujuan'                => 'nullable|in:pakan,kompos',
        ]);

        $produk = Produk::find($request->id);
        if (!$produk) {
            return response()->json(['message' => 'Produk tidak ditemukan'], 404);
        }

        $ok = $produk->alihkan(
            $request->target_kategori_pengalihan,
            $request->tipe_tujuan
        );

        if (!$ok) {
            return response()->json(['message' => 'Produk sudah pernah dialihkan'], 422);
        }

        return response()->json([
            'message' => 'Produk berhasil dialihkan',
            'data'    => $produk->fresh()->toApi(),
        ]);
    }

    // --- TAMBAH PRODUK ---
    public function tambah(Request $request)
    {
        $request->validate([
            'phone' => 'required',
            'nama' => 'required|string',
            'kategori' => 'required|string',
            'harga'      => 'required|numeric|min:0|lte:harga_asli',
            'harga_asli' => 'required|numeric|min:0',
            'stok' => 'required|numeric',
            'kadaluarsa' => 'nullable|date',
            'target_kategori_pengalihan' => 'nullable|string',
        ]);

        $mitra = \App\Models\Mitra::where('no_whatsapp', $request->phone)->first();
        if (!$mitra) {
            return response()->json(['message' => 'Mitra tidak ditemukan'], 404);
        }

        $gambarPath = null;
        if ($request->hasFile('foto')) {
            $file = $request->file('foto');
            $namaFile = time() . '_' . $file->getClientOriginalName();
            $file->move(public_path('storage/produk'), $namaFile);
            $gambarPath = 'produk/' . $namaFile;
        }

        $produk = Produk::create([
            'id_mitra' => $mitra->id_mitra,
            'nama' => $request->nama,
            'deskripsi' => $request->deskripsi ?? '-',
            'tipe' => $request->tipe ?? Produk::TIPE_DIMAKAN,
            'kategori' => $request->kategori,
            'gambar' => $gambarPath,
            'harga' => $request->harga,
            'harga_asli' => $request->harga_asli,
            'stok' => $request->stok,
            'kuota' => $request->kuota ?? $request->stok,
            'waktu_mulai' => $request->waktu_mulai ?? '00:00',
            'waktu_selesai' => $request->waktu_selesai ?? '23:59',
            'aktif' => $request->terbit ?? 1,
            'kadaluarsa' => $request->kadaluarsa,
            'target_kategori_pengalihan' => $request->target_kategori_pengalihan,
        ]);

        return response()->json(['message' => 'Produk berhasil ditambahkan', 'data' => $produk], 201);
    }

    // --- EDIT PRODUK ---
    public function update(Request $request)
    {
        $request->validate([
            'id' => 'required|numeric',
            'nama' => 'required|string',
            'harga'      => 'required|numeric|min:0|lte:harga_asli',
            'harga_asli' => 'required|numeric|min:0',
            'stok' => 'required|numeric',
            'kadaluarsa' => 'nullable|date',
            'target_kategori_pengalihan' => 'nullable|string',
        ]);

        $produk = Produk::find($request->id);
        if (!$produk) {
            return response()->json(['message' => 'Produk tidak ditemukan'], 404);
        }

        $produk->update([
            'nama' => $request->nama,
            'deskripsi' => $request->deskripsi ?? $produk->deskripsi,
            'harga_asli' => $request->harga_asli,
            'harga' => $request->harga,
            'stok' => $request->stok,
            'kadaluarsa' => $request->kadaluarsa ?? $produk->kadaluarsa,
            'target_kategori_pengalihan' => $request->target_kategori_pengalihan ?? $produk->target_kategori_pengalihan,
        ]);

        return response()->json(['message' => 'Produk berhasil diperbarui'], 200);
    }
}