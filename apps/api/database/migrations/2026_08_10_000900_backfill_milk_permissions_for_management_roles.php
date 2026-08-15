<?php

use App\Models\Permission;
use App\Models\Role;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    private const PERMISSIONS = [
        'milk.view',
        'milk.create',
        'milk.correct',
    ];

    public function up(): void
    {
        DB::transaction(function (): void {
            $permissionIds = collect(self::PERMISSIONS)
                ->map(fn (string $name) => Permission::query()->firstOrCreate([
                    'name' => $name,
                ])->id)
                ->all();

            Role::query()
                ->whereIn('slug', ['organization-owner', 'farm-manager'])
                ->each(fn (Role $role) => $role->permissions()->syncWithoutDetaching(
                    $permissionIds,
                ));
        });
    }

    public function down(): void
    {
        // These permissions predate this corrective backfill and may be in use by
        // custom roles, so rollback must not remove permission assignments.
    }
};
