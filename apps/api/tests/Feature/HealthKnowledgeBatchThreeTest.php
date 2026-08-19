<?php

namespace Tests\Feature;

use App\Domain\AnimalHealth\Models\HealthDisease;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class HealthKnowledgeBatchThreeTest extends TestCase
{
    use CreatesFoundationData, RefreshDatabase;

    public function test_batch_three_adds_nine_sourced_conditions_and_treatment_approaches(): void
    {
        $codes = ['ppr','ccpp','enterotoxemia','surra','fasciolosis','johnes','ruminal_acidosis','wooden_tongue','postparturient_hemoglobinuria'];

        $this->assertSame(50, HealthDisease::query()->count());
        $this->assertSame(9, HealthDisease::query()->whereIn('code', $codes)->where('review_status', 'approved')->count());
        $this->assertSame(9, DB::table('health_knowledge_sources')->whereIn('disease_id', HealthDisease::whereIn('code', $codes)->pluck('id'))->count());
        foreach (HealthDisease::whereIn('code', $codes)->get() as $disease) {
            $this->assertNotEmpty($disease->confirmation_guidance);
            $this->assertNotEmpty($disease->confirmation_guidance_roman_urdu);
            $this->assertGreaterThanOrEqual(4, $disease->symptoms()->count());
        }
    }

    public function test_distinctive_batch_three_signs_rank_the_expected_condition(): void
    {
        $this->foundation(['health.view']);
        $headers = $this->bearer($this->loginToken());
        config(['services.health_ai.enabled' => false]);
        $cases = [
            [['fever','oral_erosions','profuse_diarrhea'], 'goat', 'ppr'],
            [['breathing_difficulty','chest_pain','cough'], 'goat', 'ccpp'],
            [['recent_grain_change','abdominal_pain','convulsions'], 'goat', 'enterotoxemia'],
            [['chronic_diarrhea','normal_appetite_weight_loss'], 'cattle', 'johnes'],
            [['recent_grain_change','loose_sour_stool','dehydration'], 'cattle', 'ruminal_acidosis'],
            [['swollen_hard_tongue','swallowing_difficulty'], 'cattle', 'wooden_tongue'],
            [['recent_calving','post_calving_red_urine','weakness'], 'buffalo', 'postparturient_hemoglobinuria'],
        ];
        foreach ($cases as [$symptoms, $species, $expected]) {
            $this->postJson('/api/v1/health/ai/ask', [
                'question' => 'Structured veterinary evaluation case',
                'species' => $species,
                'symptom_codes' => $symptoms,
                'language' => 'both',
            ], $headers)->assertOk()->assertJsonPath('data.matches.0.code', $expected);
        }
    }
}
