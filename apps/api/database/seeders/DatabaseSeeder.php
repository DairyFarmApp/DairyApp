<?php

namespace Database\Seeders;

use App\Models\Farm;
use App\Models\Organization;
use App\Models\OrganizationMembership;
use App\Models\Permission;
use App\Models\Role;
use App\Models\Setting;
use App\Models\Shed;
use App\Models\User;
use App\Support\PermissionCatalog;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $password = config('dairycare.seed_password');
        if (! is_string($password) || strlen($password) < 12) {
            throw new \RuntimeException('DAIRYCARE_SEED_PASSWORD must contain at least 12 characters. Development seed credentials must never be used in production.');
        }

        DB::transaction(function () use ($password): void {
            $organization = Organization::query()->updateOrCreate(
                ['name' => 'Green Valley Dairy Cooperative'],
                ['timezone' => 'Asia/Karachi', 'locale' => 'en'],
            );
            $north = Farm::query()->updateOrCreate(
                ['organization_id' => $organization->id, 'code' => 'NORTH'],
                ['name' => 'North Farm', 'timezone' => 'Asia/Karachi'],
            );
            $riverside = Farm::query()->updateOrCreate(
                ['organization_id' => $organization->id, 'code' => 'RIVER'],
                ['name' => 'Riverside Farm', 'timezone' => 'Asia/Karachi'],
            );
            Setting::query()->updateOrCreate(
                [
                    'organization_id' => $organization->id,
                    'farm_id' => null,
                    'key' => 'animal_movement_requires_approval',
                ],
                ['type' => 'boolean', 'value' => ['enabled' => true]],
            );
            Setting::query()->updateOrCreate(
                [
                    'organization_id' => $organization->id,
                    'farm_id' => null,
                    'key' => 'animal_weight_max_kg',
                ],
                ['type' => 'decimal', 'value' => ['kilograms' => '3000.000000']],
            );
            foreach ([[$north, 'Lactation Shed', 'N-LACT'], [$north, 'Calf Shed', 'N-CALF'], [$riverside, 'Main Shed', 'R-MAIN'], [$riverside, 'Quarantine Shed', 'R-QUAR']] as [$farm, $name, $code]) {
                Shed::query()->updateOrCreate(
                    ['farm_id' => $farm->id, 'code' => $code],
                    ['organization_id' => $organization->id, 'name' => $name],
                );
            }

            $permissionNames = PermissionCatalog::all();
            $permissions = collect($permissionNames)->mapWithKeys(
                fn ($name) => [$name => Permission::query()->firstOrCreate(['name' => $name])],
            );
            $roles = [
                'organization-owner' => ['Organization Owner', $permissionNames],
                'farm-manager' => ['Farm Manager', [
                    'organizations.view', 'farms.view', 'farms.create', 'farms.update',
                    'sheds.view', 'sheds.create', 'sheds.update', 'sheds.archive',
                    'animals.view', 'animals.create', 'animals.update',
                    'animal_breeds.view', 'animal_breeds.manage',
                    'animal_groups.view', 'animal_groups.manage',
                    'animals.move', 'animal_movements.view', 'animal_movements.approve',
                    'animal_movements.reject', 'animal_movements.cancel',
                    'animals.record_weight', 'animals.correct_weight',
                    'animals.view_weight_history', 'animals.change_status',
                    'animals.view_status_history',
                    'inventory.view', 'inventory.manage', 'inventory.export',
                    'sessions.view_own', 'sessions.revoke_own',
                ]],
                'farm-worker' => ['Farm Worker', [
                    'organizations.view', 'farms.view', 'sheds.view', 'animals.view',
                    'animal_breeds.view', 'animal_groups.view',
                    'animals.move', 'animal_movements.view',
                    'animals.record_weight', 'animals.view_weight_history',
                    'animals.view_status_history',
                    'inventory.view',
                    'sessions.view_own', 'sessions.revoke_own',
                ]],
                'viewer' => ['Viewer', [
                    'organizations.view', 'farms.view', 'sheds.view', 'animals.view',
                    'animal_breeds.view', 'animal_groups.view',
                    'animal_movements.view',
                    'animals.view_weight_history', 'animals.view_status_history',
                    'inventory.view',
                    'sessions.view_own', 'sessions.revoke_own',
                ]],
            ];
            $roleModels = collect($roles)->mapWithKeys(function ($definition, $slug) use ($organization, $permissions) {
                $role = Role::query()->updateOrCreate(
                    ['organization_id' => $organization->id, 'slug' => $slug],
                    ['name' => $definition[0], 'is_system' => true],
                );
                $role->permissions()->sync(collect($definition[1])->map(fn ($name) => $permissions[$name]->id));

                return [$slug => $role];
            });

            $people = [
                ['Ayesha Khan', 'owner@dairycare.local', 'organization-owner', true, [], 'primary_owner'],
                ['Bilal Ahmed', 'manager@dairycare.local', 'farm-manager', false, [$north->id], 'member'],
                ['Nadia Iqbal', 'worker@dairycare.local', 'farm-worker', false, [$north->id], 'member'],
                ['Usman Raza', 'viewer@dairycare.local', 'viewer', false, [$north->id, $riverside->id], 'member'],
            ];
            foreach ($people as [$name, $email, $roleSlug, $allFarms, $farmIds, $membershipType]) {
                $user = User::query()->updateOrCreate(
                    ['email' => $email],
                    ['name' => $name, 'password' => Hash::make($password), 'email_verified_at' => now(), 'is_active' => true],
                );
                $membership = OrganizationMembership::query()->updateOrCreate(
                    ['organization_id' => $organization->id, 'user_id' => $user->id],
                    ['status' => 'active', 'membership_type' => $membershipType, 'all_farms' => $allFarms],
                );
                $membership->roles()->sync([$roleModels[$roleSlug]->id => ['organization_id' => $organization->id]]);
                $membership->farms()->sync(collect($farmIds)->mapWithKeys(
                    fn ($farmId) => [$farmId => ['organization_id' => $organization->id]],
                )->all());
            }
        });

        $this->call(AnimalRegistrySeeder::class);
    }
}
