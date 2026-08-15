<?php

namespace Tests\Feature;

use App\Models\Permission;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class HealthAiEvaluationGovernanceTest extends TestCase
{
    use CreatesFoundationData;
    use RefreshDatabase;

    public function test_authorized_veterinary_reviewer_can_list_and_sign_an_evaluation_case(): void
    {
        $this->foundation(['health.ai.review']);
        $headers = $this->bearer($this->loginToken());
        $case = DB::table('health_ai_evaluation_cases')->where('case_code', 'EVAL-FMD-01')->firstOrFail();

        $this->getJson('/api/v1/health/ai/evaluation-cases', $headers)
            ->assertOk()
            ->assertJsonCount(13, 'data')
            ->assertJsonPath('data.0.review_version', 1);

        $this->postJson("/api/v1/health/ai/evaluation-cases/{$case->id}/review", [
            'decision' => 'approved',
            'reviewer_notes' => 'Symptoms, urgency and expected disease match were clinically reviewed.',
            'reviewer_name' => 'Dr Ayesha Veterinary',
            'reviewer_registration' => 'PVMC-98765',
        ], $headers)
            ->assertOk()
            ->assertJsonPath('data.review_status', 'approved')
            ->assertJsonPath('data.reviewer_registration', 'PVMC-98765')
            ->assertJsonPath('data.review_version', 2);

        $this->assertDatabaseHas('health_ai_evaluation_reviews', [
            'evaluation_case_id' => $case->id,
            'decision' => 'approved',
            'reviewer_registration' => 'PVMC-98765',
        ]);
        $this->assertDatabaseHas('audit_logs', [
            'action' => 'health_ai.evaluation_case_reviewed',
            'entity_id' => $case->id,
        ]);
        $this->postJson("/api/v1/health/ai/evaluation-cases/{$case->id}/review", [
            'decision' => 'changes_requested',
            'reviewer_notes' => 'Roman Urdu wording requires a clearer clinical description.',
            'reviewer_name' => 'Dr Bilal Veterinary',
            'reviewer_registration' => 'PVMC-24680',
        ], $headers)->assertOk();
        $this->getJson("/api/v1/health/ai/evaluation-cases/{$case->id}/reviews", $headers)
            ->assertOk()->assertJsonCount(2, 'data')
            ->assertJsonPath('data.0.decision', 'changes_requested')
            ->assertJsonPath('data.0.reviewer_registration', 'PVMC-24680')
            ->assertJsonPath('data.1.decision', 'approved');
    }

    public function test_evaluation_review_requires_permission_and_complete_credentials(): void
    {
        $foundation = $this->foundation(['health.view']);
        $headers = $this->bearer($this->loginToken());
        $case = DB::table('health_ai_evaluation_cases')->firstOrFail();

        $this->getJson('/api/v1/health/ai/evaluation-cases', $headers)->assertForbidden();
        $this->postJson("/api/v1/health/ai/evaluation-cases/{$case->id}/review", [], $headers)->assertForbidden();
        $this->getJson("/api/v1/health/ai/evaluation-cases/{$case->id}/reviews", $headers)->assertForbidden();

        $permission = Permission::firstOrCreate(['name' => 'health.ai.review']);
        $foundation['role']->permissions()->attach($permission->id);
        $headers = $this->bearer($this->loginToken());
        $this->postJson("/api/v1/health/ai/evaluation-cases/{$case->id}/review", [
            'decision' => 'approved',
            'reviewer_notes' => 'short',
        ], $headers)
            ->assertUnprocessable()
            ->assertJsonPath('error.code', 'VALIDATION_FAILED')
            ->assertJsonStructure(['error' => ['fields' => [
                'reviewer_notes', 'reviewer_name', 'reviewer_registration',
            ]]]);
    }
}
