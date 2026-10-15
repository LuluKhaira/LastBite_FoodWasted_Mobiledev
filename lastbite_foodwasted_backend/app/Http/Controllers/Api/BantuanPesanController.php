<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\BantuanPesan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
use Throwable;

class BantuanPesanController extends Controller
{
    public function index(Request $request)
    {
        $rows = BantuanPesan::query()
            ->where('user_id', $request->user()->id)
            ->orderBy('created_at')
            ->get();

        $data = $rows->map(function (BantuanPesan $row) {
            return [
                'id' => $row->id,
                'pesan' => $row->pesan,
                'balasan' => $row->balasan,
                'status' => $row->status,
                'waktu' => optional($row->created_at)->timezone('Asia/Jakarta')->format('d M Y, H:i'),
                'dibalas' => optional($row->dibalas_at)->timezone('Asia/Jakarta')->format('d M Y, H:i'),
            ];
        });

        return response()->json(['data' => $data]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'pesan' => ['required', 'string', 'min:5', 'max:1000'],
            'kanal' => ['nullable', 'in:whatsapp,live'],
        ]);

        $user = $request->user();
        $kanal = $validated['kanal'] ?? 'whatsapp';

        // Simpan pesan lebih dulu agar pertanyaan tidak hilang jika Fonnte bermasalah.
        $pesan = BantuanPesan::create([
            'user_id' => $user->id,
            'pesan' => trim($validated['pesan']),
            'kanal' => $kanal,
            'status' => 'tersimpan',
        ]);

        $token = config('services.fonnte.token');
        $target = config('services.fonnte.cs_target');

        if (blank($token) || blank($target)) {
            $pesan->update(['status' => 'gagal']);
            return response()->json([
                'message' => 'Pesan tersimpan, tetapi Fonnte belum dikonfigurasi. Periksa FONNTE_TOKEN dan FONNTE_CS_TARGET di .env.',
                'data' => ['id' => $pesan->id, 'status' => $pesan->status],
            ], 202);
        }

        $nama = $user->name ?? 'Pelanggan Lastbite';
        $telepon = $user->phone ?? '-';
        $isi = "BANTUAN LASTBITE\n"
            . "Nama: {$nama}\n"
            . "Nomor akun: {$telepon}\n"
            . "Kanal: {$kanal}\n\n"
            . "Pesan:\n{$pesan->pesan}\n\n"
            . "ID pesan: {$pesan->id}";

        try {
            $response = Http::timeout(20)
                ->withHeaders(['Authorization' => $token])
                ->asForm()
                ->post('https://api.fonnte.com/send', [
                    'target' => $target,
                    'message' => $isi,
                ]);

            $hasil = $response->json();
            $berhasil = $response->successful()
                && is_array($hasil)
                && filter_var($hasil['status'] ?? false, FILTER_VALIDATE_BOOLEAN);

            $pesan->update(['status' => $berhasil ? 'terkirim' : 'gagal']);

            return response()->json([
                'message' => $berhasil
                    ? 'Pesan berhasil diteruskan ke WhatsApp tim CS.'
                    : 'Pesan tersimpan, tetapi Fonnte belum berhasil meneruskannya ke WhatsApp CS.',
                'data' => [
                    'id' => $pesan->id,
                    'pesan' => $pesan->pesan,
                    'status' => $pesan->status,
                    'detail_fonnte' => $berhasil ? null : ($hasil['detail'] ?? 'Periksa token, nomor tujuan, dan perangkat Fonnte.'),
                ],
            ], 201);
        } catch (Throwable $e) {
            report($e);
            $pesan->update(['status' => 'gagal']);

            return response()->json([
                'message' => 'Pesan tersimpan di database, tetapi koneksi ke Fonnte gagal. Coba lagi beberapa saat lagi.',
                'data' => ['id' => $pesan->id, 'status' => $pesan->status],
            ], 202);
        }
    }
}
