<?php

namespace Database\Seeders;

use App\Models\Faq;
use Illuminate\Database\Seeder;

class FaqSeeder extends Seeder
{
    /**
     * Isi awal FAQ. Silakan EDIT jawaban sesuai kebijakan Lastbite yang sebenarnya,
     * terutama soal pembatalan, refund, dan keamanan pangan.
     * Jalankan: php artisan db:seed --class=FaqSeeder
     */
    public function run(): void
    {
        $daftar = [
            ['Pemesanan & Ambil', 'Bagaimana cara mengambil tas kejutan di toko mitra?',
             'Buka tab Pesanan, tekan Nota, lalu tunjukkan kode pesanan (contoh: LB-261014-0001) kepada staf kasir toko pada rentang jam pengambilan yang tertera. Setelah makanan kamu terima, tekan tombol Sudah Diambil di kartu pesanan.',
             'Tip ramah lingkungan: jangan lupa bawa tas belanja sendiri untuk mengurangi sampah plastik!'],
            ['Pemesanan & Ambil', 'Mengapa isi tas kejutan tidak bisa dipilih secara spesifik?',
             'Isi paket kejutan berasal dari sisa produk yang tidak habis terjual hari itu, sehingga komposisinya baru diketahui mitra menjelang jam pengambilan. Kamu bisa menulis catatan alergi atau permintaan khusus di halaman detail, dan mitra akan berusaha menyesuaikan dengan stok yang ada.',
             null],
            ['Pemesanan & Ambil', 'Apakah Lastbite menyediakan kurir antar?',
             'Tidak. Lastbite tidak menyediakan kurir. Kamu bisa mengambil langsung ke toko, atau memesan ojek online (GoSend/GrabExpress) sendiri di luar aplikasi.',
             null],
            ['Pembayaran & Refund', 'Metode pembayaran apa saja yang tersedia?',
             'Pilihan pembayaran (QRIS, e-wallet, dan virtual account bank) tampil di halaman detail paket sebelum kamu menekan Pesan & Bayar. Produk gratis tidak memerlukan pembayaran.',
             null],
            ['Pembayaran & Refund', 'Apakah pesanan bisa dibatalkan?',
             'Saat ini pembatalan belum tersedia langsung di aplikasi. Jika ada kendala dengan pesananmu, hubungi tim CS lewat Chat WhatsApp dan sertakan nomor pesanan.',
             null],
            ['Keamanan Pangan', 'Bagaimana jika makanan yang diterima tidak layak konsumsi?',
             'Cek kondisi makanan saat pengambilan dan sampaikan ke penjual sebelum meninggalkan lokasi. Jika sudah terlanjur dibawa pulang, jangan dikonsumsi, lalu laporkan ke tim CS beserta nomor pesanan dan foto makanannya.',
             null],
            ['Akun & Keamanan', 'Bagaimana cara mengubah kata sandi?',
             'Buka tab Profil > Keamanan akun > Ubah Kata Sandi. Setelah kata sandi diubah, perangkat lain yang sedang masuk akan dikeluarkan otomatis.',
             null],
            ['Akun & Keamanan', 'Bagaimana cara menambah alamat atau mitra favorit?',
             'Alamat ditambahkan di Profil > Alamat & Lokasi Ambil Favorit > Tambah Alamat Baru. Untuk mitra favorit, tekan ikon hati di halaman detail paket milik mitra tersebut.',
             null],
        ];

        foreach ($daftar as $i => [$kategori, $tanya, $jawab, $tip]) {
            Faq::updateOrCreate(
                ['pertanyaan' => $tanya],
                ['kategori' => $kategori, 'jawaban' => $jawab, 'tip' => $tip, 'urutan' => $i + 1, 'aktif' => true]
            );
        }
    }
}