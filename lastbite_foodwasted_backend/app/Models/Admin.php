<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Admin extends Model
{
    protected $table = 'admins';

    protected $primaryKey = 'id_admin';

    protected $fillable = ['username', 'password'];

    protected $hidden = ['password'];

    // Password otomatis di-hash saat disimpan
    protected function casts(): array
    {
        return ['password' => 'hashed'];
    }
}