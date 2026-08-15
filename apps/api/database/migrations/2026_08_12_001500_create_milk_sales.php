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
        Schema::create('milk_sales', function (Blueprint $t): void {
            $t->uuid('id')->primary();
            $t->uuid('organization_id');
            $t->uuid('farm_id');
            $t->uuid('customer_id');
            $t->string('invoice_number', 60);
            $t->dateTime('sold_at');
            $t->date('milk_batch_date');
            $t->decimal('quantity_litres', 14, 3);
            $t->decimal('base_rate', 14, 2);
            $t->decimal('fat_adjustment', 14, 2)->default(0);
            $t->decimal('snf_adjustment', 14, 2)->default(0);
            $t->decimal('quality_adjustment', 14, 2)->default(0);
            $t->decimal('discount', 14, 2)->default(0);
            $t->decimal('tax', 14, 2)->default(0);
            $t->decimal('delivery_charges', 14, 2)->default(0);
            $t->decimal('total_amount', 16, 2);
            $t->decimal('paid_amount', 16, 2)->default(0);
            $t->decimal('balance_amount', 16, 2);
            $t->string('payment_status', 20)->default('unpaid');
            $t->string('status', 30)->default('draft');
            $t->string('delivery_status', 30)->default('pending');
            $t->string('payment_method', 30)->nullable();
            $t->string('driver', 160)->nullable();
            $t->string('vehicle', 100)->nullable();
            $t->text('notes')->nullable();
            $t->uuid('created_by');
            $t->uuid('confirmed_by')->nullable();
            $t->dateTime('confirmed_at')->nullable();
            $t->uuid('cancelled_by')->nullable();
            $t->dateTime('cancelled_at')->nullable();
            $t->string('cancellation_reason', 500)->nullable();
            $t->timestamps();
            $t->unique(['organization_id', 'invoice_number']);
            $t->index(['organization_id', 'farm_id', 'milk_batch_date', 'status'], 'milk_sale_batch_status_idx');
        });
        Schema::create('milk_stock_movements', function (Blueprint $t): void {
            $t->uuid('id')->primary();
            $t->uuid('organization_id');
            $t->uuid('farm_id');
            $t->date('milk_batch_date');
            $t->uuid('milk_sale_id');
            $t->string('movement_type', 30);
            $t->decimal('quantity_change', 14, 3);
            $t->dateTime('occurred_at');
            $t->string('reason', 500);
            $t->uuid('created_by');
            $t->timestamps();
            $t->index(['organization_id', 'farm_id', 'milk_batch_date'], 'milk_stock_batch_idx');
        });
        Schema::create('customer_payments', function (Blueprint $t): void {
            $t->uuid('id')->primary();
            $t->uuid('organization_id');
            $t->uuid('farm_id');
            $t->uuid('customer_id');
            $t->uuid('milk_sale_id');
            $t->string('payment_number', 60);
            $t->date('payment_date');
            $t->decimal('amount', 16, 2);
            $t->string('payment_method', 30);
            $t->string('reference', 160)->nullable();
            $t->text('notes')->nullable();
            $t->uuid('created_by');
            $t->timestamps();
        });
        $names = ['milk_sales.view', 'milk_sales.manage', 'milk_sales.confirm', 'milk_sales.cancel', 'customer_payments.manage'];
        foreach ($names as $n) {
            DB::table('permissions')->updateOrInsert(['name' => $n], ['id' => (string) Str::uuid7(), 'created_at' => now(), 'updated_at' => now()]);
        }$ids = DB::table('permissions')->whereIn('name', $names)->pluck('id');
        foreach (DB::table('roles')->whereIn('slug', ['organization-owner', 'farm-manager'])->pluck('id') as $r) {
            foreach ($ids as $id) {
                DB::table('role_permissions')->updateOrInsert(['role_id' => $r, 'permission_id' => $id], ['created_at' => now(), 'updated_at' => now()]);
            }
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('customer_payments');
        Schema::dropIfExists('milk_stock_movements');
        Schema::dropIfExists('milk_sales');
        DB::table('permissions')->whereIn('name',['milk_sales.view', 'milk_sales.manage', 'milk_sales.confirm', 'milk_sales.cancel', 'customer_payments.manage'])->delete();
    }
};
