<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::table('users', function (Blueprint $t) {
            if (!Schema::hasColumn('users', 'no_hp')) {
                $t->string('no_hp', 20)->nullable()->after('email');
                $t->index('no_hp');
            }
            if (!Schema::hasColumn('users', 'no_hp_verified_at')) {
                $t->timestamp('no_hp_verified_at')->nullable()->after('no_hp');
            }
            $t->string('email')->nullable()->change();
            $t->string('password')->nullable()->change();
        });
    }

    public function down(): void {
        Schema::table('users', function (Blueprint $t) {
            if (Schema::hasColumn('users', 'no_hp_verified_at')) {
                $t->dropColumn('no_hp_verified_at');
            }
        });
    }
};