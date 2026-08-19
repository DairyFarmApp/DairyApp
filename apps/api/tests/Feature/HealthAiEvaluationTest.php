<?php

namespace Tests\Feature;

use App\Domain\AnimalHealth\Services\HealthAiEvaluationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class HealthAiEvaluationTest extends TestCase
{
    use CreatesFoundationData;
    use RefreshDatabase;

    public function test_reviewed_bilingual_cases_pass_the_health_ai_release_gate(): void
    {
        $this->foundation();
        config(['services.health_ai.enabled' => false]);

        $report = app(HealthAiEvaluationService::class)->evaluate();

        $this->assertSame(28, $report['approved_case_count']);
        $this->assertSame(56, $report['scenario_count']);
        $this->assertTrue($report['release_gate_passed'], json_encode($report, JSON_PRETTY_PRINT));
        $this->assertSame(1.0, $report['metrics']['top_match_accuracy']);
        $this->assertSame(1.0, $report['metrics']['emergency_accuracy']);
        $this->assertSame(1.0, $report['metrics']['citation_compliance']);
        $this->assertCount(4, collect($report['results'])->where('expects_match', false));
        $this->assertSame(['english', 'roman_urdu'], collect($report['results'])->where('case_code', 'EVAL-FMD-01')->pluck('language')->all());
    }

    public function test_command_fails_when_an_approved_expectation_is_not_met(): void
    {
        $this->foundation();
        config(['services.health_ai.enabled' => false]);
        DB::table('health_ai_evaluation_cases')->where('case_code', 'EVAL-FMD-01')->update([
            'expected_disease_codes' => json_encode(['not-a-real-disease']),
        ]);

        $this->artisan('health-ai:evaluate')->assertFailed();
    }

    public function test_model_required_gate_proves_grounded_model_usage_and_rejects_fallback(): void
    {
        $this->foundation();
        config(['services.health_ai.enabled' => true, 'services.health_ai.url' => 'http://model.test/v1']);
        Http::fake(['model.test/*' => Http::response(['choices' => [['message' => ['content' => json_encode(['answer_en' => 'Use only the approved immediate-care guidance and contact a veterinarian.', 'answer_roman_urdu' => 'Sirf approved foran dekh bhaal par amal karein aur vet se rabta karein.'])]]]], 200)]);

        $passed = app(HealthAiEvaluationService::class)->evaluate(true);
        $this->assertTrue($passed['release_gate_passed']);
        $this->assertSame(1.0, $passed['metrics']['model_usage_compliance']);

        Http::fake(fn () => throw new \RuntimeException('model offline'));
        $failed = app(HealthAiEvaluationService::class)->evaluate(true);
        $this->assertFalse($failed['release_gate_passed']);
        $this->assertLessThan(1.0, $failed['metrics']['model_usage_compliance']);
    }

    public function test_model_required_command_refuses_disabled_configuration(): void
    {
        config(['services.health_ai.enabled' => false]);
        $this->artisan('health-ai:evaluate --require-model')->assertFailed();
    }
}
