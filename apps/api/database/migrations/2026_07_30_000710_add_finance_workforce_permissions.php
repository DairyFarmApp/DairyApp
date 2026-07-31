<?php

use App\Models\Permission;
use App\Models\Role;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    private const PERMISSIONS = [
        'employees.view',
        'employees.manage',
        'employee_loans.view',
        'employee_loans.manage',
        'payroll.view',
        'payroll.process',
        'finance.view',
        'finance.manage',
    ];

    public function up(): void
    {
        DB::transaction(function (): void {
            $permissions = collect(self::PERMISSIONS)
                ->mapWithKeys(fn (string $name) => [
                    $name => Permission::query()->firstOrCreate(['name' => $name]),
                ]);

            Role::query()
                ->whereIn('slug', ['organization-owner', 'farm-manager'])
                ->each(fn (Role $role) => $role->permissions()->syncWithoutDetaching(
                    $permissions->pluck('id')->all(),
                ));
        });
    }

    public function down(): void
    {
        Permission::query()->whereIn('name', self::PERMISSIONS)->delete();
    }
};
