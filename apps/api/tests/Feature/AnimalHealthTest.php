<?php

namespace Tests\Feature;

use App\Domain\AnimalHealth\Models\HealthDisease;
use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\Inventory\Models\InventoryBatch;
use App\Domain\Inventory\Models\InventoryItem;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class AnimalHealthTest extends TestCase
{
    use CreatesFoundationData, RefreshDatabase;

    public function test_guided_assessment_saves_ranked_explainable_emergency_result(): void
    {
        $context = $this->context(['health.view', 'health.assess']);
        $symptoms = collect($this->getJson('/api/v1/health/symptoms', $context['headers'])->assertOk()->json('data'));
        $selected = $symptoms->whereIn('code', ['fever', 'mouth_blisters', 'excess_saliva', 'foot_lesions'])->pluck('id')->all();

        $response = $this->postJson("/api/v1/animals/{$context['animal']->id}/health-assessments", [
            'severity' => 'severe',
            'temperature_c' => '40.50',
            'symptom_ids' => $selected,
            'notes' => 'Several animals may be affected.',
        ], [...$context['headers'], 'Idempotency-Key' => (string) Str::uuid()])
            ->assertCreated()
            ->assertJsonPath('data.case_number', 'HC-000001')
            ->assertJsonPath('data.emergency', true)
            ->assertJsonPath('data.differentials.0.disease.code', 'fmd')
            ->assertJsonPath('data.differentials.0.disease.urgency', 'emergency')
            ->assertJsonStructure(['data' => ['differentials' => [['score', 'matched_symptoms', 'missing_key_symptoms', 'disease' => ['source_url']]]]]);

        $this->getJson("/api/v1/animals/{$context['animal']->id}/health-cases", $context['headers'])
            ->assertOk()->assertJsonPath('data.0.id', $response->json('data.id'));
        $this->assertDatabaseHas('audit_logs', ['action' => 'animal_health.assessed', 'entity_id' => $response->json('data.id')]);
    }

    public function test_assessment_requires_permission_and_conceals_foreign_animals(): void
    {
        $first = $this->context(['health.view']);
        $symptom = $this->getJson('/api/v1/health/symptoms', $first['headers'])->assertOk()->json('data.0.id');
        $this->postJson("/api/v1/animals/{$first['animal']->id}/health-assessments", [
            'severity' => 'mild', 'symptom_ids' => [$symptom],
        ], $first['headers'])->assertForbidden();

        $first['foundation']['user']->forceFill(['email' => 'health-first@example.test'])->save();
        $second = $this->context(['health.view', 'health.assess'], 'health-second@example.test');
        $this->getJson("/api/v1/animals/{$first['animal']->id}/health-cases", $second['headers'])->assertNotFound();
    }

    public function test_vet_treatment_consumes_non_expired_medicine_and_restricts_milk(): void
    {
        $context = $this->context(['health.view', 'health.assess', 'health.treat', 'milk.view', 'milk.create']);
        $symptom = $this->getJson('/api/v1/health/symptoms', $context['headers'])->json('data.0.id');
        $case = $this->postJson("/api/v1/animals/{$context['animal']->id}/health-assessments", [
            'severity' => 'moderate', 'symptom_ids' => [$symptom],
        ], [...$context['headers'], 'Idempotency-Key' => (string) Str::uuid()])->assertCreated();
        $item = InventoryItem::query()->create([
            'organization_id' => $context['foundation']['organization']->id,
            'farm_id' => $context['foundation']['farm']->id,
            'kind' => 'medicine', 'item_code' => 'MED-HEALTH', 'name' => 'Vet Product',
            'generic_name' => 'Veterinarian verified ingredient', 'concentration' => '100 mg/ml',
            'category' => 'Injection', 'unit' => 'ml', 'minimum_stock' => 1,
            'milk_withdrawal_hours' => 72, 'meat_withdrawal_days' => 7,
            'is_active' => true, 'created_by' => $context['foundation']['user']->id,
            'updated_by' => $context['foundation']['user']->id,
        ]);
        InventoryBatch::query()->create([
            'organization_id' => $item->organization_id, 'farm_id' => $item->farm_id,
            'inventory_item_id' => $item->id, 'batch_number' => 'ACTIVE-1',
            'expiry_date' => today()->addYear(), 'unit_cost' => 100, 'current_quantity' => 20,
        ]);

        $treatment = $this->postJson("/api/v1/animals/{$context['animal']->id}/treatments", [
            'health_case_id' => $case->json('data.id'), 'inventory_item_id' => $item->id,
            'administered_at' => now()->toIso8601String(), 'animal_weight_kg' => '450.000',
            'dose' => '10.000', 'dose_unit' => 'ml', 'route' => 'intramuscular',
            'frequency' => 'Once, as directed by veterinarian', 'duration_days' => 1,
            'inventory_quantity_used' => '10.000', 'veterinarian_name' => 'Dr Veterinary Reviewer',
            'veterinarian_instructions' => 'Use exact verified product label and monitor response.',
        ], [...$context['headers'], 'Idempotency-Key' => (string) Str::uuid()])
            ->assertCreated()->assertJsonPath('data.treatment_number', 'TR-000001')
            ->assertJsonCount(2, 'data.withdrawals');
        $this->assertDatabaseHas('inventory_batches', ['inventory_item_id' => $item->id, 'current_quantity' => '10.000']);
        $this->assertDatabaseHas('stock_movements', ['inventory_item_id' => $item->id, 'quantity_change' => '-10.000']);
        $this->assertDatabaseHas('animal_health_cases', ['id' => $case->json('data.id'), 'status' => 'monitoring']);

        $this->postJson('/api/v1/milk/entries/bulk', [
            'production_date' => today()->toDateString(), 'session' => 'morning',
            'entries' => [[
                'id' => (string) Str::uuid7(), 'slot_id' => (string) Str::uuid7(),
                'animal_id' => $context['animal']->id, 'quantity_litres' => '12.000',
            ]],
        ], [...$context['headers'], 'Idempotency-Key' => (string) Str::uuid()])
            ->assertCreated()->assertJsonPath('data.0.rejected_quantity_litres', '12.000')
            ->assertJsonPath('data.0.sellable_quantity_litres', '0.000');
        $this->assertDatabaseHas('audit_logs', ['action' => 'animal_treatment.recorded', 'entity_id' => $treatment->json('data.id')]);
    }

    public function test_treatment_rejects_expired_stock(): void
    {
        $context = $this->context(['health.view', 'health.assess', 'health.treat']);
        $symptom = $this->getJson('/api/v1/health/symptoms', $context['headers'])->json('data.0.id');
        $case = $this->postJson("/api/v1/animals/{$context['animal']->id}/health-assessments", [
            'severity' => 'mild', 'symptom_ids' => [$symptom],
        ], [...$context['headers'], 'Idempotency-Key' => (string) Str::uuid()])->assertCreated();
        $item = InventoryItem::query()->create([
            'organization_id' => $context['foundation']['organization']->id, 'farm_id' => $context['foundation']['farm']->id,
            'kind' => 'medicine', 'item_code' => 'EXPIRED', 'name' => 'Expired medicine',
            'generic_name' => 'Verified ingredient', 'concentration' => '10 mg/ml', 'category' => 'Injection',
            'unit' => 'ml', 'minimum_stock' => 0, 'is_active' => true,
            'created_by' => $context['foundation']['user']->id, 'updated_by' => $context['foundation']['user']->id,
        ]);
        InventoryBatch::query()->create([
            'organization_id' => $item->organization_id, 'farm_id' => $item->farm_id,
            'inventory_item_id' => $item->id, 'batch_number' => 'OLD-1', 'expiry_date' => today()->subDay(),
            'unit_cost' => 10, 'current_quantity' => 50,
        ]);
        $payload = [
            'health_case_id' => $case->json('data.id'), 'inventory_item_id' => $item->id,
            'administered_at' => now()->toIso8601String(), 'animal_weight_kg' => 300, 'dose' => 5,
            'dose_unit' => 'ml', 'route' => 'oral', 'frequency' => 'once', 'duration_days' => 1,
            'inventory_quantity_used' => 5, 'veterinarian_name' => 'Dr Vet',
            'veterinarian_instructions' => 'Use only as directed.',
        ];
        $this->postJson("/api/v1/animals/{$context['animal']->id}/treatments", $payload, [...$context['headers'], 'Idempotency-Key' => (string) Str::uuid()])
            ->assertUnprocessable()->assertJsonPath('error.code', 'INSUFFICIENT_OR_EXPIRED_MEDICINE');
        $this->assertDatabaseHas('inventory_batches', ['id' => $item->batches()->first()->id, 'current_quantity' => '50.000']);
    }

    public function test_health_knowledge_is_bilingual_reviewed_and_only_approved_content_is_ranked(): void
    {
        $context = $this->context(['health.view', 'health.assess', 'health.knowledge.review']);
        $disease = HealthDisease::query()->where('code', 'fmd')->firstOrFail();
        $this->getJson('/api/v1/health/knowledge?species=cattle', $context['headers'])
            ->assertOk()->assertJsonPath('data.0.review_status', 'approved')
            ->assertJsonStructure(['data' => [['source_url', 'knowledge_version', 'symptoms' => [['name_roman_urdu']]]]]);
        $this->postJson("/api/v1/health/knowledge/{$disease->id}/review", [
            'decision' => 'rejected', 'reviewer_notes' => 'Source requires a new veterinary review.',
            'reviewer_name' => 'Dr Qualified Reviewer', 'reviewer_registration' => 'PVMC-12345',
        ], $context['headers'])->assertOk()->assertJsonPath('data.review_status', 'rejected')->assertJsonPath('data.knowledge_version', 2);
        $selected = collect($this->getJson('/api/v1/health/symptoms', $context['headers'])->json('data'))->whereIn('code', ['mouth_blisters', 'excess_saliva', 'foot_lesions'])->pluck('id')->all();
        $assessment = $this->postJson("/api/v1/animals/{$context['animal']->id}/health-assessments", [
            'severity' => 'moderate', 'symptom_ids' => $selected,
        ], [...$context['headers'], 'Idempotency-Key' => (string) Str::uuid()])->assertCreated();
        $this->assertNotContains('fmd', collect($assessment->json('data.differentials'))->pluck('disease.code')->all());
        $this->assertDatabaseHas('health_knowledge_reviews', ['disease_id' => $disease->id, 'reviewer_registration' => 'PVMC-12345', 'decision' => 'rejected']);
        $this->assertDatabaseHas('audit_logs', ['action' => 'health_knowledge.reviewed', 'entity_id' => $disease->id]);
    }

    public function test_vaccination_deducts_traceable_stock_and_creates_due_history(): void
    {
        $context = $this->context(['health.preventive.view', 'health.preventive.manage']);
        $item = InventoryItem::query()->create(['organization_id' => $context['foundation']['organization']->id, 'farm_id' => $context['foundation']['farm']->id, 'kind' => 'medicine', 'item_code' => 'VAC-1', 'name' => 'Verified vaccine', 'category' => 'Vaccine', 'unit' => 'dose', 'minimum_stock' => 0, 'is_active' => true, 'created_by' => $context['foundation']['user']->id, 'updated_by' => $context['foundation']['user']->id]);
        $batch = InventoryBatch::query()->create(['organization_id' => $item->organization_id, 'farm_id' => $item->farm_id, 'inventory_item_id' => $item->id, 'batch_number' => 'VAC-B1', 'expiry_date' => today()->addYear(), 'unit_cost' => 250, 'current_quantity' => 10]);
        $this->postJson('/api/v1/health/preventive-care', ['animal_ids' => [$context['animal']->id], 'inventory_item_id' => $item->id, 'type' => 'vaccination', 'disease_covered' => 'FMD', 'dose' => 1, 'dose_unit' => 'dose', 'inventory_quantity_used_per_animal' => 1, 'administered_at' => now()->toIso8601String(), 'next_due_date' => today()->addDays(20)->toDateString(), 'veterinarian_name' => 'Dr Vet', 'administered_by_name' => 'Farm manager', 'cost_pkr_per_animal' => 250], [...$context['headers'], 'Idempotency-Key' => (string) Str::uuid()])->assertCreated()->assertJsonPath('data.0.due_status', 'upcoming');
        $this->assertDatabaseHas('inventory_batches', ['id' => $batch->id, 'current_quantity' => '9.000']);
        $this->assertDatabaseHas('stock_movements', ['inventory_batch_id' => $batch->id, 'quantity_change' => '-1.000']);
        $this->getJson("/api/v1/animals/{$context['animal']->id}/preventive-care", $context['headers'])->assertOk()->assertJsonPath('data.0.disease_covered', 'FMD');
        $this->getJson('/api/v1/health/preventive-care/due', $context['headers'])->assertOk()->assertJsonPath('data.0.due_status', 'upcoming');
        $this->assertDatabaseHas('audit_logs', ['action' => 'animal_preventive_care.recorded']);
    }

    public function test_breeding_lifecycle_consumes_semen_and_creates_numbered_calf(): void
    {
        $context = $this->context(['breeding.view', 'breeding.manage']);
        $item = InventoryItem::query()->create(['organization_id' => $context['foundation']['organization']->id, 'farm_id' => $context['foundation']['farm']->id, 'kind' => 'semen', 'item_code' => 'SEM-1', 'name' => 'Bull semen', 'category' => 'Frozen semen', 'unit' => 'straw', 'minimum_stock' => 0, 'is_active' => true, 'created_by' => $context['foundation']['user']->id, 'updated_by' => $context['foundation']['user']->id]);
        $batch = InventoryBatch::query()->create(['organization_id' => $item->organization_id, 'farm_id' => $item->farm_id, 'inventory_item_id' => $item->id, 'batch_number' => 'SEM-B1', 'expiry_date' => today()->addYear(), 'unit_cost' => 500, 'current_quantity' => 3]);
        $headers = [...$context['headers'], 'Idempotency-Key' => (string) Str::uuid()];
        $service = $this->postJson("/api/v1/animals/{$context['animal']->id}/breeding/service", ['bred_at' => now()->subDays(60)->toIso8601String(), 'method' => 'artificial', 'semen_item_id' => $item->id, 'semen_straw_number' => 'STRAW-1', 'technician_name' => 'AI technician', 'cost_pkr' => 1000], $headers)->assertCreated()->assertJsonPath('data.service_number', 'BS-000001');
        $this->assertDatabaseHas('inventory_batches', ['id' => $batch->id, 'current_quantity' => '2.000']);
        $pregnancy = $this->postJson("/api/v1/animals/{$context['animal']->id}/breeding/pregnancy-check", ['breeding_service_id' => $service->json('data.id'), 'checked_on' => today()->toDateString(), 'method' => 'ultrasound', 'veterinarian_name' => 'Dr Vet', 'result' => 'pregnant', 'estimated_age_days' => 60], [...$context['headers'], 'Idempotency-Key' => (string) Str::uuid()])->assertCreated();
        $before = Animal::query()->count();
        $this->postJson("/api/v1/animals/{$context['animal']->id}/breeding/calving", ['pregnancy_check_id' => $pregnancy->json('data.id'), 'calved_at' => now()->toIso8601String(), 'calving_type' => 'normal', 'placenta_status' => 'normal', 'mother_condition' => 'stable', 'treatment_required' => false, 'calves' => [['sex' => 'female', 'breed_id' => $context['animal']->breed_id, 'birth_weight_kg' => 30, 'condition' => 'active']]], [...$context['headers'], 'Idempotency-Key' => (string) Str::uuid()])->assertCreated()->assertJsonCount(1, 'data.calf_animal_ids');
        $this->assertSame($before + 1, Animal::query()->count());
        $this->assertDatabaseHas('animals', ['mother_animal_id' => $context['animal']->id, 'life_stage' => 'calf', 'origin' => 'born_on_farm']);
    }

    public function test_calf_care_calculates_colostrum_weaning_and_growth_status(): void
    {
        $context = $this->context(['calves.view', 'calves.manage', 'animals.record_weight', 'animals.view_weight_history']);
        $calf = Animal::query()->create(['organization_id' => $context['animal']->organization_id, 'animal_number' => 'CALF-TEST', 'species_id' => $context['animal']->species_id, 'breed_id' => $context['animal']->breed_id, 'sex' => 'female', 'life_stage' => 'calf', 'date_of_birth' => today()->subDays(30), 'current_farm_id' => $context['animal']->current_farm_id, 'current_shed_id' => $context['animal']->current_shed_id, 'mother_animal_id' => $context['animal']->id, 'origin' => 'born_on_farm', 'operational_status' => 'active', 'created_by' => $context['foundation']['user']->id, 'updated_by' => $context['foundation']['user']->id]);
        $birth = now()->subDays(30);
        $this->postJson("/api/v1/animals/{$calf->id}/calf-care", ['birth_at' => $birth->toIso8601String(), 'birth_weight_kg' => 30, 'birth_condition' => 'active', 'colostrum_given' => true, 'colostrum_at' => $birth->copy()->addHours(2)->toIso8601String(), 'colostrum_quantity_litres' => 3, 'colostrum_quality' => 'good', 'navel_treated' => true, 'navel_treated_at' => $birth->copy()->addHour()->toIso8601String(), 'navel_product' => 'iodine', 'weaning_target_date' => today()->addDays(10)->toDateString(), 'feed_plan' => 'Calf starter', 'target_daily_gain_kg' => 0.8, 'health_status' => 'normal'], [...$context['headers'], 'Idempotency-Key' => (string) Str::uuid()])->assertCreated()->assertJsonPath('data.colostrum_compliant', true)->assertJsonPath('data.weaning_status', 'upcoming')->assertJsonPath('data.growth_status', 'insufficient_data');
        $this->getJson('/api/v1/calves/due', $context['headers'])->assertOk()->assertJsonPath('data.0.animal_number', 'CALF-TEST');
        $this->assertDatabaseHas('audit_logs', ['action' => 'calf_care.created']);
    }

    public function test_alert_sync_deduplicates_and_tracks_read_and_resolution(): void
    {
        $context = $this->context(['alerts.view', 'alerts.manage', 'calves.view', 'calves.manage']);
        $calf = Animal::query()->create(['organization_id' => $context['animal']->organization_id, 'animal_number' => 'ALERT-CALF', 'species_id' => $context['animal']->species_id, 'breed_id' => $context['animal']->breed_id, 'sex' => 'female', 'life_stage' => 'calf', 'date_of_birth' => today()->subDays(40), 'current_farm_id' => $context['animal']->current_farm_id, 'current_shed_id' => $context['animal']->current_shed_id, 'origin' => 'born_on_farm', 'operational_status' => 'active', 'created_by' => $context['foundation']['user']->id, 'updated_by' => $context['foundation']['user']->id]);
        $birth = now()->subDays(40);
        $this->postJson("/api/v1/animals/{$calf->id}/calf-care", ['birth_at' => $birth->toIso8601String(), 'birth_weight_kg' => 30, 'birth_condition' => 'active', 'colostrum_given' => false, 'navel_treated' => false, 'weaning_target_date' => today()->subDay()->toDateString(), 'target_daily_gain_kg' => 0.7, 'health_status' => 'normal'], [...$context['headers'], 'Idempotency-Key' => (string) Str::uuid()])->assertCreated();
        $first = $this->getJson('/api/v1/alerts', $context['headers'])->assertOk()->assertJsonPath('data.0.type', 'weaning_due');
        $this->getJson('/api/v1/alerts', $context['headers'])->assertOk()->assertJsonCount(1, 'data');
        $id = $first->json('data.0.id');
        $this->patchJson("/api/v1/alerts/$id", ['action' => 'read'], $context['headers'])->assertOk();
        $this->assertDatabaseHas('in_app_alerts', ['id' => $id, 'source_key' => 'weaning_due:'.$first->json('data.0.related_id'), 'status' => 'active']);
        $this->patchJson("/api/v1/alerts/$id", ['action' => 'resolve'], $context['headers'])->assertOk()->assertJsonPath('data.status', 'resolved');
        $this->assertDatabaseHas('audit_logs', ['action' => 'alert.resolve', 'entity_id' => $id]);
    }

    private function context(array $permissions, string $email = 'owner@example.test'): array
    {
        $foundation = $this->foundation([...$permissions, 'animals.view']);
        if ($email !== 'owner@example.test') {
            $foundation['user']->forceFill(['email' => $email])->save();
        }
        $references = $this->animalRegistryReferences($foundation);
        $animal = Animal::query()->create([
            'organization_id' => $foundation['organization']->id,
            'animal_number' => 'HEALTH-001',
            'species_id' => $references['species']->id,
            'breed_id' => $references['breed']->id,
            'sex' => 'female',
            'life_stage' => 'adult',
            'current_farm_id' => $foundation['farm']->id,
            'current_shed_id' => $foundation['shed']->id,
            'origin' => 'born_on_farm',
            'operational_status' => 'active',
            'created_by' => $foundation['user']->id,
            'updated_by' => $foundation['user']->id,
        ]);
        $headers = $this->bearer($this->loginToken($email));

        return compact('foundation', 'animal', 'headers');
    }
}
