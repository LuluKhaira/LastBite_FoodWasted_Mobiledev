<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AturanHarga;
use Illuminate\Http\Request;

class AturanHargaController extends Controller
{
    public function index()
    {
        return view('pages.admin.aturan', ['aturan' => AturanHarga::aktif()]);
    }

    public function simpan(Request $r)
    {
        $data = $r->validate([
            'max_diskon'    => 'required|integer|min:1|max:100',
            'min_harga'     => 'required|integer|min:0',
            'biaya_layanan' => 'required|integer|min:0',
        ]);

        AturanHarga::aktif()->update($data);

        return back()->with('success', 'Pengaturan berhasil disimpan.');
    }
}