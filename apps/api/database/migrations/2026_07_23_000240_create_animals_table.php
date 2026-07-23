<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('animals', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('organization_id')->constrained()->cascadeOnDelete();
            $table->string('animal_number', 40);
            $table->string('ear_tag_number', 80)->nullable();
            $table->string('rfid_number', 120)->nullable();
            $table->string('name', 120)->nullable();
            $table->string('registration_number', 120)->nullable();

            $table->uuid('species_id');
            $table->uuid('breed_id');
            $table->string('sex', 12);
            $table->string('life_stage', 20);
            $table->date('date_of_birth')->nullable();
            $table->boolean('is_date_of_birth_estimated')->default(false);
            $table->string('colour', 80)->nullable();
            $table->text('identifying_marks')->nullable();

            $table->uuid('current_farm_id');
            $table->uuid('current_shed_id');
            $table->uuid('current_animal_group_id')->nullable();

            $table->uuid('mother_animal_id')->nullable();
            $table->uuid('father_animal_id')->nullable();
            $table->string('external_sire_reference', 160)->nullable();

            $table->string('origin', 24);
            $table->date('acquisition_date')->nullable();
            $table->string('source_description', 255)->nullable();
            $table->text('notes')->nullable();
            $table->string('operational_status', 20)->default('active');
            $table->unsignedBigInteger('version')->default(1);
            $table->foreignUuid('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignUuid('updated_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignUuid('archived_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('archived_at')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->unique(['organization_id', 'animal_number'], 'animals_org_number_unique');
            $table->unique(['organization_id', 'ear_tag_number'], 'animals_org_ear_tag_unique');
            $table->unique(['organization_id', 'rfid_number'], 'animals_org_rfid_unique');
            $table->unique(['id', 'organization_id'], 'animals_id_org_unique');
            $table->index(['organization_id', 'current_farm_id', 'operational_status'], 'animals_org_farm_status_index');
            $table->index(['organization_id', 'species_id', 'breed_id'], 'animals_org_species_breed_index');
            $table->index(['organization_id', 'life_stage', 'sex'], 'animals_org_stage_sex_index');
            $table->index(['organization_id', 'updated_at'], 'animals_org_updated_index');
            $table->index(['organization_id', 'name']);

            $table->foreign('species_id')->references('id')->on('animal_species')->restrictOnDelete();
            $table->foreign(['breed_id', 'organization_id', 'species_id'], 'animals_breed_tenant_species_fk')
                ->references(['id', 'organization_id', 'species_id'])->on('animal_breeds')->restrictOnDelete();
            $table->foreign(['current_farm_id', 'organization_id'], 'animals_current_farm_fk')
                ->references(['id', 'organization_id'])->on('farms')->restrictOnDelete();
            $table->foreign(['current_shed_id', 'organization_id', 'current_farm_id'], 'animals_current_shed_fk')
                ->references(['id', 'organization_id', 'farm_id'])->on('sheds')->restrictOnDelete();
            $table->foreign(['current_animal_group_id', 'organization_id', 'current_farm_id'], 'animals_current_group_fk')
                ->references(['id', 'organization_id', 'farm_id'])->on('animal_groups')->restrictOnDelete();
            $table->foreign(['mother_animal_id', 'organization_id'], 'animals_mother_tenant_fk')
                ->references(['id', 'organization_id'])->on('animals')->restrictOnDelete();
            $table->foreign(['father_animal_id', 'organization_id'], 'animals_father_tenant_fk')
                ->references(['id', 'organization_id'])->on('animals')->restrictOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('animals');
    }
};
