<?php

// Tempel nilainya di file .env (lihat catatan di bawah tiap baris).
return [
    // Token Fonnte yang SAMA dengan yang dipakai untuk OTP.
    // Cek nama variabelnya di .env / kode OTP-mu; ubah 'FONNTE_TOKEN' bila beda.
    'fonnte_token' => env('FONNTE_TOKEN'),

    // Nomor WhatsApp tim CS (mis. nomor temanmu). Boleh 0812xxxx atau 62812xxxx.
    // Harus BERBEDA dari nomor perangkat yang tersambung ke Fonnte.
    'cs_whatsapp' => env('CS_WHATSAPP'),

    'bantuan_email'   => env('BANTUAN_EMAIL', 'bantuan@lastbite.id'),
    'bantuan_telepon' => env('BANTUAN_TELEPON', '021-5099-LAST'),

    // Jam operasional CS (WIB, 24 jam)
    'jam_buka'  => 8,
    'jam_tutup' => 22,
];