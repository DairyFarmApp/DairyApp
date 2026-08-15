<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('inventory_transfers', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->uuid('organization_id');
            $t->uuid('source_farm_id');
            $t->uuid('destination_farm_id');
            $t->uuid('source_item_id');
            $t->uuid('destination_item_id');
            $t->string('transfer_number', 40);
            $t->decimal('quantity', 18, 3);
            $t->string('unit', 40);
            $t->dateTime('transferred_at');
            $t->text('reason');
            $t->string('status', 20)->default('completed');
            $t->uuid('created_by');
            $t->timestamps();
            $t->unique(['organization_id', 'transfer_number'], 'inventory_transfer_number_uq');
            $t->foreign('source_item_id')->references('id')->on('inventory_items')->restrictOnDelete();
            $t->foreign('destination_item_id')->references('id')->on('inventory_items')->restrictOnDelete();
            $t->foreign('created_by')->references('id')->on('users')->restrictOnDelete();
        });
        foreach (['inventory.transfer', 'inventory.adjust'] as $n) {
            DB::table('permissions')->updateOrInsert(['name' => $n], ['id' => (string) Str::uuid7(), 'created_at' => now(), 'updated_at' => now()]);
        }$ids = DB::table('permissions')->whereIn('name', ['inventory.transfer', 'inventory.adjust'])->pluck('id');
        foreach (DB::table('roles')->whereIn('slug', ['organization-owner', 'farm-manager'])->pluck('id') as $r) {
            foreach ($ids as $id) {
                DB::table('role_permissions')->updateOrInsert(['role_id' => $r, 'permission_id' => $id], ['created_at' => now(), 'updated_at' => now()]);
            }
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('inventory_transfers');
        DB::table('permissions')->whereIn('name', ['inventory.transfer', 'inventory.adjust'])->delete();
    }
};
