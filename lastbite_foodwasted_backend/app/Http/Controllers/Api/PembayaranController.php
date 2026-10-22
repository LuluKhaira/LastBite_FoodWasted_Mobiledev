<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Pesanan;
use App\Models\Produk;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Midtrans\Config;
use Midtrans\Snap;
use Midtrans\Transaction;

class PembayaranController extends Controller
{
    private function setupMidtrans(): void
    {
        Config::$serverKey    = config('services.midtrans.server_key');
        Config::$isProduction = (bool) config('services.midtrans.is_production');
        Config::$isSanitized  = true;
        Config::$is3ds        = true;
    }

    private function milik(Request $request, string $kode): Pesanan
    {
        return Pesanan::where('kode', $kode)
            ->where('user_id', $request->user()->id)
            ->firstOrFail();
    }

    /** POST /api/pesanan/{kode}/bayar */
    public function buat(Request $request, string $kode): JsonResponse
    {
        $this->setupMidtrans();
        $pesanan = $this->milik($request, $kode);

        if ($pesanan->status_bayar === 'lunas') {
            return response()->json(['message' => 'Pesanan ini sudah dibayar.'], 422);
        }

        $total = ($pesanan->qty * $pesanan->harga_satuan) + $pesanan->biaya_layanan;
        if ($total <= 0) {
            $pesanan->status_bayar = 'lunas';
            $pesanan->save();
            return response()->json(['message' => 'Pesanan gratis, tidak perlu pembayaran.'], 200);
        }

        // order_id harus unik tiap kali membuat transaksi baru
        $orderId = $pesanan->kode . '-' . time();

        try {
            $snap = Snap::createTransaction([
                'transaction_details' => [
                    'order_id'     => $orderId,
                    'gross_amount' => (int) $total,
                ],
                'item_details' => [[
                    'id'       => (string) ($pesanan->produk_id ?? $pesanan->id),
                    'price'    => (int) $pesanan->harga_satuan,
                    'quantity' => (int) $pesanan->qty,
                    'name'     => mb_substr((string) $pesanan->produk, 0, 50),
                ], [
                    'id'       => 'biaya-layanan',
                    'price'    => (int) $pesanan->biaya_layanan,
                    'quantity' => 1,
                    'name'     => 'Biaya Layanan',
                ]],
                'customer_details' => [
                    'first_name' => $request->user()->name,
                    'email'      => $request->user()->email,
                    'phone'      => $request->user()->no_hp ?: '',
                ],
            ]);
        } catch (\Throwable $e) {
            Log::error('Midtrans createTransaction gagal: ' . $e->getMessage());
            return response()->json([
                'message' => 'Gagal membuat pembayaran: ' . $e->getMessage(),
            ], 500);
        }

        $pesanan->midtrans_order_id = $orderId;
        $pesanan->status_bayar      = 'menunggu';
        $pesanan->save();

        return response()->json([
            'redirect_url' => $snap->redirect_url,
            'token'        => $snap->token,
        ]);
    }

    /** GET /api/pesanan/{kode}/cek-bayar */
    public function cek(Request $request, string $kode): JsonResponse
    {
        $this->setupMidtrans();
        $pesanan = $this->milik($request, $kode);

        if (! $pesanan->midtrans_order_id) {
            return response()->json([
                'status_bayar' => $pesanan->status_bayar,
                'status'       => $pesanan->status,
                'data'         => $pesanan->toApi(),
            ]);
        }

        try {
            $ts          = Transaction::status($pesanan->midtrans_order_id);
            $status      = $ts->transaction_status ?? '';
            $fraud       = $ts->fraud_status ?? '';
            $paymentType = $ts->payment_type ?? null;
            if ($paymentType) {
                $pesanan->metode = strtoupper($paymentType);
            }

            if ($status === 'settlement' || ($status === 'capture' && $fraud === 'accept')) {
                $pesanan->status_bayar = 'lunas';
            } elseif (in_array($status, ['expire', 'cancel', 'deny'])) {
                $pesanan->status_bayar = 'gagal';
            } else {
                $pesanan->status_bayar = 'menunggu';
            }
            $pesanan->save();
        } catch (\Throwable $e) {
            Log::info("Cek bayar Midtrans ({$pesanan->kode}): " . $e->getMessage());
        }

        return response()->json([
            'status_bayar' => $pesanan->status_bayar,
            'status'       => $pesanan->status,
            'data'         => $pesanan->fresh(['mitra', 'produk', 'user'])->toApi(),
        ]);
    }

    /** POST /api/midtrans/webhook */
    public function webhook(Request $request): JsonResponse
    {
        $this->setupMidtrans();
        $payload = $request->all();
        Log::info('Midtrans Webhook Received: ', $payload);

        $orderId           = $payload['order_id'] ?? null;
        $statusCode        = $payload['status_code'] ?? null;
        $grossAmount       = $payload['gross_amount'] ?? null;
        $signatureKey      = $payload['signature_key'] ?? null;
        $transactionStatus = $payload['transaction_status'] ?? null;
        $fraudStatus       = $payload['fraud_status'] ?? null;
        $paymentType       = $payload['payment_type'] ?? null;

        if (! $orderId) {
            return response()->json(['message' => 'Missing order_id'], 400);
        }

        // Verifikasi signature key
        $serverKey = config('services.midtrans.server_key');
        if ($signatureKey && $serverKey && $statusCode && $grossAmount) {
            $expectedSignature = hash('sha512', $orderId . $statusCode . $grossAmount . $serverKey);
            if ($signatureKey !== $expectedSignature) {
                Log::warning('Midtrans Webhook: Invalid signature', [
                    'received' => $signatureKey,
                    'expected' => $expectedSignature,
                ]);
                return response()->json(['message' => 'Invalid signature'], 403);
            }
        }

        // Cari pesanan dari midtrans_order_id atau kode pesanan
        $pesanan = Pesanan::where('midtrans_order_id', $orderId)
            ->orWhere('kode', $orderId)
            ->orWhere('kode', explode('-', $orderId)[0] ?? '')
            ->first();

        if (! $pesanan) {
            return response()->json(['message' => 'Pesanan tidak ditemukan'], 404);
        }

        if ($paymentType) {
            $pesanan->metode = strtoupper($paymentType);
        }

        if ($transactionStatus === 'capture') {
            if ($fraudStatus === 'accept') {
                $pesanan->status_bayar = 'lunas';
                Log::info("Pesanan {$pesanan->kode} capture accepted -> Lunas.");
            } else {
                $pesanan->status_bayar = 'menunggu';
            }
        } elseif ($transactionStatus === 'settlement') {
            $pesanan->status_bayar = 'lunas';
            Log::info("Pesanan {$pesanan->kode} settlement -> Lunas. Mitra ID {$pesanan->id_mitra}: Pesanan Baru Masuk.");
        } elseif (in_array($transactionStatus, ['cancel', 'deny', 'expire'])) {
            $pesanan->status_bayar = 'gagal';
            if ($pesanan->status === 'menunggu') {
                $pesanan->status = 'dibatalkan';
                Produk::where('id', $pesanan->produk_id)->increment('stok', $pesanan->qty);
            }
        } elseif ($transactionStatus === 'refund' || $transactionStatus === 'partial_refund') {
            $pesanan->status_bayar = 'refund';
            $pesanan->status       = 'dibatalkan';
        }

        $pesanan->save();

        return response()->json([
            'status'  => 'success',
            'message' => 'Webhook processed successfully',
            'data'    => $pesanan->toApi(),
        ]);
    }
}