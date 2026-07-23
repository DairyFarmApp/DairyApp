<?php

namespace App\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Shed extends Model
{
    use SoftDeletes, UsesUuidV7;

    protected $fillable = ['id', 'organization_id', 'farm_id', 'name', 'code', 'version'];

    public function farm(): BelongsTo
    {
        return $this->belongsTo(Farm::class);
    }
}
