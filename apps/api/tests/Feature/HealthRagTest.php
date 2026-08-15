<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class HealthRagTest extends TestCase
{
    use CreatesFoundationData,RefreshDatabase;

    public function test_deterministic_rag_is_species_scoped_cited_and_emergency_safe(): void
    {
        $this->foundation(['health.view']);
        $h = $this->bearer($this->loginToken());
        config(['services.health_ai.enabled' => false]);
        $r = $this->postJson('/api/v1/health/ai/ask', ['question' => 'Mouth blisters and too much saliva, what should I do?', 'species' => 'cattle', 'symptom_codes' => ['mouth_blisters', 'excess_saliva'], 'language' => 'both'], $h)->assertOk()->assertJsonPath('data.mode', 'deterministic')->assertJsonPath('data.emergency', true)->assertJsonPath('data.matches.0.code', 'fmd')->assertJsonStructure(['data' => ['answer', 'answer_roman_urdu', 'safety_notice', 'matches' => [['source' => ['title', 'url', 'reviewed_on']]]]]);
        $this->assertDatabaseHas('audit_logs', ['action' => 'health_ai.question_answered']);
    }

    public function test_local_model_can_only_phrase_grounded_context_and_outage_falls_back(): void
    {
        $this->foundation(['health.view']);
        $h = $this->bearer($this->loginToken());
        config(['services.health_ai.enabled' => true, 'services.health_ai.url' => 'http://model.test/v1']);
        Http::fake(['model.test/*' => Http::response(['choices' => [['message' => ['content' => json_encode(['answer_en' => 'Approved guidance says isolate and contact a veterinarian.', 'answer_roman_urdu' => 'Janwar alag karein aur vet se rabta karein.'])]]]], 200)]);
        $this->postJson('/api/v1/health/ai/ask', ['question' => 'Udder is swollen and milk has clots', 'species' => 'buffalo', 'symptom_codes' => ['udder_swelling', 'abnormal_milk']], $h)->assertOk()->assertJsonPath('data.mode', 'local_model_grounded')->assertJsonPath('data.matches.0.code', 'mastitis');
        Http::fake(fn () => throw new \RuntimeException('offline'));
        $this->postJson('/api/v1/health/ai/ask', ['question' => 'Left side belly is swollen', 'species' => 'goat', 'symptom_codes' => ['left_bloat']], $h)->assertOk()->assertJsonPath('data.mode', 'deterministic')->assertJsonPath('data.matches.0.code', 'bloat');
    }

    public function test_unsafe_roman_urdu_or_oversized_model_output_is_rejected(): void
    {
        $this->foundation(['health.view']);
        $h = $this->bearer($this->loginToken());
        config(['services.health_ai.enabled' => true, 'services.health_ai.url' => 'http://model.test/v1']);
        foreach ([['Safe English', 'Dose: 5 ml injection dein.'], [str_repeat('A', 801), 'Mehfooz jawab']] as [$en,$ur]) {
            Http::fake(['model.test/*' => Http::response(['choices' => [['message' => ['content' => json_encode(['answer_en' => $en, 'answer_roman_urdu' => $ur])]]]], 200)]);
            $this->postJson('/api/v1/health/ai/ask', ['question' => 'Udder swollen with clots', 'species' => 'buffalo', 'symptom_codes' => ['udder_swelling', 'abnormal_milk']], $h)->assertOk()->assertJsonPath('data.mode', 'deterministic');
        }
    }

    public function test_model_failure_log_excludes_farmer_question(): void
    {
        $this->foundation(['health.view']);
        $h = $this->bearer($this->loginToken());
        config(['services.health_ai.enabled' => true, 'services.health_ai.url' => 'http://model.test/v1']);
        Http::fake(fn () => throw new \RuntimeException('offline'));
        Log::spy();
        $secret = 'PRIVATE FARMER OBSERVATION';
        $this->postJson('/api/v1/health/ai/ask', ['question' => $secret, 'species' => 'goat', 'symptom_codes' => ['left_bloat']], $h)->assertOk();
        Log::shouldHaveReceived('warning')->once()->withArgs(fn ($message, $context) => ! str_contains(json_encode([$message, $context]), $secret) && isset($context['model'],$context['exception']));
    }

    public function test_health_ai_questions_are_rate_limited_per_user(): void
    {
        $this->foundation(['health.view']);
        $h = $this->bearer($this->loginToken());
        config(['services.health_ai.enabled' => false]);
        $payload = ['question' => 'Mouth blisters and saliva', 'species' => 'cattle', 'symptom_codes' => ['mouth_blisters']];
        for ($i = 0; $i < 12; $i++) {
            $this->postJson('/api/v1/health/ai/ask', $payload, $h)->assertOk();
        }$this->postJson('/api/v1/health/ai/ask',$payload,$h)->assertStatus(429)->assertJsonPath('error.code','RATE_LIMITED');
    }
}
