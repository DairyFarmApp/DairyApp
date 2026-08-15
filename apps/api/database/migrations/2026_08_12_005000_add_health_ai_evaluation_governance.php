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
        Schema::table('health_ai_evaluation_cases', function (Blueprint $table): void {
            $table->uuid('reviewed_by')->nullable()->after('review_status');
            $table->string('reviewer_name', 160)->nullable()->after('reviewed_by');
            $table->string('reviewer_registration', 100)->nullable()->after('reviewer_name');
            $table->dateTime('reviewed_at')->nullable()->after('reviewer_registration');
            $table->unsignedInteger('review_version')->default(1)->after('reviewed_at');
            $table->foreign('reviewed_by', 'health_ai_evaluation_reviewer_fk')->references('id')->on('users')->nullOnDelete();
        });

        Schema::create('health_ai_evaluation_reviews', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('evaluation_case_id');
            $table->string('decision', 24);
            $table->text('reviewer_notes');
            $table->string('reviewer_name', 160);
            $table->string('reviewer_registration', 100);
            $table->uuid('reviewed_by');
            $table->timestamps();
            $table->index(['evaluation_case_id', 'created_at'], 'health_ai_eval_review_history_idx');
            $table->foreign('evaluation_case_id')->references('id')->on('health_ai_evaluation_cases')->cascadeOnDelete();
            $table->foreign('reviewed_by')->references('id')->on('users')->restrictOnDelete();
        });

        DB::table('health_ai_evaluation_cases')->where('review_status', 'approved')->update([
            'review_notes' => DB::raw("CONCAT(COALESCE(review_notes, ''), ' Legacy seeded approval; accountable veterinary re-signing is required before production release.')"),
        ]);
        DB::table('permissions')->updateOrInsert(['name' => 'health.ai.review'], [
            'id' => (string) Str::uuid7(), 'created_at' => now(), 'updated_at' => now(),
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('health_ai_evaluation_reviews');
        Schema::table('health_ai_evaluation_cases', function (Blueprint $table): void {
            $table->dropForeign('health_ai_evaluation_reviewer_fk');
            $table->dropColumn(['reviewed_by', 'reviewer_name', 'reviewer_registration', 'reviewed_at', 'review_version']);
        });
        DB::table('permissions')->where('name', 'health.ai.review')->delete();
    }
};
