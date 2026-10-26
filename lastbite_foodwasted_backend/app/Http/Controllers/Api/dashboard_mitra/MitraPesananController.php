<?php

namespace App\Http\Controllers\Api\dashboard_mitra;

use App\Http\Controllers\Controller;
use App\Models\Mitra;
use App\Models\Pesanan;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\DB;

class MitraPesananController extends Controller
{
    /**
     * Cari mitra dari nomor HP yang dikirim Flutter.
     * Normalisasi: 08xxx <-> 628xxx <-> +628xxx
     */
    private function cariMitra(?string $phone): ?Mitra
    {
        if (!$phone) return null;

        $bersih = preg_replace('/[^0-9]/', '', $phone); // hapus +, spasi, strip
        $kandidat = array_unique([
            $phone,
            $bersih,                                  // 0812xxx atau 62812xxx
            preg_replace('/^0/', '62', $bersih),      // 0812 -> 62812
            preg_replace('/^62/', '0', $bersih),      // 62812 -> 0812
            '+'.$bersih,
        ]);

        return Mitra::whereIn('no_whatsapp', $kandidat)->first();
    }

    /**
     * POST /mitra/pesanan   { phone, tab }
     * POST /partner/orders  { phone, tab }
     * tab: 'semua' | 'baru' | 'siap' | 'riwayat'
     */
    public function index(Request $r): JsonResponse
    {
        $phone = $r->input('phone');
        $tab   = strtolower((string) $r->input('tab', 'semua'));

        $mitra = $this->cariMitra($phone);
        if (!$mitra) {
            return response()->json([
                'data'    => [],
                'message' => 'Mitra tidak ditemukan untuk nomor '.$phone,
            ], 200);
        }

        $q = Pesanan::where('id_mitra', $mitra->id_mitra);

        // Terjemahkan tab Flutter -> status di database
        // DB pakai: menunggu | siap | selesai | dibatalkan | ditolak
        switch ($tab) {
            case 'baru':
                $q->whereIn('status', ['menunggu']);
                break;

            case 'siap':
                $q->whereIn('status', ['siap']);
                break;

            case 'riwayat':
            case 'selesai':
                $q->whereIn('status', ['selesai', 'dibatalkan', 'ditolak']);
                break;

            case 'semua':
            default:
                // tampilkan semua
                break;
        }

        $data = $q->latest('id')->get()->map(fn (Pesanan $p) => $p->toApi());

        return response()->json(['data' => $data]);
    }

    /**
     * POST /mitra/pesanan/{kode}/siap
     * POST /partner/orders/{order_id}/ready
     */
    public function siap(Request $r, string $kode): JsonResponse
    {
        $p = $this->milik($r, $kode);

        if ($p->status !== 'menunggu') {
            throw ValidationException::withMessages([
                'status' => 'Pesanan ini tidak dalam status menunggu.',
            ]);
        }

        $p->update([
            'status'      => 'siap',
            'siap_at'     => now(),
            'batas_ambil' => now()->addHours(2),
            'kode_ambil'  => $p->kode_ambil ?: $this->buatKodeAmbil(),
        ]);

        return response()->json(['data' => $p->fresh()->toApi()]);
    }

    /**
     * POST /mitra/pesanan/{kode}/tolak
     */
    public function tolak(Request $r, string $kode): JsonResponse
    {
        $p = $this->milik($r, $kode);

        if (!in_array($p->status, ['menunggu'])) {
            throw ValidationException::withMessages([
                'status' => 'Pesanan ini sudah tidak bisa ditolak.',
            ]);
        }

        $p->update(['status' => 'dibatalkan']);

        return response()->json(['data' => $p->fresh()->toApi()]);
    }

    /**
     * POST /mitra/pesanan/{kode}/ambil
     * POST /mitra/pesanan/verify-pickup
     * POST /partner/orders/verify-pickup
     *
     * Body:
     *  - untuk /{kode}/ambil : { phone }
     *  - untuk verify-pickup : { phone, kode_ambil }
     */
    public function ambil(Request $r, ?string $kode = null): JsonResponse
{
    $mitra = $this->cariMitra($r->input('phone'));
    if (!$mitra) {
        return response()->json(['ok' => false, 'message' => 'Mitra tidak ditemukan.'], 404);
    }

    // Terima nama field dari Flutter (pickup_code) maupun nama lama (kode_ambil)
    $kodeAmbil = $r->input('pickup_code') ?? $r->input('kode_ambil');
    $kodeAmbil = $kodeAmbil ? strtoupper(preg_replace('/\s+/', '', $kodeAmbil)) : null;

    // Kode pesanan: dari URL, atau dari body (Flutter mengirim 'kode')
    $kodePesanan = $kode ?? $r->input('kode');
    $kodePesanan = $kodePesanan ? ltrim(trim($kodePesanan), '#') : null;

    if (!$kodePesanan && !$kodeAmbil) {
        return response()->json([
            'ok' => false, 'message' => 'Kode pengambilan wajib diisi.',
        ], 422);
    }

    $query = Pesanan::where('id_mitra', $mitra->id_mitra);
    if ($kodePesanan) $query->where('kode', $kodePesanan);
    if ($kodeAmbil)   $query->where('kode_ambil', $kodeAmbil);

    $p = $query->first();
    if (!$p) {
        return response()->json([
            'ok' => false,
            'message' => $kodeAmbil
                ? 'Kode pengambilan salah atau bukan untuk pesanan ini.'
                : 'Pesanan tidak ditemukan atau bukan milik toko ini.',
        ], 404);
    }

    if ($p->status === 'menunggu') {
        return response()->json([
            'ok' => false, 'message' => 'Pesanan belum ditandai siap. Tandai siap dulu ya.',
        ], 422);
    }
    if ($p->status !== 'siap') {
        return response()->json([
            'ok' => false, 'message' => 'Pesanan ini sudah tidak aktif (status: '.$p->status.').',
        ], 422);
    }
    if ($p->batas_ambil && now()->greaterThan($p->batas_ambil)) {
        return response()->json([
            'ok' => false, 'message' => 'Batas waktu pengambilan sudah lewat.',
        ], 422);
    }

    $pendapatan = max(0, (int) ($p->harga_satuan * $p->qty));

    DB::transaction(function () use ($p, $mitra, $pendapatan) {
        $p->update(['status' => 'selesai', 'diambil_at' => now()]);
        $mitra->increment('saldo', $pendapatan);
    });
    $mitra->refresh();

    return response()->json([
        'ok'            => true,
        'message'       => 'Pengambilan berhasil.',
        'data'          => $p->fresh()->toApi(),
        'pendapatan'    => $pendapatan,
        'saldo_terbaru' => (int) $mitra->saldo,
    ]);
}

    /**
     * Ambil pesanan yang dipastikan milik mitra login.
     */
    private function milik(Request $r, string $kode): Pesanan
    {
        $mitra = $this->cariMitra($r->input('phone'));
        if (!$mitra) {
            abort(404, 'Mitra tidak ditemukan.');
        }

        $p = Pesanan::where('id_mitra', $mitra->id_mitra)
            ->where('kode', $kode)
            ->first();

        if (!$p) {
            abort(404, 'Pesanan tidak ditemukan.');
        }

        return $p;
    }

    /**
     * Buat kode pengambilan 6 digit acak, unik per pesanan.
     * Format: LB-XXXXXX
     */
    private function buatKodeAmbil(): string
    {
        do {
            $kode = 'LB-'.str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        } while (Pesanan::where('kode_ambil', $kode)->exists());

        return $kode;
    }
}