<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Mitra;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

class DashboardController extends Controller
{
    // Aturan harga: diskon minimum (%). Produk dengan diskon di bawah ini dianggap anomali.
    private const MIN_DISKON = 40;

    public function index(Request $request)
    {
        // Mitra yang sudah mengunggah dokumen dan menunggu keputusan admin
        $pending = Mitra::where(fn ($q) => $q->whereNotIn('status_verifikasi', ['disetujui', 'ditolak'])->orWhereNull('status_verifikasi'))
            ->whereNotNull('foto_ktp')
            ->orderBy('id_mitra')
            ->get();

        $anomalies = $this->anomalies();

        $rows = $pending->map(fn ($m) => $this->mitraRow($m))
            ->concat($anomalies->map(fn ($a) => $this->anomalyRow($a)))
            ->sortBy(fn ($r) => ($r['urgent'] ? '0' : '1') . ($r['type'] === 'mitra' ? '0' : '1'))
            ->values();

        // Panel moderasi kosong sampai admin memilih mitra dari antrean/tabel (?mitra=ID)
        $selected = $request->filled('mitra')
            ? $pending->firstWhere('id_mitra', (int) $request->query('mitra'))
            : null;

        $queue = $rows->take(4)->map(function ($r) use ($selected) {
            $r['active'] = $selected && $r['type'] === 'mitra' && $r['id'] === $selected->id_mitra;
            return $r;
        });

        $stats = [
            ['label' => 'Total Transaksi', 'value' => $this->rupiah($this->sum('pesanan', 'total_harga')), 'badge' => null],
            ['label' => 'Pendapatan Biaya Admin', 'value' => $this->rupiah($this->sum('pesanan', 'biaya_admin')), 'badge' => null],
            ['label' => 'Mitra Aktif', 'value' => number_format(Mitra::where('status_verifikasi', 'disetujui')->count(), 0, ',', '.') . ' Toko', 'badge' => 'Terverifikasi'],
            ['label' => 'Surplus Terselamatkan', 'value' => number_format($this->porsi(), 0, ',', '.') . ' Porsi', 'badge' => null],
        ];

        $orderCol = Schema::hasColumn('mitra', 'updated_at') ? 'updated_at' : 'id_mitra';
        $activities = Mitra::whereIn('status_verifikasi', ['disetujui', 'ditolak'])
            ->whereNotNull('nama_usaha')
            ->orderByDesc($orderCol)
            ->limit(3)
            ->get()
            ->map(fn ($m) => [
                'text' => $m->nama_usaha . ' ' . ($m->status_verifikasi === 'disetujui' ? 'disetujui' : 'ditolak'),
                'time' => $m->updated_at ? Carbon::parse($m->updated_at)->locale('id')->diffForHumans() : '',
            ]);

        return view('pages.admin.dashboard', [
            'stats' => $stats,
            'queue' => $queue,
            'rows' => $rows,
            'details' => $pending->map(fn ($m) => $this->mitraDetail($m))->values(),
            'selectedId' => $selected?->id_mitra,
            'anomalies' => $anomalies,
            'activities' => $activities,
        ]);
    }

    // ---------- Mitra ----------

    private function mitraRow($m): array
    {
        $time = $m->created_at ?? $m->updated_at ?? null;
        [$label, $urgent, $short] = $this->urgency($time);

        return [
            'type' => 'mitra',
            'id' => $m->id_mitra,
            'tag' => 'Mitra Baru',
            'name' => $m->nama_usaha ?: 'Tanpa Nama',
            'sub' => 'ID: ' . $this->kode($m),
            'meta' => 'Mitra • ' . Str::limit($m->alamat ?: '-', 24),
            'kategori' => $m->kategori_usaha ?? '-',
            'wilayah' => Str::limit($m->alamat ?: '-', 28),
            'waktu' => $this->waktu($time),
            'urgensi' => $label,
            'urgent' => $urgent,
            'short' => $short,
            'foot' => 'Verifikasi Dokumen',
            'icon' => 'verified_user',
            'url' => route('admin.dashboard', ['mitra' => $m->id_mitra]) . '#panel-moderasi',
        ];
    }

    private function mitraDetail($m): array
    {
        $time = $m->created_at ?? $m->updated_at ?? null;
        [$label, $urgent] = $this->urgency($time);

        $words = preg_split('/\s+/', trim($m->nama_usaha ?: 'M'));
        $initial = strtoupper(mb_substr($words[0], 0, 1) . (isset($words[1]) ? mb_substr($words[1], 0, 1) : ''));

        $docs = [];
        foreach ([
            'foto_ktp' => ['KTP Pemilik Usaha', 'badge'],
            'foto_npwp' => ['NPWP Usaha', 'description'],
            'sertifikat_halal' => ['Sertifikat Halal', 'verified'],
        ] as $col => [$desc, $icon]) {
            if (! empty($m->{$col})) {
                $docs[] = [
                    'icon' => $icon,
                    'name' => basename($m->{$col}),
                    'desc' => $desc,
                    'url' => Str::startsWith($m->{$col}, ['http://', 'https://']) ? $m->{$col} : route('admin.mitra.dokumen', ['id' => $m->id_mitra, 'field' => $col]),
                ];
            }
        }

        return [
            'id' => $m->id_mitra,
            'initial' => $initial,
            'name' => $m->nama_usaha ?: 'Tanpa Nama',
            'kategori' => $m->kategori_usaha ?? 'Kategori belum diisi',
            'code' => $this->kode($m),
            'wa' => $this->formatWa($m->no_whatsapp),
            'alamat' => $m->alamat ?: '-',
            'waktu' => $this->waktu($time, true),
            'urgensi' => $label,
            'urgent' => $urgent,
            'docs' => $docs,
        ];
    }

    // ---------- Anomali harga ----------

    private function anomalies()
    {
        if (! Schema::hasTable('produk')
            || ! Schema::hasColumns('produk', ['id_produk', 'nama_produk', 'harga_asli', 'harga_diskon', 'id_mitra'])) {
            return collect();
        }

        return DB::table('produk')
            ->leftJoin('mitra', 'mitra.id_mitra', '=', 'produk.id_mitra')
            ->where('produk.harga_asli', '>', 0)
            ->whereRaw('((produk.harga_asli - produk.harga_diskon) / produk.harga_asli * 100) < ?', [self::MIN_DISKON])
            ->select('produk.id_produk', 'produk.nama_produk', 'produk.harga_asli', 'produk.harga_diskon', 'mitra.nama_usaha', 'mitra.alamat')
            ->limit(20)
            ->get()
            ->map(function ($p) {
                $p->pct = (int) round(($p->harga_asli - $p->harga_diskon) / $p->harga_asli * 100);
                return $p;
            });
    }

    private function anomalyRow($a): array
    {
        return [
            'type' => 'anomali',
            'id' => $a->id_produk,
            'tag' => 'Anomali Harga',
            'name' => $a->nama_produk,
            'sub' => ($a->nama_usaha ?? 'Mitra') . ' (Diskon ' . $a->pct . '%)',
            'meta' => ($a->nama_usaha ?? 'Mitra') . ' • Diskon ' . $a->pct . '%',
            'kategori' => 'Produk',
            'wilayah' => Str::limit($a->alamat ?? '-', 28),
            'waktu' => '-',
            'urgensi' => 'Perlu Dicek',
            'urgent' => false,
            'short' => 'Cek',
            'foot' => 'Kurang dari min. ' . self::MIN_DISKON . '%',
            'icon' => 'warning',
            'url' => route('admin.dashboard', ['tab' => 'anomali']) . '#panel-moderasi',
        ];
    }

    // ---------- Helper ----------

    private function urgency($time): array
    {
        if (! $time) {
            return ['Baru Masuk', false, 'Baru'];
        }

        $hours = Carbon::parse($time)->diffInHours(now(), true);

        if ($hours >= 48) return ['Mendesak (>2 hari)', true, '>2 Hari'];
        if ($hours >= 24) return ['1-2 Hari', false, '1-2 Hari'];

        return ['Baru Masuk', false, '<1 Hari'];
    }

    private function waktu($time, bool $full = false): string
    {
        if (! $time) return '-';

        return Carbon::parse($time)->locale('id')->translatedFormat($full ? 'd F Y, H:i' : 'd M Y, H.i');
    }

    private function kode($m): string
    {
        $year = ($m->created_at ?? null) ? Carbon::parse($m->created_at)->format('Y') : date('Y');

        return 'MTR-' . $year . '-' . str_pad($m->id_mitra, 3, '0', STR_PAD_LEFT);
    }

    private function formatWa(?string $phone): string
    {
        $n = preg_replace('/\D/', '', (string) $phone);
        if ($n === '') return '-';
        if (str_starts_with($n, '0')) $n = substr($n, 1);
        if (str_starts_with($n, '62')) $n = substr($n, 2);

        return '+62 ' . substr($n, 0, 3) . '-' . substr($n, 3, 4) . '-' . substr($n, 7);
    }

    private function rupiah($n): string
    {
        return 'Rp ' . number_format($n, 0, ',', '.');
    }

    private function sum(string $table, string $col): float
    {
        return Schema::hasTable($table) && Schema::hasColumn($table, $col)
            ? (float) DB::table($table)->sum($col)
            : 0;
    }

    // Porsi terselamatkan = pesanan yang sudah diambil pembeli
    private function porsi(): int
    {
        return Schema::hasTable('pesanan') && Schema::hasColumn('pesanan', 'waktu_diambil')
            ? DB::table('pesanan')->whereNotNull('waktu_diambil')->count()
            : 0;
    }
}