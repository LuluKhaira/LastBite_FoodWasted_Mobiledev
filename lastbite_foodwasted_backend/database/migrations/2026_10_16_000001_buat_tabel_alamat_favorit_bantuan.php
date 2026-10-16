<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasTable('alamats')) {
            Schema::create('alamats', function (Blueprint $t) {
                $t->id();
                $t->foreignId('user_id')->constrained()->cascadeOnDelete();
                $t->string('label', 40);                 // Rumah / Kantor / Tempat Kerja / bebas
                $t->string('nama_penerima', 100);
                $t->string('telepon', 20);
                $t->text('alamat');
                $t->string('patokan', 200)->nullable();
                $t->boolean('is_utama')->default(false);
                $t->timestamps();
            });
        }

        if (! Schema::hasTable('mitra_favorits')) {
            Schema::create('mitra_favorits', function (Blueprint $t) {
                $t->id();
                $t->foreignId('user_id')->constrained()->cascadeOnDelete();
                $t->unsignedBigInteger('id_mitra');
                $t->timestamps();

                $t->unique(['user_id', 'id_mitra']);
                $t->foreign('id_mitra')->references('id_mitra')->on('mitras')->cascadeOnDelete();
            });
        }

        if (! Schema::hasTable('faqs')) {
            Schema::create('faqs', function (Blueprint $t) {
                $t->id();
                $t->string('kategori', 60);
                $t->string('pertanyaan');
                $t->text('jawaban');
                $t->string('tip')->nullable();            // kotak "Tip ramah lingkungan"
                $t->unsignedSmallInteger('urutan')->default(0);
                $t->boolean('aktif')->default(true);
                $t->timestamps();
            });
        }

        if (! Schema::hasTable('pesan_bantuans')) {
            Schema::create('pesan_bantuans', function (Blueprint $t) {
                $t->id();
                $t->foreignId('user_id')->constrained()->cascadeOnDelete();
                $t->string('kanal', 20)->default('whatsapp');   // whatsapp | live
                $t->text('pesan');
                $t->string('status', 20)->default('baru');      // baru | terkirim | gagal
                $t->text('balasan')->nullable();                // diisi tim CS (lewat database)
                $t->timestamp('dibalas_at')->nullable();
                $t->timestamps();
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('pesan_bantuans');
        Schema::dropIfExists('faqs');
        Schema::dropIfExists('mitra_favorits');
        Schema::dropIfExists('alamats');
    }
};