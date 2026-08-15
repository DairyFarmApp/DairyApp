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
        Schema::create('animal_preventive_care_records', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->uuid('animal_id');
            $table->uuid('inventory_item_id');
            $table->uuid('inventory_batch_id');
            $table->uuid('campaign_id')->nullable();
            $table->string('record_number', 40);
            $table->string('type', 20);
            $table->string('disease_covered')->nullable();
            $table->decimal('dose', 12, 3);
            $table->string('dose_unit', 24);
            $table->decimal('inventory_quantity_used', 18, 3);
            $table->dateTime('administered_at');
            $table->date('next_due_date')->nullable();
            $table->string('veterinarian_name', 160)->nullable();
            $table->string('administered_by_name', 160);
            $table->decimal('cost_pkr', 14, 2)->default(0);
            $table->text('reaction')->nullable();
            $table->text('notes')->nullable();
            $table->uuid('created_by');
            $table->unsignedBigInteger('version')->default(1);
            $table->timestamps();
            $table->unique(['organization_id', 'record_number'], 'preventive_record_number_uq');
            $table->index(['organization_id', 'farm_id', 'next_due_date', 'type'], 'preventive_due_idx');
            $table->foreign('organization_id')->references('id')->on('organizations')->cascadeOnDelete();
            $table->foreign(['animal_id', 'organization_id'], 'preventive_animal_org_fk')->references(['id', 'organization_id'])->on('animals')->restrictOnDelete();
            $table->foreign('inventory_item_id')->references('id')->on('inventory_items')->restrictOnDelete();
            $table->foreign('inventory_batch_id')->references('id')->on('inventory_batches')->restrictOnDelete();
            $table->foreign('created_by')->references('id')->on('users')->restrictOnDelete();
        });
        foreach (['health.preventive.view', 'health.preventive.manage'] as $name) {
            DB::table('permissions')->updateOrInsert(['name' => $name], ['id' => (string) Str::uuid7(), 'created_at' => now(), 'updated_at' => now()]);
        }
        $ids = DB::table('permissions')->whereIn('name', ['health.preventive.view', 'health.preventive.manage'])->pluck('id');
        foreach (DB::table('roles')->whereIn('slug', ['organization-owner', 'farm-manager'])->pluck('id') as $role) {
            foreach ($ids as $id) {
                DB::table('role_permissions')->updateOrInsert(['role_id' => $role, 'permission_id' => $id], ['created_at' => now(), 'updated_at' => now()]);
            }
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('animal_preventive_care_records');
        DB::table('permissions')->whereIn('name', ['health.preventive.view', 'health.preventive.manage'])->delete();
    }
};
