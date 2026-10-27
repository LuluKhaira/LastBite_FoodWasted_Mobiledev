<?php

namespace App\Http\Controllers\Api\dashboard_mitra;

use App\Http\Controllers\Controller;
use App\Models\Mitra;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class JamOperasionalController extends Controller
{
    private const NAMA_HARI = [
        1 => 'Senin', 2 => 'Selasa', 3 => 'Rabu', 4 => 'Kamis',
        5 => 'Jumat', 6 => 'Sabtu', 7 => 'Minggu',
    ];

    /** POST /api/mitra/jam-buka : ambil jam operasional (list kosong bila belum diatur) */
    public function show(Request $request)
    {
        $mitra = $this->mitraDariRequest($request);
        if (! $mitra) {
            return response()->json(['success' => false, 'message' => 'Data mitra tidak ditemukan.'], 404);
        }

        $jam = $mitra->jam_operasional;
        if (is_string($jam)) {
            $jam = json_decode($jam, true);
        }

        return response()->json([
            'success' => true,
            'data'    => is_array($jam) ? array_values($jam) : [],
        ]);
    }

    /** POST /api/mitra/jam-buka/simpan : simpan jam operasional 7 hari */
    public function simpan(Request $request)
    {
        $mitra = $this->mitraDariRequest($request);
        if (! $mitra) {
            return response()->json(['success' => false, 'message' => 'Data mitra tidak ditemukan.'], 404);
        }

        $request->validate([
            'jam'         => 'required|array|size:7',
            'jam.*.hari'  => 'required|integer|between:1,7|distinct',
            'jam.*.buka'  => 'required|boolean',
            'jam.*.mulai' => 'required|date_format:H:i',
            'jam.*.tutup' => 'required|date_format:H:i',
        ]);

        $bersih = [];
        $adaBuka = false;

        foreach ($request->input('jam') as $j) {
            $buka = filter_var($j['buka'], FILTER_VALIDATE_BOOLEAN);
            $hari = (int) $j['hari'];

            if ($buka && $j['tutup'] <= $j['mulai']) {
                throw ValidationException::withMessages([
                    'jam' => ['Jam tutup harus setelah jam buka (' . self::NAMA_HARI[$hari] . ').'],
                ]);
            }

            $adaBuka = $adaBuka || $buka;
            $bersih[] = [
                'hari'  => $hari,
                'buka'  => $buka,
                'mulai' => $j['mulai'],
                'tutup' => $j['tutup'],
            ];
        }

        if (! $adaBuka) {
            throw ValidationException::withMessages([
                'jam' => ['Minimal satu hari harus buka.'],
            ]);
        }

        usort($bersih, fn ($a, $b) => $a['hari'] <=> $b['hari']);

        DB::table('mitras')->where('id_mitra', $mitra->id_mitra)->update([
            'jam_operasional' => json_encode($bersih),
            'updated_at'      => now(),
        ]);

        return response()->json(['success' => true, 'message' => 'Jam operasional disimpan.']);
    }

    private function mitraDariRequest(Request $request): ?Mitra
    {
        $raw = $request->phone ?? $request->phoneNumber;
        if (! $raw) {
            return null;
        }

        $nomorBersih = preg_replace('/[^0-9]/', '', $raw);

        return Mitra::where('no_whatsapp', $raw)
            ->orWhere('no_whatsapp', $nomorBersih)
            ->orWhere('no_whatsapp', '0' . ltrim($nomorBersih, '0'))
            ->orWhere('no_whatsapp', '62' . ltrim($nomorBersih, '0'))
            ->first();
    }
}