<?php
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\PesananController;
use App\Http\Controllers\Api\ProdukController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\ProfilController;
use App\Http\Controllers\Api\AkunController;

//MITRA
use App\Http\Controllers\Api\MitraRegisterController;
Route::post('/mitra/set-password', [MitraRegisterController::class, 'setPassword']);

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// PELANGGAN: daftar & masuk via WhatsApp OTP (Fonnte)
Route::prefix('auth')->group(function () {
    Route::post('/register-phone', [AuthController::class, 'registerPhone'])->middleware('throttle:10,1');
    Route::post('/login-phone',    [AuthController::class, 'loginPhone'])->middleware('throttle:10,1');
    Route::post('/verify-otp',     [AuthController::class, 'verifyOtp'])->middleware('throttle:15,1');
    Route::post('/resend-otp',     [AuthController::class, 'resendOtp'])->middleware('throttle:6,1');
});

Route::get('/produk', [ProdukController::class, 'index']);
Route::get('/produk/{produk}', [ProdukController::class, 'show']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::get('/pesanan', [PesananController::class, 'index']);
    Route::post('/pesanan', [PesananController::class, 'store']);
    Route::get('/pesanan/{kode}', [PesananController::class, 'show']);
});

//MITRAA

//MITRA REGSITER
Route::post('/mitra/register-phone', [MitraRegisterController::class, 'registerPhone']);
Route::post('/mitra/verify-otp', [MitraRegisterController::class, 'verifyOtp']);
Route::post('/mitra/set-business', [MitraRegisterController::class, 'setBusinessCategory']);
Route::post('/mitra/set-address', [MitraRegisterController::class, 'setAddress']);
Route::post('/mitra/set-documents', [MitraRegisterController::class, 'setDocuments']);
Route::post('/mitra/check-status', [MitraStatusController::class, 'check']);

//pelanggan  pesanan
 
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::get('/pesanan', [PesananController::class, 'index']);
    Route::post('/pesanan', [PesananController::class, 'store']);
    Route::get('/pesanan/{kode}', [PesananController::class, 'show']);
    Route::post('/pesanan/{kode}/selesai', [PesananController::class, 'selesai']);
    Route::post('/pesanan/{kode}/rating', [PesananController::class, 'rating']);
});

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::get('/pesanan', [PesananController::class, 'index']);
    Route::post('/pesanan', [PesananController::class, 'store']);
    Route::get('/pesanan/{kode}', [PesananController::class, 'show']);
    Route::post('/pesanan/{kode}/selesai', [PesananController::class, 'selesai']);
    Route::post('/pesanan/{kode}/rating', [PesananController::class, 'rating']);

    Route::get('/profil', [ProfilController::class, 'show']);
    Route::put('/profil', [ProfilController::class, 'update']);
    Route::put('/akun/password', [AkunController::class, 'ubahPassword']);
    Route::post('/akun/logout-lainnya', [AkunController::class, 'logoutLainnya']);
});