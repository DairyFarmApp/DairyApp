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
        Schema::table('health_symptoms', function (Blueprint $table): void {
            $table->string('name_roman_urdu', 200)->nullable()->after('name');
        });
        Schema::table('health_diseases', function (Blueprint $table): void {
            $table->string('name_roman_urdu', 220)->nullable()->after('name');
            $table->text('summary_roman_urdu')->nullable()->after('summary');
            $table->text('immediate_care_roman_urdu')->nullable()->after('immediate_care');
            $table->text('confirmation_guidance_roman_urdu')->nullable()->after('confirmation_guidance');
            $table->text('safe_home_care')->nullable()->after('confirmation_guidance_roman_urdu');
            $table->text('safe_home_care_roman_urdu')->nullable()->after('safe_home_care');
            $table->string('review_status', 24)->default('pending_review')->after('source_reviewed_on');
            $table->uuid('reviewed_by')->nullable()->after('review_status');
            $table->dateTime('reviewed_at')->nullable()->after('reviewed_by');
            $table->unsignedInteger('knowledge_version')->default(1)->after('reviewed_at');
            $table->foreign('reviewed_by', 'health_disease_reviewer_fk')->references('id')->on('users')->nullOnDelete();
        });
        Schema::create('health_knowledge_reviews', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('disease_id');
            $table->string('decision', 24);
            $table->text('reviewer_notes');
            $table->string('reviewer_name', 160);
            $table->string('reviewer_registration', 100);
            $table->uuid('reviewed_by');
            $table->timestamps();
            $table->foreign('disease_id')->references('id')->on('health_diseases')->cascadeOnDelete();
            $table->foreign('reviewed_by')->references('id')->on('users')->restrictOnDelete();
        });
        DB::table('health_diseases')->update(['review_status' => 'approved', 'reviewed_at' => now()]);
        $translations = [
            'fever' => 'Bukhar', 'reduced_appetite' => 'Bhook kam hona', 'reduced_milk' => 'Doodh kam hona', 'mouth_blisters' => 'Munh mein chhalay', 'excess_saliva' => 'Munh se zyada ral', 'foot_lesions' => 'Khur par zakhm', 'skin_nodules' => 'Jild par sakht gaanthain', 'swollen_lymph_nodes' => 'Ghudood ki soojan', 'udder_swelling' => 'Than garam ya soojha hua', 'abnormal_milk' => 'Doodh mein phatkian ya pani', 'breathing_difficulty' => 'Saans mein mushkil', 'nasal_discharge' => 'Naak se pani', 'cough' => 'Khansi', 'neck_swelling' => 'Gardan ki soojan', 'sudden_collapse' => 'Achanak girna ya khara na hona', 'diarrhea' => 'Dast', 'dehydration' => 'Pani ki kami', 'left_bloat' => 'Baen taraf pait phoolna', 'lameness' => 'Langrahat', 'pale_eyelids' => 'Pheeki palkain', 'bottle_jaw' => 'Jabrray ke neechay soojan', 'vaginal_discharge' => 'Badbudar mada', 'retained_placenta' => 'Jer na girna', 'neurologic_signs' => 'Chakkar, andhapan ya doray',
        ];
        foreach ($translations as $code => $text) {
            DB::table('health_symptoms')->where('code', $code)->update(['name_roman_urdu' => $text]);
        }
        foreach (['health.knowledge.review'] as $name) {
            DB::table('permissions')->updateOrInsert(['name' => $name], ['id' => (string) Str::uuid7(), 'created_at' => now(), 'updated_at' => now()]);
        }
        $permission = DB::table('permissions')->where('name', 'health.knowledge.review')->value('id');
        foreach (DB::table('roles')->whereIn('slug', ['organization-owner', 'farm-manager'])->pluck('id') as $role) {
            DB::table('role_permissions')->updateOrInsert(['role_id' => $role, 'permission_id' => $permission], ['created_at' => now(), 'updated_at' => now()]);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('health_knowledge_reviews');
        Schema::table('health_diseases', function (Blueprint $table): void {
            $table->dropForeign('health_disease_reviewer_fk');
            $table->dropColumn(['name_roman_urdu', 'summary_roman_urdu', 'immediate_care_roman_urdu', 'confirmation_guidance_roman_urdu', 'safe_home_care', 'safe_home_care_roman_urdu', 'review_status', 'reviewed_by', 'reviewed_at', 'knowledge_version']);
        });
        Schema::table('health_symptoms', fn (Blueprint $table) => $table->dropColumn('name_roman_urdu'));
        DB::table('permissions')->where('name', 'health.knowledge.review')->delete();
    }
};
