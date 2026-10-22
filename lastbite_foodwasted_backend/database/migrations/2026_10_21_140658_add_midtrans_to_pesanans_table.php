<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
   public function up(): void
{
    Schema::table('pesanans', function (Blueprint $table) {
        $table->string('midtrans_order_id')->nullable();
        $table->string('status_bayar', 20)->default('belum');
    });
}

public function down(): void
{
    Schema::table('pesanans', function (Blueprint $table) {
        $table->dropColumn(['midtrans_order_id', 'status_bayar']);
    });
}
};
