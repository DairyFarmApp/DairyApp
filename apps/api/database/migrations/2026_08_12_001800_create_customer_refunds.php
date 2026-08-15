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
        Schema::table('milk_sale_returns', function (Blueprint $t): void {
            $t->decimal('refund_due', 16, 2)->default(0)->after('credit_amount');
            $t->decimal('refunded_amount', 16, 2)->default(0)->after('refund_due');
            $t->string('refund_status', 30)->default('not_required')->after('refunded_amount');
        });
        Schema::create('customer_refunds', function (Blueprint $t): void {
            $t->uuid('id')->primary();
            $t->uuid('organization_id');
            $t->uuid('farm_id');
            $t->uuid('customer_id');
            $t->uuid('milk_sale_id');
            $t->uuid('milk_sale_return_id');
            $t->string('refund_number', 60);
            $t->date('refund_date');
            $t->decimal('amount', 16, 2);
            $t->string('payment_method', 30);
            $t->string('reference', 160)->nullable();
            $t->text('notes')->nullable();
            $t->uuid('created_by');
            $t->timestamps();
            $t->unique(['organization_id', 'refund_number']);
            $t->index(['organization_id', 'farm_id', 'customer_id', 'refund_date'], 'customer_refund_scope_idx');
        });
        $name = 'customer_refunds.manage';
        DB::table('permissions')->updateOrInsert(['name' => $name], ['id' => (string) Str::uuid7(), 'created_at' => now(), 'updated_at' => now()]);
        $permission = DB::table('permissions')->where('name', $name)->value('id');
        foreach (DB::table('roles')->whereIn('slug', ['organization-owner', 'farm-manager'])->pluck('id') as $role) {
            DB::table('role_permissions')->updateOrInsert(['role_id' => $role, 'permission_id' => $permission], ['created_at' => now(), 'updated_at' => now()]);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('customer_refunds');
        Schema::table('milk_sale_returns', fn (Blueprint $t) => $t->dropColumn(['refund_due', 'refunded_amount', 'refund_status']));
        DB::table('permissions')->where('name', 'customer_refunds.manage')->delete();
    }
};
