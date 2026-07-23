<?php

namespace Tests\Concerns;

use App\Domain\AnimalRegistry\Models\AnimalBreed;
use App\Domain\AnimalRegistry\Models\AnimalGroup;
use App\Domain\AnimalRegistry\Models\AnimalSpecies;
use App\Domain\AnimalRegistry\Support\AnimalRegistryNormalizer;
use App\Models\Farm;
use App\Models\Organization;
use App\Models\OrganizationMembership;
use App\Models\Permission;
use App\Models\Role;
use App\Models\Shed;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

trait CreatesFoundationData
{
    protected function foundation(array $permissionNames = [], bool $allFarms = true): array
    {
        $organization = Organization::create(['name' => 'Green Valley Dairy', 'timezone' => 'Asia/Karachi', 'locale' => 'en']);
        $farm = Farm::create(['organization_id' => $organization->id, 'name' => 'North Farm', 'code' => 'NORTH', 'timezone' => 'Asia/Karachi']);
        $shed = Shed::create(['organization_id' => $organization->id, 'farm_id' => $farm->id, 'name' => 'Main Shed', 'code' => 'MAIN']);
        $user = User::create(['name' => 'Ayesha Khan', 'email' => 'owner@example.test', 'password' => Hash::make('Correct-Horse-2026'), 'is_active' => true]);
        $membership = OrganizationMembership::create(['organization_id' => $organization->id, 'user_id' => $user->id, 'status' => 'active', 'all_farms' => $allFarms]);
        $role = Role::create(['organization_id' => $organization->id, 'name' => 'Test Role', 'slug' => 'test-role', 'is_system' => true]);
        $permissionNames = array_unique([...$permissionNames, 'sessions.view_own', 'sessions.revoke_own']);
        foreach ($permissionNames as $name) {
            $role->permissions()->attach(Permission::firstOrCreate(['name' => $name])->id);
        }
        $membership->roles()->attach($role->id, ['organization_id' => $organization->id]);
        if (! $allFarms) {
            $membership->farms()->attach($farm->id, ['organization_id' => $organization->id]);
        }

        return compact('organization', 'farm', 'shed', 'user', 'membership', 'role');
    }

    protected function loginToken(string $email = 'owner@example.test', string $password = 'Correct-Horse-2026'): string
    {
        return $this->postJson('/api/v1/auth/login', ['email' => $email, 'password' => $password, 'device_name' => 'Test tablet'])->assertOk()->json('data.access_token');
    }

    protected function bearer(string $token): array
    {
        return ['Authorization' => 'Bearer '.$token];
    }

    protected function animalRegistryReferences(array $foundation): array
    {
        $species = AnimalSpecies::create(['code' => 'CATTLE', 'name' => 'Cattle', 'is_active' => true]);
        $breed = AnimalBreed::create([
            'organization_id' => $foundation['organization']->id,
            'species_id' => $species->id,
            'code' => 'SAHIWAL',
            'name' => 'Sahiwal',
            'normalized_name' => app(AnimalRegistryNormalizer::class)->name('Sahiwal'),
            'created_by' => $foundation['user']->id,
            'updated_by' => $foundation['user']->id,
        ]);
        $group = AnimalGroup::create([
            'organization_id' => $foundation['organization']->id,
            'farm_id' => $foundation['farm']->id,
            'default_shed_id' => $foundation['shed']->id,
            'code' => 'MAIN-HERD',
            'name' => 'Main Herd',
            'normalized_name' => app(AnimalRegistryNormalizer::class)->name('Main Herd'),
            'created_by' => $foundation['user']->id,
            'updated_by' => $foundation['user']->id,
        ]);

        return compact('species', 'breed', 'group');
    }
}
