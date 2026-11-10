<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Kategori extends Model
{
    public const TIPE = ['dimakan', 'pakan', 'kompos'];

    protected $guarded = [];

    protected $casts = [
        'aktif'        => 'boolean',
        'harga_per_kg' => 'integer',
    ];

    /** Kategori tujuan pengalihan (untuk kategori bertipe dimakan). */
    public function tujuan()
    {
        return $this->belongsTo(self::class, 'tujuan_id');
    }

    public function produks()
    {
        return $this->hasMany(Produk::class, 'kategori_id');
    }

    public function scopeAktif($query)
    {
        return $query->where('aktif', true);
    }

    public function scopeTujuanPengalihan($query)
    {
        return $query->where('aktif', true)
            ->whereIn('tipe', ['pakan', 'kompos']);
    }

    public function hasValidHarga(): bool
    {
        return $this->harga_per_kg !== null && $this->harga_per_kg > 0;
    }

    protected static function booted(): void
    {
        static::deleting(function (Kategori $kategori) {
            $dipakai = \Illuminate\Support\Facades\DB::table('produks')
                ->where('kategori_id', $kategori->id)
                ->orWhere('kategori_asli_id', $kategori->id)
                ->orWhere('target_kategori_id', $kategori->id)
                ->exists();

            if ($dipakai) {
                throw new \Exception("Kategori \"{$kategori->nama}\" tidak dapat dihapus karena masih digunakan oleh produk.");
            }

            if (static::where('tujuan_id', $kategori->id)->exists()) {
                throw new \Exception("Kategori \"{$kategori->nama}\" tidak dapat dihapus karena masih dijadikan tujuan pengalihan oleh kategori lain.");
            }
        });
    }
}
