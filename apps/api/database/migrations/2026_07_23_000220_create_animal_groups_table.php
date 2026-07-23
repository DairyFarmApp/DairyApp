<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('sheds', function (Blueprint $table): void {
            $table->unique(['id', 'organization_id', 'farm_id'], 'sheds_id_org_farm_unique');
        });

        Schema::create('animal_groups', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('organization_id')->constrained()->cascadeOnDelete();
            $table->uuid('farm_id');
            $table->uuid('default_shed_id')->nullable();
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

            $table->unique(['organization_id', 'farm_id', 'code'], 'animal_groups_org_farm_code_unique');
            $table->unique(['organization_id', 'farm_id', 'normalized_name'], 'animal_groups_org_farm_name_unique');
            $table->unique(['id', 'organization_id', 'farm_id'], 'animal_groups_id_org_farm_unique');
            $table->index(['organization_id', 'farm_id', 'is_active', 'name']);
            $table->index(['organization_id', 'updated_at']);
            $table->foreign(['farm_id', 'organization_id'], 'animal_groups_farm_fk')
                ->references(['id', 'organization_id'])->on('farms')->cascadeOnDelete();
            $table->foreign(['default_shed_id', 'organization_id', 'farm_id'], 'animal_groups_default_shed_fk')
                ->references(['id', 'organization_id', 'farm_id'])->on('sheds')->restrictOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('animal_groups');

        Schema::table('sheds', function (Blueprint $table): void {
            $table->dropUnique('sheds_id_org_farm_unique');
        });
    }
};
