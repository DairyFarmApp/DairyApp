<?php

use App\Domain\AnimalRegistry\Support\DefaultAnimalBreedCatalog;
use App\Models\Organization;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
    public function up(): void
    {
        $catalog = app(DefaultAnimalBreedCatalog::class);
        Organization::query()->eachById(
            fn (Organization $organization) => $catalog->ensureForOrganization($organization),
        );
    }

    public function down(): void
    {
        // Preserve breed rows because animal history may already reference them.
    }
};
