<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

return new class extends Migration
{
    public function up(): void
    {
        $permissionId = DB::table('permissions')
            ->where('name', 'inventory.export')
            ->value('id');

        if (! $permissionId) {
            $permissionId = (string) Str::uuid7();
            DB::table('permissions')->insert([
                'id' => $permissionId,
                'name' => 'inventory.export',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        DB::table('roles')
            ->whereIn('slug', ['organization-owner', 'farm-manager'])
            ->pluck('id')
            ->each(fn (string $roleId) => DB::table('permission_role')->insertOrIgnore([
                'role_id' => $roleId,
                'permission_id' => $permissionId,
            ]));
    }

    public function down(): void
    {
        $permissionId = DB::table('permissions')
            ->where('name', 'inventory.export')
            ->value('id');

        if ($permissionId) {
            DB::table('permission_role')
                ->where('permission_id', $permissionId)
                ->delete();
            DB::table('permissions')
                ->where('id', $permissionId)
                ->delete();
        }
    }
};
