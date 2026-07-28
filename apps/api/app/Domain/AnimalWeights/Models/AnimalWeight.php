<?php

namespace App\Domain\AnimalWeights\Models;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Models\Concerns\UsesUuidV7;
use App\Models\Farm;
use App\Models\Organization;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AnimalWeight extends Model
{
    use UsesUuidV7;

    protected $fillable = [
        'id',
        'organization_id',
        'farm_id',
        'animal_id',
        'entered_value',
        'entered_unit',
        'normalized_kg',
        'observed_at',
        'source',
        'notes',
        'recorded_by',
        'supersedes_weight_id',
        'superseded_by_weight_id',
        'correction_reason',
        'is_superseded',
    ];

    protected function casts(): array
    {
        return [
            'entered_value' => 'decimal:6',
            'normalized_kg' => 'decimal:6',
            'observed_at' => 'datetime',
            'is_superseded' => 'boolean',
        ];
    }

    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }

    public function farm(): BelongsTo
    {
        return $this->belongsTo(Farm::class)->withTrashed();
    }

    public function animal(): BelongsTo
    {
        return $this->belongsTo(Animal::class)->withTrashed();
    }

    public function recorder(): BelongsTo
    {
        return $this->belongsTo(User::class, 'recorded_by');
    }

    public function supersedes(): BelongsTo
    {
        return $this->belongsTo(self::class, 'supersedes_weight_id');
    }

    public function supersededBy(): BelongsTo
    {
        return $this->belongsTo(self::class, 'superseded_by_weight_id');
    }
}
