<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
{
    Schema::table('pesanans', function (Blueprint $t) {
        $t->string('kode_ambil', 12)->nullable()->unique();
        $t->unsignedSmallInteger('estimasi_menit')->default(15);
        $t->timestamp('siap_at')->nullable();
        $t->timestamp('batas_ambil')->nullable();
        $t->timestamp('diambil_at')->nullable();
    });
}

public function down(): void
{
    Schema::table('pesanans', function (Blueprint $t) {
        $t->dropColumn(['kode_ambil', 'estimasi_menit', 'siap_at', 'batas_ambil', 'diambil_at']);
    });
}
};
