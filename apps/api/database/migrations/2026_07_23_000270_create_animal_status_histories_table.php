<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('animal_status_histories', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('organization_id')->constrained()->cascadeOnDelete();
            $table->uuid('farm_id');
            $table->uuid('animal_id');
            $table->enum('previous_status', ['active', 'inactive', 'missing']);
            $table->enum('new_status', ['active', 'inactive', 'missing']);
            $table->timestamp('effective_at');
            $table->text('reason');
            $table->foreignUuid('changed_by')->constrained('users')->restrictOnDelete();
            $table->unsignedBigInteger('sequence');
            $table->timestamps();

            $table->unique(['id', 'organization_id', 'animal_id'], 'animal_status_histories_id_org_animal_unique');
            $table->unique(
                ['organization_id', 'animal_id', 'sequence'],
                'animal_status_histories_org_animal_sequence_unique',
            );
            $table->index(
                ['organization_id', 'animal_id', 'effective_at'],
                'animal_status_histories_org_animal_effective_index',
            );
            $table->index(
                ['organization_id', 'farm_id', 'updated_at'],
                'animal_status_histories_org_farm_updated_index',
            );

            $table->foreign(['animal_id', 'organization_id'], 'animal_status_histories_animal_tenant_fk')
                ->references(['id', 'organization_id'])->on('animals')->restrictOnDelete();
            $table->foreign(['farm_id', 'organization_id'], 'animal_status_histories_farm_tenant_fk')
                ->references(['id', 'organization_id'])->on('farms')->restrictOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('animal_status_histories');
    }
};
