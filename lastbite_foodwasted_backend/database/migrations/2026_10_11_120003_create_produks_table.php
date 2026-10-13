<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('produks', function (Blueprint $t) {
            $t->id();
            $t->unsignedBigInteger('id_mitra');
            $t->foreign('id_mitra')->references('id_mitra')->on('mitras')->cascadeOnDelete();
            $t->string('nama');
            $t->text('deskripsi')->nullable();
            $t->string('tipe')->default('dimakan');   // dimakan | ternak
            $t->string('kategori');                   // Roti & Bakery, Makanan Siap Saji, Sayur & Buah, Pakan Ternak, Bahan Pupuk
            $t->string('gambar')->nullable();
            $t->string('tag')->nullable();
            $t->unsignedInteger('harga')->default(0);
            $t->unsignedInteger('harga_asli')->nullable();
            $t->string('satuan')->default('/paket');
            $t->unsignedInteger('stok')->default(0);
            $t->decimal('berat_kg', 8, 2)->default(0); // untuk hitung makanan terselamatkan
            $t->time('waktu_mulai')->nullable();
            $t->time('waktu_selesai')->nullable();
            $t->decimal('rating', 2, 1)->default(0);
            $t->boolean('aktif')->default(true);
            $t->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('produks'); }
};
