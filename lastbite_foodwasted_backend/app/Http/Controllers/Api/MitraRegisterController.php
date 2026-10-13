<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Mitra;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;

class MitraRegisterController extends Controller
{
    private function formatToLocal($phone)
    {
        $phone = preg_replace('/[^0-9]/', '', $phone);

        if (str_starts_with($phone, '62')) {
            return '0' . substr($phone, 2);
        }
        if (str_starts_with($phone, '8')) {
            return '0' . $phone;
        }
        return $phone;
    }

    private function formatToInternational($phone)
    {
        $phone = preg_replace('/[^0-9]/', '', $phone);

        if (str_starts_with($phone, '0')) {
            return '62' . substr($phone, 1);
        }
        if (!str_starts_with($phone, '62')) {
            return '62' . $phone;
        }
        return $phone;
    }

    public function registerPhone(Request $request)
    {
        $request->validate(['phone' => 'required|string']);

        $dbPhone = $this->formatToLocal($request->phone);
        $fonntePhone = $this->formatToInternational($request->phone);

        $otp = sprintf("%06d", rand(0, 999999));

        Mitra::updateOrCreate(
            ['no_whatsapp' => $dbPhone],
            ['otp' => $otp, 'status_verifikasi' => 'pending']
        );

        $fonnteToken = env('FONNTE_TOKEN');
        try {
            Http::withHeaders(['Authorization' => $fonnteToken])->post('https://api.fonnte.com/send', [
                'target' => $fonntePhone,
                'message' => "Kode verifikasi LastBite Anda adalah: *{$otp}*.\n\nJangan berikan kode ini kepada siapa pun.",
            ]);

            return response()->json(['success' => true, 'message' => 'OTP terkirim']);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Gagal kirim WhatsApp'], 500);
        }
    }

    public function verifyOtp(Request $request)
    {
        $request->validate([
            'phone' => 'required|string',
            'otp' => 'required|string',
        ]);

        $dbPhone = $this->formatToLocal($request->phone);

        $mitra = Mitra::where('no_whatsapp', $dbPhone)
            ->where('otp', $request->otp)
            ->first();

        if (!$mitra) {
            return response()->json([
                'success' => false,
                'message' => 'Kode OTP salah atau tidak valid!'
            ], 400);
        }

        $mitra->forceFill([
            'status_verifikasi' => 'verified',
            'otp' => null,
        ])->save();

        return response()->json([
            'success' => true,
            'message' => 'OTP berhasil diverifikasi!',
            'data' => $mitra
        ], 200);
    }

    public function setPassword(Request $request)
    {
        Log::info('Data set-password diterima:', $request->except('password'));

        $request->validate([
            'phone' => 'required|string',
            'password' => 'required|string|min:8',
        ]);

        $dbPhone = $this->formatToLocal($request->phone);

        $mitra = Mitra::where('no_whatsapp', $dbPhone)->first();

        if (!$mitra) {
            Log::warning('Mitra tidak ditemukan untuk nomor: ' . $dbPhone);
            return response()->json([
                'success' => false,
                'message' => 'Data mitra tidak ditemukan. Silakan ulangi proses dari awal.'
            ], 404);
        }

        // forceFill + save: tetap tersimpan walau kolom belum ada di $fillable
        $mitra->forceFill([
            'password' => bcrypt($request->password),
        ])->save();

        return response()->json([
            'success' => true,
            'message' => 'Kata sandi berhasil disimpan!',
        ], 200);
    }

    public function setBusinessCategory(Request $request)
    {
        Log::info('Data kategori usaha diterima:', $request->all());

        $request->validate([
            'phone' => 'required|string',
            'kategori_usaha' => 'required|string',
        ]);

        $cleanPhone = $this->formatToLocal($request->phone);
        $mitra = Mitra::where('no_whatsapp', $cleanPhone)->first();

        if (!$mitra) {
            return response()->json([
                'success' => false,
                'message' => 'Data mitra tidak ditemukan.'
            ], 404);
        }

        // Jangan timpa nama_usaha dengan kategori. Simpan hanya jika kolom kategori_usaha ada.
        if (Schema::hasColumn($mitra->getTable(), 'kategori_usaha')) {
            $mitra->forceFill([
                'kategori_usaha' => $request->kategori_usaha,
            ])->save();
        }

        return response()->json([
            'success' => true,
            'message' => 'Kategori usaha berhasil disimpan!',
        ], 200);
    }

    public function setAddress(Request $request)
    {
        Log::info('Data alamat & usaha diterima:', $request->all());

        $request->validate([
            'phone' => 'required|string',
            'nama_usaha' => 'required|string',
            'alamat' => 'required|string',
        ]);

        $cleanPhone = $this->formatToLocal($request->phone);
        $mitra = Mitra::where('no_whatsapp', $cleanPhone)->first();

        if (!$mitra) {
            return response()->json([
                'success' => false,
                'message' => 'Data mitra tidak ditemukan.'
            ], 404);
        }

        $mitra->forceFill([
            'nama_usaha' => $request->nama_usaha,
            'alamat' => $request->alamat,
        ])->save();

        return response()->json([
            'success' => true,
            'message' => 'Nama usaha dan alamat berhasil disimpan!',
        ], 200);
    }

    public function setDocuments(Request $request)
    {
        \Log::info('Data dokumen upload diterima:', $request->all());

        $request->validate([
            'phone' => 'required|string',
            'foto_ktp' => 'required|image|max:5120', // Maks 5MB
        ]);

        $cleanPhone = $this->formatToLocal($request->phone);
        $mitra = Mitra::where('no_whatsapp', $cleanPhone)->first();

        if (!$mitra) {
            return response()->json(['success' => false, 'message' => 'Mitra tidak ditemukan'], 404);
        }

        $ktpPath = $request->file('foto_ktp')->store('documents/ktp', 'public');

        $npwpPath = $request->hasFile('foto_npwp')
            ? $request->file('foto_npwp')->store('documents/npwp', 'public')
            : null;

        $halalPath = $request->hasFile('sertifikat_halal')
            ? $request->file('sertifikat_halal')->store('documents/halal', 'public')
            : null;

        $mitra->update([
            'foto_ktp' => $ktpPath,
            'foto_npwp' => $npwpPath,
            'sertifikat_halal' => $halalPath,
            'status_verifikasi' => 'menunggu_verifikasi',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Dokumen asli berhasil diunggah!',
        ], 200);
    }
}
