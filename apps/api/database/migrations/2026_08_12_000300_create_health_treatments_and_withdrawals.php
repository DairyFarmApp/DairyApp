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
        $medicineColumns = [
            'generic_name' => fn (Blueprint $table) => $table->string('generic_name')->nullable()->after('name'),
            'drap_registration_number' => fn (Blueprint $table) => $table->string('drap_registration_number')->nullable()->after('generic_name'),
            'concentration' => fn (Blueprint $table) => $table->string('concentration')->nullable()->after('drap_registration_number'),
            'milk_withdrawal_hours' => fn (Blueprint $table) => $table->unsignedInteger('milk_withdrawal_hours')->default(0)->after('concentration'),
            'meat_withdrawal_days' => fn (Blueprint $table) => $table->unsignedInteger('meat_withdrawal_days')->default(0)->after('milk_withdrawal_hours'),
            'regulatory_verified_on' => fn (Blueprint $table) => $table->date('regulatory_verified_on')->nullable()->after('meat_withdrawal_days'),
        ];
        foreach ($medicineColumns as $column => $definition) {
            if (! Schema::hasColumn('inventory_items', $column)) {
                Schema::table('inventory_items', $definition);
            }
        }
        if (! Schema::hasTable('animal_treatments')) {
            Schema::create('animal_treatments', function (Blueprint $table): void {
                $table->uuid('id')->primary();
                $table->uuid('organization_id');
                $table->uuid('farm_id');
                $table->uuid('animal_id');
                $table->uuid('health_case_id');
                $table->uuid('inventory_item_id');
                $table->string('treatment_number', 40);
                $table->dateTime('administered_at');
                $table->decimal('animal_weight_kg', 10, 3);
                $table->decimal('dose', 12, 3);
                $table->string('dose_unit', 24);
                $table->string('route', 40);
                $table->string('frequency', 80);
                $table->unsignedSmallInteger('duration_days');
                $table->decimal('inventory_quantity_used', 18, 3);
                $table->string('veterinarian_name', 160);
                $table->text('veterinarian_instructions');
                $table->text('notes')->nullable();
                $table->uuid('administered_by');
                $table->unsignedBigInteger('version')->default(1);
                $table->timestamps();
                $table->unique(['organization_id', 'treatment_number']);
                $table->foreign('organization_id')->references('id')->on('organizations')->cascadeOnDelete();
                $table->foreign(['farm_id', 'organization_id'])->references(['id', 'organization_id'])->on('farms')->restrictOnDelete();
                $table->foreign(['animal_id', 'organization_id'])->references(['id', 'organization_id'])->on('animals')->restrictOnDelete();
                $table->foreign('health_case_id')->references('id')->on('animal_health_cases')->restrictOnDelete();
                $table->foreign(['inventory_item_id', 'organization_id', 'farm_id'], 'treatment_inventory_farm_fk')->references(['id', 'organization_id', 'farm_id'])->on('inventory_items')->restrictOnDelete();
                $table->foreign('administered_by')->references('id')->on('users')->restrictOnDelete();
            });
        }
        if (! Schema::hasTable('animal_withdrawal_restrictions')) {
            Schema::create('animal_withdrawal_restrictions', function (Blueprint $table): void {
                $table->uuid('id')->primary();
                $table->uuid('organization_id');
                $table->uuid('farm_id');
                $table->uuid('animal_id');
                $table->uuid('treatment_id');
                $table->string('type', 16);
                $table->dateTime('starts_at');
                $table->dateTime('ends_at');
                $table->string('status', 16)->default('active');
                $table->text('reason');
                $table->uuid('created_by');
                $table->timestamps();
                $table->index(['organization_id', 'farm_id', 'animal_id', 'type', 'ends_at'], 'withdrawal_active_idx');
                $table->foreign('organization_id')->references('id')->on('organizations')->cascadeOnDelete();
                $table->foreign(['farm_id', 'organization_id'])->references(['id', 'organization_id'])->on('farms')->restrictOnDelete();
                $table->foreign(['animal_id', 'organization_id'])->references(['id', 'organization_id'])->on('animals')->restrictOnDelete();
                $table->foreign('treatment_id')->references('id')->on('animal_treatments')->cascadeOnDelete();
                $table->foreign('created_by')->references('id')->on('users')->restrictOnDelete();
            });
        }
        foreach (['health.treat', 'health.override_withdrawal'] as $name) {
            DB::table('permissions')->updateOrInsert(['name' => $name], ['id' => (string) Str::uuid7(), 'created_at' => now(), 'updated_at' => now()]);
        }
        $ids = DB::table('permissions')->whereIn('name', ['health.treat', 'health.override_withdrawal'])->pluck('id');
        DB::table('roles')->whereIn('slug', ['organization-owner', 'farm-manager'])->pluck('id')->each(function ($role) use ($ids): void {
            foreach ($ids as $id) {
                DB::table('permission_role')->updateOrInsert(['role_id' => $role, 'permission_id' => $id]);
            }
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('animal_withdrawal_restrictions');
        Schema::dropIfExists('animal_treatments');
        Schema::table('inventory_items', fn (Blueprint $table) => $table->dropColumn(['generic_name', 'drap_registration_number', 'concentration', 'milk_withdrawal_hours', 'meat_withdrawal_days', 'regulatory_verified_on']));
        DB::table('permissions')->whereIn('name', ['health.treat', 'health.override_withdrawal'])->delete();
    }
};
