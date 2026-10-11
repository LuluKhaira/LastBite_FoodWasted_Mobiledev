<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Mitra extends Model
{
    use HasFactory;
    protected $primaryKey = 'id_mitra';

    protected $fillable = [
        'no_whatsapp',
        'alamat',
        'foto_ktp',
        'foto_npwp',
        'sertifikat_halal',
        'no_rekening',
        'status_verifikasi',
        'saldo',
    ];
}