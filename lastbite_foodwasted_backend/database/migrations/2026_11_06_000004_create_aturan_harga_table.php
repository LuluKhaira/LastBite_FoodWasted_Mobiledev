<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('aturan_harga')) {
            Schema::create('aturan_harga', function (Blueprint $table) {
                $table->id();
                $table->unsignedTinyInteger('max_diskon')->default(100);
                $table->unsignedInteger('min_harga')->default(0);
                $table->unsignedInteger('biaya_layanan')->default(2000);
                $table->timestamps();
            });
        }

        if (DB::table('aturan_harga')->count() === 0) {
            DB::table('aturan_harga')->insert([
                'max_diskon' => 100,
                'min_harga' => 0,
                'biaya_layanan' => 2000,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('aturan_harga');
    }
};
