<?php

namespace Tests\Feature;

use App\Domain\AnimalHealth\Models\HealthDisease;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class HealthMedicineEvidenceTest extends TestCase
{
    use CreatesFoundationData,RefreshDatabase;

    public function test_drap_evidence_requires_separate_veterinary_approval_before_dataset_export(): void
    {
        $this->foundation(['health.medicine_evidence.manage', 'health.medicine_evidence.review', 'health.ai.export', 'health.view']);
        $h = $this->bearer($this->loginToken());
        $d = HealthDisease::where('code', 'mastitis')->firstOrFail();
        $source = DB::table('health_knowledge_sources')->where('disease_id', $d->id)->value('id');
        $payload = ['disease_id' => $d->id, 'active_ingredient' => 'Veterinarian-selected active ingredient', 'brand_name' => 'Registry-verified veterinary product', 'manufacturer' => 'Verified manufacturer', 'dosage_form' => 'Veterinary formulation', 'drap_registration_number' => 'DRAP-VET-000001', 'drap_registry_url' => 'https://eapp.dra.gov.pk/WebProductIndex.php', 'drap_verified_on' => '2026-08-12', 'indication' => 'Evidence record for veterinarian assessment of mastitis only.', 'species_scope' => 'Cattle and buffalo as verified on product evidence.', 'contraindications' => 'Use only after veterinarian assessment and product-label verification.', 'withdrawal_guidance' => 'Veterinarian must copy current milk and meat withdrawal from the verified product label.', 'source_id' => $source];
        $created = $this->postJson('/api/v1/health/medicine-evidence', $payload, $h)->assertCreated()->assertJsonPath('data.review_status', 'pending_review')->assertJsonPath('data.drap_registration_number', 'DRAP-VET-000001');
        $id = $created->json('data.id');
        $before = $this->get('/api/v1/health/ai/dataset.json', $h)->assertOk()->json();
        $this->assertSame([], collect($before['diseases'])->firstWhere('code', 'mastitis')['medicine_evidence']);
        $this->postJson("/api/v1/health/medicine-evidence/$id/review", ['decision' => 'approved', 'reviewer_notes' => 'DRAP record, label evidence and species scope reviewed.', 'reviewer_name' => 'Dr Veterinary Reviewer', 'reviewer_registration' => 'PVMC-11223'], $h)->assertOk()->assertJsonPath('data.review_status', 'approved')->assertJsonPath('data.review_version', 2);
        $after = $this->get('/api/v1/health/ai/dataset.json', $h)->assertOk()->json();
        $this->assertSame('Veterinarian-selected active ingredient', collect($after['diseases'])->firstWhere('code', 'mastitis')['medicine_evidence'][0]['active_ingredient']);
        config(['services.health_ai.enabled' => false]);
        $this->postJson('/api/v1/health/ai/ask', [
            'question' => 'My cow has a swollen udder and clots in milk.',
            'species' => 'cattle',
            'symptom_codes' => ['udder_swelling', 'abnormal_milk'],
            'language' => 'both',
        ], $h)
            ->assertOk()
            ->assertJsonPath('data.matches.0.code', 'mastitis')
            ->assertJsonPath('data.matches.0.medicines.0.active_ingredient', 'Veterinarian-selected active ingredient')
            ->assertJsonPath('data.matches.0.medicines.0.brand_name', 'Registry-verified veterinary product')
            ->assertJsonPath('data.matches.0.medicines.0.drap_registration_number', 'DRAP-VET-000001');
        $this->assertDatabaseHas('health_medicine_evidence_reviews', ['medicine_evidence_id' => $id, 'reviewer_registration' => 'PVMC-11223']);
        $this->assertDatabaseHas('audit_logs', ['action' => 'health_medicine_evidence.reviewed', 'entity_id' => $id]);
    }

    public function test_medicine_evidence_rejects_non_drap_registry_url_and_wrong_disease_source(): void
    {
        $this->foundation(['health.medicine_evidence.manage']);
        $h = $this->bearer($this->loginToken());
        $mastitis = HealthDisease::where('code', 'mastitis')->firstOrFail();
        $fmd = HealthDisease::where('code', 'fmd')->firstOrFail();
        $source = DB::table('health_knowledge_sources')->where('disease_id', $fmd->id)->value('id');
        $base = ['disease_id' => $mastitis->id, 'active_ingredient' => 'Ingredient', 'brand_name' => 'Brand', 'manufacturer' => 'Maker', 'dosage_form' => 'Form', 'drap_registration_number' => 'REG-1', 'drap_registry_url' => 'https://example.com/product', 'drap_verified_on' => '2026-08-12', 'indication' => 'Evidence indication', 'species_scope' => 'Cattle', 'contraindications' => 'Veterinary review required', 'withdrawal_guidance' => 'Use verified label', 'source_id' => $source];
        $this->postJson('/api/v1/health/medicine-evidence', $base, $h)->assertUnprocessable()->assertJsonPath('error.code', 'VALIDATION_FAILED');
        $base['drap_registry_url'] = 'https://www.dra.gov.pk/therapeutic-goods/drugs/veterinary-drugs/';
        $this->postJson('/api/v1/health/medicine-evidence', $base, $h)->assertStatus(422)->assertJsonPath('error.code','SOURCE_DISEASE_MISMATCH');
    }
}
