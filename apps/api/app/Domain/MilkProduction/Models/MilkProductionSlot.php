<?php

namespace App\Domain\MilkProduction\Models;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Models\Concerns\UsesUuidV7;
use App\Models\Farm;
use App\Models\Organization;
use App\Models\Shed;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class MilkProductionSlot extends Model
{
    use UsesUuidV7;

    protected $fillable = [
        'id',
        'organization_id',
        'farm_id',
        'shed_id',
        'animal_id',
        'production_date',
        'session',
        'version',
        'created_by',
    ];

    protected function casts(): array
    {
        return [
            'production_date' => 'date:Y-m-d',
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

    public function shed(): BelongsTo
    {
        return $this->belongsTo(Shed::class);
    }

    public function animal(): BelongsTo
    {
        return $this->belongsTo(Animal::class);
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function entries(): HasMany
    {
        return $this->hasMany(MilkEntry::class);
    }

    public function currentEntry(): HasOne
    {
        return $this->hasOne(MilkEntry::class)->where('is_current', true);
    }
}
