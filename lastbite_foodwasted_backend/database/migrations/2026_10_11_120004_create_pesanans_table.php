<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('pesanans', function (Blueprint $t) {
            $t->id();
            $t->string('kode')->unique();               // LB-260930-0412
            $t->foreignId('user_id')->constrained()->cascadeOnDelete();
            $t->foreignId('produk_id')->constrained('produks');
            $t->unsignedBigInteger('id_mitra');
            $t->foreign('id_mitra')->references('id_mitra')->on('mitras');
            $t->unsignedInteger('qty');
            $t->unsignedInteger('harga_satuan');
            $t->unsignedInteger('harga_asli_satuan');
            $t->unsignedInteger('biaya_layanan')->default(1000);
            $t->unsignedInteger('total');
            $t->string('metode');                       // QRIS / GoPay / DANA
            $t->string('status')->default('menunggu');  // menunggu | dibayar | diambil | batal
            $t->decimal('co2', 8, 2)->default(0);
            $t->decimal('makanan_kg', 8, 2)->default(0);
            $t->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('pesanans'); }
};
