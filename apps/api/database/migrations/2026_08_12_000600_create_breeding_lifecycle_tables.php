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
        Schema::create('animal_heat_records', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->uuid('organization_id');
            $t->uuid('farm_id');
            $t->uuid('animal_id');
            $t->dateTime('detected_at');
            $t->json('symptoms');
            $t->string('detection_method', 80);
            $t->string('detected_by_name', 160);
            $t->string('intensity', 20);
            $t->text('recommended_action');
            $t->text('notes')->nullable();
            $t->uuid('created_by');
            $t->timestamps();
            $t->foreign('animal_id')->references('id')->on('animals')->restrictOnDelete();
            $t->foreign('created_by')->references('id')->on('users')->restrictOnDelete();
        });
        Schema::create('animal_breeding_services', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->uuid('organization_id');
            $t->uuid('farm_id');
            $t->uuid('animal_id');
            $t->uuid('heat_record_id')->nullable();
            $t->string('service_number', 40);
            $t->dateTime('bred_at');
            $t->string('method', 20);
            $t->uuid('bull_animal_id')->nullable();
            $t->uuid('semen_item_id')->nullable();
            $t->uuid('semen_batch_id')->nullable();
            $t->string('semen_straw_number')->nullable();
            $t->string('breed_name')->nullable();
            $t->string('supplier')->nullable();
            $t->string('technician_name', 160);
            $t->decimal('cost_pkr', 14, 2)->default(0);
            $t->date('pregnancy_check_due_date');
            $t->text('notes')->nullable();
            $t->uuid('created_by');
            $t->timestamps();
            $t->unique(['organization_id', 'service_number'], 'breeding_service_number_uq');
            $t->foreign('animal_id')->references('id')->on('animals')->restrictOnDelete();
            $t->foreign('heat_record_id')->references('id')->on('animal_heat_records')->nullOnDelete();
            $t->foreign('bull_animal_id')->references('id')->on('animals')->restrictOnDelete();
            $t->foreign('semen_item_id')->references('id')->on('inventory_items')->restrictOnDelete();
            $t->foreign('semen_batch_id')->references('id')->on('inventory_batches')->restrictOnDelete();
            $t->foreign('created_by')->references('id')->on('users')->restrictOnDelete();
        });
        Schema::create('animal_pregnancy_checks', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->uuid('organization_id');
            $t->uuid('farm_id');
            $t->uuid('animal_id');
            $t->uuid('breeding_service_id');
            $t->date('checked_on');
            $t->string('method', 80);
            $t->string('veterinarian_name', 160);
            $t->string('result', 20);
            $t->unsignedSmallInteger('estimated_age_days')->nullable();
            $t->date('expected_calving_date')->nullable();
            $t->date('follow_up_date')->nullable();
            $t->text('notes')->nullable();
            $t->uuid('created_by');
            $t->timestamps();
            $t->foreign('animal_id')->references('id')->on('animals')->restrictOnDelete();
            $t->foreign('breeding_service_id')->references('id')->on('animal_breeding_services')->restrictOnDelete();
            $t->foreign('created_by')->references('id')->on('users')->restrictOnDelete();
        });
        Schema::create('animal_calving_events', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->uuid('organization_id');
            $t->uuid('farm_id');
            $t->uuid('mother_animal_id');
            $t->uuid('pregnancy_check_id');
            $t->dateTime('calved_at');
            $t->string('calving_type', 20);
            $t->string('veterinarian_name')->nullable();
            $t->text('complications')->nullable();
            $t->string('placenta_status', 40);
            $t->string('mother_condition', 80);
            $t->boolean('treatment_required')->default(false);
            $t->date('post_calving_check_due');
            $t->json('calf_animal_ids');
            $t->text('notes')->nullable();
            $t->uuid('created_by');
            $t->timestamps();
            $t->unique('pregnancy_check_id');
            $t->foreign('mother_animal_id')->references('id')->on('animals')->restrictOnDelete();
            $t->foreign('pregnancy_check_id')->references('id')->on('animal_pregnancy_checks')->restrictOnDelete();
            $t->foreign('created_by')->references('id')->on('users')->restrictOnDelete();
        });
        foreach (['breeding.view', 'breeding.manage'] as $n) {
            DB::table('permissions')->updateOrInsert(['name' => $n], ['id' => (string) Str::uuid7(), 'created_at' => now(), 'updated_at' => now()]);
        }$ids = DB::table('permissions')->whereIn('name', ['breeding.view', 'breeding.manage'])->pluck('id');
        foreach (DB::table('roles')->whereIn('slug', ['organization-owner', 'farm-manager'])->pluck('id') as $r) {
            foreach ($ids as $id) {
                DB::table('role_permissions')->updateOrInsert(['role_id' => $r, 'permission_id' => $id], ['created_at' => now(), 'updated_at' => now()]);
            }
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('animal_calving_events');
        Schema::dropIfExists('animal_pregnancy_checks');
        Schema::dropIfExists('animal_breeding_services');
        Schema::dropIfExists('animal_heat_records');
        DB::table('permissions')->whereIn('name',['breeding.view', 'breeding.manage'])->delete();
    }
};
