<?php

namespace App\Domain\Visitors\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class VisitorRecord extends Model
{
    use SoftDeletes, UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'visitor_name', 'visited_at', 'purpose', 'created_by'];

    protected function casts(): array
    {
        return ['visited_at' => 'datetime'];
    }
}
