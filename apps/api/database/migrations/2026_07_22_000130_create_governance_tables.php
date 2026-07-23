<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('audit_logs', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('organization_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignUuid('user_id')->nullable()->constrained()->nullOnDelete();
            $table->string('action', 120)->index();
            $table->string('entity_type', 120)->nullable();
            $table->uuid('entity_id')->nullable();
            $table->json('old_values')->nullable();
            $table->json('new_values')->nullable();
            $table->uuid('request_id')->nullable()->index();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->timestamp('created_at')->useCurrent();
            $table->index(['organization_id', 'created_at']);
            $table->index(['entity_type', 'entity_id']);
        });

        Schema::create('idempotency_records', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('organization_id')->constrained()->cascadeOnDelete();
            $table->foreignUuid('user_id')->nullable()->constrained()->nullOnDelete();
            $table->uuid('device_id')->nullable();
            $table->char('scope_key', 64)->unique();
            $table->string('endpoint', 255);
            $table->string('method', 10);
            $table->string('idempotency_key', 160);
            $table->char('request_fingerprint', 64);
            $table->string('status', 20)->default('processing');
            $table->unsignedSmallInteger('response_status')->nullable();
            $table->json('response_body')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();
        });

        Schema::create('settings', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('organization_id')->constrained()->cascadeOnDelete();
            $table->uuid('farm_id')->nullable();
            $table->string('key', 120);
            $table->string('type', 24);
            $table->json('value');
            $table->char('scope_key', 64)->unique();
            $table->timestamps();
            $table->foreign(['farm_id', 'organization_id'], 'settings_farm_fk')->references(['id', 'organization_id'])->on('farms')->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('settings');
        Schema::dropIfExists('idempotency_records');
        Schema::dropIfExists('audit_logs');
    }
};
