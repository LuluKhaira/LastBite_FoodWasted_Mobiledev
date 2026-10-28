<?php

namespace App\Models;

class PengalihanKategori
{
    /**
     * Cadangan bila tabel kategoris belum ada / kosong.
     * Sumber utama sekarang tabel kategoris (diatur admin).
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
        try {
            $tujuan = Kategori::with('tujuan')->where('nama', $kategoriAsal)->first()?->tujuan;
            if ($tujuan) {
                return ['tipe' => $tujuan->tipe, 'kategori' => $tujuan->nama];
            }
        } catch (\Throwable $e) {
            // tabel kategoris belum dimigrasi: pakai cadangan di bawah
        }

        return self::MAP[$kategoriAsal]
            ?? ['tipe' => 'pakan', 'kategori' => Produk::KATEGORI_EXPIRED];
    }

    /** Tipe (pakan/kompos) dari sebuah kategori tujuan, null bila tidak dikenal. */
    public static function tipeUntuk(string $kategori): ?string
    {
        try {
            $tipe = Kategori::where('nama', $kategori)->value('tipe');
            if ($tipe) {
                return $tipe;
            }
        } catch (\Throwable $e) {
        }

        foreach (self::semuaTujuan() as $t) {
            if ($t['kategori'] === $kategori) {
                return $t['tipe'];
            }
        }

        return null;
    }

    /** Daftar semua kategori tujuan pakan/kompos untuk dropdown Flutter. */
    public static function semuaTujuan(): array
    {
        try {
            $rows = Kategori::aktif()
                ->whereIn('tipe', ['pakan', 'kompos'])
                ->orderBy('urutan')->orderBy('nama')
                ->get(['nama', 'tipe']);

            if ($rows->isNotEmpty()) {
                return $rows->map(fn ($k) => ['tipe' => $k->tipe, 'kategori' => $k->nama])->all();
            }
        } catch (\Throwable $e) {
        }

        return [
            ['tipe' => 'pakan',  'kategori' => 'Pakan Ternak & Ikan'],
            ['tipe' => 'kompos', 'kategori' => 'Bahan Kompos & Pupuk'],
            ['tipe' => 'kompos', 'kategori' => 'Ampas Kelapa & Kopi'],
            ['tipe' => 'kompos', 'kategori' => 'Limbah Organik'],
        ];
    }
}