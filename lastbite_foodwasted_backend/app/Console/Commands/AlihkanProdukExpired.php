<?php

namespace App\Console\Commands;

use App\Models\Produk;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

class AlihkanProdukExpired extends Command
{
    protected $signature = 'produk:alihkan-expired {--dry-run : Hanya tampilkan tanpa update}';

    protected $description = 'Ubah produk konsumsi manusia yang sudah lewat kadaluarsa menjadi kategori pakan/kompos.';

    public function handle(): int
    {
        $dry = (bool) $this->option('dry-run');

        $items = Produk::where('tipe', Produk::TIPE_DIMAKAN)
            ->whereNotNull('kadaluarsa')
            ->whereNull('dialihkan_pada')                 // jangan timpa yang sudah dialihkan
            ->where('kadaluarsa', '<=', now('Asia/Jakarta'))
            ->get();

        if ($items->isEmpty()) {
            $this->info('Tidak ada produk kadaluarsa yang perlu dialihkan.');
            return self::SUCCESS;
        }

        $count = 0;
        foreach ($items as $p) {
            // Prioritas: target pilihan mitra -> mapping default
            $target = $p->target_kategori_pengalihan
                ?? \App\Models\PengalihanKategori::cariTujuan($p->kategori)['kategori'];

            $this->line(sprintf(
                '%s[%s] %s -> %s',
                $dry ? '[DRY] ' : '',
                $p->id,
                $p->kategori,
                $target
            ));

            if (!$dry) {
                $p->alihkan();  // method di model, idempotent
                Log::info('Produk dialihkan otomatis karena kadaluarsa', [
                    'produk_id' => $p->id,
                    'kategori'  => $target,
                ]);
            }
            $count++;
        }

        $this->info(($dry ? 'Simulasi: ' : '') . "{$count} produk " . ($dry ? 'akan ' : '') . 'dialihkan.');

        return self::SUCCESS;
    }
}