<?php

namespace App\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class OrganizationMembership extends Model
{
    use UsesUuidV7;

    protected $fillable = ['organization_id', 'user_id', 'status', 'membership_type', 'all_farms', 'invited_by_membership_id'];

    protected function casts(): array
    {
        return ['all_farms' => 'boolean'];
    }

    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function roles(): BelongsToMany
    {
        return $this->belongsToMany(Role::class, 'membership_role')
            ->withPivot('organization_id')
            ->wherePivot('organization_id', $this->organization_id)
            ->where('roles.organization_id', $this->organization_id);
    }

    public function farms(): BelongsToMany
    {
        return $this->belongsToMany(Farm::class, 'user_farm_access')
            ->withPivot('organization_id')
            ->wherePivot('organization_id', $this->organization_id)
            ->where('farms.organization_id', $this->organization_id);
    }

    public function permissions(): array
    {
        return $this->roles()->with('permissions:id,name')->get()->flatMap->permissions->pluck('name')->unique()->values()->all();
    }

    public function can(string $permission): bool
    {
        return in_array($permission, $this->permissions(), true);
    }

    public function canAccessFarm(string $farmId): bool
    {
        return $this->all_farms || $this->farms()->whereKey($farmId)->exists();
    }
}
