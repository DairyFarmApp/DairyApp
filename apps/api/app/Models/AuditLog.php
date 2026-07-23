<?php

namespace App\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;

class AuditLog extends Model
{
    use UsesUuidV7;

    public const UPDATED_AT = null;

    protected $guarded = [];

    protected function casts(): array
    {
        return ['old_values' => 'array', 'new_values' => 'array', 'created_at' => 'datetime'];
    }

    public function save(array $options = []): bool
    {
        if ($this->exists) {
            throw new \LogicException('Audit logs are append-only.');
        }

        return parent::save($options);
    }
}
