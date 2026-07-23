<?php

namespace App\Domain\AnimalRegistry\Models;

use App\Models\Concerns\UsesUuidV7;
use App\Models\Farm;
use App\Models\Organization;
use App\Models\Shed;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class AnimalGroup extends Model
{
    use SoftDeletes, UsesUuidV7;

    protected $fillable = [
        'id',
        'organization_id',
        'farm_id',
        'default_shed_id',
        'code',
        'name',
        'normalized_name',
        'description',
        'is_active',
        'version',
        'created_by',
        'updated_by',
        'archived_by',
        'archived_at',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'version' => 'integer',
            'archived_at' => 'datetime',
        ];
    }

    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }

    public function farm(): BelongsTo
    {
        return $this->belongsTo(Farm::class);
    }

    public function defaultShed(): BelongsTo
    {
        return $this->belongsTo(Shed::class, 'default_shed_id');
    }

    public function animals(): HasMany
    {
        return $this->hasMany(Animal::class, 'current_animal_group_id');
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
