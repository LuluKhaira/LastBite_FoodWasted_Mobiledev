<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Alamat extends Model
{
    protected $table = 'alamats';

    protected $fillable = [
        'user_id',
        'label',
        'nama_penerima',
        'telepon',
        'alamat',
        'patokan',
        'is_utama',
    ];

    protected $casts = [
        'is_utama' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /** Bentuk JSON yang dibaca aplikasi Flutter. */
    public function toApi(): array
    {
        return [
            'id'            => $this->id,
            'label'         => $this->label,
            'nama_penerima' => $this->nama_penerima,
            'telepon'       => $this->telepon,
            'alamat'        => $this->alamat,
            'patokan'       => $this->patokan,
            'is_utama'      => (bool) $this->is_utama,
        ];
    }
}