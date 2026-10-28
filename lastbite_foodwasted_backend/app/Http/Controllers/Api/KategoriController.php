<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Kategori;

class KategoriController extends Controller
{
    /** GET /api/kategori : kategori aktif, dipakai Flutter untuk mengisi pilihan. */
    public function index()
    {
        $data = Kategori::aktif()
            ->with('tujuan')
            ->orderBy('urutan')->orderBy('nama')
            ->get()
            ->map(fn ($k) => [
                'id'     => $k->id,
                'nama'   => $k->nama,
                'tipe'   => $k->tipe,
                'tujuan' => $k->tujuan?->nama,
            ]);

        return response()->json(['data' => $data]);
    }
}