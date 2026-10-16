<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Sanctum\HasApiTokens;

class Mitra extends Model
{
    use HasFactory;
    use HasApiTokens;

    protected $table = 'mitras';
    protected $primaryKey = 'id_mitra';
    protected $hidden = ['password', 'otp'];

    protected $fillable = [
        'no_whatsapp',
        'otp',
        'alamat',
        'foto_ktp',
        'foto_npwp',
        'sertifikat_halal',
        'no_rekening',
        'status_verifikasi',
        'saldo',
    ];
}