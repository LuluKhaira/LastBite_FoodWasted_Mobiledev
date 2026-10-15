<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Faq;
use Carbon\Carbon;
use Illuminate\Http\Request;

class FaqController extends Controller
{
    public function index(Request $request)
    {
        $request->validate([
            'q' => ['nullable', 'string', 'max:100'],
            'kategori' => ['nullable', 'string', 'max:100'],
        ]);

        $query = Faq::query()->where('aktif', true);

        if ($request->filled('q')) {
            $kata = trim($request->string('q')->toString());
            $query->where(function ($sub) use ($kata) {
                $sub->where('pertanyaan', 'like', "%{$kata}%")
                    ->orWhere('jawaban', 'like', "%{$kata}%")
                    ->orWhere('kategori', 'like', "%{$kata}%");
            });
        }

        if ($request->filled('kategori')) {
            $query->where('kategori', $request->input('kategori'));
        }

        $data = $query->orderBy('urutan')->get([
            'id', 'kategori', 'pertanyaan', 'jawaban', 'tip', 'urutan',
        ]);

        $kategori = Faq::query()
            ->where('aktif', true)
            ->select('kategori')
            ->distinct()
            ->orderBy('kategori')
            ->pluck('kategori')
            ->values();

        $jam = Carbon::now('Asia/Jakarta');
        $buka = $jam->format('H:i') >= '08:00' && $jam->format('H:i') < '22:00';

        return response()->json([
            'data' => $data,
            'kategori' => $kategori,
            'kontak' => [
                'email' => config('mail.from.address', 'bantuan@lastbite.id'),
                'telepon' => config('services.lastbite_support.phone', ''),
                'jam' => 'Setiap hari, 08.00–22.00 WIB',
                'buka' => $buka,
            ],
        ]);
    }
}
