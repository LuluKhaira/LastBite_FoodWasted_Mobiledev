<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Pesanan;
use App\Models\Produk;                      // <- sesuaikan kalau nama model produkmu beda
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class PesananController extends Controller
{
    private const BIAYA_LAYANAN = 2000;     // sama dengan _fee di detail_paket.dart
    private const KG_PER_PAKET  = 0.4;      // estimasi bila produk tidak punya berat_kg
    private const CO2_PER_KG    = 2.5;      // estimasi kg CO2e per kg makanan (angka kasar)

    /** GET /api/pesanan */
    public function index(Request $r): JsonResponse
    {
        $data = Pesanan::where('user_id', $r->user()->id)
            ->latest('id')
            ->get()
            ->map(fn (Pesanan $p) => $p->toApi());

        return response()->json(['data' => $data]);
    }

    /** POST /api/pesanan  {produk_id, qty, metode, catatan?} */
    public function store(Request $r): JsonResponse
    {
        $v = $r->validate([
            'produk_id' => 'required|integer',
            'qty'       => 'required|integer|min:1|max:20',
            'metode'    => 'required|string|max:30',
            'catatan'   => 'nullable|string|max:300',
        ]);

        $pesanan = DB::transaction(function () use ($r, $v) {
            // kunci baris produk supaya stok tidak ke-oversell kalau 2 orang bayar bersamaan
            $produk = Produk::lockForUpdate()->find($v['produk_id']);
            if (! $produk) {
                throw ValidationException::withMessages(['produk_id' => 'Produk tidak ditemukan.']);
            }
            if ((int) $produk->stok < $v['qty']) {
                throw ValidationException::withMessages(['qty' => 'Stok tidak mencukupi atau sudah habis.']);
            }

            $harga = (int) $produk->harga;
            $asli  = (int) ($produk->harga_asli ?? $harga);
            $kg    = (float) ($produk->berat_kg ?: self::KG_PER_PAKET);
            $kgTot = round($kg * $v['qty'], 2);

            // ---- SESUAIKAN: asal nama penjual / alamat / gambar di skema produkmu ----
            $mitra   = $produk->mitra ?? null;
            $penjual = $produk->penjual
                ?? $mitra->nama_usaha ?? $mitra->nama_toko ?? $mitra->nama
                ?? 'Mitra Lastbite';
            $alamat  = $produk->alamat ?? $mitra->alamat ?? null;
            // --------------------------------------------------------------------------

            $pesanan = Pesanan::create([
                'user_id'           => $r->user()->id,
                'produk_id'         => $produk->id,
                'id_mitra'          => $produk->id_mitra ?? null,
                'penjual'           => $penjual,
                'inisial'           => $produk->inisial ?? null,
                'alamat'            => $alamat,
                'produk'            => $produk->nama,
                'gambar'            => $produk->gambar,
                'metode'            => $v['metode'],
                'qty'               => $v['qty'],
                'harga_satuan'      => $harga,
                'harga_asli_satuan' => $asli,
                'biaya_layanan'     => $harga === 0 ? 0 : self::BIAYA_LAYANAN,
                'co2'               => round($kgTot * self::CO2_PER_KG, 2),
                'makanan'           => $kgTot,
                'status'            => 'menunggu',
                'catatan'           => $v['catatan'] ?? null,
            ]);

            $pesanan->update([
                'kode' => sprintf('LB-%s-%04d', now('Asia/Jakarta')->format('ymd'), $pesanan->id),
            ]);

            $produk->decrement('stok', $v['qty']);

            return $pesanan->fresh();
        });

        return response()->json(['data' => $pesanan->toApi()], 201);
    }

    /** GET /api/pesanan/{kode} */
    public function show(Request $r, string $kode): JsonResponse
    {
        return response()->json(['data' => $this->milik($r, $kode)->toApi()]);
    }

    /** POST /api/pesanan/{kode}/selesai — pesanan sudah diambil */
    public function selesai(Request $r, string $kode): JsonResponse
    {
        $p = $this->milik($r, $kode);
        if ($p->status !== 'menunggu') {
            throw ValidationException::withMessages(['status' => 'Pesanan ini sudah tidak aktif.']);
        }
        $p->update(['status' => 'selesai']);

        return response()->json(['data' => $p->toApi()]);
    }

    /** POST /api/pesanan/{kode}/rating  {rating: 1..5} */
    public function rating(Request $r, string $kode): JsonResponse
    {
        $v = $r->validate(['rating' => 'required|integer|min:1|max:5']);

        $p = $this->milik($r, $kode);
        if ($p->status !== 'selesai') {
            throw ValidationException::withMessages(['rating' => 'Pesanan belum selesai.']);
        }
        $p->update(['rating' => $v['rating']]);

        return response()->json(['data' => $p->toApi()]);
    }

    private function milik(Request $r, string $kode): Pesanan
    {
        return Pesanan::where('user_id', $r->user()->id)->where('kode', $kode)->firstOrFail();
    }
}