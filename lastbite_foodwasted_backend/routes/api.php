<?php

use App\Http\Controllers\Api\MitraController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/mitra', [MitraController::class, 'index']);
Route::post('/mitra', [MitraController::class, 'store']);
Route::get('/mitra/{id}', [MitraController::class, 'show']);
