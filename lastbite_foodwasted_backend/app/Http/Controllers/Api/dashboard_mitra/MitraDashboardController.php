<?php

namespace App\Http\Controllers\Api\dashboard_mitra;

use App\Http\Controllers\Controller;
use App\Models\Mitra;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class MitraDashboardController extends Controller
{
    // Data untuk layar dashboard mitra di Flutter
    public function show(Request $request)
    {
        $mitra = $this->mitraDariRequest($request);

        if (! $mitra) {
            return response()->json([
                'success' => false,
                'message' => 'Data mitra tidak ditemukan untuk nomor: ' . ($request->phone ?? $request->phoneNumber)
            ], 404);
        }

        if ($mitra->status_verifikasi !== 'disetujui') {
            return response()->json(['success' => false, 'message' => 'Akun mitra belum disetujui admin.'], 403);
        }

        $idMitra = $mitra->id_mitra;

        // Status toko buka/tutup
        $buka = Schema::hasColumn($mitra->getTable(), 'status_buka') ? (bool) $mitra->status_buka : true;

        $jamLengkap = Schema::hasTable('jam_operasional')
            && Schema::hasColumn('jam_operasional', 'id_mitra')
            && DB::table('jam_operasional')->where('id_mitra', $idMitra)->exists();

        $dasar = DB::table('pesanans')->where('id_mitra', $idMitra);

        // Aktif = belum selesai/dibatalkan (sesuaikan nama status dengan yang dipakai aplikasi)
        $pesananAktif = (clone $dasar)->whereNotIn('status', ['selesai', 'dibatalkan'])->count();

        $hariIni = (clone $dasar)
            ->whereDate('created_at', now()->toDateString())
            ->where('status', '!=', 'dibatalkan');

        $pesananHariIni    = (clone $hariIni)->count();
        $pendapatanHariIni = (float) (clone $hariIni)->sum(DB::raw('harga_satuan * qty'));
        $porsiHariIni      = (int)   (clone $hariIni)->sum('qty');
        $co2HariIni        = (float) (clone $hariIni)->sum('co2');

        $surplus = DB::table('produks')
            ->where('id_mitra', $idMitra)
            ->where('aktif', 1)
            ->where('stok', '>', 0)
            ->orderByDesc('id')
            ->limit(10)
            ->get([
                'id as id_produk', 'nama as nama_produk',
                'harga_asli', 'harga as harga_diskon', 'stok', 'waktu_selesai',
                'gambar',
            ])
            ->map(function ($p) {
                $path = $p->gambar ? ltrim($p->gambar, '/') : null;
                $url = null;
                if ($path) {
                    if (!str_starts_with($path, 'http://') && !str_starts_with($path, 'https://')) {
                        $url = request()->root() . '/api/foto/' . $path;
                    } else {
                        $url = $path;
                    }
                }
                $p->gambar_url = $url;
                $p->image_url = $url;
                return $p;
            });

        return response()->json([
            'success' => true,
            'data' => [
                'toko' => [
                    'nama'   => $mitra->nama_usaha ?? 'Toko Mitra',
                    'alamat' => $mitra->alamat ?? '',
                    'buka'   => $buka,
                ],
                'jam_operasional_lengkap' => $jamLengkap,
                'pesanan_aktif' => $pesananAktif,
                'ringkasan' => [
                    'pesanan_hari_ini'    => $pesananHariIni,
                    'pendapatan_hari_ini' => $pendapatanHariIni,
                    'porsi_terselamatkan' => $porsiHariIni,
                    'co2_kg'              => $co2HariIni,
                ],
                'surplus' => $surplus,
            ],
        ], 200);
    }

    public function setStatusToko(Request $request)
    {
        $rawPhone = $request->phone ?? $request->phoneNumber;
        $request->merge(['phone' => $rawPhone]);

        $request->validate([
            'phone' => 'required|string',
            'buka' => 'required|boolean',
        ]);

        $mitra = $this->mitraDariRequest($request);

        if (! $mitra) {
            return response()->json(['success' => false, 'message' => 'Data mitra tidak ditemukan.'], 404);
        }

        if ($mitra->status_verifikasi !== 'disetujui') {
            return response()->json(['success' => false, 'message' => 'Akun mitra belum disetujui admin.'], 403);
        }

        if (! Schema::hasColumn($mitra->getTable(), 'status_buka')) {
            return response()->json(['success' => false, 'message' => 'Kolom status_buka belum dibuat di database.'], 422);
        }

        Mitra::where('id_mitra', $mitra->id_mitra)->update(['status_buka' => $request->boolean('buka')]);

        return response()->json(['success' => true, 'buka' => $request->boolean('buka')], 200);
    }

    private function mitraDariRequest(Request $request): ?Mitra
    {
        // Mendukung parameter 'phone' atau 'phoneNumber' dari Flutter
        $raw = $request->phone ?? $request->phoneNumber;
        if (!$raw) return null;

        $nomorBersih = preg_replace('/[^0-9]/', '', $raw);

        // Cari berdasarkan berbagai variasi format nomor WhatsApp di database
        return Mitra::where('no_whatsapp', $raw)
            ->orWhere('no_whatsapp', $nomorBersih)
            ->orWhere('no_whatsapp', '0' . ltrim($nomorBersih, '0'))
            ->orWhere('no_whatsapp', '62' . ltrim($nomorBersih, '0'))
            ->first();
    }

    // Nama tabel diambil dari model kalau ada, kalau tidak pakai nama bawaan
    private function tabelDari(string $model, string $cadangan): string
    {
        $kelas = "App\\Models\\{$model}";

        return class_exists($kelas) ? (new $kelas)->getTable() : $cadangan;
    }
}