<?php

namespace App\Domain\AnimalRegistry\Models;

use App\Models\Concerns\UsesUuidV7;
use App\Models\Organization;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AnimalPhoto extends Model
{
    use UsesUuidV7;

    protected $fillable = [
        'id', 'organization_id', 'animal_id', 'storage_path', 'original_name',
        'mime_type', 'size_bytes', 'sort_order', 'uploaded_by',
    ];

    protected function casts(): array
    {
        return ['size_bytes' => 'integer', 'sort_order' => 'integer'];
    }

    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }

    public function animal(): BelongsTo
    {
        return $this->belongsTo(Animal::class);
    }

    public function uploader(): BelongsTo
    {
        return $this->belongsTo(User::class, 'uploaded_by');
    }
}
