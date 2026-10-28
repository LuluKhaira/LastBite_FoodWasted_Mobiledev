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
}
