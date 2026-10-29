<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('kategoris', function (Blueprint $table) {
            $table->unsignedInteger('harga_per_kg')->default(0)->after('urutan');
        });

        // Set harga default untuk kategori pakan/kompos yang ada agar langsung memiliki harga valid
        $defaultHarga = [
            'Pakan Ternak & Ikan'  => 5000,
            'Bahan Kompos & Pupuk' => 3000,
            'Ampas Kelapa & Kopi'  => 2500,
            'Limbah Organik'       => 2000,
        ];

        foreach ($defaultHarga as $nama => $harga) {
            DB::table('kategoris')->where('nama', $nama)->update(['harga_per_kg' => $harga]);
        }
    }

    public function down(): void
    {
        Schema::table('kategoris', function (Blueprint $table) {
            $table->dropColumn('harga_per_kg');
        });
    }
};

