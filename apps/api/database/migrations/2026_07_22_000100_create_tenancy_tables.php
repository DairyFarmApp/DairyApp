<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('organizations', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->string('name');
            $table->string('timezone')->default('UTC');
            $table->string('locale', 10)->default('en');
            $table->unsignedBigInteger('version')->default(1);
            $table->timestamps();
            $table->softDeletes();
        });

        Schema::create('organization_memberships', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('organization_id')->constrained()->cascadeOnDelete();
            $table->foreignUuid('user_id')->constrained()->cascadeOnDelete();
            $table->string('status', 24)->default('active');
            $table->boolean('all_farms')->default(false);
            $table->timestamps();
            $table->unique(['organization_id', 'user_id']);
            $table->unique(['id', 'organization_id']);
            $table->unique(['user_id', 'organization_id']);
            $table->index(['user_id', 'status']);
        });

        Schema::create('farms', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('organization_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('code', 40);
            $table->string('timezone')->default('UTC');
            $table->unsignedBigInteger('version')->default(1);
            $table->timestamps();
            $table->softDeletes();
            $table->unique(['organization_id', 'code']);
            $table->unique(['id', 'organization_id']);
            $table->index(['organization_id', 'name']);
        });

        Schema::create('sheds', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('organization_id')->constrained()->cascadeOnDelete();
            $table->uuid('farm_id');
            $table->string('name');
            $table->string('code', 40);
            $table->unsignedBigInteger('version')->default(1);
            $table->timestamps();
            $table->softDeletes();
            $table->unique(['farm_id', 'code']);
            $table->index(['organization_id', 'farm_id', 'name']);
            $table->foreign(['farm_id', 'organization_id'])->references(['id', 'organization_id'])->on('farms')->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sheds');
        Schema::dropIfExists('farms');
        Schema::dropIfExists('organization_memberships');
        Schema::dropIfExists('organizations');
    }
};
