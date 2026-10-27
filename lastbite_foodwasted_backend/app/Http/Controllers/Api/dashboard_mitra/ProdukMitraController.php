<?php

namespace App\Http\Controllers\Api\dashboard_mitra;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ProdukMitraController extends Controller
{
    public function index(Request $request)
    {
        $phone = $request->phone; // Nomor WA dari Flutter

        // 1. Cari ID Mitra berdasarkan nomor WhatsApp
        $mitra = DB::table('mitras')->where('no_whatsapp', $phone)->first();

        if (!$mitra) {
            return response()->json([
                'success' => true,
                'data' => [],
            ]);
        }

        // 2. Ambil produk berdasarkan id_mitra
        $produks = DB::table('produks')
            ->where('id_mitra', $mitra->id_mitra)
            ->orderBy('id', 'desc')
            ->get();

        // 3. Terjemahkan data agar sesuai dengan format yang dibaca Flutter
        $data = $produks->map(function ($p) {
            $img = $p->gambar ? url('storage/' . $p->gambar) : null;
            return [
                'id' => $p->id,
                'nama' => $p->nama,
                'tipe' => $p->tipe,
                'kategori' => $p->kategori,
                'kategori_asli' => $p->kategori_asli,
                'kadaluarsa' => $p->kadaluarsa,
                'dialihkan_pada' => $p->dialihkan_pada,
                'harga' => $p->harga,
                'harga_asli' => $p->harga_asli,
                'stok' => $p->stok,
                'kuota' => $p->kuota,
                'hari' => 'Hari ini',
                'jam' => $p->waktu_selesai ? date('H:i', strtotime($p->waktu_selesai)) : '-',
                'status' => ($p->aktif == 1 && $p->stok > 0) ? 'tayang' : 'habis',
                'aktif' => $p->aktif == 1,
                // Return both keys so that both front‑ends can consume the image
                'image_url' => $img,
                'gambar' => $img,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    // 2. Untuk mengubah stok
    public function updateStok(Request $request)
    {
        $request->validate([
            'id' => 'required',
            'stok' => 'required|integer',
        ]);

        DB::table('produks')
            ->where('id', $request->id)
            ->update(['stok' => $request->stok]);

        return response()->json(['ok' => true, 'message' => 'Stok berhasil diubah']);
    }

    // 3. Untuk mengubah status aktif/nonaktif
    public function updateAktif(Request $request)
    {
        $request->validate([
            'id' => 'required',
            'aktif' => 'required|boolean',
        ]);

        DB::table('produks')
            ->where('id', $request->id)
            ->update(['aktif' => $request->aktif]);

        return response()->json(['ok' => true, 'message' => 'Status berhasil diubah']);
    }
}