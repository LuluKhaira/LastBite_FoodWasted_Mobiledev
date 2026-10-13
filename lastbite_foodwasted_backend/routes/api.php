<?php
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\PesananController;
use App\Http\Controllers\Api\ProdukController;
use Illuminate\Support\Facades\Route;

//MITRA
use App\Http\Controllers\Api\MitraRegisterController;
Route::post('/mitra/set-password', [MitraRegisterController::class, 'setPassword']);

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

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