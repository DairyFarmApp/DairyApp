<?php

namespace App\Domain\AnimalRegistry\Actions;

use App\Domain\AnimalRegistry\Exceptions\StaleAnimalRegistryVersion;
use App\Domain\AnimalRegistry\Models\AnimalBreed;
use App\Support\AuditService;
use Illuminate\Database\QueryException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

final class UpdateAnimalBreed
{
    use CreatesAnimalRegistryRecords;

    public function __construct(private readonly AuditService $audit) {}

    public function execute(Request $request, AnimalBreed $breed, array $data): AnimalBreed
    {
        try {
            return DB::transaction(function () use ($request, $breed, $data): AnimalBreed {
                $locked = AnimalBreed::withTrashed()->lockForUpdate()->findOrFail($breed->id);
                $expectedVersion = (int) $data['version'];
                if ($locked->version !== $expectedVersion) {
                    throw new StaleAnimalRegistryVersion($locked->version);
                }
                unset($data['version']);
                $old = $locked->toArray();
                $locked->fill($data);
                $locked->updated_by = $request->user()->id;
                $locked->version++;
                $locked->save();
                $this->audit->record($request, 'animal_breed.updated', 'animal_breed', $locked->id, $old, $locked->toArray());

                return $locked->load('species');
            });
        } catch (QueryException $exception) {
            $this->translateUniqueViolation($exception, 'code');
        }
    }
}
