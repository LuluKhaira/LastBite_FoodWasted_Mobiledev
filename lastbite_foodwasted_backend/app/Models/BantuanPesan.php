<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BantuanPesan extends Model
{
    protected $table = 'bantuan_pesans';

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
