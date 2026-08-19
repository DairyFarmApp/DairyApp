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
        Schema::create('suppliers', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->string('code', 30);
            $table->string('name', 180);
            $table->string('contact_person', 160)->nullable();
            $table->string('phone', 40)->nullable();
            $table->string('email', 190)->nullable();
            $table->text('address')->nullable();
            $table->string('tax_information', 190)->nullable();
            $table->json('categories')->nullable();
            $table->unsignedSmallInteger('payment_terms_days')->default(0);
            $table->decimal('credit_limit', 16, 2)->default(0);
            $table->decimal('opening_balance', 16, 2)->default(0);
            $table->decimal('current_balance', 16, 2)->default(0);
            $table->boolean('is_active')->default(true);
            $table->text('notes')->nullable();
            $table->unsignedBigInteger('version')->default(1);
            $table->uuid('created_by')->nullable();
            $table->uuid('updated_by')->nullable();
            $table->timestamps();
            $table->softDeletes();
            $table->unique(['organization_id', 'code']);
            $table->index(['organization_id', 'farm_id', 'is_active']);
        });

        Schema::create('customers', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->string('code', 30);
            $table->string('name', 180);
            $table->string('customer_type', 40);
            $table->string('phone', 40)->nullable();
            $table->string('email', 190)->nullable();
            $table->text('address')->nullable();
            $table->text('delivery_address')->nullable();
            $table->string('tax_information', 190)->nullable();
            $table->decimal('credit_limit', 16, 2)->default(0);
            $table->unsignedSmallInteger('payment_terms_days')->default(0);
            $table->decimal('default_milk_rate', 12, 2)->nullable();
            $table->boolean('quality_based_pricing')->default(false);
            $table->decimal('opening_balance', 16, 2)->default(0);
            $table->decimal('current_balance', 16, 2)->default(0);
            $table->string('route_name', 160)->nullable();
            $table->boolean('is_active')->default(true);
            $table->text('notes')->nullable();
            $table->unsignedBigInteger('version')->default(1);
            $table->uuid('created_by')->nullable();
            $table->uuid('updated_by')->nullable();
            $table->timestamps();
            $table->softDeletes();
            $table->unique(['organization_id', 'code']);
            $table->index(['organization_id', 'farm_id', 'is_active']);
        });

        Schema::create('commercial_ledger_entries', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->string('party_type', 20);
            $table->uuid('party_id');
            $table->dateTime('occurred_at');
            $table->string('entry_type', 40);
            $table->decimal('debit', 16, 2)->default(0);
            $table->decimal('credit', 16, 2)->default(0);
            $table->decimal('balance_after', 16, 2);
            $table->string('reference_type', 60)->nullable();
            $table->uuid('reference_id')->nullable();
            $table->string('description', 255);
            $table->uuid('created_by')->nullable();
            $table->timestamps();
            $table->index(['organization_id', 'farm_id', 'party_type', 'party_id', 'occurred_at'], 'commercial_party_ledger_idx');
        });

        $names = ['suppliers.view', 'suppliers.manage', 'customers.view', 'customers.manage', 'commercial_ledgers.view'];
        foreach ($names as $name) {
            DB::table('permissions')->updateOrInsert(['name' => $name], ['id' => (string) Str::uuid7(), 'created_at' => now(), 'updated_at' => now()]);
        }
        $permissionIds = DB::table('permissions')->whereIn('name', $names)->pluck('id');
        foreach (DB::table('roles')->whereIn('slug', ['organization-owner', 'farm-manager'])->pluck('id') as $roleId) {
            foreach ($permissionIds as $permissionId) {
                DB::table('permission_role')->updateOrInsert(['role_id' => $roleId, 'permission_id' => $permissionId]);
            }
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('commercial_ledger_entries');
        Schema::dropIfExists('customers');
        Schema::dropIfExists('suppliers');
        DB::table('permissions')->whereIn('name', ['suppliers.view', 'suppliers.manage', 'customers.view', 'customers.manage', 'commercial_ledgers.view'])->delete();
    }
};
