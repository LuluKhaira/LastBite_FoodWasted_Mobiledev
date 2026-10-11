<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mitra;
use Illuminate\Http\Request;

class MitraController extends Controller
{
    // 1. Ambil semua data Mitra (GET)
    public function index()
    {
        $mitras = Mitra::all();
        return response()->json([
            'success' => true,
            'message' => 'List data mitra',
            'data' => $mitras
        ], 200);
    }

    // 2. Tambah data Mitra baru (POST)
    public function store(Request $request)
    {
        $request->validate([
            'no_whatsapp' => 'required|string',
            'alamat' => 'required|string',
            'no_rekening' => 'nullable|string',
        ]);

        $mitra = Mitra::create([
            'no_whatsapp' => $request->no_whatsapp,
            'alamat' => $request->alamat,
            'foto_ktp' => $request->foto_ktp,
            'foto_npwp' => $request->foto_npwp,
            'sertifikat_halal' => $request->sertifikat_halal,
            'no_rekening' => $request->no_rekening,
            'status_verifikasi' => 'pending',
            'saldo' => 0.00,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Mitra berhasil didaftarkan',
            'data' => $mitra
        ], 201);
    }

    // 3. Ambil detail satu Mitra berdasarkan ID (GET)
    public function show($id)
    {
        $mitra = Mitra::find($id);

        if (!$mitra) {
            return response()->json([
                'success' => false,
                'message' => 'Mitra tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Detail data mitra',
            'data' => $mitra
        ], 200);
    }
}