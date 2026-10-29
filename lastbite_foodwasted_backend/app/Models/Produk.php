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

    public const STATUS_PENGALIHAN_TIDAK    = 'tidak_dialihkan';
    public const STATUS_PENGALIHAN_MENUNGGU  = 'menunggu_konfirmasi';
    public const STATUS_PENGALIHAN_DIALIHKAN = 'dialihkan';
    public const STATUS_PENGALIHAN_DIBUANG   = 'dibuang';

    protected $guarded = [];

    protected $casts = [
        'aktif'                     => 'boolean',
        'rating'                    => 'float',
        'berat_kg'                  => 'float',
        'harga'                     => 'float',
        'harga_asli'                => 'float',
        'kadaluarsa'                => 'datetime',
        'dialihkan_pada'            => 'datetime',
        'bersedia_dialihkan'        => 'boolean',
        'perkiraan_berat_per_paket' => 'float',
        'berat_aktual'              => 'float',
        'dikonfirmasi_pada'         => 'datetime',
    ];

    public function mitra()
    {
        return $this->belongsTo(Mitra::class, 'id_mitra', 'id_mitra');
    }

    public function produkSurplus()
    {
        return $this->belongsTo(self::class, 'produk_surplus_id');
    }

    public function produkAsal()
    {
        return $this->hasOne(self::class, 'produk_surplus_id');
    }

    /** Produk yang menunggu konfirmasi pengalihan dari mitra. */
    public function scopeMenungguKonfirmasi($query)
    {
        return $query->where('status_pengalihan', self::STATUS_PENGALIHAN_MENUNGGU);
    }

    /** Menghitung estimasi sisa berat berdasarkan stok tersisa * perkiraan berat per paket */
    public function totalPerkiraanBeratSisa(): float
    {
        $stok = (int) ($this->stok ?? 0);
        $perkiraan = (float) ($this->perkiraan_berat_per_paket ?? 0);
        return round($stok * $perkiraan, 2);
    }

    public function getGambarUrlAttribute(): ?string
    {
        if (empty($this->gambar)) {
            return null;
        }

        $gambar = trim($this->gambar);
        if (str_starts_with($gambar, 'http://') || str_starts_with($gambar, 'https://')) {
            return $gambar;
        }

        $path = ltrim($gambar, '/');

        // Gunakan route API langsung /api/foto/{path} agar dapat diakses tanpa bergantung symlink webserver
        try {
            $root = request()->root();
            if (!empty($root)) {
                return rtrim($root, '/') . '/api/foto/' . $path;
            }
        } catch (\Throwable $e) {}

        return url('api/foto/' . $path);
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

        $gambarUrl = $this->gambar_url;

        return [
            'id'                        => $this->id,
            'nama'                      => $this->nama,
            'deskripsi'                 => $this->deskripsi,
            'penjual'                   => $m?->nama_usaha,
            'inisial'                   => $m?->inisial,
            'alamat'                    => $m?->alamat,
            'tipe'                      => $this->tipe,
            'kategori'                  => $this->kategori,
            'gambar'                    => $gambarUrl,
            'image_url'                 => $gambarUrl,
            'tag'                       => $this->tag,
            'harga'                     => $this->harga,
            'harga_asli'                => $this->harga_asli,
            'satuan'                    => $this->satuan,
            'stok'                      => $this->stok,
            'berat_kg'                  => $this->berat_kg,
            'rating'                    => $this->rating,
            'waktu'                     => $this->waktu_mulai && $this->waktu_selesai
                ? substr($this->waktu_mulai, 0, 5) . ' - ' . substr($this->waktu_selesai, 0, 5) . ' WIB'
                : null,
            'jarak_km'                  => $jarak,
            'kadaluarsa'                => $this->kadaluarsa
                ? Carbon::parse($this->kadaluarsa, 'Asia/Jakarta')->toIso8601String()
                : null,
            'kategori_asli'             => $this->kategori_asli,
            'dialihkan_pada'            => $this->dialihkan_pada
                ? Carbon::parse($this->dialihkan_pada, 'Asia/Jakarta')->toIso8601String()
                : null,
            'sudah_dialihkan'           => $this->dialihkan_pada !== null || $this->status_pengalihan === self::STATUS_PENGALIHAN_DIALIHKAN,
            'target_kategori_pengalihan' => $this->target_kategori_pengalihan,
            'bersedia_dialihkan'        => (bool) $this->bersedia_dialihkan,
            'perkiraan_berat_per_paket' => (float) ($this->perkiraan_berat_per_paket ?? 0),
            'status_pengalihan'         => $this->status_pengalihan ?? self::STATUS_PENGALIHAN_TIDAK,
            'berat_aktual'              => (float) ($this->berat_aktual ?? 0),
            'produk_surplus_id'         => $this->produk_surplus_id,
            'dikonfirmasi_pada'         => $this->dikonfirmasi_pada
                ? Carbon::parse($this->dikonfirmasi_pada, 'Asia/Jakarta')->toIso8601String()
                : null,
            'catatan_pengalihan'        => $this->catatan_pengalihan,
            'total_perkiraan_berat'     => $this->totalPerkiraanBeratSisa(),
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
