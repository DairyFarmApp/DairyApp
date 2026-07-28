<?php

namespace App\Domain\AnimalWeights\Queries;

use App\Domain\AnimalWeights\Models\AnimalWeight;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Http\Request;

final class AnimalWeightListQuery
{
    public function __construct(private readonly AnimalWeightScope $scope) {}

    public function execute(Request $request, string $animalId): LengthAwarePaginator
    {
        $membership = $request->attributes->get('membership');
        $query = AnimalWeight::query()
            ->with($this->scope->relations())
            ->where('organization_id', $request->attributes->get('organization_id'))
            ->where('animal_id', $animalId);
        if (! $membership->all_farms) {
            $query->whereIn('farm_id', $membership->farms()->pluck('farms.id'));
        }
        $sort = (string) $request->input('sort', '-observed_at');
        $direction = str_starts_with($sort, '-') ? 'desc' : 'asc';
        $query->orderBy(ltrim($sort, '-'), $direction)
            ->orderBy('created_at', $direction)
            ->orderBy('id', $direction);

        return $query->paginate(
            (int) $request->input('page.size', 50),
            ['*'],
            'page',
            (int) $request->input('page.page', 1),
        );
    }
}
