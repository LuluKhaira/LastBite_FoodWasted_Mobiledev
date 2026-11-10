<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 1. Tambah kolom FK dan index ke tabel produks
        Schema::table('produks', function (Blueprint $table) {
            if (!Schema::hasColumn('produks', 'kategori_id')) {
                $table->unsignedBigInteger('kategori_id')->nullable()->after('id_mitra');
                $table->foreign('kategori_id')->references('id')->on('kategoris')->restrictOnDelete();
                $table->index('kategori_id');
            }

            if (!Schema::hasColumn('produks', 'kategori_asli_id')) {
                $table->unsignedBigInteger('kategori_asli_id')->nullable()->after('kategori');
                $table->foreign('kategori_asli_id')->references('id')->on('kategoris')->restrictOnDelete();
                $table->index('kategori_asli_id');
            }

            if (!Schema::hasColumn('produks', 'target_kategori_id')) {
                $table->unsignedBigInteger('target_kategori_id')->nullable()->after('target_kategori_pengalihan');
                $table->foreign('target_kategori_id')->references('id')->on('kategoris')->restrictOnDelete();
                $table->index('target_kategori_id');
            }
        });

        // 2. Backfill data lama
        $manualMap = [
            'Bahan Olahan'  => 'Bahan & Olahan Dapur',
            'Pakan Ternak'  => 'Pakan Ternak & Ikan',
            'Makanan Berat' => 'Siap Santap',
        ];

        $kategoris = DB::table('kategoris')->pluck('id', 'nama')->all();

        $produks = DB::table('produks')->get();

        foreach ($produks as $p) {
            $updates = [];

            // (a & b) kategori -> kategori_id
            if (!empty($p->kategori)) {
                $katNama = $manualMap[$p->kategori] ?? $p->kategori;
                if (isset($kategoris[$katNama])) {
                    $updates['kategori_id'] = $kategoris[$katNama];
                    // Samakan juga teks lama jika dipetakan dari alias lama
                    if ($p->kategori !== $katNama) {
                        $updates['kategori'] = $katNama;
                    }
                }
            }

            // (c) target_kategori_pengalihan -> target_kategori_id
            if (!empty($p->target_kategori_pengalihan)) {
                $targetNama = $manualMap[$p->target_kategori_pengalihan] ?? $p->target_kategori_pengalihan;
                if (isset($kategoris[$targetNama])) {
                    $updates['target_kategori_id'] = $kategoris[$targetNama];
                    if ($p->target_kategori_pengalihan !== $targetNama) {
                        $updates['target_kategori_pengalihan'] = $targetNama;
                    }
                }
            }

            // (d) kategori_asli -> kategori_asli_id
            if (!empty($p->kategori_asli)) {
                if (!in_array($p->kategori_asli, ['Konsumsi Manusia', 'Pakan / Kompos'])) {
                    $asliNama = $manualMap[$p->kategori_asli] ?? $p->kategori_asli;
                    if (isset($kategoris[$asliNama])) {
                        $updates['kategori_asli_id'] = $kategoris[$asliNama];
                        if ($p->kategori_asli !== $asliNama) {
                            $updates['kategori_asli'] = $asliNama;
                        }
                    }
                }
            }

            if (!empty($updates)) {
                DB::table('produks')->where('id', $p->id)->update($updates);
            }
        }

        // (e) Catat peringatan jika masih ada produks yang kategori_id-nya NULL
        $unmapped = DB::table('produks')->whereNull('kategori_id')->get(['id', 'nama', 'kategori']);
        foreach ($unmapped as $un) {
            Log::warning("Produk #{$un->id} ({$un->nama}) memiliki kategori '{$un->kategori}' yang tidak dapat dipetakan ke tabel kategoris.");
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('produks', function (Blueprint $table) {
            if (Schema::hasColumn('produks', 'target_kategori_id')) {
                $table->dropForeign(['target_kategori_id']);
                $table->dropIndex(['target_kategori_id']);
                $table->dropColumn('target_kategori_id');
            }

            if (Schema::hasColumn('produks', 'kategori_asli_id')) {
                $table->dropForeign(['kategori_asli_id']);
                $table->dropIndex(['kategori_asli_id']);
                $table->dropColumn('kategori_asli_id');
            }

            if (Schema::hasColumn('produks', 'kategori_id')) {
                $table->dropForeign(['kategori_id']);
                $table->dropIndex(['kategori_id']);
                $table->dropColumn('kategori_id');
            }
        });
    }
};
