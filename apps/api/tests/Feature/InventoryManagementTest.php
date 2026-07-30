<?php

namespace Tests\Feature;

use App\Domain\Inventory\Models\InventoryBatch;
use App\Domain\Inventory\Models\InventoryItem;
use App\Domain\Inventory\Models\StockMovement;
use App\Models\OrganizationMembership;
use App\Models\Permission;
use Illuminate\Foundation\Testing\RefreshDatabase;
use OpenSpout\Reader\XLSX\Reader;
use Tests\TestCase;

class InventoryManagementTest extends TestCase
{
    use RefreshDatabase;

    public function test_owner_can_create_each_inventory_kind_with_opening_stock_ledger(): void
    {
        $owner = $this->owner('inventory-owner@example.test', 'Inventory Farm');
        $headers = $this->bearer($owner->json('data.access_token'));
        $farmId = $owner->json('data.active_farm_id');

        foreach (['medicine', 'semen', 'feed'] as $kind) {
            $this->postJson(
                "/api/v1/inventory/$kind/items",
                $this->itemPayload($farmId, $kind),
                [...$headers, 'Idempotency-Key' => "create-$kind"],
            )->assertCreated()
                ->assertJsonPath('data.kind', $kind)
                ->assertJsonPath('data.current_stock', '10.000');
        }

        $this->assertDatabaseCount('inventory_items', 3);
        $this->assertDatabaseCount('inventory_batches', 3);
        $this->assertDatabaseCount('stock_movements', 3);
        $this->assertDatabaseHas('stock_movements', [
            'movement_type' => 'opening_stock',
            'quantity_change' => '10.000',
        ]);
        $this->getJson('/api/v1/inventory', $headers)->assertOk()
            ->assertJsonPath('data.medicine.item_count', 1)
            ->assertJsonPath('data.semen.item_count', 1)
            ->assertJsonPath('data.feed.item_count', 1);
    }

    public function test_receipt_is_idempotent_and_stock_changes_only_through_a_movement(): void
    {
        $owner = $this->owner('receipt-owner@example.test', 'Receipt Farm');
        $headers = $this->bearer($owner->json('data.access_token'));
        $created = $this->postJson(
            '/api/v1/inventory/medicine/items',
            $this->itemPayload($owner->json('data.active_farm_id'), 'medicine'),
            [...$headers, 'Idempotency-Key' => 'create-medicine'],
        )->assertCreated();
        $itemId = $created->json('data.id');

        $receipt = [
            'batch_number' => 'MED-BATCH-2',
            'supplier' => 'Trusted Veterinary Supply',
            'purchase_date' => '2026-07-29',
            'expiry_date' => '2027-07-29',
            'quantity' => '5.000',
            'unit_cost' => '120.5000',
            'reason' => 'Purchase receipt INV-100',
        ];
        $first = $this->postJson(
            "/api/v1/inventory/medicine/items/$itemId/receipts",
            $receipt,
            [...$headers, 'Idempotency-Key' => 'receipt-1'],
        )->assertCreated();
        $this->postJson(
            "/api/v1/inventory/medicine/items/$itemId/receipts",
            $receipt,
            [...$headers, 'Idempotency-Key' => 'receipt-1'],
        )->assertStatus($first->status())->assertExactJson($first->json());

        $this->assertDatabaseCount('stock_movements', 2);
        $overview = $this->getJson('/api/v1/inventory/medicine', $headers)
            ->assertOk()
            ->assertJsonPath('data.items.0.current_stock', '15.000');

        $version = $overview->json('data.items.0.version');
        $this->patchJson("/api/v1/inventory/medicine/items/$itemId", [
            'name' => 'Updated medicine',
            'category' => 'Injection',
            'brand' => 'DairyVet',
            'unit' => 'vial',
            'minimum_stock' => '2.000',
            'maximum_stock' => '100.000',
            'notes' => null,
            'is_active' => false,
            'version' => $version,
            'current_stock' => '999999.000',
        ], $headers)->assertOk()
            ->assertJsonPath('data.current_stock', '15.000')
            ->assertJsonPath('data.is_active', true);
        $this->assertDatabaseCount('stock_movements', 2);

        $this->patchJson("/api/v1/inventory/medicine/items/$itemId", [
            'name' => 'Stale update',
            'category' => 'Injection',
            'brand' => 'DairyVet',
            'unit' => 'vial',
            'minimum_stock' => '2.000',
            'maximum_stock' => '100.000',
            'notes' => null,
            'is_active' => true,
            'version' => $version,
        ], $headers)->assertStatus(412)
            ->assertJsonPath('error.code', 'STALE_VERSION');
        $this->assertDatabaseMissing('inventory_items', [
            'id' => $itemId,
            'name' => 'Stale update',
        ]);
    }

    public function test_low_expiring_and_expired_inventory_summary_is_calculated_from_batches(): void
    {
        $owner = $this->owner('summary-owner@example.test', 'Summary Farm');
        $headers = $this->bearer($owner->json('data.access_token'));
        $payload = $this->itemPayload($owner->json('data.active_farm_id'), 'feed');
        $payload['minimum_stock'] = '20.000';
        $payload['purchase_date'] = now()->subMonth()->toDateString();
        $payload['expiry_date'] = now()->subDay()->toDateString();

        $this->postJson(
            '/api/v1/inventory/feed/items',
            $payload,
            [...$headers, 'Idempotency-Key' => 'expired-feed'],
        )->assertCreated();

        $this->getJson('/api/v1/inventory/feed?low_stock=1', $headers)
            ->assertOk()
            ->assertJsonPath('data.summary.low_stock_items', 1)
            ->assertJsonPath('data.summary.expired_batches', 1)
            ->assertJsonCount(1, 'data.items');
    }

    public function test_inventory_requires_authentication_and_conceals_other_farms(): void
    {
        $this->getJson('/api/v1/inventory')->assertUnauthorized();
        $first = $this->owner('first-inventory@example.test', 'First Inventory Farm');
        $firstHeaders = $this->bearer($first->json('data.access_token'));
        $item = $this->postJson(
            '/api/v1/inventory/semen/items',
            $this->itemPayload($first->json('data.active_farm_id'), 'semen'),
            [...$firstHeaders, 'Idempotency-Key' => 'first-semen'],
        )->assertCreated();

        $second = $this->owner('second-inventory@example.test', 'Second Inventory Farm');
        $secondHeaders = $this->bearer($second->json('data.access_token'));
        $this->getJson(
            '/api/v1/inventory/semen/items/'.$item->json('data.id').'/movements',
            $secondHeaders,
        )->assertNotFound();
        $this->assertSame(1, InventoryItem::query()->count());
    }

    public function test_view_only_members_cannot_create_inventory(): void
    {
        $owner = $this->owner('viewer-inventory@example.test', 'Viewer Inventory Farm');
        $headers = $this->bearer($owner->json('data.access_token'));
        $membership = OrganizationMembership::query()
            ->where('user_id', $owner->json('data.user.id'))
            ->firstOrFail();
        $role = $membership->roles()->firstOrFail();
        $role->permissions()->detach(
            Permission::query()->where('name', 'inventory.manage')->firstOrFail(),
        );

        $this->getJson('/api/v1/inventory', $headers)->assertOk();
        $this->postJson(
            '/api/v1/inventory/feed/items',
            $this->itemPayload($owner->json('data.active_farm_id'), 'feed'),
            [...$headers, 'Idempotency-Key' => 'forbidden-feed'],
        )->assertForbidden();
        $this->assertDatabaseCount('inventory_items', 0);
    }

    public function test_inventory_archive_preserves_history_and_requires_zero_stock(): void
    {
        $owner = $this->owner('archive-inventory@example.test', 'Archive Inventory Farm');
        $headers = $this->bearer($owner->json('data.access_token'));
        $created = $this->postJson(
            '/api/v1/inventory/feed/items',
            $this->itemPayload($owner->json('data.active_farm_id'), 'feed'),
            [...$headers, 'Idempotency-Key' => 'archive-feed'],
        )->assertCreated();
        $itemId = $created->json('data.id');

        $this->deleteJson(
            "/api/v1/inventory/feed/items/$itemId",
            ['version' => $created->json('data.version')],
            $headers,
        )->assertConflict()
            ->assertJsonPath('error.code', 'INVENTORY_ITEM_HAS_STOCK');

        $batch = InventoryBatch::query()->where('inventory_item_id', $itemId)->firstOrFail();
        $batch->forceFill(['current_quantity' => 0, 'version' => 2])->save();
        StockMovement::create([
            'organization_id' => $batch->organization_id,
            'farm_id' => $batch->farm_id,
            'inventory_item_id' => $itemId,
            'inventory_batch_id' => $batch->id,
            'movement_type' => 'issue',
            'quantity_change' => '-10.000',
            'unit_cost' => $batch->unit_cost,
            'occurred_at' => now(),
            'reason' => 'Test stock usage before archive.',
            'created_by' => $owner->json('data.user.id'),
        ]);

        $this->deleteJson(
            "/api/v1/inventory/feed/items/$itemId",
            ['version' => $created->json('data.version')],
            $headers,
        )->assertOk()
            ->assertJsonPath('data.id', $itemId)
            ->assertJsonPath('data.is_archived', true);

        $this->assertSoftDeleted('inventory_items', ['id' => $itemId]);
        $this->assertDatabaseCount('inventory_batches', 1);
        $this->assertDatabaseCount('stock_movements', 2);
        $this->assertDatabaseHas('audit_logs', [
            'action' => 'inventory.item_archived',
            'entity_id' => $itemId,
        ]);
        $this->getJson("/api/v1/inventory/feed/items/$itemId/movements", $headers)
            ->assertNotFound();
    }

    public function test_inventory_receipt_and_spreadsheet_exports_are_selected_date_filtered_and_audited(): void
    {
        $owner = $this->owner('export-inventory@example.test', 'Export Inventory Farm');
        $headers = $this->bearer($owner->json('data.access_token'));
        $first = $this->postJson(
            '/api/v1/inventory/medicine/items',
            $this->itemPayload($owner->json('data.active_farm_id'), 'medicine'),
            [...$headers, 'Idempotency-Key' => 'export-medicine-first'],
        )->assertCreated();
        $secondPayload = $this->itemPayload($owner->json('data.active_farm_id'), 'medicine');
        $secondPayload['item_code'] = 'MED-002';
        $secondPayload['name'] = 'Second selected medicine';
        $second = $this->postJson(
            '/api/v1/inventory/medicine/items',
            $secondPayload,
            [...$headers, 'Idempotency-Key' => 'export-medicine-second'],
        )->assertCreated();

        StockMovement::query()
            ->where('inventory_item_id', $first->json('data.id'))
            ->update(['occurred_at' => now()->subDays(10)]);
        $this->postJson(
            '/api/v1/inventory/medicine/items/'.$first->json('data.id').'/receipts',
            [
                'batch_number' => 'MED-RECENT',
                'supplier' => 'Recent Supplier',
                'purchase_date' => today()->toDateString(),
                'expiry_date' => today()->addYear()->toDateString(),
                'quantity' => '2.000',
                'unit_cost' => '75.0000',
                'reason' => 'Recent receipt for export.',
            ],
            [...$headers, 'Idempotency-Key' => 'recent-export-receipt'],
        )->assertCreated();

        $period = http_build_query([
            'item_ids' => [$first->json('data.id')],
            'from_date' => today()->toDateString(),
            'to_date' => today()->toDateString(),
        ]);
        $pdf = $this->get("/api/v1/inventory/medicine/exports/receipt?$period", $headers)
            ->assertOk()
            ->assertHeader('content-type', 'application/pdf')
            ->assertHeader('cache-control', 'max-age=0, no-store, private');
        $this->assertStringStartsWith('%PDF-', $pdf->getContent());

        $xlsx = $this->get("/api/v1/inventory/medicine/exports/spreadsheet?$period", $headers)
            ->assertOk()
            ->assertHeader(
                'content-type',
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            );
        $this->assertStringStartsWith('PK', $xlsx->getContent());
        $rows = $this->xlsxRows($xlsx->getContent());
        $flat = collect($rows)->flatten()->filter()->map(fn ($value) => (string) $value);
        $this->assertTrue($flat->contains('Medicine item'));
        $this->assertFalse($flat->contains('Second selected medicine'));
        $this->assertTrue($flat->contains('Purchase receipt'));
        $this->assertFalse($flat->contains('Opening stock'));

        $allRows = $this->xlsxRows(
            $this->get(
                '/api/v1/inventory/medicine/exports/spreadsheet',
                $headers,
            )->assertOk()->getContent(),
        );
        $allFlat = collect($allRows)->flatten()->filter()->map(fn ($value) => (string) $value);
        $this->assertTrue($allFlat->contains('Medicine item'));
        $this->assertTrue($allFlat->contains('Second selected medicine'));
        $this->assertDatabaseHas('audit_logs', ['action' => 'inventory.receipt_exported']);
        $this->assertDatabaseHas('audit_logs', ['action' => 'inventory.spreadsheet_exported']);
    }

    public function test_inventory_exports_require_permission_and_conceal_cross_farm_items(): void
    {
        $first = $this->owner('first-export@example.test', 'First Export Farm');
        $firstHeaders = $this->bearer($first->json('data.access_token'));
        $item = $this->postJson(
            '/api/v1/inventory/semen/items',
            $this->itemPayload($first->json('data.active_farm_id'), 'semen'),
            [...$firstHeaders, 'Idempotency-Key' => 'first-export-item'],
        )->assertCreated();
        $second = $this->owner('second-export@example.test', 'Second Export Farm');
        $secondHeaders = $this->bearer($second->json('data.access_token'));
        $selection = http_build_query(['item_ids' => [$item->json('data.id')]]);

        $this->get("/api/v1/inventory/semen/exports/receipt?$selection")
            ->assertUnauthorized();
        $this->get(
            "/api/v1/inventory/semen/exports/receipt?$selection",
            $secondHeaders,
        )->assertNotFound();

        $membership = OrganizationMembership::query()
            ->where('user_id', $first->json('data.user.id'))
            ->firstOrFail();
        $role = $membership->roles()->firstOrFail();
        $role->permissions()->detach(
            Permission::query()->where('name', 'inventory.export')->firstOrFail(),
        );
        $this->get(
            '/api/v1/inventory/semen/exports/spreadsheet',
            $firstHeaders,
        )->assertForbidden();
    }

    private function owner(string $email, string $farmName)
    {
        return $this->postJson('/api/v1/auth/owner-signup', [
            'name' => 'Inventory Owner',
            'farm_name' => $farmName,
            'email' => $email,
            'password' => 'OwnerPass2026',
            'password_confirmation' => 'OwnerPass2026',
            'timezone' => 'Asia/Karachi',
        ])->assertCreated();
    }

    private function itemPayload(string $farmId, string $kind): array
    {
        return [
            'farm_id' => $farmId,
            'item_code' => strtoupper(substr($kind, 0, 3)).'-001',
            'name' => ucfirst($kind).' item',
            'category' => $kind === 'medicine' ? 'Injection' : ($kind === 'feed' ? 'Concentrate' : 'Frozen semen'),
            'brand' => 'DairyCare QA',
            'unit' => $kind === 'feed' ? 'kg' : ($kind === 'semen' ? 'straw' : 'vial'),
            'minimum_stock' => '2.000',
            'maximum_stock' => '100.000',
            'notes' => 'Inventory core test',
            'batch_number' => strtoupper($kind).'-BATCH-1',
            'supplier' => 'Trusted Supplier',
            'purchase_date' => '2026-07-29',
            'expiry_date' => '2027-07-29',
            'opening_quantity' => '10.000',
            'unit_cost' => '100.0000',
        ];
    }

    private function bearer(string $token): array
    {
        return ['Authorization' => 'Bearer '.$token];
    }

    private function xlsxRows(string $contents): array
    {
        $path = tempnam(sys_get_temp_dir(), 'dairycare-export-test-');
        $this->assertNotFalse($path);
        file_put_contents($path, $contents);
        $reader = new Reader;
        $rows = [];
        try {
            $reader->open($path);
            foreach ($reader->getSheetIterator() as $sheet) {
                foreach ($sheet->getRowIterator() as $row) {
                    $rows[] = $row->toArray();
                }
            }
            $reader->close();
        } finally {
            if (is_file($path)) {
                unlink($path);
            }
        }

        return $rows;
    }
}
