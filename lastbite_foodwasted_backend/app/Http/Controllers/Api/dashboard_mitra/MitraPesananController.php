<?php

namespace App\Http\Controllers\Api\dashboard_mitra;

use App\Http\Controllers\Controller;
use App\Models\Mitra;
use App\Models\Pesanan;
use App\Models\Produk;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class MitraPesananController extends Controller
{
    private function resolveMitra(Request $r): ?Mitra
    {
        if ($r->filled('id_mitra')) {
            return Mitra::where('id_mitra', $r->id_mitra)->first();
        }

        $raw = $r->phone ?? $r->phoneNumber;
        if (!$raw && $r->user() && $r->user()->role === 'mitra') {
            return Mitra::where('user_id', $r->user()->id)->first();
        }

        if (!$raw) return null;

        $nomorBersih = preg_replace('/[^0-9]/', '', $raw);

        return Mitra::where('no_whatsapp', $raw)
            ->orWhere('no_whatsapp', $nomorBersih)
            ->orWhere('no_whatsapp', '0' . ltrim($nomorBersih, '0'))
            ->orWhere('no_whatsapp', '62' . ltrim($nomorBersih, '0'))
            ->first();
    }

    private function pesananMilik(Request $r, string $kode): Pesanan
{
    $mitra = $this->resolveMitra($r);
    if (!$mitra) {
        abort(404, 'Mitra tidak ditemukan.');
    }

    return Pesanan::where(function ($query) use ($kode) {
            $query->where('kode', $kode)->orWhere('id', $kode);
        })
        ->where('id_mitra', $mitra->id_mitra)
        ->firstOrFail();
}

    /**
     * POST /api/mitra/pesanan
     * GET /api/partner/orders
     * Params: { phone / id_mitra, tab: 'baru' | 'siap' | 'riwayat' }
     */
    public function index(Request $r): JsonResponse
    {
        $mitra = $this->resolveMitra($r);
        if (!$mitra) {
            return response()->json(['success' => false, 'message' => 'Mitra tidak ditemukan.'], 404);
        }

        $q = Pesanan::with(['produk', 'user', 'mitra'])->where('id_mitra', $mitra->id_mitra);
        $tab = $r->tab ?? 'baru';

        match ($tab) {
            'semua'   => $q->where(fn ($w) => $w->where('status_bayar', 'lunas')
                            ->orWhereIn('status', ['selesai', 'dibatalkan'])),
            'siap'    => $q->where('status', 'siap'),
            'riwayat' => $q->whereIn('status', ['selesai', 'dibatalkan']),
            default   => $q->where('status', 'menunggu')->where('status_bayar', 'lunas'),
        };

        $orders = $q->latest()->get()->map(function (Pesanan $p) use ($tab) {
            $data = $p->toApi();
            // Pada tab siap, tampilkan juga kode_ambil untuk kemudahan mitra memverifikasi jika pembeli menyebutkan kode
            $data['kode_ambil_display'] = $p->status === 'siap' ? $p->kode_ambil : null;
            return $data;
        });

        return response()->json([
            'success' => true,
            'tab'     => $tab,
            'mitra'   => [
                'id_mitra'   => $mitra->id_mitra,
                'nama_usaha' => $mitra->nama_usaha,
                'saldo'      => (float) $mitra->saldo,
            ],
            'data'    => $orders,
        ]);
    }

    /**
     * POST /api/mitra/pesanan/{kode}/siap
     * POST /api/partner/orders/{order_id}/ready
     * Aksi Mitra - "Siap": Generate kode ambil LB-XXXXXX, ubah status ke READY_FOR_PICKUP
     */
    public function siap(Request $r, string $kode): JsonResponse
    {
        $p = $this->pesananMilik($r, $kode);

        if ($p->status !== 'menunggu' || $p->status_bayar !== 'lunas') {
            return response()->json([
                'success' => false,
                'message' => 'Pesanan sudah berada di status ' . $p->status . ' (tidak dapat ditandai siap).',
            ], 422);
        }

        // Generate kode unik pengambilan format: LB-XXXXXX (6 digit unik)
        do {
            $kodeAmbil = 'LB-' . str_pad((string) random_int(100000, 999999), 6, '0', STR_PAD_LEFT);
        } while (Pesanan::where('kode_ambil', $kodeAmbil)->where('status', 'siap')->exists());

        $p->update([
            'status'      => 'siap', // READY_FOR_PICKUP
            'kode_ambil'  => $kodeAmbil,
            'siap_at'     => now(),
            'batas_ambil' => now()->addHours(2),
        ]);

        Log::info("Pesanan {$p->kode} siap diambil. Kode Pengambilan: {$kodeAmbil}. Push notifikasi dikirim ke Pelanggan {$p->user_id}.");

        return response()->json([
            'success'     => true,
            'message'     => 'Pesanan berhasil disiapkan dan siap diambil.',
            'kode_ambil'  => $kodeAmbil,
            'batas_ambil' => $p->batas_ambil->toIso8601String(),
            'data'        => $p->fresh(['mitra', 'produk', 'user'])->toApi(),
        ]);
    }

    /**
     * POST /api/mitra/pesanan/{kode}/ambil
     * POST /api/partner/orders/verify-pickup
     * Payload: { "pickup_code": "LB-XXXXXX" } atau { "kode_ambil": "..." } atau scan QR string
     */
    public function ambil(Request $r, ?string $kode = null): JsonResponse
    {
        $inputCode = trim((string) ($r->pickup_code ?? $r->kode_ambil ?? $r->code ?? ''));

        // Jika QR code mengirim format "LB-YYMMDD-XXXX|LB-XXXXXX"
        if (str_contains($inputCode, '|')) {
            $parts = explode('|', $inputCode);
            if (!$kode && !empty($parts[0])) {
                $kode = trim($parts[0]);
            }
            $inputCode = trim($parts[1] ?? $parts[0]);
        }

        // Standarisasi format LB-XXXXXX
        if (preg_match('/^\d{6}$/', $inputCode)) {
            $inputCode = 'LB-' . $inputCode;
        }
        $inputCode = strtoupper($inputCode);

        // Cari pesanan berdasarkan kode pesanan atau kode pengambilan
        $q = Pesanan::with(['mitra', 'produk', 'user']);
        if ($kode) {
            $q->where(function ($query) use ($kode) {
                $query->where('kode', $kode)->orWhere('id', $kode);
            });
        }
        if ($inputCode) {
            $q->where('kode_ambil', $inputCode);
        }

        $p = $q->first();

        if (!$p) {
            return response()->json([
                'success' => false,
                'message' => 'Pesanan dengan kode pengambilan "' . $inputCode . '" tidak ditemukan.',
            ], 404);
        }

        // Verifikasi Mitra pemilik jika request membawa id_mitra / phone
        $mitra = $this->resolveMitra($r);
        if ($mitra && $p->id_mitra !== $mitra->id_mitra) {
            return response()->json([
                'success' => false,
                'message' => 'Pesanan ini bukan milik tokomu.',
            ], 403);
        }

        // Validasi status: hanya pesanan berstatus 'siap' (READY_FOR_PICKUP) yang bisa diambil
        if ($p->status !== 'siap') {
            return response()->json([
                'success' => false,
                'message' => 'Pesanan belum siap atau sudah berstatus ' . $p->status . '.',
            ], 422);
        }

        // Validasi kecocokan kode pengambilan
        if (!hash_equals((string) $p->kode_ambil, $inputCode)) {
            return response()->json([
                'success' => false,
                'message' => 'Kode pengambilan tidak cocok. Mohon periksa kembali kode dari pembeli.',
            ], 422);
        }

        $pendapatanToko = $p->qty * $p->harga_satuan;

        DB::transaction(function () use ($p, $pendapatanToko) {
            // Ubah status ke 'selesai' (COMPLETED)
            $p->update([
                'status'    => 'selesai',
                'diambil_at' => now(),
            ]);

            // Tambahkan saldo mitra (Wallet Mitra += Harga Pesanan - Komisi App)
            Mitra::where('id_mitra', $p->id_mitra)->increment('saldo', $pendapatanToko);
        });

        $mitraUpdated = Mitra::where('id_mitra', $p->id_mitra)->first();

        Log::info("Pesanan {$p->kode} SELESAI diverifikasi oleh mitra. Saldo Mitra bertambah +Rp {$pendapatanToko}. Saldo saat ini: Rp {$mitraUpdated?->saldo}.");

        return response()->json([
            'success'          => true,
            'message'          => 'Pengambilan paket berhasil diverifikasi! Pesanan telah selesai.',
            'pendapatan'       => $pendapatanToko,
            'saldo_terbaru'    => (float) $mitraUpdated?->saldo,
            'data'             => $p->fresh(['mitra', 'produk', 'user'])->toApi(),
        ]);
    }

    /**
     * POST /api/mitra/pesanan/{kode}/tolak
     * Menolak pesanan saat baru masuk, restock produk, proses refund
     */
    public function tolak(Request $r, string $kode): JsonResponse
    {
        $p = $this->pesananMilik($r, $kode);

        if ($p->status !== 'menunggu') {
            return response()->json([
                'success' => false,
                'message' => 'Pesanan tidak bisa ditolak karena sudah berada di status ' . $p->status . '.',
            ], 422);
        }

        DB::transaction(function () use ($p) {
            Produk::where('id', $p->produk_id)->increment('stok', $p->qty);
            $p->update([
                'status'       => 'dibatalkan',
                'status_bayar' => $p->status_bayar === 'lunas' ? 'refund' : $p->status_bayar,
            ]);
            Log::info("Mitra menolak pesanan {$p->kode}. Stok produk #{$p->produk_id} dikembalikan (+{$p->qty}).");
        });

        return response()->json([
            'success' => true,
            'message' => 'Pesanan berhasil ditolak. Stok produk dikembalikan dan dana pembeli akan dikembalikan.',
            'data'    => $p->fresh(['mitra', 'produk', 'user'])->toApi(),
        ]);
    }
}

}