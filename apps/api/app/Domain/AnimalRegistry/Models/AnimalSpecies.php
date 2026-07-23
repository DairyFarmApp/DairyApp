<?php

namespace App\Domain\AnimalRegistry\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class AnimalSpecies extends Model
{
    use UsesUuidV7;

    protected $table = 'animal_species';

    protected $fillable = ['id', 'code', 'name', 'is_active'];

    protected function casts(): array
    {
        return ['is_active' => 'boolean'];
    }

    public function breeds(): HasMany
    {
        return $this->hasMany(AnimalBreed::class, 'species_id');
    }
}
