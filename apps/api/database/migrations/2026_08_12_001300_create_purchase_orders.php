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
        Schema::create('purchase_orders', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->uuid('supplier_id');
            $table->string('purchase_number', 30);
            $table->date('purchase_date');
            $table->date('expected_date')->nullable();
            $table->string('status', 30)->default('draft');
            $table->decimal('discount', 16, 2)->default(0);
            $table->decimal('tax', 16, 2)->default(0);
            $table->decimal('transport_cost', 16, 2)->default(0);
            $table->decimal('other_cost', 16, 2)->default(0);
            $table->decimal('subtotal', 16, 2);
            $table->decimal('total', 16, 2);
            $table->text('notes')->nullable();
            $table->uuid('approved_by')->nullable();
            $table->dateTime('approved_at')->nullable();
            $table->unsignedBigInteger('version')->default(1);
            $table->uuid('created_by');
            $table->uuid('updated_by');
            $table->timestamps();
            $table->softDeletes();
            $table->unique(['organization_id', 'purchase_number']);
            $table->index(['organization_id', 'farm_id', 'status', 'purchase_date'], 'purchase_order_scope_status_idx');
        });
        Schema::create('purchase_order_items', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('purchase_order_id');
            $table->uuid('inventory_item_id');
            $table->decimal('ordered_quantity', 14, 3);
            $table->decimal('received_quantity', 14, 3)->default(0);
            $table->decimal('unit_rate', 14, 4);
            $table->decimal('line_total', 16, 2);
            $table->timestamps();
            $table->unique(['purchase_order_id', 'inventory_item_id']);
        });
        Schema::create('goods_receipts', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->uuid('purchase_order_id');
            $table->string('receipt_number', 30);
            $table->dateTime('received_at');
            $table->string('quality_status', 20);
            $table->text('notes')->nullable();
            $table->uuid('received_by');
            $table->timestamps();
            $table->unique(['organization_id', 'receipt_number']);
        });
        Schema::create('goods_receipt_items', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('goods_receipt_id');
            $table->uuid('purchase_order_item_id');
            $table->uuid('inventory_batch_id');
            $table->uuid('stock_movement_id');
            $table->string('batch_number', 100);
            $table->date('expiry_date')->nullable();
            $table->decimal('quantity', 14, 3);
            $table->decimal('unit_cost', 14, 4);
            $table->timestamps();
        });
        $names = ['purchases.view', 'purchases.manage', 'purchases.approve', 'purchases.receive'];
        foreach ($names as $name) {
            DB::table('permissions')->updateOrInsert(['name' => $name], ['id' => (string) Str::uuid7(), 'created_at' => now(), 'updated_at' => now()]);
        }
        $ids = DB::table('permissions')->whereIn('name', $names)->pluck('id');
        foreach (DB::table('roles')->whereIn('slug', ['organization-owner', 'farm-manager'])->pluck('id') as $role) {
            foreach ($ids as $id) {
                DB::table('role_permissions')->updateOrInsert(['role_id' => $role, 'permission_id' => $id], ['created_at' => now(), 'updated_at' => now()]);
            }
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('goods_receipt_items');
        Schema::dropIfExists('goods_receipts');
        Schema::dropIfExists('purchase_order_items');
        Schema::dropIfExists('purchase_orders');
        DB::table('permissions')->whereIn('name', ['purchases.view', 'purchases.manage', 'purchases.approve', 'purchases.receive'])->delete();
    }
};
