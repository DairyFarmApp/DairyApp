<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('inventory_items', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->enum('kind', ['medicine', 'semen', 'feed']);
            $table->string('item_code', 60);
            $table->string('barcode', 120)->nullable();
            $table->string('name', 180);
            $table->string('category', 100);
            $table->string('brand', 160)->nullable();
            $table->string('unit', 40);
            $table->decimal('minimum_stock', 18, 3)->default(0);
            $table->decimal('maximum_stock', 18, 3)->nullable();
            $table->text('notes')->nullable();
            $table->boolean('is_active')->default(true);
            $table->unsignedBigInteger('version')->default(1);
            $table->uuid('created_by');
            $table->uuid('updated_by');
            $table->timestamps();
            $table->softDeletes();

            $table->unique(['organization_id', 'farm_id', 'kind', 'item_code'], 'inventory_items_farm_kind_code_unique');
            $table->unique(['id', 'organization_id', 'farm_id'], 'inventory_items_id_org_farm_unique');
            $table->index(['organization_id', 'farm_id', 'kind', 'name'], 'inventory_items_farm_kind_name_index');
            $table->foreign('organization_id')->references('id')->on('organizations')->cascadeOnDelete();
            $table->foreign(['farm_id', 'organization_id'], 'inventory_items_farm_tenant_fk')
                ->references(['id', 'organization_id'])->on('farms')->restrictOnDelete();
            $table->foreign('created_by')->references('id')->on('users')->restrictOnDelete();
            $table->foreign('updated_by')->references('id')->on('users')->restrictOnDelete();
        });

        Schema::create('inventory_batches', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->uuid('inventory_item_id');
            $table->string('batch_number', 120);
            $table->string('supplier', 180)->nullable();
            $table->date('purchase_date')->nullable();
            $table->date('expiry_date')->nullable();
            $table->decimal('unit_cost', 19, 4)->default(0);
            $table->decimal('current_quantity', 18, 3)->default(0);
            $table->unsignedBigInteger('version')->default(1);
            $table->timestamps();

            $table->unique(['inventory_item_id', 'batch_number'], 'inventory_batches_item_number_unique');
            $table->unique(['id', 'organization_id', 'farm_id', 'inventory_item_id'], 'inventory_batches_scope_unique');
            $table->index(['organization_id', 'farm_id', 'expiry_date'], 'inventory_batches_farm_expiry_index');
            $table->foreign(['inventory_item_id', 'organization_id', 'farm_id'], 'inventory_batches_item_scope_fk')
                ->references(['id', 'organization_id', 'farm_id'])->on('inventory_items')->restrictOnDelete();
        });

        Schema::create('stock_movements', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->uuid('inventory_item_id');
            $table->uuid('inventory_batch_id');
            $table->enum('movement_type', [
                'opening_stock',
                'purchase_receipt',
                'issue',
                'return',
                'adjustment',
                'damage',
                'expiry',
                'consumption',
            ]);
            $table->decimal('quantity_change', 18, 3);
            $table->decimal('unit_cost', 19, 4);
            $table->timestamp('occurred_at');
            $table->text('reason')->nullable();
            $table->uuid('created_by');
            $table->timestamps();

            $table->index(['organization_id', 'farm_id', 'inventory_item_id', 'occurred_at'], 'stock_movements_item_time_index');
            $table->index(['organization_id', 'updated_at'], 'stock_movements_sync_index');
            $table->foreign(
                ['inventory_batch_id', 'organization_id', 'farm_id', 'inventory_item_id'],
                'stock_movements_batch_scope_fk',
            )->references(['id', 'organization_id', 'farm_id', 'inventory_item_id'])
                ->on('inventory_batches')->restrictOnDelete();
            $table->foreign('created_by')->references('id')->on('users')->restrictOnDelete();
        });

        $permissionIds = [];
        foreach (['inventory.view', 'inventory.manage'] as $name) {
            $permissionId = DB::table('permissions')->where('name', $name)->value('id');
            if (! $permissionId) {
                $permissionId = (string) Str::uuid7();
                DB::table('permissions')->insert([
                    'id' => $permissionId,
                    'name' => $name,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
            $permissionIds[$name] = $permissionId;
        }
        DB::table('roles')
            ->select(['id', 'slug'])
            ->whereIn('slug', ['organization-owner', 'farm-manager', 'farm-worker', 'viewer'])
            ->orderBy('id')
            ->each(function ($role) use ($permissionIds): void {
                $names = in_array($role->slug, ['organization-owner', 'farm-manager'], true)
                    ? ['inventory.view', 'inventory.manage']
                    : ['inventory.view'];
                foreach ($names as $name) {
                    DB::table('permission_role')->insertOrIgnore([
                        'role_id' => $role->id,
                        'permission_id' => $permissionIds[$name],
                    ]);
                }
            });
    }

    public function down(): void
    {
        Schema::dropIfExists('stock_movements');
        Schema::dropIfExists('inventory_batches');
        Schema::dropIfExists('inventory_items');
        DB::table('permissions')->whereIn('name', ['inventory.view', 'inventory.manage'])->delete();
    }
};
