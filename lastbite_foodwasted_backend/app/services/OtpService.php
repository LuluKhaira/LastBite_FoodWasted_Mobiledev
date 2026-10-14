<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use RuntimeException;
use Throwable;

/**
 * OTP WhatsApp lewat Fonnte. Kode disimpan (ter-hash) di Cache, jadi tidak perlu tabel baru.
 * Exception membawa HTTP status di getCode().
 */
class OtpService
{
    public const EXPIRE_MINUTES = 5;
    public const RESEND_SECONDS = 60;
    public const MAX_ATTEMPTS   = 5;
    private const PENDING_MINUTES = 30;

    private function key(string $purpose, string $phone): string
    {
        return "otp:{$purpose}:{$phone}";
    }

    private function pendingKey(string $phone): string
    {
        return "otp-pending:{$phone}";
    }

    /** Data pendaftaran yang menunggu verifikasi (nama, email, hash sandi). */
    public function getPending(string $phone): ?array
    {
        return Cache::get($this->pendingKey($phone));
    }

    public function pullPending(string $phone): ?array
    {
        return Cache::pull($this->pendingKey($phone));
    }

    public function send(string $phone, string $purpose, ?array $pending = null): void
    {
        $cooldown = "otp-cooldown:{$purpose}:{$phone}";

        if (! Cache::add($cooldown, time() + self::RESEND_SECONDS, self::RESEND_SECONDS)) {
            $wait = max(1, (int) Cache::get($cooldown, time() + 1) - time());
            throw new RuntimeException("Tunggu {$wait} detik sebelum meminta kode baru.", 429);
        }

        $code = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        Cache::put($this->key($purpose, $phone), [
            'hash'     => Hash::make($code),
            'attempts' => 0,
            'exp'      => time() + self::EXPIRE_MINUTES * 60,
        ], now()->addMinutes(self::EXPIRE_MINUTES));

        if ($pending !== null) {
            Cache::put($this->pendingKey($phone), $pending, now()->addMinutes(self::PENDING_MINUTES));
        }

        $message = "Kode verifikasi LastBite Anda adalah: *{$code}*.\n\n"
            . 'Berlaku ' . self::EXPIRE_MINUTES . " menit. Jangan berikan kode ini kepada siapa pun.";

        $gagal = $this->kirimWhatsApp($phone, $message);

        if ($gagal !== null) {
            Cache::forget($this->key($purpose, $phone));
            Cache::forget($cooldown);

            $pesan = config('app.debug')
                ? "Gagal mengirim OTP ke WhatsApp. Alasan: {$gagal}"
                : 'Gagal mengirim OTP ke WhatsApp. Coba lagi sebentar.';
            throw new RuntimeException($pesan, 502);
        }
    }

    public function verify(string $phone, string $purpose, string $code): void
    {
        $key  = $this->key($purpose, $phone);
        $data = Cache::get($key);

        if (! $data) {
            throw new RuntimeException('Kode OTP sudah kedaluwarsa. Silakan kirim ulang.', 422);
        }

        if ($data['attempts'] >= self::MAX_ATTEMPTS) {
            Cache::forget($key);
            throw new RuntimeException('Terlalu banyak percobaan. Silakan kirim ulang kode.', 429);
        }

        if (! Hash::check($code, $data['hash'])) {
            $data['attempts']++;
            Cache::put($key, $data, max(1, $data['exp'] - time()));
            $sisa = self::MAX_ATTEMPTS - $data['attempts'];
            throw new RuntimeException("Kode OTP salah. Sisa percobaan: {$sisa}.", 422);
        }

        Cache::forget($key);
    }

    private function kirimWhatsApp(string $phone, string $message): ?string
    {
        $token = config('services.fonnte.token');

        try {
            $res  = Http::withHeaders(['Authorization' => $token])
                ->asForm()->timeout(15)
                ->post('https://api.fonnte.com/send', ['target' => $phone, 'message' => $message]);
            $body = $res->json();

            if ($res->successful() && ($body['status'] ?? false) === true) {
                return null;
            }

            Log::warning('Fonnte gagal kirim', ['phone' => $phone, 'http' => $res->status(), 'response' => $body ?? $res->body()]);
            return is_array($body)
                ? (string) ($body['reason'] ?? json_encode($body))
                : 'HTTP ' . $res->status();
        } catch (Throwable $e) {
            Log::error('Fonnte error: ' . $e->getMessage());
            return mb_substr($e->getMessage(), 0, 160);
        }
    }
}