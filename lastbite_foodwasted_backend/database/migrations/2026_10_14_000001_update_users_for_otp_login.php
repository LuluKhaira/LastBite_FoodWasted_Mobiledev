<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// Pelanggan yang daftar lewat WhatsApp belum tentu punya email & kata sandi.
// Nomor HP memakai kolom `no_hp` yang sudah ada (format tersimpan: 62812xxxx).
return new class extends Migration {
    public function up(): void {
        Schema::table('users', function (Blueprint $t) {
            $t->string('email')->nullable()->change();
            $t->string('password')->nullable()->change();
            $t->timestamp('no_hp_verified_at')->nullable()->after('no_hp');
            $t->index('no_hp');
        });
    }

    public function down(): void {
        Schema::table('users', function (Blueprint $t) {
            $t->dropIndex(['no_hp']);
            $t->dropColumn('no_hp_verified_at');
        });
    }
};
