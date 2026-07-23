<?php

namespace App\Domain\AnimalRegistry\Actions;

use App\Domain\AnimalRegistry\Exceptions\StaleAnimalRegistryVersion;
use App\Domain\AnimalRegistry\Models\Animal;
use App\Support\AuditService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

final class RestoreAnimal
{
    public function __construct(private readonly AuditService $audit) {}

    public function execute(Request $request, Animal $animal, int $version): Animal
    {
        return DB::transaction(function () use ($request, $animal, $version): Animal {
            $locked = Animal::withTrashed()->lockForUpdate()->findOrFail($animal->id);
            if ($locked->version !== $version) {
                throw new StaleAnimalRegistryVersion($locked->version);
            }
            if (! $locked->trashed()) {
                return $locked;
            }
            $old = $locked->toArray();
            $locked->restore();
            $locked->forceFill([
                'archived_at' => null,
                'archived_by' => null,
                'updated_by' => $request->user()->id,
                'version' => $locked->version + 1,
            ])->save();
            $this->audit->record($request, 'animal.restored', 'animal', $locked->id, $old, $locked->toArray());

            return $locked;
        });
    }
}
