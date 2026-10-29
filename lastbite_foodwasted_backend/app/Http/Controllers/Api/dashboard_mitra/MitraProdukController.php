<?php

namespace App\Http\Controllers\Api\dashboard_mitra;

use App\Http\Controllers\Controller;
use App\Models\Kategori;
use App\Models\Mitra;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class MitraProdukController extends Controller
{
    // Cadangan bila tabel kategoris belum ada. Sumber utama: tabel kategoris (diatur admin).
    private const KATEGORI = [
        // Kategori Manusia
        'Roti & Pastry', 'Roti Tawar', 'Siap Santap', 'Sayur & Buah', 'Bahan & Olahan Dapur',
        // Kategori Pakan/Kompos
        'Bahan Kompos & Pupuk', 'Pakan Ternak & Ikan', 'Ampas Kelapa & Kopi', 'Limbah Organik'
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

        // VALIDASI DIPERBARUI (Menambahkan skema_harga, deskripsi, tipe, kuota, waktu_mulai)
        $skemaHarga = $request->input('skema_harga');
        if (empty($skemaHarga)) {
            $skemaHarga = ((int) $request->input('harga', 1) === 0) ? 'sedekah' : 'diskon';
        }
        $isSedekah = $skemaHarga === 'sedekah';

        $hargaRule = $isSedekah
            ? 'nullable|integer|in:0'
            : 'required|integer|min:1|lt:harga_asli';

        $data = $request->validate([
            'phone'         => 'required|string',
            'nama'          => 'required|string|max:255',
            'deskripsi'     => 'nullable|string',
            'tipe'          => 'required|string|in:dimakan,kompos',
            'kategori'      => ['required', Rule::in($this->namaKategori())],
            'skema_harga'   => 'nullable|string|in:diskon,sedekah',
            'harga_asli'    => 'required|integer|min:1|max:99999999',
            'harga'         => $hargaRule,
            'stok'          => 'required|integer|min:1|max:999',
            'kuota'         => 'required|integer|min:1|max:999',
            'waktu_mulai'   => 'required|date_format:H:i',
            'waktu_selesai' => 'required|date_format:H:i',
            'kadaluarsa'    => 'required_if:tipe,dimakan|nullable|date',
            'terbit'        => 'required|boolean',
            'foto'          => 'nullable|image|max:5120',
            'gambar_lama'   => 'nullable|string|max:255',
            'bersedia_dialihkan'        => 'nullable|boolean',
            'target_kategori_pengalihan' => 'nullable|string|max:255',
            'perkiraan_berat_per_paket'  => 'nullable|numeric|min:0',
        ], [
            'nama.required'      => 'Nama produk wajib diisi.',
            'kategori.required'  => 'Pilih kategori produk.',
            'kategori.in'        => 'Kategori tidak valid.',
            'harga_asli.required' => 'Harga asli wajib diisi.',
            'harga_asli.min'     => 'Harga asli harus lebih dari Rp 0.',
            'harga.required'     => 'Harga diskon wajib diisi.',
            'harga.min'          => 'Harga diskon harus lebih besar dari Rp 0.',
            'harga.lt'           => 'Harga Lastbite harus lebih hemat dari harga normal toko.',
            'harga.in'           => 'Untuk produk Sedekah, harga produk harus Rp 0.',
            'stok.min'           => 'Jumlah stok minimal 1.',
            'waktu_selesai.date_format' => 'Format jam batas pengambilan tidak valid.',
            'kadaluarsa.required' => 'Tanggal dan jam kadaluarsa wajib diisi.',
            'kadaluarsa.date'    => 'Format tanggal kadaluarsa tidak valid.',
            'foto.image'         => 'File harus berupa gambar.',
            'foto.max'           => 'Ukuran foto maksimal 5 MB.',
        ]);

        $terbit = $request->boolean('terbit');

        // Input dari Flutter dianggap waktu WIB bila tidak membawa offset zona waktu
        $kadaluarsa = ! empty($data['kadaluarsa'])
            ? Carbon::parse($data['kadaluarsa'], 'Asia/Jakarta')->setTimezone('Asia/Jakarta')
            : null;

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
            // Foto wajib ada jika diterbitkan (kecuali pakai gambar lama)
            if (! $request->hasFile('foto') && ! $gambarLama) {
                throw ValidationException::withMessages(['foto' => ['Foto makanan wajib diunggah.']]);
            }

            // Kadaluarsa harus di masa depan
            if ($kadaluarsa && $kadaluarsa->lessThanOrEqualTo(now('Asia/Jakarta'))) {
                throw ValidationException::withMessages([
                    'kadaluarsa' => ['Waktu kadaluarsa harus setelah sekarang.'],
                ]);
            }

            // Cek jam batas pengambilan
            $batas = Carbon::today('Asia/Jakarta')->setTimeFromTimeString($data['waktu_selesai']);
            if ($batas->lessThanOrEqualTo(now('Asia/Jakarta'))) {
                throw ValidationException::withMessages([
                    'waktu_selesai' => ['Batas pengambilan harus lebih lambat dari jam sekarang.'],
                ]);
            }

            // Batas pengambilan tidak boleh melewati jam tutup toko (pengaturan Jam Buka)
            $this->periksaJamOperasional($mitra, $data['waktu_selesai']);
        }

        $gambar = $gambarLama;
        if ($request->hasFile('foto')) {
            $gambar = $request->file('foto')->store('produk', 'public');
        }

        $hargaFinal = $isSedekah ? 0 : (int) $data['harga'];
        $kategoriAsli = $request->input('kategori_asli')
            ?? ($data['tipe'] === 'dimakan' ? 'Konsumsi Manusia' : 'Pakan / Kompos');

        // SIMPAN KE DATABASE
        $id = DB::table('produks')->insertGetId([
            'id_mitra'      => $mitra->id_mitra,
            'nama'          => trim($data['nama']),
            'deskripsi'     => $data['deskripsi'] ?? null,
            'tipe'          => $data['tipe'],
            'kategori'      => $data['kategori'],
            'kategori_asli' => $kategoriAsli,
            'skema_harga'   => $skemaHarga,
            'gambar'        => $gambar,
            'harga'         => $hargaFinal,
            'harga_asli'    => (int) $data['harga_asli'],
            'satuan'        => '/paket',
            'stok'          => (int) $data['stok'],
            'kuota'         => (int) $data['kuota'],
            'waktu_mulai'   => $data['waktu_mulai'] . ':00',
            'waktu_selesai' => $data['waktu_selesai'] . ':00',
            'kadaluarsa'    => $kadaluarsa?->format('Y-m-d H:i:s'),
            // Konfigurasi pengalihan produk (hanya untuk produk konsumsi manusia)
            'bersedia_dialihkan'        => $data['tipe'] === 'dimakan' ? $request->boolean('bersedia_dialihkan') : false,
            'target_kategori_pengalihan' => ($data['tipe'] === 'dimakan' && $request->boolean('bersedia_dialihkan'))
                ? ($data['target_kategori_pengalihan'] ?? null)
                : null,
            'perkiraan_berat_per_paket'  => ($data['tipe'] === 'dimakan' && $request->boolean('bersedia_dialihkan'))
                ? (float) ($data['perkiraan_berat_per_paket'] ?? 0)
                : null,
            'status_pengalihan'         => ($data['tipe'] === 'dimakan' && $request->boolean('bersedia_dialihkan'))
                ? \App\Models\Produk::STATUS_PENGALIHAN_AKAN
                : \App\Models\Produk::STATUS_PENGALIHAN_TIDAK,
            'aktif'         => $terbit ? 1 : 0,
            'draf'          => ! $terbit,
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

        $path = $p->gambar ? ltrim($p->gambar, '/') : null;
        if ($path && !str_starts_with($path, 'http://') && !str_starts_with($path, 'https://')) {
            if (str_starts_with($path, 'storage/')) {
                $path = substr($path, 8);
            }
            $imgUrl = request()->root() . '/api/foto/' . $path;
        } else {
            $imgUrl = $path;
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
                'gambar_url' => $imgUrl,
            ],
        ]);
    }

    /**
     * Tolak bila batas pengambilan melewati jam tutup toko hari ini,
     * atau toko diatur libur hari ini. Belum diatur = tidak dibatasi.
     */
    private function periksaJamOperasional(Mitra $mitra, string $waktuSelesai): void
    {
        $jam = $mitra->jam_operasional;
        if (is_string($jam)) {
            $jam = json_decode($jam, true);
        }
        if (! is_array($jam) || empty($jam)) {
            return;
        }

        $namaHari = [1 => 'Senin', 2 => 'Selasa', 3 => 'Rabu', 4 => 'Kamis', 5 => 'Jumat', 6 => 'Sabtu', 7 => 'Minggu'];
        $hariIni  = now('Asia/Jakarta')->dayOfWeekIso;
        $atur     = collect($jam)->firstWhere('hari', $hariIni);

        if (! $atur) {
            return;
        }

        if (empty($atur['buka'])) {
            throw ValidationException::withMessages([
                'waktu_selesai' => ["Toko kamu diatur libur hari {$namaHari[$hariIni]}. Ubah di Jam Buka kalau ingin menerbitkan produk hari ini."],
            ]);
        }

        $selesai = substr($waktuSelesai, 0, 5);
        if ($selesai > $atur['tutup']) {
            throw ValidationException::withMessages([
                'waktu_selesai' => ["Batas pengambilan ({$selesai}) melewati jam tutup toko ({$atur['tutup']}). Ubah batas pengambilan atau atur ulang Jam Buka."],
            ]);
        }
    }

    /** Nama kategori aktif dari tabel kategoris (cadangan: daftar tetap di atas). */
    private function namaKategori(): array
    {
        try {
            $nama = Kategori::aktif()->pluck('nama')->all();
        } catch (\Throwable $e) {
            $nama = [];
        }

        return $nama ?: self::KATEGORI;
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