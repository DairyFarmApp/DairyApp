<?php

namespace App\Domain\AnimalRegistry\Queries;

use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;

final class AnimalListQuery
{
    public function __construct(private readonly AnimalRegistryScope $scope) {}

    public function execute(Request $request): LengthAwarePaginator
    {
        $query = $this->scope->animals(
            $request->attributes->get('organization_id'),
            $request->attributes->get('membership'),
        );
        $archiveState = (string) $request->input('filter.archive_state', 'active');
        if ($archiveState === 'archived') {
            $query->onlyTrashed();
        } elseif ($archiveState === 'all') {
            $query->withTrashed();
        }

        $search = trim((string) $request->input('filter.search', ''));
        if ($search !== '') {
            $like = '%'.addcslashes($search, '\\%_').'%';
            $query->where(function (Builder $inner) use ($like): void {
                $inner->where('animal_number', 'like', $like)
                    ->orWhere('ear_tag_number', 'like', $like)
                    ->orWhere('rfid_number', 'like', $like)
                    ->orWhere('name', 'like', $like);
            });
        }

        foreach ([
            'species_id' => 'species_id',
            'breed_id' => 'breed_id',
            'sex' => 'sex',
            'life_stage' => 'life_stage',
            'farm_id' => 'current_farm_id',
            'shed_id' => 'current_shed_id',
            'group_id' => 'current_animal_group_id',
            'operational_status' => 'operational_status',
        ] as $filter => $column) {
            $value = $request->input("filter.{$filter}");
            if (is_string($value) && $value !== '') {
                $query->where($column, $value);
            }
        }

        $sort = (string) $request->input('sort', 'animal_number');
        $direction = str_starts_with($sort, '-') ? 'desc' : 'asc';
        $sortKey = ltrim($sort, '-');
        $column = [
            'animal_number' => 'animal_number',
            'name' => 'name',
            'date_of_birth' => 'date_of_birth',
            'created_at' => 'created_at',
            'updated_at' => 'updated_at',
            'operational_status' => 'operational_status',
        ][$sortKey] ?? 'animal_number';
        $query->orderBy($column, $direction)->orderBy('id');

        return $query->paginate($this->pageSize($request))->withQueryString();
    }

    private function pageSize(Request $request): int
    {
        return max(1, min((int) $request->input('page.size', 25), 100));
    }
}
