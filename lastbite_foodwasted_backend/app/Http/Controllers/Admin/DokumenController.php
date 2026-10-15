<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Mitra;
use Illuminate\Support\Facades\Storage;

class DokumenController extends Controller
{
    // Menampilkan dokumen mitra (KTP, NPWP, sertifikat halal) hanya untuk admin yang login.
    // Dibaca langsung dari storage, jadi tidak perlu storage:link dan file tetap privat.
    public function show($id, string $field)
    {
        $mitra = Mitra::where('id_mitra', $id)->firstOrFail();
        $path = ltrim((string) $mitra->{$field}, '/');

        abort_if($path === '', 404);

        $candidates = [
            Storage::disk('local')->path($path),   // storage/app/private/...
            Storage::disk('public')->path($path),  // storage/app/public/...
            storage_path('app/' . $path),          // storage/app/...
        ];

        foreach ($candidates as $file) {
            if (is_file($file)) {
                return response()->file($file);
            }
        }

        abort(404);
    }
}