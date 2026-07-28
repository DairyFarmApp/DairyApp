<?php

namespace App\Domain\AnimalStatuses\Models;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Models\Concerns\UsesUuidV7;
use App\Models\Farm;
use App\Models\Organization;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AnimalStatusChange extends Model
{
    use UsesUuidV7;

    protected $table = 'animal_status_histories';

    protected $fillable = [
        'id',
        'organization_id',
        'farm_id',
        'animal_id',
        'previous_status',
        'new_status',
        'effective_at',
        'reason',
        'changed_by',
        'sequence',
    ];

    protected function casts(): array
    {
        return [
            'effective_at' => 'datetime',
            'sequence' => 'integer',
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

    public function changer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'changed_by');
    }
}
