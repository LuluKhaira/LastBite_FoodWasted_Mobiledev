<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pesanans', function (Blueprint $t) {
            if (Schema::hasTable('pesanans')) {
        return;
        }
            $t->id();
            $t->string('kode', 30)->nullable()->unique();      // LB-261014-0001
            $t->foreignId('user_id')->constrained()->cascadeOnDelete();
            $t->unsignedBigInteger('produk_id')->nullable()->index();

            // snapshot data produk saat dipesan (supaya riwayat tidak berubah
            // kalau mitra mengedit / menghapus produknya)
            $t->string('penjual');
            $t->string('inisial', 4)->nullable();
            $t->string('alamat')->nullable();
            $t->string('produk');
            $t->text('gambar')->nullable();

            $t->string('metode', 30);
            $t->unsignedInteger('qty')->default(1);
            $t->unsignedInteger('harga_satuan');
            $t->unsignedInteger('harga_asli_satuan');
            $t->unsignedInteger('biaya_layanan')->default(0);
            $t->decimal('co2', 8, 2)->default(0);
            $t->decimal('makanan', 8, 2)->default(0);

            $t->string('status', 20)->default('menunggu');     // menunggu | selesai | dibatalkan
            $t->unsignedTinyInteger('rating')->nullable();
            $t->text('catatan')->nullable();
            $t->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pesanans');
    }
};