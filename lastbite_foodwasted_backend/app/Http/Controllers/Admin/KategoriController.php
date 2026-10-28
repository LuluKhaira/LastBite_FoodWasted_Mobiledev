<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Kategori;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class KategoriController extends Controller
{
    // Nama view. Sesuaikan bila file kategori.blade.php kamu simpan di folder lain.
    private const VIEW = 'pages.admin.kategori';

    public function index()
    {
        $kategoris = Kategori::with('tujuan')
            ->orderByRaw("FIELD(tipe, 'dimakan', 'pakan', 'kompos')")
            ->orderBy('urutan')
            ->orderBy('nama')
            ->get();

        // Jumlah produk per kategori (tanpa relasi, produks.kategori berisi nama)
        $jumlahProduk = DB::table('produks')
            ->select('kategori', DB::raw('COUNT(*) as total'))
            ->groupBy('kategori')
            ->pluck('total', 'kategori');

        $opsiTujuan = Kategori::aktif()
            ->whereIn('tipe', ['pakan', 'kompos'])
            ->orderBy('urutan')->orderBy('nama')
            ->get();

        return view(self::VIEW, compact('kategoris', 'jumlahProduk', 'opsiTujuan'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nama'      => ['required', 'string', 'max:100', 'unique:kategoris,nama'],
            'tipe'      => ['required', Rule::in(Kategori::TIPE)],
            'tujuan_id' => ['nullable', 'integer', Rule::exists('kategoris', 'id')->whereIn('tipe', ['pakan', 'kompos'])],
        ], [
            'nama.required' => 'Nama kategori wajib diisi.',
            'nama.unique'   => 'Nama kategori sudah dipakai.',
            'tipe.required' => 'Pilih tipe kategori.',
            'tujuan_id.exists' => 'Tujuan pengalihan harus kategori pakan atau kompos.',
        ]);

        Kategori::create([
            'nama'      => trim($data['nama']),
            'tipe'      => $data['tipe'],
            'tujuan_id' => $data['tipe'] === 'dimakan' ? ($data['tujuan_id'] ?? null) : null,
            'urutan'    => ((int) Kategori::max('urutan')) + 1,
            'aktif'     => true,
        ]);

        return back()->with('success', 'Kategori berhasil ditambahkan.');
    }

    public function update(Request $request, $id)
    {
        $kategori = Kategori::findOrFail($id);

        $data = $request->validate([
            'nama'      => ['required', 'string', 'max:100', Rule::unique('kategoris', 'nama')->ignore($kategori->id)],
            'urutan'    => ['nullable', 'integer', 'min:0', 'max:999'],
            'tujuan_id' => ['nullable', 'integer', Rule::exists('kategoris', 'id')->whereIn('tipe', ['pakan', 'kompos'])],
        ], [
            'nama.unique'      => 'Nama kategori sudah dipakai.',
            'tujuan_id.exists' => 'Tujuan pengalihan harus kategori pakan atau kompos.',
        ]);

        $lama = $kategori->nama;
        $baru = trim($data['nama']);

        DB::transaction(function () use ($kategori, $data, $lama, $baru) {
            // Nama berubah: samakan semua produk yang memakai nama lama
            if ($lama !== $baru) {
                foreach (['kategori', 'kategori_asli', 'target_kategori_pengalihan'] as $kolom) {
                    DB::table('produks')->where($kolom, $lama)->update([$kolom => $baru]);
                }
            }

            $kategori->update([
                'nama'      => $baru,
                'urutan'    => $data['urutan'] ?? $kategori->urutan,
                'tujuan_id' => $kategori->tipe === 'dimakan' ? ($data['tujuan_id'] ?? null) : null,
            ]);
        });

        return back()->with('success', 'Kategori berhasil diperbarui.');
    }

    public function toggle($id)
    {
        $kategori = Kategori::findOrFail($id);
        $kategori->update(['aktif' => ! $kategori->aktif]);

        return back()->with('success', $kategori->aktif
            ? "Kategori {$kategori->nama} diaktifkan."
            : "Kategori {$kategori->nama} dinonaktifkan. Produk lama tetap aman.");
    }
}