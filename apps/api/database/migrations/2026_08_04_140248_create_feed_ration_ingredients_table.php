<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('feed_ration_ingredients', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->uuid('feed_ration_plan_id');
            $table->uuid('inventory_item_id');
            $table->decimal('quantity_per_animal', 18, 3);
            $table->string('unit', 40);
            $table->decimal('estimated_cost', 19, 4)->default(0);
            $table->timestamps();

            $table->unique(['feed_ration_plan_id', 'inventory_item_id'], 'feed_ration_ingredients_plan_item_unique');
            $table->foreign(['feed_ration_plan_id', 'organization_id', 'farm_id'], 'feed_ration_ingredients_plan_scope_fk')
                ->references(['id', 'organization_id', 'farm_id'])->on('feed_ration_plans')->cascadeOnDelete();
            $table->foreign(['inventory_item_id', 'organization_id', 'farm_id'], 'feed_ration_ingredients_item_scope_fk')
                ->references(['id', 'organization_id', 'farm_id'])->on('inventory_items')->restrictOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('feed_ration_ingredients');
    }
};
