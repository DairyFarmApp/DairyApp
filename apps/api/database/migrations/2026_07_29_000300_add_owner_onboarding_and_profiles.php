<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table): void {
            $table->string('phone_number', 40)->nullable()->after('email');
            $table->string('profile_photo_path', 500)->nullable()->after('password');
        });

        Schema::table('organization_memberships', function (Blueprint $table): void {
            $table->string('membership_type', 24)->default('member')->after('status')->index();
            $table->uuid('invited_by_membership_id')->nullable()->after('all_farms');
            $table->foreign(
                ['invited_by_membership_id', 'organization_id'],
                'membership_inviter_organization_fk',
            )->references(['id', 'organization_id'])
                ->on('organization_memberships')
                ->restrictOnDelete();
        });

        Schema::create('farm_invite_links', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->uuid('created_by_membership_id');
            $table->char('token_hash', 64)->unique();
            $table->text('token_ciphertext');
            $table->boolean('is_enabled')->default(true)->index();
            $table->unsignedInteger('generation')->default(1);
            $table->timestamps();

            $table->unique('organization_id');
            $table->foreign('organization_id')->references('id')->on('organizations')->cascadeOnDelete();
            $table->foreign(
                ['farm_id', 'organization_id'],
                'farm_invite_link_farm_fk',
            )->references(['id', 'organization_id'])
                ->on('farms')
                ->cascadeOnDelete();
            $table->foreign(
                ['created_by_membership_id', 'organization_id'],
                'farm_invite_link_creator_fk',
            )->references(['id', 'organization_id'])
                ->on('organization_memberships')
                ->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('farm_invite_links');

        Schema::table('organization_memberships', function (Blueprint $table): void {
            $table->dropForeign('membership_inviter_organization_fk');
            $table->dropColumn(['membership_type', 'invited_by_membership_id']);
        });

        Schema::table('users', function (Blueprint $table): void {
            $table->dropColumn(['phone_number', 'profile_photo_path']);
        });
    }
};
