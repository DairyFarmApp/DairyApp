<?php

namespace App\Domain\AnimalRegistry\Queries;

use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;

final class AnimalReferenceListQuery
{
    public function __construct(private readonly AnimalRegistryScope $scope) {}

    public function breeds(Request $request): LengthAwarePaginator
    {
        $query = $this->scope->breeds($request->attributes->get('organization_id'));
        $this->archiveScope($query, (string) $request->input('filter.archive_state', 'active'));
        foreach (['species_id' => 'species_id', 'is_active' => 'is_active'] as $filter => $column) {
            $value = $request->input("filter.{$filter}");
            if ($value !== null && $value !== '') {
                $query->where($column, filter_var($value, FILTER_VALIDATE_BOOL, FILTER_NULL_ON_FAILURE) ?? $value);
            }
        }
        $this->search($query, (string) $request->input('filter.search', ''));

        return $query->orderBy('name')->orderBy('id')->paginate($this->pageSize($request))->withQueryString();
    }

    public function groups(Request $request): LengthAwarePaginator
    {
        $query = $this->scope->groups(
            $request->attributes->get('organization_id'),
            $request->attributes->get('membership'),
        );
        $this->archiveScope($query, (string) $request->input('filter.archive_state', 'active'));
        foreach (['farm_id' => 'farm_id', 'is_active' => 'is_active'] as $filter => $column) {
            $value = $request->input("filter.{$filter}");
            if ($value !== null && $value !== '') {
                $query->where($column, filter_var($value, FILTER_VALIDATE_BOOL, FILTER_NULL_ON_FAILURE) ?? $value);
            }
        }
        $this->search($query, (string) $request->input('filter.search', ''));

        return $query->orderBy('name')->orderBy('id')->paginate($this->pageSize($request))->withQueryString();
    }

    private function archiveScope(Builder $query, string $state): void
    {
        if ($state === 'archived') {
            $query->onlyTrashed();
        } elseif ($state === 'all') {
            $query->withTrashed();
        }
    }

    private function search(Builder $query, string $search): void
    {
        $search = trim($search);
        if ($search === '') {
            return;
        }
        $like = '%'.addcslashes($search, '\\%_').'%';
        $query->where(fn (Builder $inner) => $inner->where('code', 'like', $like)->orWhere('name', 'like', $like));
    }

    private function pageSize(Request $request): int
    {
        return max(1, min((int) $request->input('page.size', 50), 100));
    }
}
