<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('animal_movements', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('organization_id')->constrained()->cascadeOnDelete();
            $table->uuid('animal_id');

            $table->uuid('source_farm_id');
            $table->uuid('source_shed_id');
            $table->uuid('source_animal_group_id')->nullable();
            $table->uuid('destination_farm_id');
            $table->uuid('destination_shed_id');
            $table->uuid('destination_animal_group_id')->nullable();

            $table->timestamp('requested_effective_at');
            $table->timestamp('actual_effective_at')->nullable();
            $table->string('reason', 255);
            $table->text('notes')->nullable();
            $table->enum('status', ['pending', 'approved', 'rejected', 'cancelled'])->default('pending');
            $table->boolean('approval_required')->default(true);
            $table->foreignUuid('requested_by')->constrained('users')->restrictOnDelete();
            $table->foreignUuid('decided_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('decision_at')->nullable();
            $table->text('rejection_reason')->nullable();
            $table->text('cancellation_reason')->nullable();
            $table->unsignedBigInteger('version')->default(1);
            $table->timestamps();

            $table->unique(['id', 'organization_id'], 'animal_movements_id_org_unique');
            $table->index(
                ['organization_id', 'animal_id', 'status', 'requested_effective_at'],
                'animal_movements_org_animal_status_index',
            );
            $table->index(
                ['organization_id', 'source_farm_id', 'destination_farm_id', 'status'],
                'animal_movements_org_farms_status_index',
            );
            $table->index(['organization_id', 'updated_at'], 'animal_movements_org_updated_index');

            $table->foreign(['animal_id', 'organization_id'], 'animal_movements_animal_tenant_fk')
                ->references(['id', 'organization_id'])->on('animals')->restrictOnDelete();
            $table->foreign(['source_farm_id', 'organization_id'], 'animal_movements_source_farm_fk')
                ->references(['id', 'organization_id'])->on('farms')->restrictOnDelete();
            $table->foreign(
                ['source_shed_id', 'organization_id', 'source_farm_id'],
                'animal_movements_source_shed_fk',
            )->references(['id', 'organization_id', 'farm_id'])->on('sheds')->restrictOnDelete();
            $table->foreign(
                ['source_animal_group_id', 'organization_id', 'source_farm_id'],
                'animal_movements_source_group_fk',
            )->references(['id', 'organization_id', 'farm_id'])->on('animal_groups')->restrictOnDelete();
            $table->foreign(['destination_farm_id', 'organization_id'], 'animal_movements_destination_farm_fk')
                ->references(['id', 'organization_id'])->on('farms')->restrictOnDelete();
            $table->foreign(
                ['destination_shed_id', 'organization_id', 'destination_farm_id'],
                'animal_movements_destination_shed_fk',
            )->references(['id', 'organization_id', 'farm_id'])->on('sheds')->restrictOnDelete();
            $table->foreign(
                ['destination_animal_group_id', 'organization_id', 'destination_farm_id'],
                'animal_movements_destination_group_fk',
            )->references(['id', 'organization_id', 'farm_id'])->on('animal_groups')->restrictOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('animal_movements');
    }
};
