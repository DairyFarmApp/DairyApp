<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('milk_production_slots', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('organization_id')->constrained()->cascadeOnDelete();
            $table->uuid('farm_id');
            $table->uuid('shed_id');
            $table->uuid('animal_id');
            $table->date('production_date');
            $table->string('session', 24);
            $table->unsignedBigInteger('version')->default(1);
            $table->foreignUuid('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();

            $table->unique(
                ['organization_id', 'animal_id', 'production_date', 'session'],
                'milk_slot_animal_date_session_unique',
            );
            $table->unique(
                ['id', 'organization_id', 'farm_id', 'animal_id'],
                'milk_slot_scope_unique',
            );
            $table->index(
                ['organization_id', 'farm_id', 'production_date', 'session'],
                'milk_slot_daily_index',
            );
            $table->foreign(
                ['farm_id', 'organization_id'],
                'milk_slot_farm_fk',
            )->references(['id', 'organization_id'])->on('farms')->restrictOnDelete();
            $table->foreign(
                ['shed_id', 'organization_id', 'farm_id'],
                'milk_slot_shed_fk',
            )->references(['id', 'organization_id', 'farm_id'])->on('sheds')->restrictOnDelete();
            $table->foreign(
                ['animal_id', 'organization_id'],
                'milk_slot_animal_fk',
            )->references(['id', 'organization_id'])->on('animals')->restrictOnDelete();
        });

        Schema::create('milk_entries', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('organization_id')->constrained()->cascadeOnDelete();
            $table->uuid('farm_id');
            $table->uuid('milk_production_slot_id');
            $table->uuid('animal_id');
            $table->unsignedInteger('revision')->default(1);
            $table->decimal('quantity_litres', 18, 3);
            $table->decimal('rejected_quantity_litres', 18, 3)->default(0);
            $table->string('rejection_reason', 255)->nullable();
            $table->text('notes')->nullable();
            $table->string('entry_source', 24)->default('manual');
            $table->boolean('is_current')->default(true);
            $table->uuid('supersedes_entry_id')->nullable();
            $table->uuid('superseded_by_entry_id')->nullable();
            $table->string('correction_reason', 500)->nullable();
            $table->foreignUuid('recorded_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();

            $table->unique(
                ['milk_production_slot_id', 'revision'],
                'milk_entry_slot_revision_unique',
            );
            $table->index(
                ['organization_id', 'farm_id', 'is_current'],
                'milk_entry_current_index',
            );
            $table->foreign(
                ['milk_production_slot_id', 'organization_id', 'farm_id', 'animal_id'],
                'milk_entry_slot_scope_fk',
            )->references(['id', 'organization_id', 'farm_id', 'animal_id'])
                ->on('milk_production_slots')
                ->restrictOnDelete();
            $table->foreign('supersedes_entry_id', 'milk_entry_supersedes_fk')
                ->references('id')->on('milk_entries')->restrictOnDelete();
            $table->foreign('superseded_by_entry_id', 'milk_entry_superseded_by_fk')
                ->references('id')->on('milk_entries')->restrictOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('milk_entries');
        Schema::dropIfExists('milk_production_slots');
    }
};
