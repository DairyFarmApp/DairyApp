<?php

namespace App\Domain\AnimalMovements\Queries;

use App\Domain\AnimalMovements\Models\AnimalMovement;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;

final class AnimalMovementListQuery
{
    public function __construct(private readonly AnimalMovementScope $scope) {}

    public function execute(Request $request, string $animalId): LengthAwarePaginator
    {
        $organizationId = $request->attributes->get('organization_id');
        $membership = $request->attributes->get('membership');
        $filters = (array) $request->input('filter', []);
        $query = AnimalMovement::query()
            ->with($this->scope->relations())
            ->where('organization_id', $organizationId)
            ->where('animal_id', $animalId);
        if (! $membership->all_farms) {
            $farmIds = $membership->farms()->pluck('farms.id');
            $query->whereIn('source_farm_id', $farmIds)
                ->whereIn('destination_farm_id', $farmIds);
        }
        $query
            ->when(
                $filters['status'] ?? null,
                fn (Builder $builder, string $status) => $builder->where('status', $status),
            )
            ->when(
                trim((string) ($filters['search'] ?? '')),
                function (Builder $builder, string $search): void {
                    $escaped = addcslashes(trim($search), '%_\\');
                    $builder->where(function (Builder $nested) use ($escaped): void {
                        $nested->where('reason', 'like', "%{$escaped}%")
                            ->orWhere('notes', 'like', "%{$escaped}%")
                            ->orWhere('rejection_reason', 'like', "%{$escaped}%")
                            ->orWhere('cancellation_reason', 'like', "%{$escaped}%");
                    });
                },
            );

        $sort = (string) $request->input('sort', '-requested_effective_at');
        $direction = str_starts_with($sort, '-') ? 'desc' : 'asc';
        $column = ltrim($sort, '-');
        $query->orderBy($column, $direction)->orderBy('id', 'desc');

        return $query->paginate((int) $request->input('page.size', 50));
    }
}
