<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Mail;

class EmailOtpController extends Controller
{
    public function kirim(Request $request)
    {
        $request->validate(['email' => 'required|email']);
        $email = strtolower($request->email);

        $kunci = 'email_otp_cooldown:' . $email;
        if (Cache::has($kunci)) {
            return response()->json(['message' => 'Tunggu 60 detik sebelum meminta kode lagi.'], 429);
        }

        $kode = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        Cache::put('email_otp:' . $email, $kode, now()->addMinutes(10));
        Cache::put($kunci, true, now()->addSeconds(60));

        Mail::raw(
            "Kode verifikasi LastBite kamu: {$kode}\n\nKode berlaku 10 menit. Jangan bagikan kode ini ke siapa pun.",
            fn ($m) => $m->to($email)->subject('Kode OTP LastBite')
        );

        return response()->json(['message' => 'Kode OTP dikirim ke email.']);
    }

    public function verifikasi(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'kode'  => 'required|digits:6',
        ]);
        $email = strtolower($request->email);

        $tersimpan = Cache::get('email_otp:' . $email);
        if (!$tersimpan || !hash_equals($tersimpan, $request->kode)) {
            return response()->json(['message' => 'Kode salah atau sudah kedaluwarsa.'], 422);
        }

        Cache::forget('email_otp:' . $email);

        $user = User::firstOrCreate(
            ['email' => $email],
            ['name' => explode('@', $email)[0], 'role' => 'pelanggan']
        );

        return response()->json([
            'token' => $user->createToken('email-otp')->plainTextToken,
            'user'  => $user,
        ]);
    }
}