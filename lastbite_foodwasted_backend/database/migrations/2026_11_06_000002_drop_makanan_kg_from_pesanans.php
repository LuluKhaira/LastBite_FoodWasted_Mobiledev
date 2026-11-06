<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasColumn('pesanans', 'makanan_kg')) {
            Schema::table('pesanans', function (Blueprint $table) {
                $table->dropColumn('makanan_kg');
            });
        }
    }

    public function down(): void
    {
        Schema::table('pesanans', function (Blueprint $table) {
            $table->decimal('makanan_kg', 8, 2)->default(0)->after('co2');
        });
    }
};