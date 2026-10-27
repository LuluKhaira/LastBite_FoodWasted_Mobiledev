<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('produks', function (Blueprint $table) {
            // Null = pakai mapping default dari PengalihanKategori::MAP
            $table->string('target_kategori_pengalihan')->nullable()->after('kategori_asli');
        });
    }

    public function down(): void
    {
        Schema::table('produks', function (Blueprint $table) {
            $table->dropColumn('target_kategori_pengalihan');
        });
    }
};