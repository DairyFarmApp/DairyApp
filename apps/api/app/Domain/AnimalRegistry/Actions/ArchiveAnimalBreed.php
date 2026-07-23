<?php

namespace App\Domain\AnimalRegistry\Actions;

use App\Domain\AnimalRegistry\Exceptions\StaleAnimalRegistryVersion;
use App\Domain\AnimalRegistry\Models\AnimalBreed;
use App\Support\AuditService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

final class ArchiveAnimalBreed
{
    public function __construct(private readonly AuditService $audit) {}

    public function execute(Request $request, AnimalBreed $breed, int $version): AnimalBreed
    {
        return DB::transaction(function () use ($request, $breed, $version): AnimalBreed {
            $locked = AnimalBreed::withTrashed()->lockForUpdate()->findOrFail($breed->id);
            if ($locked->version !== $version) {
                throw new StaleAnimalRegistryVersion($locked->version);
            }
            if ($locked->trashed()) {
                return $locked;
            }
            $old = $locked->toArray();
            $locked->forceFill([
                'archived_at' => now(),
                'archived_by' => $request->user()->id,
                'updated_by' => $request->user()->id,
                'version' => $locked->version + 1,
            ])->save();
            $locked->delete();
            $this->audit->record($request, 'animal_breed.archived', 'animal_breed', $locked->id, $old, $locked->toArray());

            return $locked;
        });
    }
}
