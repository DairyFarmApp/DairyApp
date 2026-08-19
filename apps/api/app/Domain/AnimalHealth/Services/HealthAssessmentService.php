<?php

namespace App\Domain\AnimalHealth\Services;

use App\Domain\AnimalHealth\Models\HealthDisease;
use Illuminate\Support\Collection;

class HealthAssessmentService
{
    public function rank(string $speciesCode, array $symptomIds): Collection
    {
        $selected = collect($symptomIds)->unique();

        return HealthDisease::query()->where('is_active', true)->where('review_status', 'approved')->with('symptoms')->get()
            ->filter(fn (HealthDisease $disease) => in_array(strtolower($speciesCode), $disease->species, true))
            ->map(function (HealthDisease $disease) use ($selected): array {
                $matched = $disease->symptoms->filter(fn ($s) => $selected->contains($s->id));
                $total = max(1, $disease->symptoms->sum(fn ($s) => (int) $s->pivot->weight));
                $earned = $matched->sum(fn ($s) => (int) $s->pivot->weight);
                $missingKeys = $disease->symptoms->filter(fn ($s) => $s->pivot->is_key && ! $selected->contains($s->id));
                $score = round(($earned / $total) * 100, 2);

                return ['disease' => $disease, 'score' => $score, 'matched' => $matched->pluck('name')->values()->all(), 'missing_key' => $missingKeys->pluck('name')->values()->all()];
            })->filter(fn ($result) => $result['score'] > 0)
            ->sortByDesc(fn (array $result): float => ($result['score'] * 100) + count($result['matched']))
            ->take(5)->values();
    }
}
