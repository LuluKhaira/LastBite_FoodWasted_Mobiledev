<?php

use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\DokumenController;
use App\Http\Controllers\Admin\MitraVerifikasiController;
use App\Http\Middleware\AdminAuth;
use Illuminate\Support\Facades\Route;

// Login admin (halaman pertama saat aplikasi dibuka)
Route::get('/', [AuthController::class, 'showLogin'])->name('admin.login');
Route::post('/login', [AuthController::class, 'login'])
    ->middleware('throttle:5,1')
    ->name('admin.login.submit');

// Halaman admin (wajib login)
Route::middleware(AdminAuth::class)->group(function () {
    Route::get('/admin', [DashboardController::class, 'index'])->name('admin.dashboard');
    Route::post('/admin/mitra/{id}/setujui', [MitraVerifikasiController::class, 'setujui'])->name('admin.mitra.setujui');
    Route::post('/admin/mitra/{id}/tolak', [MitraVerifikasiController::class, 'tolak'])->name('admin.mitra.tolak');
    Route::get('/admin/mitra/{id}/dokumen/{field}', [DokumenController::class, 'show'])
        ->whereIn('field', ['foto_ktp', 'foto_npwp', 'sertifikat_halal'])
        ->name('admin.mitra.dokumen');
    Route::post('/logout', [AuthController::class, 'logout'])->name('admin.logout');
});