<?php

namespace App\Http\Controllers\Api\dashboard_mitra;

use App\Http\Controllers\Controller;
use App\Models\Kategori;
use App\Models\Produk;
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
            $path = $p->gambar ? ltrim($p->gambar, '/') : null;
            if ($path && !str_starts_with($path, 'http://') && !str_starts_with($path, 'https://')) {
                if (str_starts_with($path, 'storage/')) {
                    $path = substr($path, 8);
                }
                $img = request()->root() . '/api/foto/' . $path;
            } else {
                $img = $path;
            }

            $stok = (int) $p->stok;
            $perkiraanBerat = (float) ($p->perkiraan_berat_per_paket ?? 0);
            $totalEst = round($stok * $perkiraanBerat, 2);

            $statusPengalihan = $p->status_pengalihan ?? Produk::STATUS_PENGALIHAN_TIDAK;
            $statusUI = 'tayang';
            if ($statusPengalihan === Produk::STATUS_PENGALIHAN_MENUNGGU) {
                $statusUI = 'menunggu_konfirmasi';
            } elseif ($p->aktif != 1 || $stok <= 0) {
                $statusUI = 'habis';
            }

            return [
                'id'                         => $p->id,
                'nama'                       => $p->nama,
                'deskripsi'                  => $p->deskripsi ?? 'Kombinasi produk surplus berkualitas',
                'tipe'                       => $p->tipe,
                'kategori'                   => $p->kategori,
                'kategori_asli'              => $p->kategori_asli,
                'satuan'                     => $p->satuan ?? '/paket',
                'kadaluarsa'                 => $p->kadaluarsa,
                'dialihkan_pada'             => $p->dialihkan_pada,
                'harga'                      => (int) $p->harga,
                'harga_asli'                 => (int) $p->harga_asli,
                'stok'                       => $stok,
                'kuota'                      => (int) $p->kuota,
                'hari'                       => 'Hari ini',
                'jam'                        => $p->waktu_selesai ? date('H:i', strtotime($p->waktu_selesai)) : '-',
                'status'                     => $statusUI,
                'aktif'                      => $p->aktif == 1,
                'image_url'                  => $img,
                'gambar'                     => $img,
                // Kolom fitur pengalihan
                'bersedia_dialihkan'         => (bool) ($p->bersedia_dialihkan ?? false),
                'target_kategori_pengalihan' => $p->target_kategori_pengalihan,
                'perkiraan_berat_per_paket'  => $perkiraanBerat,
                'status_pengalihan'          => $statusPengalihan,
                'berat_aktual'               => (float) ($p->berat_aktual ?? 0),
                'produk_surplus_id'          => $p->produk_surplus_id,
                'dikonfirmasi_pada'          => $p->dikonfirmasi_pada,
                'catatan_pengalihan'         => $p->catatan_pengalihan,
                'total_perkiraan_berat'      => $totalEst,
            ];
        });

        return response()->json([
            'success' => true,
            'data'    => $data,
        ]);
    }

    /**
     * Mengambil daftar produk milik mitra yang berstatus 'menunggu_konfirmasi'
     */
    public function menungguKonfirmasi(Request $request)
    {
        $phone = $request->phone;
        $mitra = DB::table('mitras')->where('no_whatsapp', $phone)->first();

        if (!$mitra) {
            return response()->json(['success' => false, 'message' => 'Mitra tidak ditemukan'], 404);
        }

        $items = Produk::where('id_mitra', $mitra->id_mitra)
            ->where('status_pengalihan', Produk::STATUS_PENGALIHAN_MENUNGGU)
            ->orderByDesc('id')
            ->get()
            ->map(fn ($p) => $p->toApi());

        return response()->json([
            'success' => true,
            'data'    => $items,
        ]);
    }

    /**
     * Konfirmasi pengalihan produk oleh mitra:
     * - aksi: 'alihkan' -> buat produk surplus pakan/kompos, catat berat aktual, harga per kg dari admin
     * - aksi: 'buang'   -> produk ditandai tidak layak dan dibuang, tanpa produk surplus
     */
    public function konfirmasiPengalihan(Request $request)
    {
        $request->validate([
            'phone'           => 'required|string',
            'id'              => 'required|integer',
            'aksi'            => 'required|string|in:alihkan,buang',
            'berat_aktual'    => 'required_if:aksi,alihkan|nullable|numeric|min:0.01',
            'target_kategori' => 'required_if:aksi,alihkan|nullable|string',
            'catatan'         => 'nullable|string|max:500',
        ], [
            'aksi.in'                    => 'Aksi harus berupa alihkan atau buang.',
            'berat_aktual.required_if'   => 'Berat aktual wajib diisi saat menyetujui pengalihan.',
            'berat_aktual.min'           => 'Berat aktual harus berupa angka positif lebih dari 0 kg.',
            'target_kategori.required_if'=> 'Kategori tujuan pengalihan wajib dipilih.',
        ]);

        $mitra = DB::table('mitras')->where('no_whatsapp', $request->phone)->first();
        if (!$mitra) {
            return response()->json(['success' => false, 'message' => 'Data mitra tidak ditemukan.'], 404);
        }

        $produk = Produk::where('id', $request->id)
            ->where('id_mitra', $mitra->id_mitra)
            ->first();

        if (!$produk) {
            return response()->json(['success' => false, 'message' => 'Produk tidak ditemukan atau bukan milik toko Anda.'], 404);
        }

        // Cek status agar idempotent & tidak diproses ganda
        if ($produk->status_pengalihan !== Produk::STATUS_PENGALIHAN_MENUNGGU) {
            return response()->json([
                'success' => false,
                'message' => 'Produk ini tidak dalam status menunggu konfirmasi (status saat ini: ' . $produk->status_pengalihan . ').',
            ], 422);
        }

        // KASUS: MITRA MEMILIH BUANG / TIDAK LAYAK
        if ($request->aksi === 'buang') {
            DB::transaction(function () use ($produk, $request) {
                $produk->update([
                    'aktif'              => false,
                    'status_pengalihan'  => Produk::STATUS_PENGALIHAN_DIBUANG,
                    'dikonfirmasi_pada'  => now('Asia/Jakarta'),
                    'catatan_pengalihan' => $request->catatan ?? 'Produk tidak layak dialihkan (dibuang oleh mitra)',
                ]);
            });

            return response()->json([
                'success' => true,
                'message' => 'Sisa produk ditandai sebagai tidak layak dan dibuang. Produk tidak diterbitkan ke Pakan/Kompos.',
                'data'    => $produk->fresh()->toApi(),
            ]);
        }

        // KASUS: MITRA MEMILIH ALIH KAN
        $targetKategoriNama = trim($request->target_kategori);
        $kategori = Kategori::where('nama', $targetKategoriNama)
            ->where('aktif', true)
            ->whereIn('tipe', ['pakan', 'kompos'])
            ->first();

        if (!$kategori) {
            return response()->json([
                'success' => false,
                'message' => 'Kategori tujuan "' . $targetKategoriNama . '" tidak ditemukan atau sedang nonaktif.',
            ], 422);
        }

        // Validasi harga per kg dari tabel kategori admin
        if (!$kategori->harga_per_kg || $kategori->harga_per_kg <= 0) {
            return response()->json([
                'success' => false,
                'message' => 'Kategori "' . $kategori->nama . '" belum memiliki harga per kilogram yang valid dari admin (Rp 0). Harap hubungi admin untuk melengkapi konfigurasi harga.',
            ], 422);
        }

        $beratAktual = (float) $request->berat_aktual;
        if ($beratAktual <= 0) {
            return response()->json([
                'success' => false,
                'message' => 'Berat aktual sisa produk harus lebih dari 0 kg.',
            ], 422);
        }

        $surplus = null;
        DB::transaction(function () use ($produk, $mitra, $kategori, $beratAktual, $request, &$surplus) {
            // 1. Buat produk surplus baru di kategori Pakan/Kompos dalam satuan kg
            $surplus = Produk::create([
                'id_mitra'                   => $mitra->id_mitra,
                'nama'                       => 'Surplus ' . $kategori->nama . ' - ' . $produk->nama,
                'deskripsi'                  => 'Bahan surplus dialihkan dari ' . $produk->nama . ' (' . $beratAktual . ' kg). ' . ($request->catatan ?? 'Kondisi telah diperiksa mitra.'),
                'tipe'                       => $kategori->tipe,
                'kategori'                   => $kategori->nama,
                'kategori_asli'              => $produk->kategori,
                'gambar'                     => $produk->gambar,
                'harga'                      => (int) $kategori->harga_per_kg,
                'harga_asli'                 => (int) $kategori->harga_per_kg,
                'satuan'                     => 'kg',
                'stok'                       => max(1, (int) ceil($beratAktual)),
                'kuota'                      => max(1, (int) ceil($beratAktual)),
                'berat_kg'                   => $beratAktual,
                'waktu_mulai'                => '00:00:00',
                'waktu_selesai'              => '23:59:00',
                'aktif'                      => true,
                'bersedia_dialihkan'         => false,
                'status_pengalihan'          => Produk::STATUS_PENGALIHAN_TIDAK,
                'created_at'                 => now(),
                'updated_at'                 => now(),
            ]);

            // 2. Perbarui produk asal: nonaktif dan ubah status menjadi dialihkan
            $produk->update([
                'aktif'                      => false,
                'status_pengalihan'          => Produk::STATUS_PENGALIHAN_DIALIHKAN,
                'berat_aktual'               => $beratAktual,
                'target_kategori_pengalihan' => $kategori->nama,
                'produk_surplus_id'          => $surplus->id,
                'dialihkan_pada'             => now('Asia/Jakarta'),
                'dikonfirmasi_pada'          => now('Asia/Jakarta'),
                'catatan_pengalihan'         => $request->catatan,
            ]);
        });

        return response()->json([
            'success' => true,
            'message' => 'Produk berhasil dialihkan ke ' . $kategori->nama . ' sebanyak ' . $beratAktual . ' kg seharga Rp ' . number_format($kategori->harga_per_kg, 0, ',', '.') . '/kg.',
            'data'    => [
                'produk_asal'    => $produk->fresh()->toApi(),
                'produk_surplus' => $surplus->fresh()->toApi(),
            ],
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
