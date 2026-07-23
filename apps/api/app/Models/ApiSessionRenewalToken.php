<?php

namespace App\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ApiSessionRenewalToken extends Model
{
    use UsesUuidV7;

    protected $fillable = ['api_session_id', 'token_hash', 'expires_at', 'consumed_at'];

    protected $hidden = ['token_hash'];

    protected function casts(): array
    {
        return ['expires_at' => 'datetime', 'consumed_at' => 'datetime'];
    }

    public function session(): BelongsTo
    {
        return $this->belongsTo(ApiSession::class, 'api_session_id');
    }
}
