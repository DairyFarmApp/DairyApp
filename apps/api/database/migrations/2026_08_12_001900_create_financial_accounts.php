<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

return new class extends Migration {
    public function up(): void {
        Schema::create('financial_accounts', function (Blueprint $t): void {
            $t->uuid('id')->primary(); $t->uuid('organization_id'); $t->uuid('farm_id');
            $t->string('account_number', 60); $t->string('name', 160); $t->string('account_type', 30);
            $t->string('institution', 160)->nullable(); $t->string('external_number', 120)->nullable();
            $t->boolean('is_active')->default(true); $t->uuid('created_by'); $t->timestamps(); $t->softDeletes();
            $t->unique(['organization_id', 'account_number']); $t->index(['organization_id', 'farm_id', 'is_active']);
        });
        Schema::create('financial_account_transactions', function (Blueprint $t): void {
            $t->uuid('id')->primary(); $t->uuid('organization_id'); $t->uuid('farm_id'); $t->uuid('financial_account_id');
            $t->string('transaction_number', 60); $t->dateTime('occurred_at'); $t->string('transaction_type', 40);
            $t->decimal('amount_change', 18, 2); $t->string('reference_type', 60); $t->uuid('reference_id');
            $t->string('description', 500); $t->uuid('journal_entry_id'); $t->uuid('created_by'); $t->timestamps();
            $t->unique(['organization_id', 'transaction_number'], 'financial_account_tx_number_unique'); $t->index(['organization_id', 'farm_id', 'financial_account_id', 'occurred_at'], 'financial_account_ledger_idx');
        });
        Schema::create('financial_account_transfers', function (Blueprint $t): void {
            $t->uuid('id')->primary(); $t->uuid('organization_id'); $t->uuid('farm_id'); $t->string('transfer_number', 60);
            $t->uuid('from_account_id'); $t->uuid('to_account_id'); $t->dateTime('transferred_at'); $t->decimal('amount', 18, 2);
            $t->string('reference', 160)->nullable(); $t->text('notes')->nullable(); $t->uuid('created_by'); $t->timestamps();
            $t->unique(['organization_id', 'transfer_number'], 'financial_account_transfer_number_unique');
        });
        foreach (['finance_accounts.view', 'finance_accounts.manage', 'finance_accounts.transfer'] as $name) DB::table('permissions')->updateOrInsert(['name'=>$name], ['id'=>(string)Str::uuid7(),'created_at'=>now(),'updated_at'=>now()]);
        $ids=DB::table('permissions')->whereIn('name',['finance_accounts.view','finance_accounts.manage','finance_accounts.transfer'])->pluck('id');
        foreach(DB::table('roles')->whereIn('slug',['organization-owner','farm-manager'])->pluck('id') as $role) foreach($ids as $id) DB::table('permission_role')->updateOrInsert(['role_id'=>$role,'permission_id'=>$id]);
    }
    public function down(): void { Schema::dropIfExists('financial_account_transfers'); Schema::dropIfExists('financial_account_transactions'); Schema::dropIfExists('financial_accounts'); DB::table('permissions')->whereIn('name',['finance_accounts.view','finance_accounts.manage','finance_accounts.transfer'])->delete(); }
};
