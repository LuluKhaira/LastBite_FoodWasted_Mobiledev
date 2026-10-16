<?php

namespace App\Http\Controllers\Api\dashboard_mitra;

use App\Http\Controllers\Controller;
use App\Models\Mitra;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class MitraProdukController extends Controller
{
    private const KATEGORI = [
        'Roti & Bakery', 'Dessert', 'Makanan Berat', 'Bahan Olahan', 'Pakan Ternak',
    ];

    /** POST /api/mitra/produk : simpan produk (terbit) atau draf */
    public function store(Request $request)
    {
        $mitra = $this->mitraDariRequest($request);

        if (! $mitra) {
            return response()->json(['success' => false, 'message' => 'Data mitra tidak ditemukan.'], 404);
        }
        if ($mitra->status_verifikasi !== 'disetujui') {
            return response()->json(['success' => false, 'message' => 'Akun mitra belum disetujui admin.'], 403);
        }

        $data = $request->validate([
            'phone'         => 'required|string',
            'nama'          => 'required|string|max:50',
            'kategori'      => ['required', Rule::in(self::KATEGORI)],
            'harga_asli'    => 'required|integer|min:1|max:99999999',
            'harga'         => 'required|integer|min:0|lt:harga_asli',
            'stok'          => 'required|integer|min:1|max:999',
            'waktu_selesai' => 'required|date_format:H:i',
            'terbit'        => 'required|boolean',
            'foto'          => 'nullable|image|max:5120',
            'gambar_lama'   => 'nullable|string|max:255',
        ], [
            'nama.required'      => 'Nama produk wajib diisi.',
            'nama.max'           => 'Nama produk maksimal 50 karakter.',
            'kategori.required'  => 'Pilih kategori produk.',
            'kategori.in'        => 'Kategori tidak valid.',
            'harga_asli.required' => 'Harga asli wajib diisi.',
            'harga_asli.min'     => 'Harga asli harus lebih dari Rp 0.',
            'harga.required'     => 'Harga diskon wajib diisi (boleh Rp 0 untuk donasi).',
            'harga.lt'           => 'Harga Lastbite harus lebih hemat dari harga asli.',
            'stok.min'           => 'Jumlah stok minimal 1.',
            'waktu_selesai.date_format' => 'Format jam batas pengambilan tidak valid.',
            'foto.image'         => 'File harus berupa gambar.',
            'foto.max'           => 'Ukuran foto maksimal 5 MB.',
        ]);

        $terbit = $request->boolean('terbit');

        // Foto lama hanya boleh dipakai kalau memang milik mitra ini (dipakai fitur template)
        $gambarLama = null;
        if (! empty($data['gambar_lama'])) {
            $milikSendiri = DB::table('produks')
                ->where('id_mitra', $mitra->id_mitra)
                ->where('gambar', $data['gambar_lama'])
                ->exists();
            if ($milikSendiri) {
                $gambarLama = $data['gambar_lama'];
            }
        }

        if ($terbit) {
            if (! $request->hasFile('foto') && ! $gambarLama) {
                throw ValidationException::withMessages(['foto' => ['Foto makanan wajib diunggah.']]);
            }

            $batas = Carbon::today('Asia/Jakarta')->setTimeFromTimeString($data['waktu_selesai']);
            if ($batas->lessThanOrEqualTo(now('Asia/Jakarta'))) {
                throw ValidationException::withMessages([
                    'waktu_selesai' => ['Batas pengambilan harus lebih lambat dari jam sekarang.'],
                ]);
            }
        }

        $gambar = $gambarLama;
        if ($request->hasFile('foto')) {
            $gambar = $request->file('foto')->store('produk', 'public');
        }

        $id = DB::table('produks')->insertGetId([
            'id_mitra'      => $mitra->id_mitra,
            'nama'          => trim($data['nama']),
            'kategori'      => $data['kategori'],
            'gambar'        => $gambar,
            'harga'         => (int) $data['harga'],
            'harga_asli'    => (int) $data['harga_asli'],
            'satuan'        => '/paket',
            'stok'          => (int) $data['stok'],
            'waktu_mulai'   => now('Asia/Jakarta')->format('H:i:s'),
            'waktu_selesai' => $data['waktu_selesai'] . ':00',
            'aktif'         => $terbit ? 1 : 0,
            'created_at'    => now(),
            'updated_at'    => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => $terbit ? 'Produk berhasil diterbitkan.' : 'Draf toko tersimpan.',
            'data'    => ['id' => $id, 'aktif' => $terbit],
        ], 201);
    }

    /** POST /api/mitra/produk/template : produk terakhir mitra, untuk fitur "Salin dari" */
    public function template(Request $request)
    {
        $mitra = $this->mitraDariRequest($request);

        if (! $mitra) {
            return response()->json(['success' => false, 'message' => 'Data mitra tidak ditemukan.'], 404);
        }

        $p = DB::table('produks')->where('id_mitra', $mitra->id_mitra)->orderByDesc('id')->first();

        if (! $p) {
            return response()->json(['success' => true, 'data' => null]);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'nama'       => $p->nama,
                'kategori'   => $p->kategori,
                'harga_asli' => $p->harga_asli,
                'harga'      => $p->harga,
                'stok'       => $p->stok,
                'gambar'     => $p->gambar,
                'gambar_url' => $p->gambar ? url('storage/' . $p->gambar) : null,
            ],
        ]);
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