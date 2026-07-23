<?php

namespace App\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Farm extends Model
{
    use SoftDeletes, UsesUuidV7;

    protected $fillable = ['id', 'organization_id', 'name', 'code', 'timezone', 'version'];

    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }

    public function sheds(): HasMany
    {
        return $this->hasMany(Shed::class);
    }
}
