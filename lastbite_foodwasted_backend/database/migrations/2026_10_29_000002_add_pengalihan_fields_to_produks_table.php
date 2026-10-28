<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('produks', function (Blueprint $table) {
            $table->boolean('bersedia_dialihkan')->default(false)->after('target_kategori_pengalihan');
            $table->decimal('perkiraan_berat_per_paket', 8, 2)->nullable()->after('bersedia_dialihkan');
            $table->string('status_pengalihan', 30)->default('tidak_dialihkan')->after('perkiraan_berat_per_paket');
            $table->decimal('berat_aktual', 8, 2)->nullable()->after('status_pengalihan');
            $table->foreignId('produk_surplus_id')->nullable()->after('berat_aktual')->constrained('produks')->nullOnDelete();
            $table->timestamp('dikonfirmasi_pada')->nullable()->after('produk_surplus_id');
            $table->text('catatan_pengalihan')->nullable()->after('dikonfirmasi_pada');

            $table->index('status_pengalihan');
            $table->index('bersedia_dialihkan');
        });
    }

    public function down(): void
    {
        Schema::table('produks', function (Blueprint $table) {
            $table->dropForeign(['produk_surplus_id']);
            $table->dropIndex(['status_pengalihan']);
            $table->dropIndex(['bersedia_dialihkan']);
            $table->dropColumn([
                'bersedia_dialihkan',
                'perkiraan_berat_per_paket',
                'status_pengalihan',
                'berat_aktual',
                'produk_surplus_id',
                'dikonfirmasi_pada',
                'catatan_pengalihan',
            ]);
        });
    }
};

