<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Pesanan;
use App\Models\Produk;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class PesananController extends Controller
{
    const BIAYA_LAYANAN = 1000;
    const FAKTOR_CO2 = 2.5; // kg CO2e per kg makanan

    /** GET /api/pesanan */
    public function index(Request $r)
    {
        $data = Pesanan::with(['mitra', 'produk', 'user'])
            ->where('user_id', $r->user()->id)
            ->latest()
            ->get()
            ->map->toApi();

        return response()->json(['data' => $data]);
    }

    /** GET /api/pesanan/{kode} */
    public function show(Request $r, string $kode)
    {
        $p = Pesanan::with(['mitra', 'produk', 'user'])
            ->where('user_id', $r->user()->id)
            ->where(function ($q) use ($kode) {
                $q->where('kode', $kode)->orWhere('id', $kode);
            })
            ->firstOrFail();

        return response()->json(['data' => $p->toApi()]);
    }

    /** POST /api/pesanan */
    public function store(Request $r)
    {
        $data = $r->validate([
            'produk_id' => 'required|exists:produks,id',
            'qty'       => 'required|integer|min:1|max:20',
            'metode'    => 'nullable|string|max:30',
            'catatan'   => 'nullable|string|max:500',
        ]);

        $pesanan = DB::transaction(function () use ($data, $r) {
            $produk = Produk::with('mitra')->lockForUpdate()->findOrFail($data['produk_id']);
            if (!$produk->aktif || $produk->stok < $data['qty']) {
                abort(422, 'Stok produk tidak mencukupi.');
            }
            $produk->decrement('stok', $data['qty']);

            $mitra   = $produk->mitra;
            $makanan = round($produk->berat_kg * $data['qty'], 2);
            $gratis  = ($produk->harga == 0);

            return Pesanan::create([
                'kode'              => $this->buatKode(),
                'user_id'           => $r->user()->id,
                'produk_id'         => $produk->id,
                'id_mitra'          => $produk->id_mitra,
                'penjual'           => $mitra?->nama_usaha ?: 'Mitra LastBite',
                'inisial'           => $mitra?->inisial ?: 'LB',
                'alamat'            => $mitra?->alamat ?: 'Alamat toko',
                'produk'            => $produk->nama,
                'gambar'            => $produk->gambar,
                'qty'               => $data['qty'],
                'harga_satuan'      => $produk->harga,
                'harga_asli_satuan' => $produk->harga_asli ?? $produk->harga,
                'biaya_layanan'     => $gratis ? 0 : self::BIAYA_LAYANAN,
                'metode'            => $data['metode'] ?? 'QRIS',
                'status'            => 'menunggu',
                'status_bayar'      => $gratis ? 'lunas' : 'belum',
                'makanan'           => $makanan,
                'co2'               => round($makanan * self::FAKTOR_CO2, 2),
                'catatan'           => $data['catatan'] ?? null,
                'estimasi_menit'    => 20,
            ]);
        });

        return response()->json([
            'message' => 'Pesanan berhasil dibuat',
            'data'    => $pesanan->load(['mitra', 'produk', 'user'])->toApi(),
        ], 201);
    }

    private function buatKode(): string
    {
        do {
            $kode = 'LB-' . now()->format('ymd') . '-' . str_pad((string) random_int(1, 9999), 4, '0', STR_PAD_LEFT);
        } while (Pesanan::where('kode', $kode)->exists());
        return $kode;
    }

    /**
     * POST /api/pesanan/{kode}/batal
     * POST /api/orders/{order_id}/cancel
     * Pembatalan hanya bisa sebelum "Siap Diambil"
     */
    public function batal(Request $r, string $kode)
    {
        $p = Pesanan::where('user_id', $r->user()->id)
            ->where(function ($q) use ($kode) {
                $q->where('kode', $kode)->orWhere('id', $kode);
            })
            ->firstOrFail();

        // Validasi: Cek apakah status pesanan masih WAITING_PREPARATION (menunggu)
        if ($p->status === 'siap' || $p->status === Pesanan::STATUS_READY_FOR_PICKUP) {
            return response()->json([
                'success' => false,
                'message' => 'Pesanan tidak dapat dibatalkan karena sudah siap.',
            ], 422);
        }

        if (in_array($p->status, ['selesai', 'dibatalkan', Pesanan::STATUS_COMPLETED, Pesanan::STATUS_CANCELLED])) {
            return response()->json([
                'success' => false,
                'message' => 'Pesanan sudah ' . $p->status . ' dan tidak bisa dibatalkan.',
            ], 422);
        }

        DB::transaction(function () use ($p) {
            // 1. Restock produk
            Produk::where('id', $p->produk_id)->increment('stok', $p->qty);

            // 2. Refund jika sudah bayar
            if ($p->status_bayar === 'lunas' && $p->midtrans_order_id && $p->total > 0) {
                try {
                    \Midtrans\Config::$serverKey    = config('services.midtrans.server_key');
                    \Midtrans\Config::$isProduction = (bool) config('services.midtrans.is_production');
                    \Midtrans\Transaction::refund($p->midtrans_order_id, [
                        'amount' => (int) $p->total,
                        'reason' => 'Dibatalkan oleh pelanggan',
                    ]);
                } catch (\Throwable $e) {
                    Log::warning('Midtrans Refund info: ' . $e->getMessage());
                }
                $p->status_bayar = 'refund';
            }

            // 3. Ubah status menjadi CANCELLED
            $p->status = 'dibatalkan';
            $p->save();

            Log::info("Pesanan {$p->kode} dibatalkan oleh user {$p->user_id}. Stok produk #{$p->produk_id} dikembalikan (+{$p->qty}).");
        });

        return response()->json([
            'success' => true,
            'message' => 'Pesanan berhasil dibatalkan. Pengembalian dana penuh telah diproses.',
            'data'    => $p->fresh(['mitra', 'produk', 'user'])->toApi(),
        ]);
    }

    /** POST /api/pesanan/{kode}/rating */
    public function rating(Request $r, string $kode)
    {
        $d = $r->validate([
            'rating' => 'required|integer|min:1|max:5',
            'ulasan' => 'nullable|string|max:500',
        ]);

        $p = Pesanan::where('user_id', $r->user()->id)
            ->where(function ($q) use ($kode) {
                $q->where('kode', $kode)->orWhere('id', $kode);
            })
            ->firstOrFail();

        if ($p->status !== 'selesai' && $p->status !== Pesanan::STATUS_COMPLETED) {
            return response()->json([
                'success' => false,
                'message' => 'Ulasan hanya dapat diberikan untuk pesanan yang telah selesai.',
            ], 422);
        }

        $p->update([
            'rating' => $d['rating'],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Terima kasih atas ulasanmu!',
            'data'    => $p->fresh(['mitra', 'produk', 'user'])->toApi(),
        ]);
    }
}
