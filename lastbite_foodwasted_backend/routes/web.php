<?php

use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\DokumenController;
use App\Http\Controllers\Admin\MitraVerifikasiController;
use App\Http\Controllers\Admin\ManajemenController; // <-- Tambahkan ini
use App\Http\Middleware\AdminAuth;
use Illuminate\Support\Facades\Route;

// Login admin
Route::get('/', [AuthController::class, 'showLogin'])->name('admin.login');
Route::post('/login', [AuthController::class, 'login'])
    ->middleware('throttle:5,1')
    ->name('admin.login.submit');

// Halaman admin (wajib login)
Route::middleware(AdminAuth::class)->group(function () {
    // Dashboard
    Route::get('/admin', [DashboardController::class, 'index'])->name('admin.dashboard');
    
    // Aksi Verifikasi (dari dashboard)
    Route::post('/admin/mitra/{id}/setujui', [MitraVerifikasiController::class, 'setujui'])->name('admin.mitra.setujui');
    Route::post('/admin/mitra/{id}/tolak', [MitraVerifikasiController::class, 'tolak'])->name('admin.mitra.tolak');
    
    // Dokumen
    Route::get('/admin/mitra/{id}/dokumen/{field}', [DokumenController::class, 'show'])
        ->whereIn('field', ['foto_ktp', 'foto_npwp', 'sertifikat_halal'])
        ->name('admin.mitra.dokumen');
        
    // ==========================================
    // RUTE BARU UNTUK MENU SIDEBAR
    // ==========================================
    Route::get('/admin/verifikasi', [ManajemenController::class, 'verifikasi'])->name('admin.verifikasi');
    Route::get('/admin/mitra', [ManajemenController::class, 'mitra'])->name('admin.mitra');
    Route::get('/admin/pengguna', [ManajemenController::class, 'pengguna'])->name('admin.pengguna');
    Route::get('/admin/produk', [ManajemenController::class, 'produk'])->name('admin.produk');
    Route::get('/admin/pesanan', [ManajemenController::class, 'pesanan'])->name('admin.pesanan');
    Route::get('/admin/laporan', [ManajemenController::class, 'laporan'])->name('admin.laporan');
    Route::get('/admin/aturan-harga', [ManajemenController::class, 'aturanHarga'])->name('admin.aturan');

    // Logout
    Route::post('/logout', [AuthController::class, 'logout'])->name('admin.logout');
});