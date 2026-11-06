<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasColumn('mitras', 'user_id')) {
            Schema::table('mitras', function (Blueprint $table) {
                $table->dropForeign(['user_id']);
                $table->dropColumn('user_id');
            });
        }
    }

    public function down(): void
    {
        Schema::table('mitras', function (Blueprint $table) {
            $table->unsignedBigInteger('user_id')->nullable()->after('id_mitra');
            $table->foreign('user_id')->references('id')->on('users')->nullOnDelete();
        });
    }
};