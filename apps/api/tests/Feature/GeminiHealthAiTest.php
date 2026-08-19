<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class GeminiHealthAiTest extends TestCase
{
    use CreatesFoundationData, RefreshDatabase;

    public function test_gemini_only_rephrases_retrieved_approved_context(): void
    {
        $this->foundation(['health.view']);
        $headers = $this->bearer($this->loginToken());
        config([
            'services.health_ai.enabled' => true,
            'services.health_ai.provider' => 'gemini',
            'services.health_ai.url' => 'https://generativelanguage.test/v1beta',
            'services.health_ai.model' => 'gemini-test',
            'services.health_ai.api_key' => 'server-secret',
        ]);
        Http::fake([
            'generativelanguage.test/*' => Http::response([
                'candidates' => [['content' => ['parts' => [['text' => json_encode([
                    'answer_en' => 'The reviewed guidance says to separate the animal and arrange veterinary assessment.',
                ])]]]]],
            ]),
        ]);

        $this->postJson('/api/v1/health/ai/ask', [
            'question' => 'Udder is swollen and milk has clots',
            'species' => 'buffalo',
            'symptom_codes' => ['udder_swelling', 'abnormal_milk'],
            'language' => 'both',
        ], $headers)
            ->assertOk()
            ->assertJsonPath('data.mode', 'gemini_grounded')
            ->assertJsonPath('data.matches.0.code', 'mastitis');

        Http::assertSent(function ($request): bool {
            $prompt = $request->data()['contents'][0]['parts'][0]['text'] ?? '';

            return $request->url() === 'https://generativelanguage.test/v1beta/models/gemini-test:generateContent'
                && $request->hasHeader('x-goog-api-key', 'server-secret')
                && ($request->data()['generationConfig']['responseMimeType'] ?? null) === 'application/json'
                && str_contains($prompt, 'PRIMARY_CONTEXT:')
                && str_contains($prompt, '"code":"mastitis"')
                && ! str_contains($prompt, '"code":"foot_rot"');
        });
    }

    public function test_missing_gemini_key_uses_deterministic_fallback_without_an_http_call(): void
    {
        $this->foundation(['health.view']);
        $headers = $this->bearer($this->loginToken());
        config([
            'services.health_ai.enabled' => true,
            'services.health_ai.provider' => 'gemini',
            'services.health_ai.api_key' => null,
        ]);
        Http::fake();

        $this->postJson('/api/v1/health/ai/ask', [
            'question' => 'Left belly is swollen and breathing is difficult',
            'species' => 'goat',
            'symptom_codes' => ['left_bloat', 'breathing_difficulty'],
            'language' => 'both',
        ], $headers)
            ->assertOk()
            ->assertJsonPath('data.mode', 'deterministic')
            ->assertJsonPath('data.matches.0.code', 'bloat');

        Http::assertNothingSent();
    }
}
