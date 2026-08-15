<?php

use App\Domain\AnimalRegistry\Support\DefaultAnimalBreedCatalog;
use App\Models\Organization;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('animals', function (Blueprint $table): void {
            $table->boolean('photo_requirement_exempt')->default(true)->after('operational_status');
        });

        Schema::create('animal_photos', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('animal_id');
            $table->string('storage_path', 500);
            $table->string('original_name', 255);
            $table->string('mime_type', 100);
            $table->unsignedBigInteger('size_bytes');
            $table->unsignedSmallInteger('sort_order');
            $table->uuid('uploaded_by');
            $table->timestamps();

            $table->unique(['animal_id', 'sort_order']);
            $table->foreign(['animal_id', 'organization_id'], 'animal_photos_animal_scope_fk')
                ->references(['id', 'organization_id'])->on('animals')->cascadeOnDelete();
            $table->foreign('uploaded_by')->references('id')->on('users')->restrictOnDelete();
            $table->index(['organization_id', 'animal_id']);
        });

        Organization::query()->each(
            fn (Organization $organization) => app(DefaultAnimalBreedCatalog::class)
                ->ensureForOrganization($organization),
        );
    }

    public function down(): void
    {
        Schema::dropIfExists('animal_photos');
        Schema::table('animals', fn (Blueprint $table) => $table->dropColumn('photo_requirement_exempt'));
    }
};
