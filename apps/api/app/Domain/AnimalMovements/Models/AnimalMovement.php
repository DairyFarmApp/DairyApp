<?php

namespace App\Domain\AnimalMovements\Models;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\AnimalRegistry\Models\AnimalGroup;
use App\Models\Concerns\UsesUuidV7;
use App\Models\Farm;
use App\Models\Organization;
use App\Models\Shed;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AnimalMovement extends Model
{
    use UsesUuidV7;

    protected $fillable = [
        'id',
        'organization_id',
        'animal_id',
        'source_farm_id',
        'source_shed_id',
        'source_animal_group_id',
        'destination_farm_id',
        'destination_shed_id',
        'destination_animal_group_id',
        'requested_effective_at',
        'actual_effective_at',
        'reason',
        'notes',
        'status',
        'approval_required',
        'requested_by',
        'decided_by',
        'decision_at',
        'rejection_reason',
        'cancellation_reason',
        'version',
    ];

    protected function casts(): array
    {
        return [
            'requested_effective_at' => 'datetime',
            'actual_effective_at' => 'datetime',
            'decision_at' => 'datetime',
            'approval_required' => 'boolean',
            'version' => 'integer',
        ];
    }

    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }

    public function animal(): BelongsTo
    {
        return $this->belongsTo(Animal::class)->withTrashed();
    }

    public function sourceFarm(): BelongsTo
    {
        return $this->belongsTo(Farm::class, 'source_farm_id')->withTrashed();
    }

    public function sourceShed(): BelongsTo
    {
        return $this->belongsTo(Shed::class, 'source_shed_id')->withTrashed();
    }

    public function sourceGroup(): BelongsTo
    {
        return $this->belongsTo(AnimalGroup::class, 'source_animal_group_id')->withTrashed();
    }

    public function destinationFarm(): BelongsTo
    {
        return $this->belongsTo(Farm::class, 'destination_farm_id')->withTrashed();
    }

    public function destinationShed(): BelongsTo
    {
        return $this->belongsTo(Shed::class, 'destination_shed_id')->withTrashed();
    }

    public function destinationGroup(): BelongsTo
    {
        return $this->belongsTo(AnimalGroup::class, 'destination_animal_group_id')->withTrashed();
    }

    public function requester(): BelongsTo
    {
        return $this->belongsTo(User::class, 'requested_by');
    }

    public function decisionMaker(): BelongsTo
    {
        return $this->belongsTo(User::class, 'decided_by');
    }
}
