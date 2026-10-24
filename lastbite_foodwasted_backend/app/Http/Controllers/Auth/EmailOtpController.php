<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;

class EmailOtpController extends Controller
{
    // ------------------------------------------------------------
    // Helper: kirim & cek kode (dipakai semua endpoint di bawah)
    // ------------------------------------------------------------
    private function kirimKode(string $key, string $email): JsonResponse
    {
        $cd = "{$key}:cd";
        if (Cache::has($cd)) {
            return response()->json(['message' => 'Tunggu 60 detik sebelum kirim ulang.'], 429);
        }

        $kode = (string) random_int(100000, 999999);
        Cache::put("{$key}:hash", Hash::make($kode), now()->addMinutes(5));
        Cache::put("{$key}:try", 0, now()->addMinutes(5));
        Cache::put($cd, 1, now()->addSeconds(60));

        \Illuminate\Support\Facades\Log::info("Email OTP untuk {$email}: {$kode}");

        try {
            Mail::raw(
                "Kode OTP LastBite kamu: $kode\n\nBerlaku 5 menit. Jangan bagikan kode ini ke siapa pun.",
                fn ($m) => $m->to($email)->subject  ('Kode OTP LastBite')
            );
        } catch (\Throwable $e) {
            report($e);
            Cache::forget($cd);
            return response()->json([
                'message' => 'Gagal mengirim email: ' . $e->getMessage()
            ], 500);
        }

        return response()->json(['message' => 'Kode OTP dikirim ke email.']);
    }

    /** null = kode benar. Selain itu = response error. */
    private function cekKode(string $key, string $kode): ?JsonResponse
    {
        $hash = Cache::get("{$key}:hash");
        if (! $hash) {
            return response()->json(['message' => 'Kode kedaluwarsa. Kirim ulang kode.'], 422);
        }

        $try = (int) Cache::get("{$key}:try", 0);
        if ($try >= 5) {
            Cache::forget("{$key}:hash");
            return response()->json(['message' => 'Terlalu banyak percobaan. Kirim ulang kode.'], 429);
        }

        if (! Hash::check($kode, $hash)) {
            Cache::put("{$key}:try", $try + 1, now()->addMinutes(5));
            return response()->json(['message' => 'Kode salah.'], 422);
        }

        Cache::forget("{$key}:hash");
        Cache::forget("{$key}:try");
        return null;
    }

    // ------------------------------------------------------------
    // PUBLIK (belum login): masuk lewat OTP email
    // POST /api/auth/login-email
    // POST /api/auth/verify-email-otp
    // ------------------------------------------------------------
    public function kirim(Request $request)
    {
        $data  = $request->validate(['email' => 'required|email']);
        $email = strtolower(trim($data['email']));

        return $this->kirimKode("otp_login:$email", $email);
    }

    public function verifikasi(Request $request)
    {
        $data = $request->validate([
            'email' => 'required|email',
            'code'  => 'required|digits:6',
        ]);
        $email = strtolower(trim($data['email']));

        if ($err = $this->cekKode("otp_login:$email", $data['code'])) {
            return $err;
        }

        // Login kalau email sudah terdaftar, kalau belum buat akun baru
        $user = User::firstOrCreate(
            ['email' => $email],
            ['name' => Str::before($email, '@'), 'password' => Hash::make(Str::random(32))]
        );

        // Kode dikirim ke email ini & benar -> email terbukti milik user
        if (! $user->email_verified_at) {
            $user->forceFill(['email_verified_at' => now()])->save();
        }

        return response()->json(['token' => $user->createToken('mobile')->plainTextToken]);
    }

    // ------------------------------------------------------------
    // SUDAH LOGIN: verifikasi email akun (halaman Keamanan Akun)
    // POST /api/akun/email/kirim-otp
    // POST /api/akun/email/verifikasi
    // ------------------------------------------------------------
    public function kirimVerifikasi(Request $request)
    {
        $user  = $request->user();
        $email = strtolower(trim((string) $user->email));

        if ($email === '') {
            return response()->json(['message' => 'Akun ini belum punya email.'], 422);
        }
        if ($user->email_verified_at) {
            return response()->json(['message' => 'Email sudah terverifikasi.']);
        }

        return $this->kirimKode("otp_verif:{$user->id}", $email);
    }

    public function verifikasiEmail(Request $request)
    {
        $data = $request->validate(['code' => 'required|digits:6']);
        $user = $request->user();

        if ($err = $this->cekKode("otp_verif:{$user->id}", $data['code'])) {
            return $err;
        }

        $user->forceFill(['email_verified_at' => now()])->save();

        return response()->json(['message' => 'Email berhasil diverifikasi.']);
    }
}