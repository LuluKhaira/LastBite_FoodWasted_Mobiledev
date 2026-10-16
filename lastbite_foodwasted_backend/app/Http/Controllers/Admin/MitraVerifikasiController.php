<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Mitra;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class MitraVerifikasiController extends Controller
{
    public function setujui($id)
    {
        $mitra = Mitra::where('id_mitra', $id)->firstOrFail();

        Mitra::where('id_mitra', $id)->update([
            'status_verifikasi' => 'disetujui',
            'alasan_penolakan' => null,
        ]);

        $this->kirimWhatsApp(
            $mitra->no_whatsapp,
            "Selamat! Pendaftaran toko *{$mitra->nama_usaha}* di LastBite telah disetujui.\n\n"
            . "Silakan buka aplikasi LastBite Mitra dan masuk dengan akun Anda untuk mulai berjualan."
        );

        return redirect()->route('admin.dashboard')->with('status', 'Pendaftaran mitra disetujui dan notifikasi WhatsApp dikirim.');
    }

    public function tolak(Request $request, $id)
    {
        $request->validate(['alasan' => 'required|string|max:255']);

        $mitra = Mitra::where('id_mitra', $id)->firstOrFail();

        Mitra::where('id_mitra', $id)->update([
            'status_verifikasi' => 'ditolak',
            'alasan_penolakan' => $request->alasan,
        ]);

        $this->kirimWhatsApp(
            $mitra->no_whatsapp,
            "Mohon maaf, pendaftaran toko *{$mitra->nama_usaha}* di LastBite belum dapat disetujui.\n\n"
            . "Alasan: {$request->alasan}\n\n"
            . "Silakan perbaiki data Anda lalu daftar ulang melalui aplikasi LastBite Mitra."
        );

        return redirect()->route('admin.dashboard')->with('status', 'Pendaftaran mitra ditolak dan notifikasi WhatsApp dikirim.');
    }

    // Kabari mitra lewat WhatsApp (Fonnte). Kegagalan kirim tidak membatalkan keputusan admin.
    private function kirimWhatsApp(?string $phone, string $pesan): void
    {
        $nomor = preg_replace('/[^0-9]/', '', (string) $phone);
        if ($nomor === '') {
            return;
        }
        if (str_starts_with($nomor, '0')) {
            $nomor = '62' . substr($nomor, 1);
        }

        try {
            Http::withHeaders(['Authorization' => env('FONNTE_TOKEN')])
                ->post('https://api.fonnte.com/send', [
                    'target' => $nomor,
                    'message' => $pesan,
                ]);
        } catch (\Throwable $e) {
            Log::warning('Gagal kirim WhatsApp ke mitra: ' . $e->getMessage());
        }
    }
}