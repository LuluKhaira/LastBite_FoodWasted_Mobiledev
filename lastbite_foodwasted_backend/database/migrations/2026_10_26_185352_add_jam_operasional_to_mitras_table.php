<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('mitras', function (Blueprint $table) {
            // Berisi 7 entri: [{"hari":1,"buka":true,"mulai":"08:00","tutup":"21:00"}, ...]
            // hari: 1 = Senin ... 7 = Minggu. NULL = belum diatur (tidak ada pembatasan).
            $table->json('jam_operasional')->nullable()->after('status_buka');
        });
    }

    public function down(): void
    {
        Schema::table('mitras', function (Blueprint $table) {
            $table->dropColumn('jam_operasional');
        });
    }
};