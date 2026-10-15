<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasColumn('pesanans', 'id_mitra')) {
            return;
        }

        Schema::table('pesanans', function (Blueprint $t) {
            // tabel lama punya id_mitra -> mitras.id_mitra; dikembalikan supaya
            // dashboard mitra nanti bisa melihat pesanan toko-nya
            $t->unsignedBigInteger('id_mitra')->nullable()->after('produk_id');
            $t->foreign('id_mitra')->references('id_mitra')->on('mitras')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('pesanans', function (Blueprint $t) {
            $t->dropForeign(['id_mitra']);
            $t->dropColumn('id_mitra');
        });
    }
};