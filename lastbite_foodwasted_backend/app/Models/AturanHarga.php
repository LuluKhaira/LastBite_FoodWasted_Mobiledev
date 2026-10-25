<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AturanHarga extends Model
{
    protected $table = 'aturan_harga';
    protected $guarded = [];

    public static function aktif(): self
    {
        return static::firstOrCreate([]);
    }
}