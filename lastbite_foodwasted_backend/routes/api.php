<?php

use App\Http\Controllers\Api\AkunController;
use App\Http\Controllers\Api\AlamatController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BantuanPesanController;
use App\Http\Controllers\Api\FaqController;
use App\Http\Controllers\Api\MitraFavoritController;
use App\Http\Controllers\Api\MitraRegisterController;
use App\Http\Controllers\Api\PesananController;
use App\Http\Controllers\Api\ProdukController;
use App\Http\Controllers\Api\ProfilController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\MitraStatusController;
use App\Http\Controllers\Api\dashboard_mitra\MitraDashboardController;
use App\Http\Controllers\Auth\EmailOtpController;
use App\Http\Controllers\Api\GoogleAuthController;
use App\Http\Controllers\Api\PembayaranController;
use App\Http\Controllers\Api\dashboard_mitra\MitraPesananController;
use App\Http\Controllers\Api\dashboard_mitra\ProdukMitraController;

// MITRA
// ============================================================
Route::post('/mitra/set-password', [MitraRegisterController::class, 'setPassword']);
Route::post('/mitra/register-phone', [MitraRegisterController::class, 'registerPhone']);
Route::post('/mitra/verify-otp', [MitraRegisterController::class, 'verifyOtp']);
Route::post('/mitra/set-business', [MitraRegisterController::class, 'setBusinessCategory']);
Route::post('/mitra/set-address', [MitraRegisterController::class, 'setAddress']);
Route::post('/mitra/set-documents', [MitraRegisterController::class, 'setDocuments']);
// MitraStatusController belum di-import & belum ada di daftar controller-mu;
// baris ini tetap ada seperti semula, tapi akan error bila dipanggil.
Route::post('/mitra/check-status', [\App\Http\Controllers\Api\MitraStatusController::class, 'check']);
//mitra produk
Route::post('/mitra/produk/list', [ProdukMitraController::class, 'index']);
Route::post('/mitra/produk/stok', [ProdukMitraController::class, 'updateStok']);
Route::post('/mitra/produk/aktif', [ProdukMitraController::class, 'updateAktif']);
Route::post('/mitra/produk', [ProdukController::class, 'tambah']);
Route::post('/mitra/produk/update', [ProdukController::class, 'update']);

// ============================================================
// PELANGGAN (publik)
// ============================================================
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/login-mitra', [AuthController::class, 'loginMitra']);
//MITRA DASHBOARD
Route::post('/mitra/dashboard', [MitraDashboardController::class, 'show']);
Route::post('/mitra/toko-status', [MitraDashboardController::class, 'setStatusToko']);
Route::post('/mitra/produk', [\App\Http\Controllers\Api\dashboard_mitra\MitraProdukController::class, 'store']);
Route::post('/mitra/produk/template', [\App\Http\Controllers\Api\dashboard_mitra\MitraProdukController::class, 'template']);

// daftar & masuk via WhatsApp OTP & Email OTP
Route::prefix('auth')->group(function () {
    Route::post('/register-phone', [AuthController::class, 'registerPhone'])->middleware('throttle:10,1');
    Route::post('/login-phone',    [AuthController::class, 'loginPhone'])->middleware('throttle:10,1');
    Route::post('/verify-otp',     [AuthController::class, 'verifyOtp'])->middleware('throttle:15,1');
    Route::post('/resend-otp',     [AuthController::class, 'resendOtp'])->middleware('throttle:6,1');

    // Email OTP publik (masuk & verifikasi tanpa login)
    Route::post('/login-email',      [EmailOtpController::class, 'kirim'])->middleware('throttle:10,1');
    Route::post('/verify-email-otp', [EmailOtpController::class, 'verifikasi'])->middleware('throttle:15,1');
});

// Alias tanpa prefix /auth untuk fleksibilitas client
Route::post('/login-email',      [EmailOtpController::class, 'kirim'])->middleware('throttle:10,1');
Route::post('/verify-email-otp', [EmailOtpController::class, 'verifikasi'])->middleware('throttle:15,1');

// Webhook Midtrans (publik, dipanggil server Midtrans)
Route::post('/midtrans/webhook', [PembayaranController::class, 'webhook']);
Route::post('/payment/webhook',  [PembayaranController::class, 'webhook']);

// Partner / Mitra order API (publik atau berbasis token mitra)
Route::post('/partner/orders',                     [MitraPesananController::class, 'index']);
Route::get('/partner/orders',                      [MitraPesananController::class, 'index']);
Route::post('/partner/orders/verify-pickup',       [MitraPesananController::class, 'ambil']);
Route::post('/partner/orders/{order_id}/ready',    [MitraPesananController::class, 'siap']);
Route::post('/mitra/pesanan',                      [MitraPesananController::class, 'index']);
Route::post('/mitra/pesanan/verify-pickup',        [MitraPesananController::class, 'ambil']);
Route::post('/mitra/pesanan/{kode}/siap',          [MitraPesananController::class, 'siap']);
Route::post('/mitra/pesanan/{kode}/ambil',         [MitraPesananController::class, 'ambil']);
Route::post('/mitra/pesanan/{kode}/tolak',         [MitraPesananController::class, 'tolak']);

Route::get('/produk', [ProdukController::class, 'index']);
Route::get('/produk/{produk}', [ProdukController::class, 'show']);

Route::get('/faq', [FaqController::class, 'index']);

// ============================================================
// PELANGGAN (harus login)
// ============================================================
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // pesanan
    Route::get('/pesanan', [PesananController::class, 'index']);
    Route::post('/pesanan', [PesananController::class, 'store']);
    Route::get('/pesanan/{kode}', [PesananController::class, 'show']);
    Route::post('/pesanan/{kode}/batal', [PesananController::class, 'batal']);
    Route::post('/orders/{order_id}/cancel', [PesananController::class, 'batal']);
    Route::post('/pesanan/{kode}/rating', [PesananController::class, 'rating']);

    // profil & akun
    Route::get('/profil', [ProfilController::class, 'show']);
    Route::put('/profil', [ProfilController::class, 'update']);
    Route::put('/akun/password', [AkunController::class, 'ubahPassword']);
    Route::post('/akun/logout-lainnya', [AkunController::class, 'logoutLainnya']);

    // alamat
    Route::get('/alamat', [AlamatController::class, 'index']);
    Route::post('/alamat', [AlamatController::class, 'store']);
    Route::put('/alamat/{id}', [AlamatController::class, 'update']);
    Route::delete('/alamat/{id}', [AlamatController::class, 'destroy']);
    Route::post('/alamat/{id}/utama', [AlamatController::class, 'utama']);

    // mitra favorit
    Route::get('/mitra-favorit', [MitraFavoritController::class, 'index']);
    Route::get('/mitra-favorit/status', [MitraFavoritController::class, 'status']);
    Route::post('/mitra-favorit/toggle', [MitraFavoritController::class, 'toggle']);
    Route::delete('/mitra-favorit/{idMitra}', [MitraFavoritController::class, 'destroy']);

    // live chat CS
    Route::get('/bantuan/pesan', [BantuanPesanController::class, 'index']);
    Route::post('/bantuan/pesan', [BantuanPesanController::class, 'store']);

    // verifikasi email akun pengguna yang sedang login
    Route::post('/akun/email/kirim-otp',  [EmailOtpController::class, 'kirimVerifikasi'])->middleware('throttle:6,1');
    Route::post('/akun/email/verifikasi', [EmailOtpController::class, 'verifikasiEmail'])->middleware('throttle:15,1');

    // login via Google
    Route::post('/auth/google', [GoogleAuthController::class, 'login']);

    //otp gmail
    
    Route::post('/email-otp/kirim', [EmailOtpController::class, 'kirim']);
    Route::post('/email-otp/verifikasi', [EmailOtpController::class, 'verifikasi']);

    
    // pembayaran via Midtrans
    Route::post('/pesanan/{kode}/bayar', [PembayaranController::class, 'buat']);
    Route::get('/pesanan/{kode}/cek-bayar', [PembayaranController::class, 'cek']);

    Route::middleware('auth:sanctum')->group(function () {
    Route::post('/akun/email/kirim-otp',  [EmailOtpController::class, 'kirimVerifikasi']);
    Route::post('/akun/email/verifikasi', [EmailOtpController::class, 'verifikasiEmail']);
    });
// ============================================================
});