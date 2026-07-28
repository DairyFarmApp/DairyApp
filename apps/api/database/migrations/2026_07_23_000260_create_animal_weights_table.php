<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('animal_weights', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('organization_id')->constrained()->cascadeOnDelete();
            $table->uuid('farm_id');
            $table->uuid('animal_id');
            $table->decimal('entered_value', 18, 6);
            $table->enum('entered_unit', ['kg', 'lb']);
            $table->decimal('normalized_kg', 18, 6);
            $table->timestamp('observed_at');
            $table->enum('source', ['manual', 'scale', 'estimated', 'imported']);
            $table->text('notes')->nullable();
            $table->foreignUuid('recorded_by')->constrained('users')->restrictOnDelete();
            $table->uuid('supersedes_weight_id')->nullable();
            $table->uuid('superseded_by_weight_id')->nullable();
            $table->text('correction_reason')->nullable();
            $table->boolean('is_superseded')->default(false);
            $table->timestamps();

            $table->unique(['id', 'organization_id', 'animal_id'], 'animal_weights_id_org_animal_unique');
            $table->unique('supersedes_weight_id', 'animal_weights_supersedes_unique');
            $table->unique('superseded_by_weight_id', 'animal_weights_superseded_by_unique');
            $table->index(
                ['organization_id', 'animal_id', 'is_superseded', 'observed_at'],
                'animal_weights_org_animal_latest_index',
            );
            $table->index(['organization_id', 'farm_id', 'observed_at'], 'animal_weights_org_farm_observed_index');
            $table->index(['organization_id', 'updated_at'], 'animal_weights_org_updated_index');

            $table->foreign(['animal_id', 'organization_id'], 'animal_weights_animal_tenant_fk')
                ->references(['id', 'organization_id'])->on('animals')->restrictOnDelete();
            $table->foreign(['farm_id', 'organization_id'], 'animal_weights_farm_tenant_fk')
                ->references(['id', 'organization_id'])->on('farms')->restrictOnDelete();
            $table->foreign(
                ['supersedes_weight_id', 'organization_id', 'animal_id'],
                'animal_weights_supersedes_same_animal_fk',
            )->references(['id', 'organization_id', 'animal_id'])->on('animal_weights')->restrictOnDelete();
            $table->foreign(
                ['superseded_by_weight_id', 'organization_id', 'animal_id'],
                'animal_weights_superseded_by_same_animal_fk',
            )->references(['id', 'organization_id', 'animal_id'])->on('animal_weights')->restrictOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('animal_weights');
    }
};
