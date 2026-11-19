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
            $table->string('icon', 16)->nullable()->after('tipe');
        });

        $default = [
            'Roti & Pastry'        => '🥐',
            'Roti Tawar'           => '🍞',
            'Siap Santap'          => '🍱',
            'Sayur & Buah'         => '🥬',
            'Bahan & Olahan Dapur' => '🧺',
        ];
        foreach ($default as $nama => $icon) {
            DB::table('kategoris')->where('nama', $nama)->update(['icon' => $icon]);
        }
    }

    public function down(): void
    {
        Schema::table('kategoris', function (Blueprint $table) {
            $table->dropColumn('icon');
        });
    }
};