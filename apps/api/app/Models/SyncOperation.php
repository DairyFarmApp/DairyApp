<?php

namespace App\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;

class SyncOperation extends Model
{
    use UsesUuidV7;

    protected $guarded = [];

    protected function casts(): array
    {
        return ['error' => 'array'];
    }
}
