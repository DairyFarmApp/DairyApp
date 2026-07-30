<?php

use App\Models\OrganizationMembership;
use App\Models\Permission;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::transaction(function (): void {
            $permissions = collect(['milk.view', 'milk.create', 'milk.correct'])
                ->mapWithKeys(fn (string $name) => [
                    $name => Permission::query()->firstOrCreate(['name' => $name]),
                ]);

            OrganizationMembership::query()
                ->whereIn('membership_type', ['primary_owner', 'family_admin'])
                ->with('roles')
                ->get()
                ->flatMap->roles
                ->unique('id')
                ->each(fn ($role) => $role->permissions()->syncWithoutDetaching(
                    $permissions->pluck('id')->all(),
                ));
        });
    }

    public function down(): void
    {
        Permission::query()
            ->whereIn('name', ['milk.view', 'milk.create', 'milk.correct'])
            ->delete();
    }
};
