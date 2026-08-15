<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('feed_ration_plans', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->string('name', 180);
            $table->uuid('animal_group_id')->nullable();
            $table->string('production_stage', 60)->nullable();
            $table->date('effective_date');
            $table->date('end_date')->nullable();
            $table->integer('feeding_frequency')->default(1);
            $table->uuid('created_by');
            $table->uuid('approved_by')->nullable();
            $table->unsignedBigInteger('version')->default(1);
            $table->timestamps();
            $table->softDeletes();

            $table->unique(['id', 'organization_id', 'farm_id'], 'feed_ration_plans_scope_unique');
            $table->foreign('organization_id')->references('id')->on('organizations')->cascadeOnDelete();
            $table->foreign(['farm_id', 'organization_id'], 'feed_ration_plans_farm_tenant_fk')
                ->references(['id', 'organization_id'])->on('farms')->restrictOnDelete();
            $table->foreign(['animal_group_id', 'organization_id', 'farm_id'], 'feed_ration_plans_group_fk')
                ->references(['id', 'organization_id', 'farm_id'])->on('animal_groups')->restrictOnDelete();
            $table->foreign('created_by')->references('id')->on('users')->restrictOnDelete();
            $table->foreign('approved_by')->references('id')->on('users')->restrictOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('feed_ration_plans');
    }
};
