<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('health_disease_medicine_evidence', function (Blueprint $table): void {
            $table->string('brand_name', 180)->nullable()->after('active_ingredient');
            $table->string('manufacturer', 180)->nullable()->after('brand_name');
            $table->string('dosage_form', 120)->nullable()->after('manufacturer');
            $table->string('drap_registration_number', 100)->nullable()->after('dosage_form');
            $table->string('drap_registry_url', 1000)->nullable()->after('drap_registration_number');
            $table->date('drap_verified_on')->nullable()->after('drap_registry_url');
            $table->string('species_scope', 255)->nullable()->after('indication');
            $table->string('reviewer_name', 160)->nullable()->after('reviewed_by');
            $table->string('reviewer_registration', 100)->nullable()->after('reviewer_name');
            $table->text('review_notes')->nullable()->after('reviewer_registration');
            $table->unsignedInteger('review_version')->default(1)->after('reviewed_at');
            $table->unique(['disease_id', 'drap_registration_number'], 'health_med_evidence_disease_drap_unique');
            $table->foreign('reviewed_by', 'health_med_evidence_reviewer_fk')->references('id')->on('users')->nullOnDelete();
        });
        Schema::create('health_medicine_evidence_reviews', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('medicine_evidence_id');
            $table->string('decision', 24);
            $table->text('reviewer_notes');
            $table->string('reviewer_name', 160);
            $table->string('reviewer_registration', 100);
            $table->uuid('reviewed_by');
            $table->timestamps();
            $table->foreign('medicine_evidence_id')->references('id')->on('health_disease_medicine_evidence')->cascadeOnDelete();
            $table->foreign('reviewed_by')->references('id')->on('users')->restrictOnDelete();
        });
        foreach (['health.medicine_evidence.manage', 'health.medicine_evidence.review'] as $permission) {
            DB::table('permissions')->updateOrInsert(['name' => $permission], ['id' => (string) Str::uuid7(), 'created_at' => now(), 'updated_at' => now()]);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('health_medicine_evidence_reviews');
        Schema::table('health_disease_medicine_evidence', function (Blueprint $table): void {
            $table->dropForeign('health_med_evidence_reviewer_fk');
            $table->index('disease_id', 'health_med_evidence_disease_fk_idx');
            $table->dropUnique('health_med_evidence_disease_drap_unique');
            $table->dropColumn(['brand_name', 'manufacturer', 'dosage_form', 'drap_registration_number', 'drap_registry_url', 'drap_verified_on', 'species_scope', 'reviewer_name', 'reviewer_registration', 'review_notes', 'review_version']);
        });
        DB::table('permissions')->whereIn('name', ['health.medicine_evidence.manage', 'health.medicine_evidence.review'])->delete();
    }
};
