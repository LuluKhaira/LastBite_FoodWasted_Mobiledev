<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MitraFavorit extends Model
{
    protected $table = 'mitra_favorits';

    protected $fillable = [
        'user_id',
        'id_mitra',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function mitra()
    {
        return $this->belongsTo(Mitra::class, 'id_mitra', 'id_mitra');
    }
}