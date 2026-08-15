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
        Schema::create('in_app_alerts', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->uuid('organization_id');
            $t->uuid('farm_id');
            $t->string('source_key', 190);
            $t->string('type', 60);
            $t->string('severity', 20);
            $t->string('title', 220);
            $t->text('description');
            $t->string('title_roman_urdu', 220)->nullable();
            $t->text('description_roman_urdu')->nullable();
            $t->string('related_type', 80);
            $t->uuid('related_id');
            $t->dateTime('due_at');
            $t->string('status', 20)->default('active');
            $t->uuid('assigned_user_id')->nullable();
            $t->dateTime('read_at')->nullable();
            $t->dateTime('resolved_at')->nullable();
            $t->uuid('resolved_by')->nullable();
            $t->timestamps();
            $t->unique(['organization_id', 'farm_id', 'source_key'], 'alert_source_uq');
            $t->index(['organization_id', 'farm_id', 'status', 'due_at'], 'alert_active_due_idx');
            $t->foreign('assigned_user_id')->references('id')->on('users')->nullOnDelete();
            $t->foreign('resolved_by')->references('id')->on('users')->nullOnDelete();
        });
        foreach (['alerts.view', 'alerts.manage'] as $n) {
            DB::table('permissions')->updateOrInsert(['name' => $n], ['id' => (string) Str::uuid7(), 'created_at' => now(), 'updated_at' => now()]);
        }$ids = DB::table('permissions')->whereIn('name', ['alerts.view', 'alerts.manage'])->pluck('id');
        foreach (DB::table('roles')->whereIn('slug', ['organization-owner', 'farm-manager'])->pluck('id') as $r) {
            foreach ($ids as $id) {
                DB::table('role_permissions')->updateOrInsert(['role_id' => $r, 'permission_id' => $id], ['created_at' => now(), 'updated_at' => now()]);
            }
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('in_app_alerts');
        DB::table('permissions')->whereIn('name', ['alerts.view', 'alerts.manage'])->delete();
    }
};
