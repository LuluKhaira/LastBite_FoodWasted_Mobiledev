<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Alihkan produk kadaluarsa tiap 10 menit.
Schedule::command('produk:alihkan-expired')
    ->everyTenMinutes()
    ->withoutOverlapping()
    ->runInBackground();