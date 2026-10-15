<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Mitra;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Schema;

class MitraVerifikasiController extends Controller
{
    public function setujui($id)
    {
        Mitra::where('id_mitra', $id)->update(['status_verifikasi' => 'disetujui']);

        return redirect()->route('admin.dashboard')->with('status', 'Pendaftaran mitra disetujui.');
    }

    public function tolak(Request $request, $id)
    {
        $request->validate(['alasan' => 'required|string|max:255']);

        $data = ['status_verifikasi' => 'ditolak'];
        if (Schema::hasColumn('mitra', 'alasan_penolakan')) {
            $data['alasan_penolakan'] = $request->alasan;
        }

        Mitra::where('id_mitra', $id)->update($data);

        return redirect()->route('admin.dashboard')->with('status', 'Pendaftaran mitra ditolak.');
    }
}