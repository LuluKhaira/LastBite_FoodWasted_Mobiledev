<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasColumn('pesanans', 'total')) {
            Schema::table('pesanans', function (Blueprint $table) {
                $table->unsignedBigInteger('total')->default(0)->after('biaya_layanan');
            });
        }

        DB::statement('UPDATE pesanans SET total = qty * harga_satuan + biaya_layanan WHERE total = 0 AND harga_satuan > 0');
    }

    public function down(): void
    {
        if (Schema::hasColumn('pesanans', 'total')) {
            Schema::table('pesanans', function (Blueprint $table) {
                $table->dropColumn('total');
            });
        }
    }
};
