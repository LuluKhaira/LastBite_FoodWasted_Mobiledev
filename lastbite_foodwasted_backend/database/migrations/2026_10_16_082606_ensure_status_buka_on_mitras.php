<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasColumn('mitras', 'status_buka')) {
            Schema::table('mitras', function (Blueprint $table) {
                $table->boolean('status_buka')->default(true);
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('mitras', 'status_buka')) {
            Schema::table('mitras', function (Blueprint $table) {
                $table->dropColumn('status_buka');
            });
        }
    }
};