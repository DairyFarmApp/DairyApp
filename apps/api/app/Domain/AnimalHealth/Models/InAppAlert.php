<?php

namespace App\Domain\AnimalHealth\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;

class InAppAlert extends Model
{
    use UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'source_key', 'type', 'severity', 'title', 'description', 'title_roman_urdu', 'description_roman_urdu', 'related_type', 'related_id', 'due_at', 'status', 'assigned_user_id', 'read_at', 'resolved_at', 'resolved_by'];

    protected function casts(): array
    {
        return ['due_at' => 'datetime', 'read_at' => 'datetime', 'resolved_at' => 'datetime'];
    }
}
