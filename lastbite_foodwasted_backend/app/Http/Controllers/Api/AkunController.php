<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AkunController extends Controller
{
    /**
     * PUT /api/akun/password  {password_lama?, password_baru}
     * password_lama wajib bila akun sudah punya kata sandi. Akun yang daftar
     * lewat OTP WhatsApp boleh membuat kata sandi pertama tanpa password_lama.
     */
    public function ubahPassword(Request $r): JsonResponse
    {
        $u = $r->user();
        abort_unless($u, 401, 'Unauthenticated.');

        $v = $r->validate([
            'password_lama' => 'nullable|string',
            'password_baru' => 'required|string|min:8|max:100',
        ]);

        if (! empty($u->password) && ! Hash::check($v['password_lama'] ?? '', $u->password)) {
            throw ValidationException::withMessages(['password_lama' => 'Kata sandi lama salah.']);
        }

        $u->forceFill([
            'password'            => Hash::make($v['password_baru']),
            'password_changed_at' => now(),
        ])->save();

        // keluarkan perangkat lain (perangkat ini tetap masuk)
        $this->cabutTokenLain($r);

        return response()->json(['message' => 'Kata sandi berhasil disimpan.']);
    }

    /** POST /api/akun/logout-lainnya */
    public function logoutLainnya(Request $r): JsonResponse
    {
        abort_unless($r->user(), 401, 'Unauthenticated.');

        $jumlah = $this->cabutTokenLain($r);

        return response()->json(['message' => "$jumlah perangkat lain dikeluarkan."]);
    }

    private function cabutTokenLain(Request $r): int
    {
        $u    = $r->user();
        $saat = $u->currentAccessToken();
        $id   = $saat->id ?? null;       // TransientToken tidak punya id

        $q = $u->tokens();
        if ($id) {
            $q->where('id', '!=', $id);
        }

        return $q->delete();
    }
}