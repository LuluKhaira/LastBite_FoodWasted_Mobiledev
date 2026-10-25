<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Produk extends Model
{
    protected $guarded = [];

    protected $casts = [
        'aktif' => 'boolean',
        'rating' => 'float',
        'berat_kg' => 'float',
        'harga'      => 'float',
        'harga_asli' => 'float',
    ];

    public function mitra()
    {
        return $this->belongsTo(Mitra::class, 'id_mitra', 'id_mitra');
    }

    /** Bentuk JSON yang cocok dengan field BahanItem di Flutter. */
    public function toApi(?float $lat = null, ?float $lng = null): array
    {
        $m = $this->mitra;
        $jarak = null;

        if ($lat !== null && $lng !== null && $m?->latitude && $m?->longitude) {
            $jarak = round(
                self::haversine($lat, $lng, (float) $m->latitude, (float) $m->longitude),
                1
            );
        }

        // Database menyimpan path relatif, misalnya: produk/nama-file.jpg.
        // Ubah menjadi URL publik agar Flutter bisa memuat gambar.
        $gambarUrl = $this->gambar
            ? url('storage/' . ltrim($this->gambar, '/'))
            : null;

        return [
            'id'         => $this->id,
            'nama'       => $this->nama,
            'deskripsi'  => $this->deskripsi,
            'penjual'    => $m?->nama_usaha,
            'inisial'    => $m?->inisial,
            'alamat'     => $m?->alamat,
            'tipe'       => $this->tipe,
            'kategori'   => $this->kategori,
            'gambar'     => $gambarUrl,
            'image_url'  => $gambarUrl,
            'tag'        => $this->tag,
            'harga'      => $this->harga,
            'harga_asli' => $this->harga_asli,
            'satuan'     => $this->satuan,
            'stok'       => $this->stok,
            'berat_kg'   => $this->berat_kg,
            'rating'     => $this->rating,
            'waktu'      => $this->waktu_mulai && $this->waktu_selesai
                ? substr($this->waktu_mulai, 0, 5) . ' - ' . substr($this->waktu_selesai, 0, 5) . ' WIB'
                : null,
            'jarak_km'   => $jarak,
        ];
    }

    public static function haversine($lat1, $lng1, $lat2, $lng2): float
    {
        $r = 6371;
        $dLat = deg2rad($lat2 - $lat1);
        $dLng = deg2rad($lng2 - $lng1);
        $a = sin($dLat / 2) ** 2
            + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * sin($dLng / 2) ** 2;

        return 2 * $r * asin(sqrt($a));
    }

    public function getIsAnomaliAttribute(): bool
    {
        return $this->harga > $this->harga_asli;
    }

    public function scopeAnomali($query)
    {
        return $query->whereColumn('harga', '>', 'harga_asli');
    }
}
