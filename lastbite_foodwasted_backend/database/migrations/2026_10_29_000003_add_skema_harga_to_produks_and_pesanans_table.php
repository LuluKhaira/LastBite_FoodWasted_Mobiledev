<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasColumn('produks', 'skema_harga')) {
            Schema::table('produks', function (Blueprint $table) {
                $table->enum('skema_harga', ['diskon', 'sedekah'])
                    ->default('diskon')
                    ->after('kategori')
                    ->index();
            });
        }

        if (!Schema::hasColumn('pesanans', 'skema_harga')) {
            Schema::table('pesanans', function (Blueprint $table) {
                $table->enum('skema_harga', ['diskon', 'sedekah'])
                    ->default('diskon')
                    ->after('produk')
                    ->index();
            });
        }

        if (!Schema::hasColumn('pesanans', 'nilai_sedekah')) {
            Schema::table('pesanans', function (Blueprint $table) {
                $table->unsignedBigInteger('nilai_sedekah')->default(0)->after('status_bayar');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('produks', 'skema_harga')) {
            Schema::table('produks', function (Blueprint $table) {
                $table->dropIndex(['skema_harga']);
                $table->dropColumn('skema_harga');
            });
        }

        if (Schema::hasColumn('pesanans', 'skema_harga')) {
            Schema::table('pesanans', function (Blueprint $table) {
                $table->dropIndex(['skema_harga']);
                $table->dropColumn('skema_harga');
            });
        }

        if (Schema::hasColumn('pesanans', 'nilai_sedekah')) {
            Schema::table('pesanans', function (Blueprint $table) {
                $table->dropColumn('nilai_sedekah');
            });
        }
    }
};

