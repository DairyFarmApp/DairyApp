<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('animal_feed_consumptions', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('organization_id')->constrained()->cascadeOnDelete();
            $table->uuid('farm_id');
            $table->uuid('animal_id');
            $table->uuid('inventory_item_id');
            $table->date('date');
            $table->string('session', 24)->default('all_day');
            $table->decimal('quantity', 18, 3);
            $table->string('unit', 16)->default('kg');
            $table->text('notes')->nullable();
            $table->foreignUuid('recorded_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();

            $table->index(['organization_id', 'farm_id', 'animal_id', 'date'], 'animal_feed_consumptions_scope_index');

            $table->foreign(['farm_id', 'organization_id'], 'animal_feed_consumptions_farm_fk')
                ->references(['id', 'organization_id'])->on('farms')->restrictOnDelete();
            $table->foreign(['animal_id', 'organization_id'], 'animal_feed_consumptions_animal_fk')
                ->references(['id', 'organization_id'])->on('animals')->restrictOnDelete();
            $table->foreign(['inventory_item_id', 'organization_id', 'farm_id'], 'animal_feed_consumptions_item_fk')
                ->references(['id', 'organization_id', 'farm_id'])->on('inventory_items')->restrictOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('animal_feed_consumptions');
    }
};
