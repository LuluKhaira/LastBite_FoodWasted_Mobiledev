<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('pesanans', function (Blueprint $t) {
            if (!Schema::hasColumn('pesanans', 'penjual'))  $t->string('penjual')->default('');
            if (!Schema::hasColumn('pesanans', 'inisial'))  $t->string('inisial', 4)->nullable();
            if (!Schema::hasColumn('pesanans', 'alamat'))   $t->string('alamat')->nullable();
            if (!Schema::hasColumn('pesanans', 'produk'))   $t->string('produk')->default('');
            if (!Schema::hasColumn('pesanans', 'gambar'))   $t->text('gambar')->nullable();
            if (!Schema::hasColumn('pesanans', 'makanan'))  $t->decimal('makanan', 8, 2)->default(0);
            if (!Schema::hasColumn('pesanans', 'rating'))   $t->unsignedTinyInteger('rating')->nullable();
            if (!Schema::hasColumn('pesanans', 'catatan'))  $t->text('catatan')->nullable();
        });

        // Kolom skema lama yang tidak diisi oleh model Pesanan
        DB::statement('ALTER TABLE pesanans MODIFY produk_id BIGINT UNSIGNED NULL');
        if (Schema::hasColumn('pesanans', 'total')) {
            DB::statement('ALTER TABLE pesanans MODIFY total INT UNSIGNED NOT NULL DEFAULT 0');
        }
    }

    public function down(): void
    {
        // sengaja kosong
    }
};