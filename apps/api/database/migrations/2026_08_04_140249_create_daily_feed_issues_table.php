<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('daily_feed_issues', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->uuid('shed_id')->nullable();
            $table->uuid('animal_group_id')->nullable();
            $table->date('date');
            $table->uuid('inventory_item_id');
            $table->decimal('planned_quantity', 18, 3)->default(0);
            $table->decimal('issued_quantity', 18, 3)->default(0);
            $table->decimal('consumed_quantity', 18, 3)->default(0);
            $table->decimal('wasted_quantity', 18, 3)->default(0);
            $table->decimal('returned_quantity', 18, 3)->default(0);
            $table->uuid('employee_id')->nullable();
            $table->text('notes')->nullable();
            $table->unsignedBigInteger('version')->default(1);
            $table->uuid('created_by');
            $table->uuid('updated_by');
            $table->timestamps();
            $table->softDeletes();

            $table->unique(['id', 'organization_id', 'farm_id'], 'daily_feed_issues_scope_unique');
            $table->index(['organization_id', 'farm_id', 'date'], 'daily_feed_issues_tenant_date_index');

            $table->foreign('organization_id')->references('id')->on('organizations')->cascadeOnDelete();
            $table->foreign(['farm_id', 'organization_id'], 'daily_feed_issues_farm_tenant_fk')
                ->references(['id', 'organization_id'])->on('farms')->restrictOnDelete();
            $table->foreign(['shed_id', 'organization_id', 'farm_id'], 'daily_feed_issues_shed_fk')
                ->references(['id', 'organization_id', 'farm_id'])->on('sheds')->restrictOnDelete();
            $table->foreign(['animal_group_id', 'organization_id', 'farm_id'], 'daily_feed_issues_group_fk')
                ->references(['id', 'organization_id', 'farm_id'])->on('animal_groups')->restrictOnDelete();
            $table->foreign(['inventory_item_id', 'organization_id', 'farm_id'], 'daily_feed_issues_item_fk')
                ->references(['id', 'organization_id', 'farm_id'])->on('inventory_items')->restrictOnDelete();
            $table->foreign(['employee_id', 'organization_id', 'farm_id'], 'daily_feed_issues_employee_fk')
                ->references(['id', 'organization_id', 'farm_id'])->on('employees')->restrictOnDelete();
            $table->foreign('created_by')->references('id')->on('users')->restrictOnDelete();
            $table->foreign('updated_by')->references('id')->on('users')->restrictOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('daily_feed_issues');
    }
};
