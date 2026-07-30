<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    use HasFactory, HasUuids, Notifiable;

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = ['name', 'email', 'phone_number', 'password', 'profile_photo_path', 'is_active', 'failed_login_count', 'last_failed_login_at', 'locked_until'];

    protected $hidden = ['password'];

    protected function casts(): array
    {
        return ['email_verified_at' => 'datetime', 'password' => 'hashed', 'is_active' => 'boolean', 'last_failed_login_at' => 'datetime', 'locked_until' => 'datetime'];
    }

    public function memberships(): HasMany
    {
        return $this->hasMany(OrganizationMembership::class);
    }

    public function apiSessions(): HasMany
    {
        return $this->hasMany(ApiSession::class);
    }

    protected static function booted(): void
    {
        static::updated(function (User $user): void {
            if (($user->wasChanged('is_active') && ! $user->is_active) || $user->wasChanged('password')) {
                $user->apiSessions()->whereNull('revoked_at')->update(['revoked_at' => now()]);
            }
        });
    }
}
