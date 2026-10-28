<?php

namespace App\Console\Commands;

use App\Models\Produk;
use Illuminate\Console\Command;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class AlihkanProdukExpired extends Command
{
    protected $signature = 'produk:alihkan-expired {--dry-run : Hanya tampilkan tanpa mengubah database}';

    protected $description = 'Memeriksa produk konsumsi manusia yang melewati batas waktu penjualan dan memproses status pengalihan sesuai persetujuan mitra.';

    public function handle(): int
    {
        $dry = (bool) $this->option('dry-run');
        $now = now('Asia/Jakarta');

        // Ambil produk konsumsi manusia yang aktif atau belum diproses kadaluarsanya
        // dan status_pengalihannya masih default ('tidak_dialihkan')
        $candidates = Produk::where('tipe', Produk::TIPE_DIMAKAN)
            ->where('status_pengalihan', Produk::STATUS_PENGALIHAN_TIDAK)
            ->where(function ($q) {
                $q->where('aktif', true)
                  ->orWhereNull('dialihkan_pada');
            })
            ->get();

        $expiredItems = $candidates->filter(function ($p) use ($now) {
            // 1. Cek tanggal & jam kadaluarsa jika ada
            if ($p->kadaluarsa !== null) {
                $kadaluarsa = Carbon::parse($p->kadaluarsa, 'Asia/Jakarta');
                if ($kadaluarsa->lessThanOrEqualTo($now)) {
                    return true;
                }
            }

            // 2. Cek batas jam pengambilan (waktu_selesai) hari ini
            if (!empty($p->waktu_selesai)) {
                try {
                    $jamBatas = Carbon::today('Asia/Jakarta')->setTimeFromTimeString($p->waktu_selesai);
                    if ($jamBatas->lessThanOrEqualTo($now)) {
                        return true;
                    }
                } catch (\Throwable $e) {}
            }

            return false;
        });

        if ($expiredItems->isEmpty()) {
            $this->info('Tidak ada produk melewati batas waktu yang perlu diproses.');
            return self::SUCCESS;
        }

        $kondisiA = 0;
        $kondisiB = 0;
        $kondisiC = 0;

        foreach ($expiredItems as $p) {
            $stokSisa = (int) ($p->stok ?? 0);
            $bersedia = (bool) $p->bersedia_dialihkan;

            if (!$bersedia) {
                // KONDISI A: Mitra tidak bersedia mengalihkan produk
                // - Produk otomatis dinonaktifkan
                // - Tidak dapat dibeli/diklaim lagi
                // - Tidak ada produk surplus dibuat
                // - Tidak ada perpindahan ke Pakan/Kompos
                $this->line(sprintf(
                    '%s[Kondisi A] Produk #%d "%s": Mitra TIDAK bersedia. Dinonaktifkan.',
                    $dry ? '[DRY] ' : '',
                    $p->id,
                    $p->nama
                ));

                if (!$dry) {
                    DB::transaction(function () use ($p, $now) {
                        $p->update([
                            'aktif'              => false,
                            'status_pengalihan'  => Produk::STATUS_PENGALIHAN_TIDAK,
                            'dialihkan_pada'     => $now,
                        ]);
                    });

                    Log::info('Produk melewati batas waktu dinonaktifkan (Kondisi A: tidak bersedia)', [
                        'produk_id' => $p->id,
                        'nama'      => $p->nama,
                    ]);
                }
                $kondisiA++;

            } elseif ($bersedia && $stokSisa <= 0) {
                // KONDISI B: Mitra bersedia tapi stok sudah habis
                // - Produk dinonaktifkan
                // - Tidak ada pengalihan karena tidak ada sisa produk
                // - Jangan buat produk surplus berat nol
                $this->line(sprintf(
                    '%s[Kondisi B] Produk #%d "%s": Mitra bersedia tapi stok habis (0). Dinonaktifkan.',
                    $dry ? '[DRY] ' : '',
                    $p->id,
                    $p->nama
                ));

                if (!$dry) {
                    DB::transaction(function () use ($p, $now) {
                        $p->update([
                            'aktif'              => false,
                            'status_pengalihan'  => Produk::STATUS_PENGALIHAN_TIDAK,
                            'dialihkan_pada'     => $now,
                        ]);
                    });

                    Log::info('Produk melewati batas waktu dinonaktifkan (Kondisi B: stok habis)', [
                        'produk_id' => $p->id,
                        'nama'      => $p->nama,
                    ]);
                }
                $kondisiB++;

            } else {
                // KONDISI C: Mitra bersedia dan masih memiliki sisa stok
                // - Nonaktifkan penjualan produk awal
                // - Hitung stok sisa
                // - Ubah status pengalihan menjadi 'menunggu_konfirmasi'
                // - JANGAN langsung terbitkan produk Pakan/Kompos
                $totalBeratEst = $p->totalPerkiraanBeratSisa();
                $this->line(sprintf(
                    '%s[Kondisi C] Produk #%d "%s": Sisa %d paket (est %s kg). Status diubah -> MENUNGGU_KONFIRMASI.',
                    $dry ? '[DRY] ' : '',
                    $p->id,
                    $p->nama,
                    $stokSisa,
                    $totalBeratEst
                ));

                if (!$dry) {
                    DB::transaction(function () use ($p, $now) {
                        $p->update([
                            'aktif'              => false, // Stop penjualan konsumsi manusia
                            'status_pengalihan'  => Produk::STATUS_PENGALIHAN_MENUNGGU,
                            'dialihkan_pada'     => $now,
                        ]);
                    });

                    Log::info('Produk melewati batas waktu siap konfirmasi (Kondisi C: menunggu konfirmasi mitra)', [
                        'produk_id'   => $p->id,
                        'nama'        => $p->nama,
                        'stok_sisa'   => $stokSisa,
                        'berat_est'   => $totalBeratEst,
                    ]);
                }
                $kondisiC++;
            }
        }

        $total = $kondisiA + $kondisiB + $kondisiC;
        $this->info(sprintf(
            '%sSelesai memproses %d produk (Kondisi A: %d, Kondisi B: %d, Kondisi C Menunggu Konfirmasi: %d).',
            $dry ? 'Simulasi: ' : '',
            $total,
            $kondisiA,
            $kondisiB,
            $kondisiC
        ));

        return self::SUCCESS;
    }
}
