<?php
namespace Database\Seeders;

use App\Models\Mitra;
use App\Models\Produk;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class LastbiteSeeder extends Seeder
{
    public function run(): void
    {
        User::firstOrCreate(['email' => 'demo@lastbite.test'], [
            'name' => 'Demo Pembeli', 'password' => Hash::make('password'), 'role' => 'pembeli',
        ]);

        $mitra = fn ($nama, $ini, $alamat, $lat, $lng) => Mitra::firstOrCreate(
            ['nama_usaha' => $nama],
            ['inisial' => $ini, 'alamat' => $alamat, 'no_whatsapp' => '081234567890',
             'latitude' => $lat, 'longitude' => $lng, 'status_verifikasi' => 'terverifikasi']
        );

        $hb = $mitra('Holland Bakery - Batam Center', 'HB', 'Jl. Engku Putri No. 8, Batam Center', 1.1291, 104.0530);
        $rs = $mitra('Resto Sederhana - Nagoya', 'RS', 'Nagoya, Batam', 1.1450, 104.0300);
        $ks = $mitra('Kios Sayur Segar Pasar Mitra', 'KS', 'Pasar Mitra, Batam', 1.1180, 104.0480);
        $kb = $mitra('Kebun Barokah - Batam Center', 'KB', 'Batam Center', 1.1260, 104.0560);

        $rows = [
            [$hb, 'Paket Kejutan Roti Manis & Pastry', 'dimakan', 'Roti & Bakery', 'Harga Spesial', 15000, 30000, '/paket', 3, 0.8, '19:00', '20:00', 4.9, 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&q=80'],
            [$rs, 'Paket Kejutan Nasi Box Spesial', 'dimakan', 'Makanan Siap Saji', 'Harga Dinamis', 12000, 36000, '/paket', 1, 0.6, '21:00', '22:00', 4.5, 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80'],
            [$ks, 'Paket Kejutan Sayur & Buah Segar', 'dimakan', 'Sayur & Buah', 'Harga Spesial', 10000, 25000, '/paket', 5, 1.0, '17:00', '18:00', 4.7, 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600&q=80'],
            [$hb, 'Sisa Roti untuk Pakan Ternak', 'ternak', 'Pakan Ternak', 'Pakan Ternak', 0, null, 'Gratis', 20, 20, '08:00', '10:00', 4.9, 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&q=80'],
            [$kb, 'Kompos & Sisa Organik Siap Olah (Karung 5kg)', 'ternak', 'Bahan Pupuk', 'Bahan Pupuk', 12500, null, '/karung', 10, 5, '16:00', '18:00', 4.9, 'https://images.unsplash.com/photo-1591857177580-dc82b9ac4e1e?w=600&q=80'],
        ];

        foreach ($rows as [$m, $nama, $tipe, $kat, $tag, $harga, $asli, $sat, $stok, $berat, $mulai, $selesai, $rating, $img]) {
            Produk::firstOrCreate(['nama' => $nama, 'id_mitra' => $m->id_mitra], [
                'tipe' => $tipe, 'kategori' => $kat, 'tag' => $tag, 'harga' => $harga,
                'harga_asli' => $asli, 'satuan' => $sat, 'stok' => $stok, 'berat_kg' => $berat,
                'waktu_mulai' => $mulai, 'waktu_selesai' => $selesai, 'rating' => $rating, 'gambar' => $img,
            ]);
        }
    }
}
