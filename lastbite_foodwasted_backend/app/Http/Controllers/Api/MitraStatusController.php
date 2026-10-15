<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mitra;
use Carbon\Carbon;
use Illuminate\Http\Request;

class MitraStatusController extends Controller
{
    // Dipanggil aplikasi Flutter (layar "Menunggu Verifikasi") untuk membaca keputusan admin
    public function check(Request $request)
    {
        $request->validate(['phone' => 'required|string']);

        $phone = preg_replace('/[^0-9]/', '', $request->phone);
        if (str_starts_with($phone, '62')) {
            $phone = '0' . substr($phone, 2);
        } elseif (str_starts_with($phone, '8')) {
            $phone = '0' . $phone;
        }

        $mitra = Mitra::where('no_whatsapp', $phone)->first();

        if (! $mitra) {
            return response()->json(['success' => false, 'message' => 'Data mitra tidak ditemukan.'], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $mitra->id_mitra,
                'status' => $mitra->status_verifikasi,
                'nama_usaha' => $mitra->nama_usaha,
                'kategori' => $mitra->kategori_usaha ?? null,
                'alasan_penolakan' => $mitra->alasan_penolakan ?? null,
                'diajukan' => $mitra->created_at
                    ? Carbon::parse($mitra->created_at)->locale('id')->translatedFormat('d M Y, H:i')
                    : null,
            ],
        ], 200);
    }
}