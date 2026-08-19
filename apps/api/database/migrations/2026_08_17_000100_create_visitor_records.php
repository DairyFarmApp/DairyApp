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
        Schema::create('visitor_records', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->string('visitor_name', 160);
            $table->dateTime('visited_at');
            $table->string('purpose', 500);
            $table->uuid('created_by');
            $table->timestamps();
            $table->softDeletes();
            $table->index(['organization_id', 'farm_id', 'visited_at']);
            $table->foreign(['farm_id', 'organization_id'])->references(['id', 'organization_id'])->on('farms')->restrictOnDelete();
            $table->foreign('created_by')->references('id')->on('users')->restrictOnDelete();
        });
        foreach (['visitors.view', 'visitors.manage'] as $name) {
            DB::table('permissions')->updateOrInsert(['name' => $name], ['id' => (string) Str::uuid7(), 'created_at' => now(), 'updated_at' => now()]);
        }
        $ids = DB::table('permissions')->whereIn('name', ['visitors.view', 'visitors.manage'])->pluck('id');
        foreach (DB::table('roles')->whereIn('slug', ['organization-owner', 'farm-manager', 'assistant-manager'])->pluck('id') as $role) {
            foreach ($ids as $id) {
                DB::table('permission_role')->updateOrInsert(['role_id' => $role, 'permission_id' => $id]);
            }
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('visitor_records');
        DB::table('permissions')->whereIn('name', ['visitors.view', 'visitors.manage'])->delete();
    }
};
