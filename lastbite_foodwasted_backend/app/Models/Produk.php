<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Carbon;

class Produk extends Model
{
    /** Kategori tujuan default saat produk konsumsi manusia sudah lewat kadaluarsa. */
    public const KATEGORI_EXPIRED = 'Pakan Ternak & Ikan';

    public const TIPE_DIMAKAN = 'dimakan';
    public const TIPE_PAKAN   = 'pakan';
    public const TIPE_KOMPOS  = 'kompos';

    protected $guarded = [];

    protected $casts = [
        'aktif' => 'boolean',
        'rating' => 'float',
        'berat_kg' => 'float',
        'harga'      => 'float',
        'harga_asli' => 'float',
        'kadaluarsa'     => 'datetime',
        'dialihkan_pada' => 'datetime',
    ];

    public function mitra()
    {
        return $this->belongsTo(Mitra::class, 'id_mitra', 'id_mitra');
    }

    /** Produk yang sudah lewat kadaluarsa tapi belum dialihkan. */
    public function scopePerluDialihkan($query)
    {
        return $query->where('tipe', self::TIPE_DIMAKAN)
            ->whereNotNull('kadaluarsa')
            ->whereNull('dialihkan_pada')
            ->where('kadaluarsa', '<=', now('Asia/Jakarta'));
    }

    /** Produk yang sudah dialihkan. */
    public function scopeSudahDialihkan($query)
    {
        return $query->whereNotNull('dialihkan_pada');
    }

    /**
     * Alihkan produk ini ke kategori tujuan.
     * Prioritas: parameter -> target pilihan mitra -> mapping default.
     * Idempotent: kalau sudah dialihkan, tidak melakukan apa-apa.
     */
    public function alihkan(?string $kategoriTujuan = null, ?string $tipeTujuan = null): bool
    {
        if ($this->dialihkan_pada !== null) {
            return false;
        }

        if ($kategoriTujuan === null) {
            $kategoriTujuan = $this->target_kategori_pengalihan;
        }

        if ($kategoriTujuan === null) {
            $tujuan = PengalihanKategori::cariTujuan($this->kategori);
            $kategoriTujuan = $tujuan['kategori'];
            $tipeTujuan = $tipeTujuan ?? $tujuan['tipe'];
        }

        $this->update([
            'kategori_asli'  => $this->kategori_asli ?? $this->kategori,
            'kategori'       => $kategoriTujuan,
            'tipe'           => $tipeTujuan ?? self::TIPE_PAKAN,
            'dialihkan_pada' => now('Asia/Jakarta'),
        ]);

        return true;
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
            'kadaluarsa'     => $this->kadaluarsa
                ? Carbon::parse($this->kadaluarsa, 'Asia/Jakarta')->toIso8601String()
                : null,
            'kategori_asli'  => $this->kategori_asli,
            'dialihkan_pada' => $this->dialihkan_pada
                ? Carbon::parse($this->dialihkan_pada, 'Asia/Jakarta')->toIso8601String()
                : null,
            'sudah_dialihkan' => $this->dialihkan_pada !== null,
            'target_kategori_pengalihan' => $this->target_kategori_pengalihan,
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