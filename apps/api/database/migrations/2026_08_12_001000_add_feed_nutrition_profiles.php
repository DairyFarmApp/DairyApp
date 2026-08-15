<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('inventory_items', function (Blueprint $t) {
            $t->decimal('dry_matter_percent', 6, 3)->nullable();
            $t->decimal('crude_protein_percent', 6, 3)->nullable();
            $t->decimal('metabolizable_energy_mj_per_kg', 8, 3)->nullable();
            $t->decimal('fibre_percent', 6, 3)->nullable();
            $t->decimal('fat_percent', 6, 3)->nullable();
            $t->decimal('minerals_percent', 6, 3)->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('inventory_items', fn (Blueprint $t) => $t->dropColumn(['dry_matter_percent', 'crude_protein_percent', 'metabolizable_energy_mj_per_kg', 'fibre_percent', 'fat_percent', 'minerals_percent']));
    }
};
