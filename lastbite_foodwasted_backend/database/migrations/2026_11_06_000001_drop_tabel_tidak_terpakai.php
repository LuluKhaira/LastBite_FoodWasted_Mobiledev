<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::dropIfExists('password_reset_tokens');
        Schema::dropIfExists('aturan_harga');
    }

    public function down(): void
    {
        Schema::create('password_reset_tokens', function (Blueprint $table) {
            $table->string('email')->primary();
            $table->string('token');
            $table->timestamp('created_at')->nullable();
        });

        Schema::create('aturan_harga', function (Blueprint $table) {
            $table->id();
            $table->unsignedTinyInteger('max_diskon')->default(100);
            $table->unsignedInteger('min_harga')->default(0);
            $table->unsignedInteger('biaya_layanan')->default(2000);
            $table->timestamps();
        });
    }
};