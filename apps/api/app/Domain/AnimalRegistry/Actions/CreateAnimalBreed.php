<?php

namespace App\Domain\AnimalRegistry\Actions;

use App\Domain\AnimalRegistry\Models\AnimalBreed;
use App\Support\AuditService;
use Illuminate\Database\QueryException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

final class CreateAnimalBreed
{
    use CreatesAnimalRegistryRecords;

    public function __construct(private readonly AuditService $audit) {}

    public function execute(Request $request, array $data): AnimalBreed
    {
        $duplicate = AnimalBreed::withTrashed()
            ->where('organization_id', $request->attributes->get('organization_id'))
            ->where('species_id', $data['species_id'])
            ->where(fn ($query) => $query->where('code', $data['code'])->orWhere('normalized_name', $data['normalized_name']))
            ->exists();
        if ($duplicate) {
            throw ValidationException::withMessages(['code' => ['A breed with this code or name already exists for the species.']]);
        }

        try {
            return DB::transaction(function () use ($request, $data): AnimalBreed {
                $breed = AnimalBreed::create([
                    ...$data,
                    'id' => $data['id'] ?? (string) Str::uuid7(),
                    'organization_id' => $request->attributes->get('organization_id'),
                    'version' => 1,
                    'created_by' => $request->user()->id,
                    'updated_by' => $request->user()->id,
                ]);
                $this->audit->record($request, 'animal_breed.created', 'animal_breed', $breed->id, null, $breed->toArray());

                return $breed->load('species');
            });
        } catch (QueryException $exception) {
            $this->translateUniqueViolation($exception, 'code');
        }
    }
}
