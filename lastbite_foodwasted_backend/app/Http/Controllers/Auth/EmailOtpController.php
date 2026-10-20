<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;

class EmailOtpController extends Controller
{
    // POST /api/auth/login-email  -> kirim OTP ke email
    public function kirim(Request $request)
    {
        $data = $request->validate(['email' => 'required|email']);
        $email = strtolower(trim($data['email']));

        // Batasi: 1 kirim per 60 detik
        $cdKey = "otp_email_cd:$email";
        if (Cache::has($cdKey)) {
            return response()->json(['message' => 'Tunggu 60 detik sebelum kirim ulang.'], 429);
        }

        $kode = (string) random_int(100000, 999999);
        Cache::put("otp_email:$email", Hash::make($kode), now()->addMinutes(5));
        Cache::put("otp_email_try:$email", 0, now()->addMinutes(5));
        Cache::put($cdKey, 1, now()->addSeconds(60));

        try {
            Mail::raw(
                "Kode masuk LastBite kamu: $kode\n\nBerlaku 5 menit. Jangan bagikan kode ini ke siapa pun.",
                fn ($m) => $m->to($email)->subject('Kode OTP LastBite')
            );
        } catch (\Throwable $e) {
            report($e);
            Cache::forget($cdKey);
            return response()->json(['message' => 'Gagal mengirim email. Coba lagi.'], 500);
        }

        return response()->json(['message' => 'Kode OTP dikirim ke email.']);
    }

    // POST /api/auth/verify-email-otp  -> cek OTP, kembalikan token
    public function verifikasi(Request $request)
    {
        $data = $request->validate([
            'email' => 'required|email',
            'code'  => 'required|digits:6',
        ]);
        $email = strtolower(trim($data['email']));

        $hash = Cache::get("otp_email:$email");
        if (!$hash) {
            return response()->json(['message' => 'Kode kedaluwarsa. Kirim ulang kode.'], 422);
        }

        $try = (int) Cache::get("otp_email_try:$email", 0);
        if ($try >= 5) {
            Cache::forget("otp_email:$email");
            return response()->json(['message' => 'Terlalu banyak percobaan. Kirim ulang kode.'], 429);
        }

        if (!Hash::check($data['code'], $hash)) {
            Cache::put("otp_email_try:$email", $try + 1, now()->addMinutes(5));
            return response()->json(['message' => 'Kode salah.'], 422);
        }

        Cache::forget("otp_email:$email");
        Cache::forget("otp_email_try:$email");

        // Login kalau email sudah terdaftar, kalau belum buat akun baru
        $user = User::firstOrCreate(
            ['email' => $email],
            ['name' => Str::before($email, '@'), 'password' => Hash::make(Str::random(32))]
        );

        return response()->json(['token' => $user->createToken('mobile')->plainTextToken]);
    }
}