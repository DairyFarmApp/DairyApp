<?php

namespace Tests\Feature;

use App\Domain\AnimalHealth\Models\HealthDisease;
use App\Domain\AnimalHealth\Services\HealthAssessmentService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class HealthAiDatasetTest extends TestCase
{
    use CreatesFoundationData,RefreshDatabase;

    public function test_export_contains_only_approved_model_ready_knowledge_and_locked_evaluations(): void
    {
        $this->foundation(['health.ai.export']);
        $h = $this->bearer($this->loginToken());
        $rejected = HealthDisease::where('code', 'foot_rot')->firstOrFail();
        $rejected->update(['review_status' => 'rejected']);
        $d = HealthDisease::where('code', 'mastitis')->firstOrFail();
        $source = DB::table('health_knowledge_sources')->where('disease_id', $d->id)->value('id');
        DB::table('health_disease_medicine_evidence')->insert(['id' => (string) Str::uuid7(), 'disease_id' => $d->id, 'active_ingredient' => 'Unreviewed ingredient', 'indication' => 'Test only', 'source_id' => $source, 'review_status' => 'pending_review', 'created_at' => now(), 'updated_at' => now()]);
        $r = $this->get('/api/v1/health/ai/dataset.json', $h)->assertOk()->assertHeader('content-type', 'application/json');
        $data = $r->json();
        $this->assertSame('1.0', $data['schema_version']);
        $this->assertNotContains('foot_rot', collect($data['diseases'])->pluck('code')->all());
        $this->assertCount(49, $data['diseases']);
        $this->assertSame([], collect($data['diseases'])->firstWhere('code', 'mastitis')['medicine_evidence']);
        $this->assertCount(28, $data['evaluation_cases']);
        $this->assertNotEmpty(collect($data['diseases'])->firstWhere('code', 'fmd')['do_not_do']['roman_urdu']);
        $this->assertDatabaseHas('audit_logs', ['action' => 'health_ai.dataset_exported']);
    }

    public function test_approved_evaluation_cases_match_deterministic_ranker(): void
    {
        $this->foundation();
        $ranker = app(HealthAssessmentService::class);
        foreach (DB::table('health_ai_evaluation_cases')->where('review_status', 'approved')->where('expects_match', true)->get() as $case) {
            $codes = json_decode($case->symptom_codes, true);
            $ids = DB::table('health_symptoms')->whereIn('code', $codes)->pluck('id')->all();
            $top = $ranker->rank($case->species, $ids)->first();
            $this->assertContains($top['disease']->code, json_decode($case->expected_disease_codes, true), $case->case_code);
        }
    }
}
