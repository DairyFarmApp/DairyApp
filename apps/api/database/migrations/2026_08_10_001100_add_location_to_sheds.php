<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('sheds', function (Blueprint $table): void {
            $table->string('location', 255)->nullable()->after('code');
        });
    }

    public function down(): void
    {
        Schema::table('sheds', fn (Blueprint $table) => $table->dropColumn('location'));
    }
};
