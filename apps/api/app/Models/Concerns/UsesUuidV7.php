<?php

namespace App\Models\Concerns;

use Illuminate\Database\Eloquent\Concerns\HasUuids;

trait UsesUuidV7
{
    use HasUuids;

    public $incrementing = false;

    protected $keyType = 'string';
}
