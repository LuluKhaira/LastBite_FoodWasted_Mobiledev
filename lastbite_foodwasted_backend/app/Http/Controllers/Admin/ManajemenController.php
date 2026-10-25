<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Mitra;
use App\Models\User;
use App\Models\Produk;
use App\Models\Pesanan;

class ManajemenController extends Controller
{
    public function verifikasi()
    {
        $pendingMitras = Mitra::whereNotIn('status_verifikasi', ['disetujui', 'ditolak'])
                              ->whereNotNull('foto_ktp')
                              ->latest()
                              ->get();
        return view('pages.admin.verifikasi', compact('pendingMitras'));
    }

    public function mitra()
    {
        $mitras = Mitra::latest()->paginate(10);
        return view('pages.admin.mitra', compact('mitras'));
    }

    public function pengguna()
    {
        $users = User::where('role', 'pembeli')->latest()->paginate(15);
        return view('pages.admin.pengguna', compact('users'));
    }

    public function produk()
    {
        $produks = Produk::with('mitra')->latest()->paginate(15);
        return view('pages.admin.produk', compact('produks'));
    }

    public function pesanan()
    {
        $pesanans = Pesanan::with(['user', 'mitra'])->latest()->paginate(20);
        return view('pages.admin.pesanan', compact('pesanans'));
    }

    public function laporan()
    {
        $totalMakanan = Pesanan::sum('makanan') ?? 0;
        $totalCo2 = Pesanan::sum('co2') ?? 0;
        $totalTransaksi = Pesanan::where('status', 'selesai')->count() ?? 0;

        $rekapMitra = Mitra::withCount(['pesanan as total_pesanan' => function ($q) {
            $q->where('status', 'selesai');
        }])->get()->map(function ($mitra) {
            $pesananSelesai = $mitra->pesanan()->where('status', 'selesai')->get();
            $mitra->total_kg = $pesananSelesai->sum('makanan');
            $mitra->total_pendapatan = $pesananSelesai->sum(function ($p) {
                return $p->qty * $p->harga_satuan;
            });
            return $mitra;
        });

        return view('pages.admin.laporan', compact('totalMakanan', 'totalCo2', 'totalTransaksi', 'rekapMitra'));
    }
}