<?php

namespace App\Domain\Feed\Models;

use App\Domain\AnimalRegistry\Models\AnimalGroup;
use App\Models\Concerns\UsesUuidV7;
use App\Models\Farm;
use App\Models\Organization;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class FeedRationPlan extends Model
{
    use SoftDeletes, UsesUuidV7;

    protected $fillable = [
        'organization_id',
        'farm_id',
        'name',
        'animal_group_id',
        'production_stage',
        'effective_date',
        'end_date',
        'feeding_frequency',
        'created_by',
        'approved_by',
        'version',
    ];

    protected function casts(): array
    {
        return [
            'effective_date' => 'date',
            'end_date' => 'date',
            'feeding_frequency' => 'integer',
            'version' => 'integer',
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

    public function animalGroup(): BelongsTo
    {
        return $this->belongsTo(AnimalGroup::class);
    }

    public function ingredients(): HasMany
    {
        return $this->hasMany(FeedRationIngredient::class);
    }

    public function createdBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function approvedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'approved_by');
    }
}
