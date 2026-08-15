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
        Schema::create('calf_care_profiles', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->uuid('organization_id');
            $t->uuid('farm_id');
            $t->uuid('animal_id')->unique();
            $t->dateTime('birth_at');
            $t->decimal('birth_weight_kg', 8, 3);
            $t->string('birth_condition', 80);
            $t->boolean('colostrum_given')->default(false);
            $t->dateTime('colostrum_at')->nullable();
            $t->decimal('colostrum_quantity_litres', 8, 3)->nullable();
            $t->string('colostrum_quality', 40)->nullable();
            $t->boolean('navel_treated')->default(false);
            $t->dateTime('navel_treated_at')->nullable();
            $t->string('navel_product')->nullable();
            $t->date('weaning_target_date');
            $t->date('actual_weaning_date')->nullable();
            $t->string('feed_plan')->nullable();
            $t->decimal('target_daily_gain_kg', 6, 3);
            $t->string('health_status', 40)->default('normal');
            $t->text('notes')->nullable();
            $t->uuid('created_by');
            $t->uuid('updated_by');
            $t->unsignedBigInteger('version')->default(1);
            $t->timestamps();
            $t->index(['organization_id', 'farm_id', 'weaning_target_date'], 'calf_weaning_due_idx');
            $t->foreign('animal_id')->references('id')->on('animals')->cascadeOnDelete();
            $t->foreign('created_by')->references('id')->on('users')->restrictOnDelete();
            $t->foreign('updated_by')->references('id')->on('users')->restrictOnDelete();
        });
        foreach (['calves.view', 'calves.manage'] as $n) {
            DB::table('permissions')->updateOrInsert(['name' => $n], ['id' => (string) Str::uuid7(), 'created_at' => now(), 'updated_at' => now()]);
        }$ids = DB::table('permissions')->whereIn('name', ['calves.view', 'calves.manage'])->pluck('id');
        foreach (DB::table('roles')->whereIn('slug', ['organization-owner', 'farm-manager'])->pluck('id') as $r) {
            foreach ($ids as $id) {
                DB::table('role_permissions')->updateOrInsert(['role_id' => $r, 'permission_id' => $id], ['created_at' => now(), 'updated_at' => now()]);
            }
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('calf_care_profiles');
        DB::table('permissions')->whereIn('name', ['calves.view', 'calves.manage'])->delete();
    }
};
