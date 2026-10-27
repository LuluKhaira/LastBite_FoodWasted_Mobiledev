<?php

namespace App\Models;

class PengalihanKategori
{
    /**
     * Mapping default kategori konsumsi manusia -> tujuan saat kadaluarsa.
     */
    public const MAP = [
        'Roti & Pastry'        => ['tipe' => 'pakan',  'kategori' => 'Pakan Ternak & Ikan'],
        'Roti Tawar'           => ['tipe' => 'pakan',  'kategori' => 'Pakan Ternak & Ikan'],
        'Siap Santap'          => ['tipe' => 'pakan',  'kategori' => 'Pakan Ternak & Ikan'],
        'Sayur & Buah'         => ['tipe' => 'kompos', 'kategori' => 'Bahan Kompos & Pupuk'],
        'Bahan Olahan'         => ['tipe' => 'kompos', 'kategori' => 'Limbah Organik'],
        'Bahan & Olahan Dapur' => ['tipe' => 'kompos', 'kategori' => 'Limbah Organik'],
    ];

    /** Cari tujuan berdasarkan kategori asal (fallback ke default pakan). */
    public static function cariTujuan(string $kategoriAsal): array
    {
        return self::MAP[$kategoriAsal]
            ?? ['tipe' => 'pakan', 'kategori' => Produk::KATEGORI_EXPIRED];
    }

    /** Daftar semua kategori tujuan pakan/kompos untuk dropdown Flutter. */
    public static function semuaTujuan(): array
    {
        return [
            ['tipe' => 'pakan',  'kategori' => 'Pakan Ternak & Ikan'],
            ['tipe' => 'pakan',  'kategori' => 'Bahan Kompos & Pupuk'],
            ['tipe' => 'kompos', 'kategori' => 'Ampas Kelapa & Kopi'],
            ['tipe' => 'kompos', 'kategori' => 'Limbah Organik'],
        ];
    }
}