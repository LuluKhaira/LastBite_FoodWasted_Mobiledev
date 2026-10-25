<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('aturan_harga', function (Blueprint $t) {
            $t->id();
            $t->unsignedTinyInteger('max_diskon')->default(100);
            $t->unsignedInteger('min_harga')->default(0);
            $t->unsignedInteger('biaya_layanan')->default(2000);
            $t->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('aturan_harga');
    }
};