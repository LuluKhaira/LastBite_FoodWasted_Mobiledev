<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
{
    Schema::table('mitras', function (Blueprint $table) {
        $table->string('alamat')->nullable()->change();
    });
}

public function down(): void
{
    Schema::table('mitras', function (Blueprint $table) {
        $table->string('alamat')->nullable(false)->change();
    });
}
};
