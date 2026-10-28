<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('kategoris', function (Blueprint $table) {
            $table->id();
            $table->string('nama')->unique();
            $table->string('tipe', 20);                       // dimakan | pakan | kompos
            // Kategori tujuan saat produk kadaluarsa (hanya diisi untuk tipe "dimakan")
            $table->foreignId('tujuan_id')->nullable()->constrained('kategoris')->nullOnDelete();
            $table->unsignedSmallInteger('urutan')->default(0);
            $table->boolean('aktif')->default(true);
            $table->timestamps();
        });

        // Isi awal = daftar kategori yang selama ini ditulis langsung di kode
        $now = now();
        $awal = [
            ['Pakan Ternak & Ikan',    'pakan'],
            ['Bahan Kompos & Pupuk',   'kompos'],
            ['Ampas Kelapa & Kopi',    'kompos'],
            ['Limbah Organik',         'kompos'],
            ['Roti & Pastry',          'dimakan'],
            ['Roti Tawar',             'dimakan'],
            ['Siap Santap',            'dimakan'],
            ['Sayur & Buah',           'dimakan'],
            ['Bahan & Olahan Dapur',   'dimakan'],
        ];
        foreach ($awal as $i => [$nama, $tipe]) {
            DB::table('kategoris')->insert([
                'nama' => $nama, 'tipe' => $tipe, 'urutan' => $i + 1, 'aktif' => true,
                'created_at' => $now, 'updated_at' => $now,
            ]);
        }

        // Pemetaan default (sama dengan PengalihanKategori::MAP sebelumnya)
        $tujuan = [
            'Roti & Pastry'        => 'Pakan Ternak & Ikan',
            'Roti Tawar'           => 'Pakan Ternak & Ikan',
            'Siap Santap'          => 'Pakan Ternak & Ikan',
            'Sayur & Buah'         => 'Bahan Kompos & Pupuk',
            'Bahan & Olahan Dapur' => 'Limbah Organik',
        ];
        foreach ($tujuan as $asal => $tuju) {
            DB::table('kategoris')->where('nama', $asal)->update([
                'tujuan_id' => DB::table('kategoris')->where('nama', $tuju)->value('id'),
            ]);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('kategoris');
    }
};