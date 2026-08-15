<?php

namespace App\Domain\AnimalHealth\Services;

use App\Domain\AnimalHealth\Models\HealthDisease;
use Illuminate\Support\Facades\DB;

class HealthAiDatasetService
{
    public function export(): array
    {
        $diseases = HealthDisease::with('symptoms')->where('is_active', true)->where('review_status', 'approved')->orderBy('code')->get();

        return ['schema_version' => '1.0', 'generated_at' => now()->toIso8601String(), 'safety_policy' => ['purpose' => 'Decision support and retrieval; not autonomous diagnosis or prescribing.', 'medicine_rule' => 'Only veterinarian-approved medicine evidence may be exported.', 'emergency_rule' => 'Emergency signs must always trigger immediate veterinary escalation.'], 'diseases' => $diseases->map(fn ($d) => ['code' => $d->code, 'name' => ['en' => $d->name, 'roman_urdu' => $d->name_roman_urdu], 'species' => $d->species, 'urgency' => $d->urgency, 'summary' => ['en' => $d->summary, 'roman_urdu' => $d->summary_roman_urdu], 'immediate_care' => ['en' => $d->immediate_care, 'roman_urdu' => $d->immediate_care_roman_urdu], 'safe_home_care' => ['en' => $d->safe_home_care, 'roman_urdu' => $d->safe_home_care_roman_urdu], 'do_not_do' => ['en' => $d->do_not_do, 'roman_urdu' => $d->do_not_do_roman_urdu], 'feed_water_guidance' => ['en' => $d->feed_water_guidance, 'roman_urdu' => $d->feed_water_guidance_roman_urdu], 'confirmation_guidance' => ['en' => $d->confirmation_guidance, 'roman_urdu' => $d->confirmation_guidance_roman_urdu], 'symptoms' => $d->symptoms->map(fn ($s) => ['code' => $s->code, 'name' => ['en' => $s->name, 'roman_urdu' => $s->name_roman_urdu], 'weight' => $s->pivot->weight, 'is_key' => (bool) $s->pivot->is_key, 'is_emergency' => $s->is_emergency])->values(), 'sources' => DB::table('health_knowledge_sources')->where('disease_id', $d->id)->get(['title', 'url', 'publisher', 'source_type', 'accessed_on', 'evidence_scope', 'is_primary']), 'medicine_evidence' => DB::table('health_disease_medicine_evidence')->where('disease_id', $d->id)->where('review_status', 'approved')->get(['active_ingredient', 'indication', 'contraindications', 'withdrawal_guidance'])])->values(), 'evaluation_cases' => DB::table('health_ai_evaluation_cases')->where('review_status', 'approved')->orderBy('case_code')->get(['case_code', 'species', 'question_en', 'question_roman_urdu', 'symptom_codes', 'expected_disease_codes', 'expected_emergency', 'expects_match'])];
    }
}
