<?php

namespace App\Domain\Finance\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;

class SystemAccount extends Model
{
    use UsesUuidV7;

    protected $fillable = ['organization_id', 'code', 'name', 'type', 'is_hidden'];

    protected function casts(): array
    {
        return ['is_hidden' => 'boolean'];
    }
}
