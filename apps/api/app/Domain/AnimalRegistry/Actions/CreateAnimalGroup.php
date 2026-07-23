<?php

namespace App\Domain\AnimalRegistry\Actions;

use App\Domain\AnimalRegistry\Models\AnimalGroup;
use App\Domain\AnimalRegistry\Support\AnimalRegistryValidator;
use App\Support\AuditService;
use Illuminate\Database\QueryException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

final class CreateAnimalGroup
{
    use CreatesAnimalRegistryRecords;

    public function __construct(
        private readonly AnimalRegistryValidator $validator,
        private readonly AuditService $audit,
    ) {}

    public function execute(Request $request, array $data): AnimalGroup
    {
        $this->validator->groupLocation(
            $request->attributes->get('organization_id'),
            $request->attributes->get('membership'),
            $data['farm_id'],
            $data['default_shed_id'] ?? null,
        );
        $duplicate = AnimalGroup::withTrashed()
            ->where('organization_id', $request->attributes->get('organization_id'))
            ->where('farm_id', $data['farm_id'])
            ->where(fn ($query) => $query->where('code', $data['code'])->orWhere('normalized_name', $data['normalized_name']))
            ->exists();
        if ($duplicate) {
            throw ValidationException::withMessages(['code' => ['An animal group with this code or name already exists for the farm.']]);
        }

        try {
            return DB::transaction(function () use ($request, $data): AnimalGroup {
                $group = AnimalGroup::create([
                    ...$data,
                    'id' => $data['id'] ?? (string) Str::uuid7(),
                    'organization_id' => $request->attributes->get('organization_id'),
                    'version' => 1,
                    'created_by' => $request->user()->id,
                    'updated_by' => $request->user()->id,
                ]);
                $this->audit->record($request, 'animal_group.created', 'animal_group', $group->id, null, $group->toArray());

                return $group->load(['farm', 'defaultShed']);
            });
        } catch (QueryException $exception) {
            $this->translateUniqueViolation($exception, 'code');
        }
    }
}
