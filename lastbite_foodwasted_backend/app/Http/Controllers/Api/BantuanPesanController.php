<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\BantuanPesan;
use Illuminate\Http\Request;

/**
 * Live Chat CS.
 * Pesan pelanggan disimpan di tabel pesan_bantuans. Tim CS membalas dengan
 * mengisi kolom `balasan` (dan `dibalas_at`) pada baris tersebut, lalu balasan
 * muncul di aplikasi saat layar dimuat ulang.
 */
class BantuanPesanController extends Controller
{
    /** GET /api/bantuan/pesan */
    public function index(Request $request)
    {
        $data = BantuanPesan::query()
            ->where('user_id', $request->user()->id)
            ->orderBy('created_at')
            ->get()
            ->map(fn (BantuanPesan $row) => [
                'id'      => $row->id,
                'pesan'   => $row->pesan,
                'balasan' => $row->balasan,
                'status'  => $row->status,
                'waktu'   => optional($row->created_at)->timezone('Asia/Jakarta')->format('d M Y, H:i'),
                'dibalas' => optional($row->dibalas_at)->timezone('Asia/Jakarta')->format('d M Y, H:i'),
            ])
            ->values();

        return response()->json(['data' => $data]);
    }

    /** POST /api/bantuan/pesan */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'pesan' => ['required', 'string', 'min:1', 'max:1000'],
        ]);

        $pesan = BantuanPesan::create([
            'user_id' => $request->user()->id,
            'pesan'   => trim($validated['pesan']),
            'kanal'   => 'live',
            'status'  => 'terkirim',
        ]);

        return response()->json([
            'message' => 'Pesan terkirim ke tim CS.',
            'data'    => ['id' => $pesan->id, 'status' => $pesan->status],
        ], 201);
    }
}