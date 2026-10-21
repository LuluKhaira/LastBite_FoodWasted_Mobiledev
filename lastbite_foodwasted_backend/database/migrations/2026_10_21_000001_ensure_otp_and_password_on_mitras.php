<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('mitras', function (Blueprint $table) {
            if (!Schema::hasColumn('mitras', 'otp')) {
                $table->string('otp')->nullable()->after('no_whatsapp');
            }
            if (!Schema::hasColumn('mitras', 'password')) {
                $table->string('password')->nullable()->after('otp');
            }
        });
    }

    public function down(): void
    {
        Schema::table('mitras', function (Blueprint $table) {
            if (Schema::hasColumn('mitras', 'otp')) {
                $table->dropColumn('otp');
            }
            if (Schema::hasColumn('mitras', 'password')) {
                $table->dropColumn('password');
            }
        });
    }
};

