<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('mitras', function (Blueprint $table) {
            $table->id('id_mitra'); 
            $table->string('no_whatsapp')->unique();
            $table->string('otp')->nullable();
            $table->string('password')->nullable();
            $table->text('alamat')->nullable();
            $table->string('foto_ktp')->nullable();
            $table->string('foto_npwp')->nullable();
            $table->string('sertifikat_halal')->nullable();
            $table->string('no_rekening')->nullable();
            $table->string('status_verifikasi')->default('pending');
            $table->decimal('saldo', 12, 2)->default(0.00);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('mitras');
    }
};