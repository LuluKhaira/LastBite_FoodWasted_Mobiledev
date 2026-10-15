<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Alamat;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AlamatController extends Controller
{
    /** GET /api/alamat */
    public function index(Request $r): JsonResponse
    {
        $data = Alamat::where('user_id', $r->user()->id)
            ->orderByDesc('is_utama')
            ->orderBy('id')
            ->get()
            ->map(fn (Alamat $a) => $a->toApi())
            ->values();

        return response()->json(['data' => $data]);
    }

    /** POST /api/alamat */
    public function store(Request $r): JsonResponse
    {
        $v  = $this->validasi($r);
        $uid = $r->user()->id;

        $alamat = DB::transaction(function () use ($v, $uid) {
            $pertama = ! Alamat::where('user_id', $uid)->exists();
            $utama   = $pertama || ($v['is_utama'] ?? false);

            if ($utama) {
                Alamat::where('user_id', $uid)->update(['is_utama' => false]);
            }

            return Alamat::create([
                'user_id'       => $uid,
                'label'         => $v['label'],
                'nama_penerima' => $v['nama_penerima'],
                'telepon'       => $v['telepon'],
                'alamat'        => $v['alamat'],
                'patokan'       => $v['patokan'] ?? null,
                'is_utama'      => $utama,
            ]);
        });

        return response()->json(['data' => $alamat->toApi()], 201);
    }

    /** PUT /api/alamat/{id} */
    public function update(Request $r, int $id): JsonResponse
    {
        $v = $this->validasi($r);
        $a = $this->milik($r, $id);

        DB::transaction(function () use ($v, $a, $r) {
            // alamat utama tidak boleh "diturunkan" lewat form; pindahkan lewat Jadikan Utama
            $utama = $a->is_utama || ($v['is_utama'] ?? false);

            if ($utama && ! $a->is_utama) {
                Alamat::where('user_id', $r->user()->id)->update(['is_utama' => false]);
            }

            $a->update([
                'label'         => $v['label'],
                'nama_penerima' => $v['nama_penerima'],
                'telepon'       => $v['telepon'],
                'alamat'        => $v['alamat'],
                'patokan'       => $v['patokan'] ?? null,
                'is_utama'      => $utama,
            ]);
        });

        return response()->json(['data' => $a->fresh()->toApi()]);
    }

    /** DELETE /api/alamat/{id} */
    public function destroy(Request $r, int $id): JsonResponse
    {
        $a = $this->milik($r, $id);

        DB::transaction(function () use ($a, $r) {
            $adalahUtama = $a->is_utama;
            $a->delete();

            if ($adalahUtama) {
                $berikut = Alamat::where('user_id', $r->user()->id)->orderBy('id')->first();
                $berikut?->update(['is_utama' => true]);
            }
        });

        return response()->json(['message' => 'Alamat dihapus.']);
    }

    /** POST /api/alamat/{id}/utama */
    public function utama(Request $r, int $id): JsonResponse
    {
        $a = $this->milik($r, $id);

        DB::transaction(function () use ($a, $r) {
            Alamat::where('user_id', $r->user()->id)->update(['is_utama' => false]);
            $a->update(['is_utama' => true]);
        });

        return response()->json(['data' => $a->fresh()->toApi()]);
    }

    private function validasi(Request $r): array
    {
        return $r->validate([
            'label'         => 'required|string|max:40',
            'nama_penerima' => 'required|string|max:100',
            'telepon'       => 'required|string|max:20',
            'alamat'        => 'required|string|max:300',
            'patokan'       => 'nullable|string|max:200',
            'is_utama'      => 'sometimes|boolean',
        ]);
    }

    private function milik(Request $r, int $id): Alamat
    {
        return Alamat::where('user_id', $r->user()->id)->where('id', $id)->firstOrFail();
    }
}