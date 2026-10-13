<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Produk;
use Illuminate\Http\Request;

class ProdukController extends Controller
{
    /**
     * GET /api/produk
     *  tipe       : dimakan | ternak
     *  kategori[] : satu atau lebih kategori
     *  q          : kata kunci (nama produk / nama toko)
     *  urutan     : Rekomendasi | Jarak Terdekat | Harga Terendah
     *  harga_min, harga_max : rentang harga (rupiah)
     *  tersedia   : 1 = hanya yang stoknya > 0
     *  lat, lng   : lokasi pembeli (untuk hitung jarak)
     *  jarak      : jarak maksimal (km), dipakai kalau lat & lng dikirim
     */
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
            $q->where(fn ($w) => $w->where('nama', 'like', $s)
                ->orWhereHas('mitra', fn ($m) => $m->where('nama_usaha', 'like', $s)));
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

        $items = $q->get()->map(fn ($p) => $p->toApi($lat, $lng));

        if ($lat !== null && $lng !== null && $r->filled('jarak')) {
            $max = (float) $r->jarak;
            // 10 km = batas slider paling jauh -> anggap "tanpa batas"
            if ($max < 10) {
                $items = $items->filter(fn ($i) => $i['jarak_km'] === null || $i['jarak_km'] <= $max);
            }
        }

        if ($r->urutan === 'Jarak Terdekat') {
            $items = $items->sortBy(fn ($i) => $i['jarak_km'] ?? 9999);
        }

        return response()->json(['data' => $items->values()]);
    }

    public function show(Produk $produk)
    {
        return response()->json(['data' => $produk->load('mitra')->toApi()]);
    }
}
