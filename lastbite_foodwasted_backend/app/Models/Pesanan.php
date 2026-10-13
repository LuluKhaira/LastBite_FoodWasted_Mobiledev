<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pesanan extends Model
{
    protected $guarded = [];
    protected $casts = ['co2' => 'float', 'makanan_kg' => 'float'];

    public function user() { return $this->belongsTo(User::class); }
    public function produk() { return $this->belongsTo(Produk::class); }
    public function mitra() { return $this->belongsTo(Mitra::class, 'id_mitra', 'id_mitra'); }

    public function toApi(): array
    {
        return [
            'kode'              => $this->kode,
            'tanggal'           => $this->created_at->isToday() ? 'Hari ini' : $this->created_at->translatedFormat('d M Y'),
            'jam'               => $this->created_at->format('H.i'),
            'penjual'           => $this->mitra?->nama_usaha,
            'inisial'           => $this->mitra?->inisial,
            'alamat'            => $this->mitra?->alamat,
            'produk'            => $this->produk?->nama,
            'gambar'            => $this->produk?->gambar,
            'metode'            => $this->metode,
            'qty'               => $this->qty,
            'harga_satuan'      => $this->harga_satuan,
            'harga_asli_satuan' => $this->harga_asli_satuan,
            'biaya_layanan'     => $this->biaya_layanan,
            'total'             => $this->total,
            'status'            => $this->status,
            'co2'               => $this->co2,
            'makanan'           => $this->makanan_kg,
        ];
    }
}
