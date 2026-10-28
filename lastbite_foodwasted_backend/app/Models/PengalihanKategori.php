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
                return [
                    'tipe'         => $tujuan->tipe,
                    'kategori'     => $tujuan->nama,
                    'harga_per_kg' => (int) ($tujuan->harga_per_kg ?? 0),
                ];
            }
        } catch (\Throwable $e) {
            // tabel kategoris belum dimigrasi: pakai cadangan di bawah
        }

        $fallback = self::MAP[$kategoriAsal] ?? ['tipe' => 'pakan', 'kategori' => Produk::KATEGORI_EXPIRED];
        return array_merge($fallback, ['harga_per_kg' => 5000]);
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
                ->get(['id', 'nama', 'tipe', 'harga_per_kg']);

            if ($rows->isNotEmpty()) {
                return $rows->map(fn ($k) => [
                    'id'           => $k->id,
                    'tipe'         => $k->tipe,
                    'kategori'     => $k->nama,
                    'harga_per_kg' => (int) ($k->harga_per_kg ?? 0),
                ])->all();
            }
        } catch (\Throwable $e) {
        }

        return [
            ['id' => 1, 'tipe' => 'pakan',  'kategori' => 'Pakan Ternak & Ikan',  'harga_per_kg' => 5000],
            ['id' => 2, 'tipe' => 'kompos', 'kategori' => 'Bahan Kompos & Pupuk', 'harga_per_kg' => 3000],
            ['id' => 3, 'tipe' => 'kompos', 'kategori' => 'Ampas Kelapa & Kopi',  'harga_per_kg' => 2500],
            ['id' => 4, 'tipe' => 'kompos', 'kategori' => 'Limbah Organik',       'harga_per_kg' => 2000],
        ];
    }
}
