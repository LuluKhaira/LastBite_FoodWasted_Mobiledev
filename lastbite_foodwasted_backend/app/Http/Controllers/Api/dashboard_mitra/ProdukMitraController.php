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

        // Auto-sinkronisasi produk kadaluarsa milik mitra ini secara realtime
        $now = now('Asia/Jakarta');
        $activeProducts = DB::table('produks')
            ->where('id_mitra', $mitra->id_mitra)
            ->where('tipe', Produk::TIPE_DIMAKAN)
            ->where('aktif', 1)
            ->get();

        foreach ($activeProducts as $ap) {
            $isExpired = false;
            if (!empty($ap->kadaluarsa)) {
                $exp = \Illuminate\Support\Carbon::parse($ap->kadaluarsa, 'Asia/Jakarta');
                if ($exp->lessThanOrEqualTo($now)) {
                    $isExpired = true;
                }
            }
            if (!empty($ap->waktu_selesai)) {
                try {
                    $jamBatas = \Illuminate\Support\Carbon::today('Asia/Jakarta')->setTimeFromTimeString($ap->waktu_selesai);
                    if ($jamBatas->lessThanOrEqualTo($now)) {
                        $isExpired = true;
                    }
                } catch (\Throwable $e) {}
            }

            if ($isExpired) {
                $stokSisa = (int) ($ap->stok ?? 0);
                $bersedia = (bool) ($ap->bersedia_dialihkan ?? false);
                $newStatus = Produk::STATUS_PENGALIHAN_TIDAK;
                if ($bersedia && $stokSisa > 0) {
                    $newStatus = Produk::STATUS_PENGALIHAN_MENUNGGU;
                } elseif ($stokSisa <= 0) {
                    $newStatus = Produk::STATUS_PENGALIHAN_SELESAI;
                }

                DB::table('produks')->where('id', $ap->id)->update([
                    'aktif'             => 0,
                    'status_pengalihan' => $newStatus,
                    'dialihkan_pada'    => $now,
                    'updated_at'        => now(),
                ]);
            }
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

            $isDraf = (bool) ($p->draf ?? false);
            $statusPengalihan = $p->status_pengalihan ?? Produk::STATUS_PENGALIHAN_TIDAK;
            $statusUI = 'tayang';
            if ($isDraf) {
                $statusUI = 'draf';
            } elseif ($statusPengalihan === Produk::STATUS_PENGALIHAN_MENUNGGU) {
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
                'skema_harga'                => $p->skema_harga ?? 'diskon',
                'is_sedekah'                 => ($p->skema_harga === 'sedekah') || ((int)$p->harga === 0),
                'harga'                      => (int) $p->harga,
                'harga_asli'                 => (int) $p->harga_asli,
                'stok'                       => $stok,
                'kuota'                      => (int) $p->kuota,
                'hari'                       => 'Hari ini',
                'jam'                        => $p->waktu_selesai ? date('H:i', strtotime($p->waktu_selesai)) : '-',
                'waktu_mulai'                => $p->waktu_mulai ? substr($p->waktu_mulai, 0, 5) : '00:00',
                'waktu_selesai'              => $p->waktu_selesai ? substr($p->waktu_selesai, 0, 5) : '00:00',
                'status'                     => $statusUI,
                'aktif'                      => $p->aktif == 1,
                'draf'                       => $isDraf,
                'image_url'                  => $img,
                'gambar'                     => $img,
                // Kolom fitur pengalihan
                'bersedia_dialihkan'         => (bool) ($p->bersedia_dialihkan ?? false),
                'target_kategori_pengalihan' => $p->target_kategori_pengalihan,
                'perkiraan_berat_per_paket'  => $perkiraanBerat,
                'status_pengalihan'          => $statusPengalihan,
                'berat_aktual'               => (float) ($p->berat_aktual ?? 0),
                'berat_sisa_kg'              => (float) ($p->berat_aktual ?? 0),
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
            'berat_aktual'    => 'required_if:aksi,alihkan|nullable|numeric|min:1',
            'target_kategori' => 'required_if:aksi,alihkan|nullable|string',
            'catatan'         => 'nullable|string|max:500',
        ], [
            'aksi.in'                    => 'Aksi harus berupa alihkan atau buang.',
            'berat_aktual.required_if'   => 'Berat aktual wajib diisi saat menyetujui pengalihan.',
            'berat_aktual.min'           => 'Berat aktual sisa produk minimal 1 kg.',
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

        // Validasi harga per kg dari tabel kategori admin sebagai harga MAKSIMAL
        $maxHarga = (int) ($kategori->harga_per_kg ?? 0);
        if ($maxHarga <= 0) {
            return response()->json([
                'success' => false,
                'message' => 'Kategori "' . $kategori->nama . '" belum memiliki konfigurasi harga per kilogram maksimal dari admin. Harap hubungi admin.',
            ], 422);
        }

        // Tentukan harga per kg (opsional, min 0, max harga_per_kg kategori tujuan; bila kosong pakai harga kategori)
        if ($request->has('harga_per_kg') && $request->harga_per_kg !== null && $request->harga_per_kg !== '') {
            $hargaInput = (int) $request->harga_per_kg;
            if ($hargaInput < 0) {
                return response()->json([
                    'success' => false,
                    'message' => 'Harga per kg minimal Rp 0 (gratis/sedekah).',
                ], 422);
            }
            if ($hargaInput > $maxHarga) {
                return response()->json([
                    'success' => false,
                    'message' => 'Harga per kg tidak boleh melebihi harga maksimal kategori "' . $kategori->nama . '" (Rp ' . number_format($maxHarga, 0, ',', '.') . '/kg).',
                ], 422);
            }
            $hargaFinal = $hargaInput;
        } else {
            $hargaFinal = $maxHarga;
        }

        $beratAktual = (float) $request->berat_aktual;
        if ($beratAktual <= 0) {
            return response()->json([
                'success' => false,
                'message' => 'Berat aktual sisa produk harus lebih dari 0 kg.',
            ], 422);
        }

        $surplus = null;
        DB::transaction(function () use ($produk, $kategori, $beratAktual, $hargaFinal, $request, &$surplus) {
            $surplus = $produk->konfirmasiPengalihan($kategori, $beratAktual, $hargaFinal, $request->catatan);
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

    // 3. Untuk mengubah status aktif/nonaktif dan aktivasi draf
    public function updateAktif(Request $request)
    {
        $request->validate([
            'id'    => 'required|integer',
            'aktif' => 'required|boolean',
        ]);

        $produk = DB::table('produks')->where('id', $request->id)->first();
        if (!$produk) {
            return response()->json(['ok' => false, 'message' => 'Produk tidak ditemukan.'], 404);
        }

        $aktifTarget = $request->boolean('aktif');

        // Jika mengaktifkan produk yang masih berstatus draf: lakukan validasi kelayakan tayang
        if ($aktifTarget && ($produk->draf ?? false)) {
            // 1. Validasi foto wajib ada
            if (empty($produk->gambar)) {
                return response()->json([
                    'ok'      => false,
                    'message' => 'Foto makanan wajib diunggah sebelum produk dapat ditayangkan.',
                ], 422);
            }

            // 2. Untuk tipe dimakan, waktu kadaluarsa harus di masa depan
            if ($produk->tipe === Produk::TIPE_DIMAKAN) {
                if (empty($produk->kadaluarsa)) {
                    return response()->json([
                        'ok'      => false,
                        'message' => 'Tanggal dan jam kedaluwarsa wajib diisi sebelum produk dapat ditayangkan.',
                    ], 422);
                }

                $kadaluarsa = \Illuminate\Support\Carbon::parse($produk->kadaluarsa, 'Asia/Jakarta');
                if ($kadaluarsa->lessThanOrEqualTo(now('Asia/Jakarta'))) {
                    return response()->json([
                        'ok'      => false,
                        'message' => 'Waktu kedaluwarsa sudah lewat. Perbarui tanggal dan jam kedaluwarsa terlebih dahulu.',
                    ], 422);
                }
            }

            // 3. Batas jam pengambilan (waktu_selesai) hari ini belum lewat
            if (!empty($produk->waktu_selesai)) {
                try {
                    $jamBatas = \Illuminate\Support\Carbon::today('Asia/Jakarta')->setTimeFromTimeString($produk->waktu_selesai);
                    if ($jamBatas->lessThanOrEqualTo(now('Asia/Jakarta'))) {
                        return response()->json([
                            'ok'      => false,
                            'message' => 'Batas jam pengambilan hari ini (' . substr($produk->waktu_selesai, 0, 5) . ' WIB) sudah lewat. Perbarui jam pengambilan terlebih dahulu.',
                        ], 422);
                    }
                } catch (\Throwable $e) {}
            }

            // Lolos semua validasi: set draf = false dan aktif = 1
            DB::table('produks')
                ->where('id', $produk->id)
                ->update([
                    'aktif'      => 1,
                    'draf'       => 0,
                    'updated_at' => now(),
                ]);

            return response()->json([
                'ok'      => true,
                'message' => 'Produk berhasil ditayangkan!',
            ]);
        }

        // Pengubahan status aktif biasa (bukan aktivasi draf)
        DB::table('produks')
            ->where('id', $produk->id)
            ->update([
                'aktif'      => $aktifTarget ? 1 : 0,
                'updated_at' => now(),
            ]);

        return response()->json([
            'ok'      => true,
            'message' => $aktifTarget ? 'Produk berhasil diaktifkan' : 'Produk berhasil dinonaktifkan',
        ]);
    }
}
