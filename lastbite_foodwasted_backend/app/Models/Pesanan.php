<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pesanan extends Model
{
    protected $table = 'pesanans';

    const STATUS_PENDING_PAYMENT     = 'PENDING_PAYMENT';
    const STATUS_WAITING_PREPARATION = 'WAITING_PREPARATION';
    const STATUS_READY_FOR_PICKUP    = 'READY_FOR_PICKUP';
    const STATUS_COMPLETED           = 'COMPLETED';
    const STATUS_CANCELLED           = 'CANCELLED';

    protected $fillable = [
        'kode', 'user_id', 'produk_id', 'id_mitra',
        'penjual', 'inisial', 'alamat', 'produk', 'skema_harga', 'gambar',
        'metode', 'qty', 'harga_satuan', 'harga_asli_satuan', 'biaya_layanan',
        'co2', 'makanan', 'status', 'rating', 'catatan',
        'midtrans_order_id', 'status_bayar', 'nilai_sedekah',
        'kode_ambil', 'estimasi_menit', 'siap_at', 'batas_ambil', 'diambil_at',
    ];

    protected $casts = [
        'co2' => 'float', 'makanan' => 'float', 'qty' => 'integer', 'rating' => 'integer',
        'siap_at' => 'datetime', 'batas_ambil' => 'datetime', 'diambil_at' => 'datetime',
    ];

    public function user()   { return $this->belongsTo(User::class); }
    public function mitra()  { return $this->belongsTo(Mitra::class, 'id_mitra', 'id_mitra'); }
    public function produk() { return $this->belongsTo(Produk::class, 'produk_id'); }

    public function getTotalAttribute(): int
    {
        return ($this->qty * $this->harga_satuan) + $this->biaya_layanan;
    }

    public function toApi(): array
    {
        $t = $this->created_at ? $this->created_at->copy()->timezone('Asia/Jakarta') : now()->timezone('Asia/Jakarta');

        $statusEnum = match ($this->status) {
            'siap', self::STATUS_READY_FOR_PICKUP         => self::STATUS_READY_FOR_PICKUP,
            'selesai', self::STATUS_COMPLETED             => self::STATUS_COMPLETED,
            'dibatalkan', self::STATUS_CANCELLED          => self::STATUS_CANCELLED,
            default                                       => ($this->status_bayar === 'lunas' || (int) $this->total <= 0)
                ? self::STATUS_WAITING_PREPARATION
                : self::STATUS_PENDING_PAYMENT,
        };

        $statusLabel = match ($statusEnum) {
            self::STATUS_PENDING_PAYMENT     => 'Menunggu Pembayaran',
            self::STATUS_WAITING_PREPARATION => 'Menunggu Konfirmasi & Penyiapan',
            self::STATUS_READY_FOR_PICKUP    => 'Siap Diambil',
            self::STATUS_COMPLETED           => 'Selesai',
            self::STATUS_CANCELLED           => 'Dibatalkan',
        };

        $estMin = (int) ($this->estimasi_menit ?: 20);
        $estimasiWaktu = $t->copy()->addMinutes($estMin)->format('H.i') . ' WIB';

        $isSiap = in_array($this->status, ['siap', self::STATUS_READY_FOR_PICKUP]);
        $isSelesai = in_array($this->status, ['selesai', self::STATUS_COMPLETED]);

        $path = $this->gambar ? ltrim($this->gambar, '/') : null;
        if ($path && !str_starts_with($path, 'http://') && !str_starts_with($path, 'https://')) {
            if (str_starts_with($path, 'storage/')) {
                $path = substr($path, 8);
            }
            try {
                $root = request()->root();
                $gambarUrl = !empty($root) ? (rtrim($root, '/') . '/api/foto/' . $path) : url('api/foto/' . $path);
            } catch (\Throwable $e) {
                $gambarUrl = url('api/foto/' . $path);
            }
        } else {
            $gambarUrl = $path;
        }

        return [
            'id'                => $this->id,
            'kode'              => $this->kode,
            'tanggal'           => $t->isToday() ? 'Hari ini' : $t->locale('id')->translatedFormat('d M Y'),
            'jam'               => $t->format('H.i'),
            'penjual'           => $this->penjual,
            'inisial'           => $this->inisial,
            'alamat'            => $this->alamat,
            'produk'            => $this->produk,
            'skema_harga'       => $this->skema_harga ?? 'diskon',
            'is_sedekah'        => ($this->skema_harga === 'sedekah') || ((int) $this->harga_satuan === 0),
            'nilai_sedekah'     => (int) ($this->nilai_sedekah ?? 0),
            'gambar'            => $gambarUrl,
            'image_url'         => $gambarUrl,
            'metode'            => $this->metode ?: 'QRIS',
            'qty'               => $this->qty,
            'harga_satuan'      => (int) $this->harga_satuan,
            'harga_asli_satuan' => (int) $this->harga_asli_satuan,
            'biaya_layanan'     => (int) $this->biaya_layanan,
            'total'             => $this->total,
            'co2'               => $this->co2,
            'makanan'           => $this->makanan,
            'status'            => $this->status,        // 'menunggu' | 'siap' | 'selesai' | 'dibatalkan'
            'status_enum'       => $statusEnum,          // PENDING_PAYMENT | WAITING_PREPARATION | READY_FOR_PICKUP | COMPLETED | CANCELLED
            'status_label'      => $statusLabel,
            'status_bayar'      => $this->status_bayar,  // 'belum' | 'menunggu' | 'lunas' | 'gagal' | 'refund'
            'rating'            => $this->rating,
            'catatan'           => $this->catatan,
            'estimasi_menit'    => $estMin,
            'estimasi_waktu'    => $estimasiWaktu,
            // Kode ambil hanya dibuka ke pembeli setelah status 'siap'
            'kode_ambil'        => $isSiap ? $this->kode_ambil : null,
            'batas_ambil'       => $this->batas_ambil?->toIso8601String(),
            'telp_toko'         => $this->mitra?->no_whatsapp,
            'lat'               => $this->mitra?->latitude,
            'lng'               => $this->mitra?->longitude,
            'baru'              => $isSelesai && $this->rating === null,
            'pembeli_nama'      => $this->user?->name ?: 'Pelanggan LastBite',
            'pembeli_hp'        => $this->user?->no_hp,
            'created_at'        => $this->created_at?->toIso8601String(),
        ];
    }
}
