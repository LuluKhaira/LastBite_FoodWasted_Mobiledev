<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Pesanan;
use App\Models\Produk;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PesananController extends Controller
{
    const BIAYA_LAYANAN = 1000;
    const FAKTOR_CO2 = 2.5; // kg CO2e per kg makanan (perkiraan, sesuaikan dengan sumbermu)

    public function index(Request $r)
    {
        $data = Pesanan::with(['mitra', 'produk'])
            ->where('user_id', $r->user()->id)->latest()->get()
            ->map->toApi();
        return response()->json(['data' => $data]);
    }

    public function show(Request $r, string $kode)
    {
        $p = Pesanan::with(['mitra', 'produk'])
            ->where('user_id', $r->user()->id)->where('kode', $kode)->firstOrFail();
        return response()->json(['data' => $p->toApi()]);
    }

    public function store(Request $r)
    {
        $data = $r->validate([
            'produk_id' => 'required|exists:produks,id',
            'qty'       => 'required|integer|min:1|max:20',
            'metode'    => 'required|string|in:QRIS,GoPay,DANA,OVO,ShopeePay',
        ]);

        $pesanan = DB::transaction(function () use ($data, $r) {
            $produk = Produk::lockForUpdate()->findOrFail($data['produk_id']);
            if (!$produk->aktif || $produk->stok < $data['qty']) {
                abort(422, 'Stok tidak mencukupi.');
            }
            $produk->decrement('stok', $data['qty']);

            $makanan = round($produk->berat_kg * $data['qty'], 2);
            $subtotal = $produk->harga * $data['qty'];

            return Pesanan::create([
                'kode'              => $this->buatKode(),
                'user_id'           => $r->user()->id,
                'produk_id'         => $produk->id,
                'id_mitra'          => $produk->id_mitra,
                'qty'               => $data['qty'],
                'harga_satuan'      => $produk->harga,
                'harga_asli_satuan' => $produk->harga_asli ?? $produk->harga,
                'biaya_layanan'     => self::BIAYA_LAYANAN,
                'total'             => $subtotal + self::BIAYA_LAYANAN,
                'metode'            => $data['metode'],
                'status'            => 'menunggu',
                'makanan_kg'        => $makanan,
                'co2'               => round($makanan * self::FAKTOR_CO2, 2),
            ]);
        });

        return response()->json(['data' => $pesanan->load(['mitra', 'produk'])->toApi()], 201);
    }

    private function buatKode(): string
    {
        do {
            $kode = 'LB-' . now()->format('ymd') . '-' . str_pad((string) random_int(1, 9999), 4, '0', STR_PAD_LEFT);
        } while (Pesanan::where('kode', $kode)->exists());
        return $kode;
    }
}
