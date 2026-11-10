<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Kategori;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class KategoriController extends Controller
{
    private const VIEW = 'pages.admin.kategori';

    public function index()
    {
        $kategoris = Kategori::with('tujuan')
            ->orderByRaw("FIELD(tipe, 'dimakan', 'pakan', 'kompos')")
            ->orderBy('urutan')
            ->orderBy('nama')
            ->get();

        // Jumlah produk per kategori
        $jumlahProdukById = DB::table('produks')
            ->select('kategori_id', DB::raw('COUNT(*) as total'))
            ->groupBy('kategori_id')
            ->pluck('total', 'kategori_id')
            ->all();

        $jumlahProdukByNama = DB::table('produks')
            ->select('kategori', DB::raw('COUNT(*) as total'))
            ->groupBy('kategori')
            ->pluck('total', 'kategori')
            ->all();

        $jumlahProduk = array_merge($jumlahProdukByNama, $jumlahProdukById);

        $opsiTujuan = Kategori::aktif()
            ->whereIn('tipe', ['pakan', 'kompos'])
            ->orderBy('urutan')->orderBy('nama')
            ->get();

        return view(self::VIEW, compact('kategoris', 'jumlahProduk', 'opsiTujuan'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nama'         => ['required', 'string', 'max:100', 'unique:kategoris,nama'],
            'tipe'         => ['required', Rule::in(Kategori::TIPE)],
            'tujuan_id'    => ['nullable', 'integer', Rule::exists('kategoris', 'id')->whereIn('tipe', ['pakan', 'kompos'])],
            'harga_per_kg' => ['nullable', 'integer', 'min:0', 'max:99999999'],
        ], [
            'nama.required'    => 'Nama kategori wajib diisi.',
            'nama.unique'      => 'Nama kategori sudah dipakai.',
            'tipe.required'    => 'Pilih tipe kategori.',
            'tujuan_id.exists' => 'Tujuan pengalihan harus kategori pakan atau kompos.',
            'harga_per_kg.min' => 'Harga per kg minimal Rp 0.',
        ]);

        $hargaPerKg = in_array($data['tipe'], ['pakan', 'kompos']) ? (int) ($request->harga_per_kg ?? 0) : 0;

        Kategori::create([
            'nama'         => trim($data['nama']),
            'tipe'         => $data['tipe'],
            'tujuan_id'    => $data['tipe'] === 'dimakan' ? ($data['tujuan_id'] ?? null) : null,
            'harga_per_kg' => $hargaPerKg,
            'urutan'       => ((int) Kategori::max('urutan')) + 1,
            'aktif'        => true,
        ]);

        return back()->with('success', 'Kategori berhasil ditambahkan.');
    }

    public function update(Request $request, $id)
    {
        $kategori = Kategori::findOrFail($id);

        $data = $request->validate([
            'nama'         => ['required', 'string', 'max:100', Rule::unique('kategoris', 'nama')->ignore($kategori->id)],
            'urutan'       => ['nullable', 'integer', 'min:0', 'max:999'],
            'tujuan_id'    => ['nullable', 'integer', Rule::exists('kategoris', 'id')->whereIn('tipe', ['pakan', 'kompos'])],
            'harga_per_kg' => ['nullable', 'integer', 'min:0', 'max:99999999'],
        ], [
            'nama.unique'      => 'Nama kategori sudah dipakai.',
            'tujuan_id.exists' => 'Tujuan pengalihan harus kategori pakan atau kompos.',
            'harga_per_kg.min' => 'Harga per kg minimal Rp 0.',
        ]);

        $lama = $kategori->nama;
        $baru = trim($data['nama']);
        $hargaPerKg = in_array($kategori->tipe, ['pakan', 'kompos'])
            ? (int) ($request->harga_per_kg ?? $kategori->harga_per_kg ?? 0)
            : 0;

        DB::transaction(function () use ($kategori, $data, $lama, $baru, $hargaPerKg) {
            $kategori->update([
                'nama'         => $baru,
                'urutan'       => $data['urutan'] ?? $kategori->urutan,
                'tujuan_id'    => $kategori->tipe === 'dimakan' ? ($data['tujuan_id'] ?? null) : null,
                'harga_per_kg' => $hargaPerKg,
            ]);

            // Tetap perbarui kolom teks lama dengan satu query UPDATE per kolom selama masa transisi
            if ($lama !== $baru) {
                DB::table('produks')->where('kategori_id', $kategori->id)->update(['kategori' => $baru]);
                DB::table('produks')->where('kategori_asli_id', $kategori->id)->update(['kategori_asli' => $baru]);
                DB::table('produks')->where('target_kategori_id', $kategori->id)->update(['target_kategori_pengalihan' => $baru]);
            }
        });

        return back()->with('success', 'Kategori berhasil diperbarui.');
    }

    public function destroy($id)
    {
        $kategori = Kategori::findOrFail($id);

        $terpakaiProduk = DB::table('produks')
            ->where('kategori_id', $kategori->id)
            ->orWhere('kategori_asli_id', $kategori->id)
            ->orWhere('target_kategori_id', $kategori->id)
            ->exists();

        if ($terpakaiProduk) {
            return back()->with('error', "Kategori \"{$kategori->nama}\" tidak dapat dihapus karena masih digunakan oleh produk.");
        }

        if (Kategori::where('tujuan_id', $kategori->id)->exists()) {
            return back()->with('error', "Kategori \"{$kategori->nama}\" tidak dapat dihapus karena masih dijadikan tujuan pengalihan oleh kategori lain.");
        }

        try {
            $kategori->delete();
            return back()->with('success', "Kategori \"{$kategori->nama}\" berhasil dihapus.");
        } catch (\Illuminate\Database\QueryException $e) {
            return back()->with('error', "Kategori \"{$kategori->nama}\" tidak dapat dihapus karena masih memiliki keterkaitan data.");
        }
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
