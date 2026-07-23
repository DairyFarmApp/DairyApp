<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('api_sessions', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained()->cascadeOnDelete();
            $table->uuid('organization_id')->nullable();
            $table->uuid('farm_id')->nullable();
            $table->char('access_token_hash', 64)->unique();
            $table->char('renewal_token_hash', 64)->unique();
            $table->timestamp('access_expires_at')->index();
            $table->timestamp('renewal_expires_at')->index();
            $table->timestamp('last_used_at')->nullable();
            $table->timestamp('revoked_at')->nullable()->index();
            $table->timestamp('renewal_reuse_detected_at')->nullable()->index();
            $table->string('device_name')->nullable();
            $table->uuid('device_id')->nullable()->index();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->timestamps();
            $table->index(['user_id', 'revoked_at']);
            $table->foreign(['user_id', 'organization_id'], 'api_sessions_membership_fk')->references(['user_id', 'organization_id'])->on('organization_memberships')->cascadeOnDelete();
            $table->foreign(['farm_id', 'organization_id'], 'api_sessions_farm_fk')->references(['id', 'organization_id'])->on('farms')->nullOnDelete();
        });

        Schema::create('api_session_renewal_tokens', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('api_session_id')->constrained()->cascadeOnDelete();
            $table->char('token_hash', 64)->unique();
            $table->timestamp('expires_at')->index();
            $table->timestamp('consumed_at')->nullable()->index();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('api_session_renewal_tokens');
        Schema::dropIfExists('api_sessions');
    }
};
