<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasColumn('users', 'password_changed_at')) {
            return;
        }

        Schema::table('users', function (Blueprint $t) {
            $t->timestamp('password_changed_at')->nullable();
        });
    }

    public function down(): void
    {
        if (Schema::hasColumn('users', 'password_changed_at')) {
            Schema::table('users', function (Blueprint $t) {
                $t->dropColumn('password_changed_at');
            });
        }
    }
};