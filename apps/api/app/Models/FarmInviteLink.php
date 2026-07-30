<?php

namespace App\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FarmInviteLink extends Model
{
    use UsesUuidV7;

    protected $fillable = [
        'organization_id',
        'farm_id',
        'created_by_membership_id',
        'token_hash',
        'token_ciphertext',
        'is_enabled',
        'generation',
    ];

    protected $hidden = ['token_hash', 'token_ciphertext'];

    protected function casts(): array
    {
        return ['is_enabled' => 'boolean'];
    }

    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }

    public function farm(): BelongsTo
    {
        return $this->belongsTo(Farm::class);
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(OrganizationMembership::class, 'created_by_membership_id');
    }
}
