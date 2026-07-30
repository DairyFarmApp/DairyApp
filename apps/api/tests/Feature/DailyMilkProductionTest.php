<?php

namespace Tests\Feature;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\AnimalRegistry\Models\AnimalBreed;
use App\Domain\AnimalRegistry\Models\AnimalSpecies;
use App\Domain\MilkProduction\Models\MilkEntry;
use App\Models\OrganizationMembership;
use App\Models\Permission;
use App\Models\Shed;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class DailyMilkProductionTest extends TestCase
{
    use RefreshDatabase;

    public function test_daily_milk_requires_authentication_and_returns_real_empty_totals(): void
    {
        $this->getJson('/api/v1/milk/daily?date=2026-07-30')->assertUnauthorized();
        $context = $this->context('milk-view@example.test');

        $this->getJson('/api/v1/milk/daily?date=2026-07-30', $context['headers'])
            ->assertOk()
            ->assertJsonPath('data.summary.total_litres', '0.000')
            ->assertJsonPath('data.summary.sellable_litres', '0.000')
            ->assertJsonPath('data.summary.entry_count', 0)
            ->assertJsonCount(1, 'data.eligible_animals');
    }

    public function test_bulk_entry_is_balanced_by_real_rows_idempotent_and_duplicate_safe(): void
    {
        $context = $this->context('milk-create@example.test');
        $payload = $this->bulkPayload($context['animal']->id);
        $headers = [...$context['headers'], 'Idempotency-Key' => 'daily-milk-batch-1'];

        $first = $this->postJson('/api/v1/milk/entries/bulk', $payload, $headers)
            ->assertCreated()
            ->assertJsonPath('data.0.quantity_litres', '12.500')
            ->assertJsonPath('data.0.rejected_quantity_litres', '0.500')
            ->assertJsonPath('data.0.sellable_quantity_litres', '12.000');
        $this->postJson('/api/v1/milk/entries/bulk', $payload, $headers)
            ->assertStatus($first->status())
            ->assertExactJson($first->json());
        $this->assertDatabaseCount('milk_production_slots', 1);
        $this->assertDatabaseCount('milk_entries', 1);

        $duplicate = $this->bulkPayload($context['animal']->id);
        $this->postJson(
            '/api/v1/milk/entries/bulk',
            $duplicate,
            [...$context['headers'], 'Idempotency-Key' => 'daily-milk-batch-2'],
        )->assertConflict()->assertJsonPath('error.code', 'DUPLICATE_MILK_ENTRY');

        $this->getJson(
            '/api/v1/milk/daily?date=2026-07-30&session=morning',
            $context['headers'],
        )->assertOk()
            ->assertJsonPath('data.summary.total_litres', '12.500')
            ->assertJsonPath('data.summary.rejected_litres', '0.500')
            ->assertJsonPath('data.summary.sellable_litres', '12.000')
            ->assertJsonPath('data.summary.animals_recorded', 1);
        $this->assertDatabaseHas('audit_logs', ['action' => 'milk.entries_recorded']);
    }

    public function test_male_inactive_and_cross_farm_animals_are_not_eligible(): void
    {
        $context = $this->context('milk-scope@example.test');
        $male = $this->animal($context, number: 'MILK-MALE', sex: 'male');
        $inactive = $this->animal(
            $context,
            number: 'MILK-INACTIVE',
            status: 'inactive',
        );
        $other = $this->context('milk-other@example.test');

        foreach ([$male, $inactive, $other['animal']] as $index => $animal) {
            $this->postJson(
                '/api/v1/milk/entries/bulk',
                $this->bulkPayload($animal->id),
                [...$context['headers'], 'Idempotency-Key' => "ineligible-$index"],
            )->assertUnprocessable()
                ->assertJsonPath('error.code', 'MILK_ANIMAL_NOT_ELIGIBLE');
        }
        $this->assertDatabaseCount('milk_entries', 0);
    }

    public function test_rejected_quantity_validation_is_enforced_on_the_server(): void
    {
        $context = $this->context('milk-validation@example.test');
        $payload = $this->bulkPayload($context['animal']->id);
        $payload['entries'][0]['rejected_quantity_litres'] = '13.000';
        $payload['entries'][0]['rejection_reason'] = null;

        $this->postJson(
            '/api/v1/milk/entries/bulk',
            $payload,
            [...$context['headers'], 'Idempotency-Key' => 'invalid-rejected'],
        )->assertUnprocessable()
            ->assertJsonStructure(['error' => ['fields' => [
                'entries.0.rejected_quantity_litres',
                'entries.0.rejection_reason',
            ]]]);
        $this->assertDatabaseCount('milk_entries', 0);
    }

    public function test_correction_appends_a_revision_and_preserves_original_values(): void
    {
        $context = $this->context('milk-correct@example.test');
        $entry = $this->postJson(
            '/api/v1/milk/entries/bulk',
            $this->bulkPayload($context['animal']->id),
            [...$context['headers'], 'Idempotency-Key' => 'correct-original'],
        )->assertCreated()->json('data.0');

        $replacementId = (string) Str::uuid7();
        $this->postJson(
            "/api/v1/milk/entries/{$entry['id']}/correct",
            [
                'id' => $replacementId,
                'quantity_litres' => '11.750',
                'rejected_quantity_litres' => '0.250',
                'rejection_reason' => 'Spillage during transfer',
                'notes' => 'Checked against the paper log.',
                'correction_reason' => 'Original reading was entered incorrectly.',
            ],
            [...$context['headers'], 'Idempotency-Key' => 'correct-revision-1'],
        )->assertCreated()
            ->assertJsonPath('data.id', $replacementId)
            ->assertJsonPath('data.revision', 2)
            ->assertJsonPath('data.supersedes_entry_id', $entry['id']);

        $this->assertDatabaseHas('milk_entries', [
            'id' => $entry['id'],
            'quantity_litres' => '12.500',
            'is_current' => false,
            'superseded_by_entry_id' => $replacementId,
        ]);
        $this->assertDatabaseHas('milk_entries', [
            'id' => $replacementId,
            'quantity_litres' => '11.750',
            'is_current' => true,
        ]);
        $this->assertDatabaseCount('milk_entries', 2);
        $this->assertDatabaseHas('audit_logs', ['action' => 'milk.entry_corrected']);
    }

    public function test_permissions_separate_view_create_and_correction(): void
    {
        $context = $this->context('milk-permission@example.test');
        $entry = $this->postJson(
            '/api/v1/milk/entries/bulk',
            $this->bulkPayload($context['animal']->id),
            [...$context['headers'], 'Idempotency-Key' => 'permission-original'],
        )->assertCreated()->json('data.0');
        $membership = OrganizationMembership::query()
            ->where('user_id', $context['user_id'])
            ->firstOrFail();
        $role = $membership->roles()->firstOrFail();
        $role->permissions()->detach(
            Permission::query()
                ->whereIn('name', ['milk.create', 'milk.correct'])
                ->pluck('id'),
        );

        $this->getJson('/api/v1/milk/daily?date=2026-07-30', $context['headers'])
            ->assertOk();
        $this->postJson(
            '/api/v1/milk/entries/bulk',
            $this->bulkPayload($context['animal']->id),
            [...$context['headers'], 'Idempotency-Key' => 'permission-create'],
        )->assertForbidden();
        $this->postJson(
            "/api/v1/milk/entries/{$entry['id']}/correct",
            [
                'id' => (string) Str::uuid7(),
                'quantity_litres' => '10.000',
                'correction_reason' => 'Correction permission should be required.',
            ],
            [...$context['headers'], 'Idempotency-Key' => 'permission-correct'],
        )->assertForbidden();
        $this->assertSame(1, MilkEntry::query()->count());
    }

    public function test_sync_returns_only_authorized_current_milk_entries(): void
    {
        $context = $this->context('milk-sync@example.test');
        $entryId = $this->postJson(
            '/api/v1/milk/entries/bulk',
            $this->bulkPayload($context['animal']->id),
            [...$context['headers'], 'Idempotency-Key' => 'sync-entry'],
        )->assertCreated()->json('data.0.id');

        $this->getJson('/api/v1/sync/bootstrap', $context['headers'])
            ->assertOk()
            ->assertJsonPath('data.milk_entries_authorized', true)
            ->assertJsonPath('data.milk_entries.0.id', $entryId);
    }

    private function context(string $email): array
    {
        $owner = $this->postJson('/api/v1/auth/owner-signup', [
            'name' => 'Milk Owner',
            'farm_name' => 'Milk Farm '.Str::upper(Str::random(5)),
            'email' => $email,
            'password' => 'OwnerPass2026',
            'password_confirmation' => 'OwnerPass2026',
            'timezone' => 'Asia/Karachi',
        ])->assertCreated();
        $organizationId = $owner->json('data.active_organization_id');
        $farmId = $owner->json('data.active_farm_id');
        $userId = $owner->json('data.user.id');
        $shed = Shed::query()->create([
            'organization_id' => $organizationId,
            'farm_id' => $farmId,
            'name' => 'Milking Shed',
            'code' => 'MILK',
        ]);
        $species = AnimalSpecies::query()->firstOrCreate(
            ['code' => 'CATTLE'],
            ['name' => 'Cattle', 'is_active' => true],
        );
        $breed = AnimalBreed::query()->create([
            'organization_id' => $organizationId,
            'species_id' => $species->id,
            'code' => 'DAIRY',
            'name' => 'Dairy Breed',
            'normalized_name' => 'dairy breed',
            'is_active' => true,
            'created_by' => $userId,
            'updated_by' => $userId,
        ]);
        $context = [
            'organization_id' => $organizationId,
            'farm_id' => $farmId,
            'user_id' => $userId,
            'shed' => $shed,
            'species' => $species,
            'breed' => $breed,
            'headers' => ['Authorization' => 'Bearer '.$owner->json('data.access_token')],
        ];
        $context['animal'] = $this->animal($context);

        return $context;
    }

    private function animal(
        array $context,
        string $number = 'MILK-001',
        string $sex = 'female',
        string $status = 'active',
    ): Animal {
        return Animal::query()->create([
            'organization_id' => $context['organization_id'],
            'animal_number' => $number,
            'name' => $number,
            'species_id' => $context['species']->id,
            'breed_id' => $context['breed']->id,
            'sex' => $sex,
            'life_stage' => 'adult',
            'current_farm_id' => $context['farm_id'],
            'current_shed_id' => $context['shed']->id,
            'origin' => 'born_on_farm',
            'operational_status' => $status,
            'created_by' => $context['user_id'],
            'updated_by' => $context['user_id'],
        ]);
    }

    private function bulkPayload(string $animalId): array
    {
        return [
            'production_date' => '2026-07-30',
            'session' => 'morning',
            'entries' => [[
                'id' => (string) Str::uuid7(),
                'slot_id' => (string) Str::uuid7(),
                'animal_id' => $animalId,
                'quantity_litres' => '12.500',
                'rejected_quantity_litres' => '0.500',
                'rejection_reason' => 'Quality sample rejected',
                'notes' => 'Morning quick entry.',
                'entry_source' => 'manual',
            ]],
        ];
    }
}
