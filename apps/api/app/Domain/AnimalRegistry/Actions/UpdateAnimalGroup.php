<?php

namespace App\Domain\AnimalRegistry\Actions;

use App\Domain\AnimalRegistry\Exceptions\StaleAnimalRegistryVersion;
use App\Domain\AnimalRegistry\Models\AnimalGroup;
use App\Domain\AnimalRegistry\Support\AnimalRegistryValidator;
use App\Support\AuditService;
use Illuminate\Database\QueryException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

final class UpdateAnimalGroup
{
    use CreatesAnimalRegistryRecords;

    public function __construct(
        private readonly AnimalRegistryValidator $validator,
        private readonly AuditService $audit,
    ) {}

    public function execute(Request $request, AnimalGroup $group, array $data): AnimalGroup
    {
        if (array_key_exists('default_shed_id', $data)) {
            $this->validator->groupLocation(
                $group->organization_id,
                $request->attributes->get('membership'),
                $group->farm_id,
                $data['default_shed_id'],
            );
        }

        try {
            return DB::transaction(function () use ($request, $group, $data): AnimalGroup {
                $locked = AnimalGroup::withTrashed()->lockForUpdate()->findOrFail($group->id);
                if ($locked->version !== (int) $data['version']) {
                    throw new StaleAnimalRegistryVersion($locked->version);
                }
                unset($data['version']);
                $old = $locked->toArray();
                $locked->fill($data);
                $locked->updated_by = $request->user()->id;
                $locked->version++;
                $locked->save();
                $this->audit->record($request, 'animal_group.updated', 'animal_group', $locked->id, $old, $locked->toArray());

                return $locked->load(['farm', 'defaultShed']);
            });
        } catch (QueryException $exception) {
            $this->translateUniqueViolation($exception, 'code');
        }
    }
}
