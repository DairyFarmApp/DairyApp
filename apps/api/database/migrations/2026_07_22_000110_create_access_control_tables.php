<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('roles', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('organization_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('slug', 80);
            $table->boolean('is_system')->default(false);
            $table->timestamps();
            $table->unique(['organization_id', 'slug']);
            $table->unique(['id', 'organization_id']);
        });

        Schema::create('permissions', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->string('name', 120)->unique();
            $table->string('description')->nullable();
            $table->timestamps();
        });

        Schema::create('membership_role', function (Blueprint $table): void {
            $table->uuid('organization_id');
            $table->uuid('organization_membership_id');
            $table->uuid('role_id');
            $table->primary(['organization_membership_id', 'role_id']);
            $table->foreign(['organization_membership_id', 'organization_id'], 'membership_role_membership_fk')->references(['id', 'organization_id'])->on('organization_memberships')->cascadeOnDelete();
            $table->foreign(['role_id', 'organization_id'], 'membership_role_role_fk')->references(['id', 'organization_id'])->on('roles')->cascadeOnDelete();
        });

        Schema::create('permission_role', function (Blueprint $table): void {
            $table->foreignUuid('role_id')->constrained()->cascadeOnDelete();
            $table->foreignUuid('permission_id')->constrained()->cascadeOnDelete();
            $table->primary(['role_id', 'permission_id']);
        });

        Schema::create('user_farm_access', function (Blueprint $table): void {
            $table->uuid('organization_id');
            $table->uuid('organization_membership_id');
            $table->uuid('farm_id');
            $table->primary(['organization_membership_id', 'farm_id']);
            $table->foreign(['organization_membership_id', 'organization_id'], 'user_farm_access_membership_fk')->references(['id', 'organization_id'])->on('organization_memberships')->cascadeOnDelete();
            $table->foreign(['farm_id', 'organization_id'], 'user_farm_access_farm_fk')->references(['id', 'organization_id'])->on('farms')->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_farm_access');
        Schema::dropIfExists('permission_role');
        Schema::dropIfExists('membership_role');
        Schema::dropIfExists('permissions');
        Schema::dropIfExists('roles');
    }
};
