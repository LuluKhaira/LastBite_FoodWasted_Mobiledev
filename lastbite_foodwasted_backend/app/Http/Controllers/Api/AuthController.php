<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\OtpService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use RuntimeException;

class AuthController extends Controller
{
    public function register(Request $r)
    {
        $data = $r->validate([
            'name'     => 'required|string|max:255',
            'email'    => 'required|email|unique:users,email',
            'password' => 'required|string|min:6',
            'no_hp'    => 'nullable|string|max:20',
        ]);
        $user = User::create([
            'name' => $data['name'], 'email' => $data['email'],
            'password' => Hash::make($data['password']),
            'no_hp' => $data['no_hp'] ?? null, 'role' => 'pembeli',
        ]);
        return response()->json([
            'user'  => $user,
            'token' => $user->createToken('flutter')->plainTextToken,
        ], 201);
    }

    public function login(Request $r)
    {
        $data = $r->validate(['email' => 'required|email', 'password' => 'required']);
        $user = User::where('email', $data['email'])->first();
        if (!$user || !Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages(['email' => ['Email atau password salah.']]);
        }
        return response()->json([
            'user'  => $user,
            'token' => $user->createToken('flutter')->plainTextToken,
        ]);
    }

    public function me(Request $r) { return $r->user(); }

    public function logout(Request $r)
    {
        $r->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Berhasil keluar']);
    }

    // =====================================================================
    //  DAFTAR & MASUK VIA WHATSAPP OTP (Fonnte)
    //  Login email + sandi tetap memakai login() di atas.
    // =====================================================================

    /** POST /api/auth/register-phone : validasi lalu kirim OTP. Akun baru dibuat SETELAH OTP benar. */
    public function registerPhone(Request $r, OtpService $otp)
    {
        $r->merge(['phone' => $this->normalizePhone($r->input('phone'))]);

        $data = $r->validate([
            'name'     => 'required|string|min:3|max:100',
            'phone'    => 'required|string',
            'email'    => 'nullable|email|max:255',
            'password' => 'nullable|string|min:8|max:72',
        ], ['phone.required' => 'Nomor WhatsApp tidak valid.']);

        if (User::where('no_hp', $data['phone'])->whereNotNull('no_hp_verified_at')->exists()) {
            throw ValidationException::withMessages(['phone' => ['Nomor ini sudah terdaftar. Silakan masuk.']]);
        }

        if (!empty($data['email']) && User::where('email', $data['email'])->exists()) {
            throw ValidationException::withMessages(['email' => ['Email sudah dipakai akun lain.']]);
        }

        if (!empty($data['password']) && empty($data['email'])) {
            throw ValidationException::withMessages(['email' => ['Isi email dulu untuk memakai kata sandi.']]);
        }

        // Email & sandi baru disimpan setelah nomor terbukti milik pendaftar (anti pengambilalihan akun)
        $pending = [
            'name'     => $data['name'],
            'email'    => $data['email'] ?? null,
            'password' => !empty($data['password']) ? Hash::make($data['password']) : null,
        ];

        return $this->kirimOtp($otp, $data['phone'], 'register', $pending);
    }

    /** POST /api/auth/login-phone : kirim OTP untuk masuk */
    public function loginPhone(Request $r, OtpService $otp)
    {
        $r->merge(['phone' => $this->normalizePhone($r->input('phone'))]);
        $data = $r->validate(['phone' => 'required|string'], ['phone.required' => 'Nomor WhatsApp tidak valid.']);

        $ada = User::where('no_hp', $data['phone'])->whereNotNull('no_hp_verified_at')->exists();
        if (!$ada) {
            return response()->json(['message' => 'Nomor belum terdaftar. Silakan daftar dulu.'], 404);
        }

        return $this->kirimOtp($otp, $data['phone'], 'login');
    }

    /** POST /api/auth/resend-otp */
    public function resendOtp(Request $r, OtpService $otp)
    {
        $r->merge(['phone' => $this->normalizePhone($r->input('phone'))]);
        $data = $r->validate([
            'phone'   => 'required|string',
            'purpose' => 'required|in:register,login',
        ]);

        if ($data['purpose'] === 'register' && !$otp->getPending($data['phone'])) {
            return response()->json(['message' => 'Sesi pendaftaran berakhir. Silakan daftar ulang.'], 422);
        }
        if ($data['purpose'] === 'login'
            && !User::where('no_hp', $data['phone'])->whereNotNull('no_hp_verified_at')->exists()) {
            return response()->json(['message' => 'Nomor belum terdaftar.'], 404);
        }

        return $this->kirimOtp($otp, $data['phone'], $data['purpose']);
    }

    /** POST /api/auth/verify-otp : OTP benar -> {user, token} */
    public function verifyOtp(Request $r, OtpService $otp)
    {
        $r->merge(['phone' => $this->normalizePhone($r->input('phone'))]);
        $data = $r->validate([
            'phone'   => 'required|string',
            'code'    => 'required|digits:6',
            'purpose' => 'required|in:register,login',
        ]);

        try {
            $otp->verify($data['phone'], $data['purpose'], $data['code']);
        } catch (RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], $e->getCode() ?: 422);
        }

        if ($data['purpose'] === 'register') {
            $pending = $otp->pullPending($data['phone']);
            if (!$pending) {
                return response()->json(['message' => 'Sesi pendaftaran berakhir. Silakan daftar ulang.'], 422);
            }

            $user = User::firstOrNew(['no_hp' => $data['phone']]);
            $user->name = $pending['name'];

            $email = $pending['email'] ?? null;
            if ($email && !User::where('email', $email)->where('id', '!=', $user->id ?? 0)->exists()) {
                $user->email = $email;
            }
            if (!empty($pending['password'])) {
                $user->password = $pending['password'];
            }
            if (!$user->exists) {
                $user->role = 'pembeli';
            }
            $user->no_hp_verified_at = now();
            $user->save();

            $pesan = 'Akun berhasil dibuat. Selamat datang!';
        } else {
            $user = User::where('no_hp', $data['phone'])->whereNotNull('no_hp_verified_at')->first();
            if (!$user) {
                return response()->json(['message' => 'Akun tidak ditemukan.'], 404);
            }
            $pesan = 'Berhasil masuk.';
        }

        return response()->json([
            'message' => $pesan,
            'user'    => $user,
            'token'   => $user->createToken('flutter')->plainTextToken,
        ]);
    }

    // ---------------------------------------------------------------------

    private function kirimOtp(OtpService $otp, string $phone, string $purpose, ?array $pending = null)
    {
        try {
            $otp->send($phone, $purpose, $pending);
        } catch (RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], $e->getCode() ?: 500);
        }

        return response()->json([
            'message'        => 'Kode OTP sudah dikirim ke WhatsApp kamu.',
            'phone'          => $phone,
            'resend_seconds' => OtpService::RESEND_SECONDS,
        ]);
    }

    /** 0812... / +62812... / 812... -> 62812... (null kalau bukan nomor HP Indonesia) */
    private function normalizePhone(?string $raw): ?string
    {
        $d = preg_replace('/\D+/', '', (string) $raw);
        if ($d === '') return null;

        if (str_starts_with($d, '62')) {
            // sudah benar
        } elseif (str_starts_with($d, '0')) {
            $d = '62' . substr($d, 1);
        } elseif (str_starts_with($d, '8')) {
            $d = '62' . $d;
        } else {
            return null;
        }

        return preg_match('/^628[1-9][0-9]{7,11}$/', $d) ? $d : null;
    }
}
