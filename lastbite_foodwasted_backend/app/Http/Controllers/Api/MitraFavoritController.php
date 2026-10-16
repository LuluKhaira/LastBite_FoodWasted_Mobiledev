<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MitraFavorit;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Validation\ValidationException;

class MitraFavoritController extends Controller
{
    /** GET /api/mitra-favorit */
    public function index(Request $r): JsonResponse
    {
        $data = MitraFavorit::where('user_id', $r->user()->id)
            ->latest('id')
            ->get()
            ->map(fn (MitraFavorit $f) => $this->ringkas((int) $f->id_mitra))
            ->values();

        return response()->json(['data' => $data]);
    }

    /** GET /api/mitra-favorit/status?produk_id= */
    public function status(Request $r): JsonResponse
    {
        $v = $r->validate(['produk_id' => 'required|integer']);

        $idMitra = $this->idMitraDariProduk((int) $v['produk_id']);
        $favorit = $idMitra
            && MitraFavorit::where('user_id', $r->user()->id)->where('id_mitra', $idMitra)->exists();

        return response()->json(['favorit' => (bool) $favorit]);
    }

    /** POST /api/mitra-favorit/toggle  {produk_id} */
    public function toggle(Request $r): JsonResponse
    {
        $v = $r->validate(['produk_id' => 'required|integer']);

        $idMitra = $this->idMitraDariProduk((int) $v['produk_id']);
        if (! $idMitra) {
            throw ValidationException::withMessages(['produk_id' => 'Produk ini belum terhubung ke mitra.']);
        }

        $q = MitraFavorit::where('user_id', $r->user()->id)->where('id_mitra', $idMitra);

        if ($q->exists()) {
            $q->delete();
            return response()->json(['favorit' => false]);
        }

        MitraFavorit::create(['user_id' => $r->user()->id, 'id_mitra' => $idMitra]);

        return response()->json(['favorit' => true]);
    }

    /** DELETE /api/mitra-favorit/{idMitra} */
    public function destroy(Request $r, int $idMitra): JsonResponse
    {
        MitraFavorit::where('user_id', $r->user()->id)->where('id_mitra', $idMitra)->delete();

        return response()->json(['message' => 'Dihapus dari favorit.']);
    }

    // ------------------------------------------------------------
    private function idMitraDariProduk(int $produkId): ?int
    {
        $p = DB::table('produks')->where('id', $produkId)->first();

        return $p && ! empty($p->id_mitra) ? (int) $p->id_mitra : null;
    }

    /**
     * Data ringkas satu mitra untuk kartu favorit.
     * Produk yang dipilih: yang masih ada stok dulu, lalu yang terbaru.
     */
    private function ringkas(int $idMitra): array
    {
        $m = DB::table('mitras')->where('id_mitra', $idMitra)->first();

        $qp = DB::table('produks')->where('id_mitra', $idMitra);
        if (Schema::hasColumn('produks', 'aktif')) {
            $qp->where('aktif', true);
        }
        $p = $qp->orderByRaw('CASE WHEN stok > 0 THEN 0 ELSE 1 END')
            ->orderByDesc('id')
            ->first();

        $nama   = $this->pilih($m, ['nama_usaha', 'nama_toko', 'nama_bisnis', 'nama_mitra', 'nama', 'name'])
            ?? $this->pilih($p, ['penjual'])
            ?? 'Mitra Lastbite';
        $alamat = $this->pilih($m, ['alamat', 'alamat_lengkap', 'alamat_usaha', 'alamat_toko'])
            ?? $this->pilih($p, ['alamat']);
        $gambar = $this->pilih($p, ['gambar', 'foto', 'image'])
            ?? $this->pilih($m, ['foto', 'logo', 'gambar']);

        $waktu = $this->pilih($p, ['waktu', 'waktu_ambil', 'jam_ambil']);
        if (! $waktu && $p) {
            $mulai   = $this->pilih($p, ['waktu_mulai', 'jam_mulai']);
            $selesai = $this->pilih($p, ['waktu_selesai', 'jam_selesai']);
            if ($mulai && $selesai) {
                $waktu = substr($mulai, 0, 5) . ' - ' . substr($selesai, 0, 5) . ' WIB';
            }
        }

        $hargaAsli = $p && isset($p->harga_asli) && $p->harga_asli !== null ? (int) $p->harga_asli : null;

        return [
            'id_mitra'    => $idMitra,
            'nama'        => $nama,
            'alamat'      => $alamat,
            'gambar'      => $gambar,
            'waktu'       => $waktu,
            // data tambahan untuk halaman Favorit
            'produk_id'   => $p ? (int) $p->id : null,
            'nama_produk' => $this->pilih($p, ['nama']),
            'harga'       => $p ? (int) ($p->harga ?? 0) : 0,
            'harga_asli'  => $hargaAsli,
            'stok'        => $p ? (int) ($p->stok ?? 0) : 0,
            'jarak_km'    => null,
        ];
    }

    private function pilih(?object $row, array $kolom): ?string
    {
        if (! $row) {
            return null;
        }
        foreach ($kolom as $k) {
            if (isset($row->$k) && trim((string) $row->$k) !== '') {
                return (string) $row->$k;
            }
        }

        return null;
    }
}