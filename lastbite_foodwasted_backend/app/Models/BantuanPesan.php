<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BantuanPesan extends Model
{
    // Nama tabel di migration 2026_10_16_000001 adalah 'pesan_bantuans'
    protected $table = 'pesan_bantuans';

    protected $fillable = [
        'user_id',
        'pesan',
        'balasan',
        'kanal',
        'status',
        'dibalas_at',
    ];

    protected $casts = [
        'dibalas_at' => 'datetime',
    ];
}