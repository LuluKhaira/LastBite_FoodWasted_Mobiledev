<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('produks', function (Blueprint $table) {
            $table->dateTime('kadaluarsa')->nullable()->after('waktu_selesai');
            $table->string('kategori_asli')->nullable()->after('kategori');
            $table->dateTime('dialihkan_pada')->nullable()->after('kadaluarsa');
            $table->index('kadaluarsa');
        });
    }

    public function down(): void
    {
        Schema::table('produks', function (Blueprint $table) {
            $table->dropIndex(['kadaluarsa']);
            $table->dropColumn(['kadaluarsa', 'kategori_asli', 'dialihkan_pada']);
        });
    }
};