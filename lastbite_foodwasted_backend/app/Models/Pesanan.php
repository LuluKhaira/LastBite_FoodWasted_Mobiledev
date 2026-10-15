<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pesanan extends Model
{
    protected $table = 'pesanans';

    protected $fillable = [
        'kode', 'user_id', 'produk_id', 'id_mitra',
        'penjual', 'inisial', 'alamat', 'produk', 'gambar',
        'metode', 'qty', 'harga_satuan', 'harga_asli_satuan', 'biaya_layanan',
        'co2', 'makanan', 'status', 'rating', 'catatan',
    ];

    protected $casts = [
        'co2'      => 'float',
        'makanan'  => 'float',
        'qty'      => 'integer',
        'rating'   => 'integer',
    ];

    /** Bentuk JSON yang dibaca Pesanan.fromJson di Flutter. */
    public function toApi(): array
    {
        $t = $this->created_at->copy()->timezone('Asia/Jakarta');

        return [
            'kode'              => $this->kode,
            'tanggal'           => $t->isToday() ? 'Hari ini' : $t->locale('id')->translatedFormat('d M Y'),
            'jam'               => $t->format('H.i'),
            'penjual'           => $this->penjual,
            'inisial'           => $this->inisial,
            'alamat'            => $this->alamat,
            'produk'            => $this->produk,
            'gambar'            => $this->gambar,
            'metode'            => $this->metode,
            'qty'               => $this->qty,
            'harga_satuan'      => (int) $this->harga_satuan,
            'harga_asli_satuan' => (int) $this->harga_asli_satuan,
            'biaya_layanan'     => (int) $this->biaya_layanan,
            'co2'               => $this->co2,
            'makanan'           => $this->makanan,
            'status'            => $this->status,
            'rating'            => $this->rating,
            // "Baru Selesai": sudah selesai tapi belum diberi bintang
            'baru'              => $this->status === 'selesai' && $this->rating === null,
        ];
    }
}