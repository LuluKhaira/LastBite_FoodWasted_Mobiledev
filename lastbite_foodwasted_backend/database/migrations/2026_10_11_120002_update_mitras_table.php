<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::table('mitras', function (Blueprint $t) {
            $t->foreignId('user_id')->nullable()->after('id_mitra')->constrained('users')->nullOnDelete();
            $t->string('nama_usaha')->nullable()->after('user_id');
            $t->string('inisial', 4)->nullable()->after('nama_usaha')->nullable();
            $t->decimal('latitude', 10, 7)->nullable();
            $t->decimal('longitude', 10, 7)->nullable();
        });
    }
    public function down(): void {
        Schema::table('mitras', function (Blueprint $t) {
            $t->dropConstrainedForeignId('user_id');
            $t->dropColumn(['nama_usaha', 'inisial', 'latitude', 'longitude']);
        });
    }
};
