<?php

namespace App\Domain\AnimalRegistry\Models;

use App\Domain\AnimalMovements\Models\AnimalMovement;
use App\Models\Concerns\UsesUuidV7;
use App\Models\Farm;
use App\Models\Organization;
use App\Models\Shed;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Animal extends Model
{
    use SoftDeletes, UsesUuidV7;

    protected $fillable = [
        'id',
        'organization_id',
        'animal_number',
        'ear_tag_number',
        'rfid_number',
        'name',
        'registration_number',
        'species_id',
        'breed_id',
        'sex',
        'life_stage',
        'date_of_birth',
        'is_date_of_birth_estimated',
        'colour',
        'identifying_marks',
        'current_farm_id',
        'current_shed_id',
        'current_animal_group_id',
        'mother_animal_id',
        'father_animal_id',
        'external_sire_reference',
        'origin',
        'acquisition_date',
        'source_description',
        'notes',
        'operational_status',
        'version',
        'created_by',
        'updated_by',
        'archived_by',
        'archived_at',
    ];

    protected function casts(): array
    {
        return [
            'date_of_birth' => 'date',
            'acquisition_date' => 'date',
            'is_date_of_birth_estimated' => 'boolean',
            'version' => 'integer',
            'archived_at' => 'datetime',
        ];
    }

    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }

    public function species(): BelongsTo
    {
        return $this->belongsTo(AnimalSpecies::class, 'species_id');
    }

    public function breed(): BelongsTo
    {
        return $this->belongsTo(AnimalBreed::class, 'breed_id');
    }

    public function currentFarm(): BelongsTo
    {
        return $this->belongsTo(Farm::class, 'current_farm_id');
    }

    public function currentShed(): BelongsTo
    {
        return $this->belongsTo(Shed::class, 'current_shed_id');
    }

    public function currentGroup(): BelongsTo
    {
        return $this->belongsTo(AnimalGroup::class, 'current_animal_group_id');
    }

    public function mother(): BelongsTo
    {
        return $this->belongsTo(self::class, 'mother_animal_id')->withTrashed();
    }

    public function father(): BelongsTo
    {
        return $this->belongsTo(self::class, 'father_animal_id')->withTrashed();
    }

    public function offspringAsMother(): HasMany
    {
        return $this->hasMany(self::class, 'mother_animal_id');
    }

    public function offspringAsFather(): HasMany
    {
        return $this->hasMany(self::class, 'father_animal_id');
    }

    public function movements(): HasMany
    {
        return $this->hasMany(AnimalMovement::class);
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
