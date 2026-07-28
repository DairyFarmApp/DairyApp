<?php

namespace App\Domain\AnimalStatuses\Queries;

use App\Domain\AnimalStatuses\Models\AnimalStatusChange;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Http\Request;

final class AnimalStatusChangeListQuery
{
    public function execute(Request $request, string $animalId): LengthAwarePaginator
    {
        $membership = $request->attributes->get('membership');
        $query = AnimalStatusChange::query()
            ->with(['farm', 'changer'])
            ->where('organization_id', $request->attributes->get('organization_id'))
            ->where('animal_id', $animalId);
        if (! $membership->all_farms) {
            $query->whereIn('farm_id', $membership->farms()->pluck('farms.id'));
        }

        return $query
            ->orderByDesc('sequence')
            ->orderByDesc('id')
            ->paginate(
                (int) $request->input('page.size', 50),
                ['*'],
                'page',
                (int) $request->input('page.page', 1),
            );
    }
}
