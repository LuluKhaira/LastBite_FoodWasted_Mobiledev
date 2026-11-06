<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Backfill kolom total pada tabel pesanans.
     * Hanya menyentuh baris yang total-nya 0 tetapi harga_satuan > 0 (bukan produk gratis/sedekah).
     */
    public function up(): void
    {
        // Hanya menyentuh baris lama dengan total = 0 dan harga_satuan > 0
        DB::statement('UPDATE pesanans SET total = qty * harga_satuan + biaya_layanan WHERE total = 0 AND harga_satuan > 0');
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Tidak perlu di-rollback karena perbaikan data historis
    }
};
