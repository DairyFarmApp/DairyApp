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
        Schema::create('supplier_invoices', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->uuid('supplier_id');
            $table->uuid('purchase_order_id');
            $table->string('invoice_number', 60);
            $table->string('supplier_invoice_number', 100);
            $table->date('invoice_date');
            $table->date('due_date');
            $table->decimal('total_amount', 16, 2);
            $table->decimal('paid_amount', 16, 2)->default(0);
            $table->decimal('balance_amount', 16, 2);
            $table->string('payment_status', 20)->default('unpaid');
            $table->text('notes')->nullable();
            $table->uuid('created_by');
            $table->timestamps();
            $table->unique('purchase_order_id');
            $table->unique(['organization_id', 'supplier_id', 'supplier_invoice_number'], 'supplier_external_invoice_uq');
            $table->index(['organization_id', 'farm_id', 'payment_status', 'due_date'], 'supplier_invoice_due_idx');
        });
        Schema::create('supplier_payments', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->uuid('supplier_id');
            $table->uuid('supplier_invoice_id');
            $table->string('payment_number', 60);
            $table->date('payment_date');
            $table->decimal('amount', 16, 2);
            $table->string('payment_method', 30);
            $table->string('reference', 160)->nullable();
            $table->text('notes')->nullable();
            $table->uuid('created_by');
            $table->timestamps();
            $table->index(['organization_id', 'farm_id', 'supplier_id', 'payment_date'], 'supplier_payment_scope_idx');
        });
        $names = ['supplier_invoices.view', 'supplier_invoices.manage', 'supplier_payments.manage'];
        foreach ($names as $name) {
            DB::table('permissions')->updateOrInsert(['name' => $name], ['id' => (string) Str::uuid7(), 'created_at' => now(), 'updated_at' => now()]);
        }
        $ids = DB::table('permissions')->whereIn('name', $names)->pluck('id');
        foreach (DB::table('roles')->whereIn('slug', ['organization-owner', 'farm-manager'])->pluck('id') as $role) {
            foreach ($ids as $id) {
                DB::table('permission_role')->updateOrInsert(['role_id' => $role, 'permission_id' => $id]);
            }
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('supplier_payments');
        Schema::dropIfExists('supplier_invoices');
        DB::table('permissions')->whereIn('name', ['supplier_invoices.view', 'supplier_invoices.manage', 'supplier_payments.manage'])->delete();
    }
};
