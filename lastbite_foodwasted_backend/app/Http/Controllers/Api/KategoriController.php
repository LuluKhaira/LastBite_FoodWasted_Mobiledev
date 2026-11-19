<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Kategori;
use Illuminate\Http\Request;

class KategoriController extends Controller
{
    /**
     * GET /api/kategori               : semua kategori aktif
     * GET /api/kategori?tipe=dimakan  : hanya kategori makanan (untuk chip beranda pelanggan)
     */
    public function index(Request $request)
    {
        $q = Kategori::aktif()->with('tujuan');

        if ($request->filled('tipe') && in_array($request->tipe, Kategori::TIPE, true)) {
            $q->where('tipe', $request->tipe);
        }

        $data = $q->orderBy('urutan')->orderBy('nama')
            ->get()
            ->map(fn ($k) => [
                'id'     => $k->id,
                'nama'   => $k->nama,
                'tipe'   => $k->tipe,
                'icon'   => $k->icon,
                'urutan' => (int) $k->urutan,
                'tujuan' => $k->tujuan?->nama,
            ]);

        return response()->json(['data' => $data]);
    }
}