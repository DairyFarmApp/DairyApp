<?php

namespace App\Domain\OwnerAccounts\Support;

use App\Domain\AnimalRegistry\Support\DefaultAnimalBreedCatalog;
use App\Models\ApiSession;
use App\Models\Farm;
use App\Models\FarmInviteLink;
use App\Models\Organization;
use App\Models\OrganizationMembership;
use App\Models\Permission;
use App\Models\Role;
use App\Models\Setting;
use App\Models\User;
use App\Support\PermissionCatalog;
use Illuminate\Support\Facades\Crypt;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

final class OwnerAccountService
{
    public function __construct(private readonly DefaultAnimalBreedCatalog $breeds) {}

    /**
     * @return array{user: User, organization: Organization, farm: Farm, membership: OrganizationMembership}
     */
    public function registerPrimaryOwner(array $data): array
    {
        return DB::transaction(function () use ($data): array {
            $organization = Organization::create([
                'name' => trim($data['farm_name']),
                'timezone' => $data['timezone'] ?? 'UTC',
                'locale' => 'en',
            ]);
            $farm = Farm::create([
                'organization_id' => $organization->id,
                'name' => trim($data['farm_name']),
                'code' => $this->farmCode($data['farm_name']),
                'timezone' => $data['timezone'] ?? 'UTC',
            ]);
            $user = User::create([
                'name' => trim($data['name']),
                'email' => strtolower(trim($data['email'])),
                'phone_number' => $this->nullableTrim($data['phone_number'] ?? null),
                'password' => Hash::make($data['password']),
                'is_active' => true,
            ]);
            $membership = OrganizationMembership::create([
                'organization_id' => $organization->id,
                'user_id' => $user->id,
                'status' => 'active',
                'membership_type' => 'primary_owner',
                'all_farms' => true,
            ]);
            $ownerRole = $this->ownerRole($organization);
            $membership->roles()->attach($ownerRole->id, [
                'organization_id' => $organization->id,
            ]);
            $this->breeds->ensureForOrganization($organization, $user);
            $this->createDefaultSettings($organization);

            return compact('user', 'organization', 'farm', 'membership');
        });
    }

    /**
     * @return array{link: FarmInviteLink, token: string}
     */
    public function createOrRotateInvite(
        OrganizationMembership $owner,
        Farm $farm,
    ): array {
        return DB::transaction(function () use ($owner, $farm): array {
            $link = FarmInviteLink::query()
                ->where('organization_id', $owner->organization_id)
                ->lockForUpdate()
                ->first();
            $secret = $this->secret();
            if (! $link) {
                $link = new FarmInviteLink([
                    'organization_id' => $owner->organization_id,
                    'farm_id' => $farm->id,
                    'generation' => 0,
                ]);
                $link->id = (string) Str::uuid7();
            }
            $token = $link->id.'.'.$secret;
            $link->created_by_membership_id = $owner->id;
            $link->farm_id = $farm->id;
            $link->token_hash = hash('sha256', $secret);
            $link->token_ciphertext = Crypt::encryptString($token);
            $link->is_enabled = true;
            $link->generation++;
            $link->save();

            return compact('link', 'token');
        });
    }

    public function currentInvite(OrganizationMembership $owner): ?array
    {
        $link = FarmInviteLink::query()
            ->where('organization_id', $owner->organization_id)
            ->first();
        if (! $link) {
            return null;
        }

        return [
            'link' => $link,
            'token' => Crypt::decryptString($link->token_ciphertext),
        ];
    }

    public function inspectInvite(string $token): ?FarmInviteLink
    {
        [$id, $secret] = $this->parseToken($token);
        if ($id === null || $secret === null) {
            return null;
        }
        $link = FarmInviteLink::query()
            ->with(['organization', 'farm'])
            ->find($id);
        if (! $link || ! $link->is_enabled) {
            return null;
        }

        return hash_equals($link->token_hash, hash('sha256', $secret))
            ? $link
            : null;
    }

    /**
     * @return array{user: User, organization: Organization, farm: Farm, membership: OrganizationMembership}
     */
    public function registerFamilyOwner(string $token, array $data): array
    {
        return DB::transaction(function () use ($token, $data): array {
            [$id, $secret] = $this->parseToken($token);
            $link = $id === null
                ? null
                : FarmInviteLink::query()
                    ->with(['organization', 'farm'])
                    ->lockForUpdate()
                    ->find($id);
            if (
                ! $link ||
                ! $link->is_enabled ||
                $secret === null ||
                ! hash_equals($link->token_hash, hash('sha256', $secret))
            ) {
                throw new \DomainException('The farm invitation is invalid or has been disabled.');
            }
            $familyCount = OrganizationMembership::query()
                ->where('organization_id', $link->organization_id)
                ->where('membership_type', 'family_admin')
                ->where('status', 'active')
                ->count();
            if ($familyCount >= (int) config('dairycare.auth.maximum_family_accounts', 25)) {
                throw new \DomainException('This farm has reached its family-account limit.');
            }
            if (User::query()->whereRaw('LOWER(email) = ?', [strtolower($data['email'])])->exists()) {
                throw new \DomainException('An account already uses this email address.');
            }

            $user = User::create([
                'name' => trim($data['name']),
                'email' => strtolower(trim($data['email'])),
                'phone_number' => $this->nullableTrim($data['phone_number'] ?? null),
                'password' => Hash::make($data['password']),
                'is_active' => true,
            ]);
            $membership = OrganizationMembership::create([
                'organization_id' => $link->organization_id,
                'user_id' => $user->id,
                'status' => 'active',
                'membership_type' => 'family_admin',
                'all_farms' => true,
                'invited_by_membership_id' => $link->created_by_membership_id,
            ]);
            $ownerRole = $this->ownerRole($link->organization);
            $membership->roles()->attach($ownerRole->id, [
                'organization_id' => $link->organization_id,
            ]);

            return [
                'user' => $user,
                'organization' => $link->organization,
                'farm' => $link->farm,
                'membership' => $membership,
            ];
        });
    }

    public function removeFamily(
        OrganizationMembership $owner,
        OrganizationMembership $family,
    ): void {
        DB::transaction(function () use ($owner, $family): void {
            $locked = OrganizationMembership::query()
                ->where('organization_id', $owner->organization_id)
                ->lockForUpdate()
                ->findOrFail($family->id);
            if ($locked->membership_type !== 'family_admin') {
                throw new \DomainException('Only a family account can be removed.');
            }
            $locked->forceFill(['status' => 'removed'])->save();
            ApiSession::query()
                ->where('organization_id', $owner->organization_id)
                ->where('user_id', $locked->user_id)
                ->whereNull('revoked_at')
                ->update(['revoked_at' => now(), 'updated_at' => now()]);
        });
    }

    public function restoreFamily(
        OrganizationMembership $owner,
        OrganizationMembership $family,
    ): void {
        DB::transaction(function () use ($owner, $family): void {
            $locked = OrganizationMembership::query()
                ->where('organization_id', $owner->organization_id)
                ->lockForUpdate()
                ->findOrFail($family->id);
            if ($locked->membership_type !== 'family_admin') {
                throw new \DomainException('Only a family account can be restored.');
            }
            $activeFamilyCount = OrganizationMembership::query()
                ->where('organization_id', $owner->organization_id)
                ->where('membership_type', 'family_admin')
                ->where('status', 'active')
                ->whereKeyNot($locked->id)
                ->count();
            if ($activeFamilyCount >= (int) config('dairycare.auth.maximum_family_accounts', 25)) {
                throw new \DomainException('This farm has reached its family-account limit.');
            }
            $locked->forceFill(['status' => 'active'])->save();
        });
    }

    public function ownerRole(Organization $organization): Role
    {
        $ownerPermissions = collect(PermissionCatalog::all())
            ->reject(fn (string $name) => $name === 'farms.archive');
        $permissions = $ownerPermissions->mapWithKeys(
            fn (string $name) => [
                $name => Permission::query()->firstOrCreate(['name' => $name]),
            ],
        );
        $role = Role::query()->firstOrCreate(
            [
                'organization_id' => $organization->id,
                'slug' => 'organization-owner',
            ],
            ['name' => 'Organization Owner', 'is_system' => true],
        );
        $role->permissions()->sync($permissions->pluck('id')->all());

        return $role;
    }

    private function createDefaultSettings(Organization $organization): void
    {
        Setting::create([
            'organization_id' => $organization->id,
            'farm_id' => null,
            'key' => 'animal_movement_requires_approval',
            'type' => 'boolean',
            'value' => ['enabled' => true],
        ]);
        Setting::create([
            'organization_id' => $organization->id,
            'farm_id' => null,
            'key' => 'animal_weight_max_kg',
            'type' => 'decimal',
            'value' => ['kilograms' => '3000.000000'],
        ]);
    }

    private function farmCode(string $name): string
    {
        $code = strtoupper(Str::slug($name, '-'));

        return Str::limit($code === '' ? 'FARM' : $code, 40, '');
    }

    private function nullableTrim(mixed $value): ?string
    {
        $trimmed = is_string($value) ? trim($value) : '';

        return $trimmed === '' ? null : $trimmed;
    }

    private function secret(): string
    {
        return rtrim(strtr(base64_encode(random_bytes(32)), '+/', '-_'), '=');
    }

    /**
     * @return array{0: ?string, 1: ?string}
     */
    private function parseToken(string $token): array
    {
        [$id, $secret] = array_pad(explode('.', $token, 2), 2, null);
        if (! is_string($id) || ! Str::isUuid($id) || ! is_string($secret) || strlen($secret) < 40) {
            return [null, null];
        }

        return [$id, $secret];
    }
}
