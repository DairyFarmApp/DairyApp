<?php

use App\Models\Permission;
use App\Models\Role;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::transaction(function (): void {
            $permission = Permission::query()->firstOrCreate([
                'name' => 'farms.create',
            ]);

            Role::query()
                ->where('slug', 'organization-owner')
                ->each(fn (Role $role) => $role->permissions()
                    ->syncWithoutDetaching([$permission->id]));
        });
    }

    public function down(): void
    {
        $permission = Permission::query()
            ->where('name', 'farms.create')
            ->first();
        if ($permission === null) {
            return;
        }

        Role::query()
            ->where('slug', 'organization-owner')
            ->each(fn (Role $role) => $role->permissions()->detach($permission->id));
    }
};
