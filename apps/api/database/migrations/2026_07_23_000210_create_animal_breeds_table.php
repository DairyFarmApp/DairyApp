<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('animal_breeds', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('organization_id')->constrained()->cascadeOnDelete();
            $table->foreignUuid('species_id')->constrained('animal_species')->restrictOnDelete();
            $table->string('code', 40);
            $table->string('name', 120);
            $table->string('normalized_name', 120);
            $table->text('description')->nullable();
            $table->boolean('is_active')->default(true);
            $table->unsignedBigInteger('version')->default(1);
            $table->foreignUuid('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignUuid('updated_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignUuid('archived_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('archived_at')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->unique(['organization_id', 'species_id', 'code'], 'animal_breeds_org_species_code_unique');
            $table->unique(['organization_id', 'species_id', 'normalized_name'], 'animal_breeds_org_species_name_unique');
            $table->unique(['id', 'organization_id', 'species_id'], 'animal_breeds_id_org_species_unique');
            $table->index(['organization_id', 'is_active', 'name']);
            $table->index(['organization_id', 'updated_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('animal_breeds');
    }
};
