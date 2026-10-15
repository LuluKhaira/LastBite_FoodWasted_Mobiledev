<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Pesanan;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class ProfilController extends Controller
{
    /** Nama kolom nomor HP di tabel users (dari migration tambah_no_hp_ke_users_table). */
    private const KOLOM_HP = 'no_hp';

    /** Tiap sekian paket yang sudah diambil, level penyelamat naik 1. */
    private const PAKET_PER_LEVEL = 5;

    /** GET /api/profil */
    public function show(Request $r): JsonResponse
    {
        abort_unless($r->user(), 401, 'Unauthenticated.');

        return response()->json(['data' => $this->payload($r->user())]);
    }

    /** PUT /api/profil  {name, phone?} */
    public function update(Request $r): JsonResponse
    {
        $v = $r->validate([
            'name'  => 'required|string|max:100',
            'phone' => 'nullable|string|max:20',
        ]);

        $u = $r->user();
        abort_unless($u, 401, 'Unauthenticated.');
        $data = ['name' => trim($v['name'])];

        if (! empty($v['phone'])) {
            $hp = $this->normalisasiHp($v['phone']);
            if (! preg_match('/^62\d{8,13}$/', $hp)) {
                throw ValidationException::withMessages(['phone' => 'Format nomor HP tidak valid (contoh: 0812xxxx atau +62812xxxx).']);
            }
            $dipakai = User::where(self::KOLOM_HP, $hp)->where('id', '!=', $u->id)->exists();
            if ($dipakai) {
                throw ValidationException::withMessages(['phone' => 'Nomor HP sudah dipakai akun lain.']);
            }
            $data[self::KOLOM_HP] = $hp;
        }

        $u->forceFill($data)->save();

        return response()->json(['data' => $this->payload($u->fresh())]);
    }

    private function payload(User $u): array
    {
        // statistik hanya dari pesanan yang sudah DIAMBIL (status selesai)
        $q = Pesanan::where('user_id', $u->id)->where('status', 'selesai');

        $paket = (int) (clone $q)->sum('qty');
        $kg    = round((float) (clone $q)->sum('makanan'), 2);
        $hemat = (int) (clone $q)->value(DB::raw(
            'COALESCE(SUM(GREATEST(CAST(harga_asli_satuan AS SIGNED) - CAST(harga_satuan AS SIGNED), 0) * qty), 0)'
        ));

        $nama  = (string) $u->name;
        $kata  = preg_split('/\s+/', trim($nama), -1, PREG_SPLIT_NO_EMPTY) ?: [];
        $inisial = '';
        foreach (array_slice($kata, 0, 2) as $k) {
            $inisial .= mb_strtoupper(mb_substr($k, 0, 1));
        }

        return [
            'name'               => $nama,
            'email'              => (string) ($u->email ?? ''),
            'phone'              => (string) ($u->{self::KOLOM_HP} ?? ''),
            'inisial'            => $inisial,
            'is_vip'             => false,                       // belum ada fitur langganan
            'level'              => 1 + intdiv($paket, self::PAKET_PER_LEVEL),
            'kg_diselamatkan'    => $kg,
            'paket_diselamatkan' => $paket,
            'hemat_rupiah'       => $hemat,
            'voucher_tersedia'   => 0,                           // belum ada tabel voucher
            'metode_bayar'       => '',                          // belum ada fitur simpan metode bayar

            // dipakai halaman Keamanan Akun
            'email_terverifikasi'  => ! empty($u->email_verified_at),
            'punya_password'       => ! empty($u->password),
            'password_diubah_hari' => $u->password_changed_at
                ? (int) abs(Carbon::parse($u->password_changed_at)->diffInDays(now()))
                : null,
        ];
    }

    /** 0812... / +62812... / 62812... -> 62812... */
    private function normalisasiHp(string $hp): string
    {
        $d = preg_replace('/\D+/', '', $hp);
        if (str_starts_with($d, '0')) {
            $d = '62' . substr($d, 1);
        } elseif (str_starts_with($d, '8')) {
            $d = '62' . $d;
        }
        return $d;
    }
}