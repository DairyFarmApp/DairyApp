<?php

namespace App\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ApiSession extends Model
{
    use UsesUuidV7;

    protected $fillable = ['user_id', 'organization_id', 'farm_id', 'access_token_hash', 'renewal_token_hash', 'access_expires_at', 'renewal_expires_at', 'last_used_at', 'revoked_at', 'device_name', 'device_id', 'ip_address', 'user_agent'];

    protected $hidden = ['access_token_hash', 'renewal_token_hash'];

    protected function casts(): array
    {
        return ['access_expires_at' => 'datetime', 'renewal_expires_at' => 'datetime', 'last_used_at' => 'datetime', 'revoked_at' => 'datetime', 'renewal_reuse_detected_at' => 'datetime'];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }

    public function farm(): BelongsTo
    {
        return $this->belongsTo(Farm::class);
    }

    public function renewalTokens(): HasMany
    {
        return $this->hasMany(ApiSessionRenewalToken::class);
    }
}
