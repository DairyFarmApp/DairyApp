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
        Schema::create('health_symptoms', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->string('code', 80)->unique();
            $table->string('name', 160);
            $table->string('body_system', 80);
            $table->boolean('is_emergency')->default(false);
            $table->string('emergency_message')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
        Schema::create('health_diseases', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->string('code', 80)->unique();
            $table->string('name', 180);
            $table->json('species');
            $table->text('summary');
            $table->text('immediate_care');
            $table->text('confirmation_guidance');
            $table->string('urgency', 24)->default('routine');
            $table->string('source_title');
            $table->text('source_url');
            $table->date('source_reviewed_on');
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
        Schema::create('health_disease_symptom', function (Blueprint $table): void {
            $table->uuid('disease_id');
            $table->uuid('symptom_id');
            $table->unsignedTinyInteger('weight')->default(1);
            $table->boolean('is_key')->default(false);
            $table->primary(['disease_id', 'symptom_id']);
            $table->foreign('disease_id')->references('id')->on('health_diseases')->cascadeOnDelete();
            $table->foreign('symptom_id')->references('id')->on('health_symptoms')->cascadeOnDelete();
        });
        Schema::create('animal_health_cases', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->uuid('animal_id');
            $table->string('case_number', 40);
            $table->dateTime('reported_at');
            $table->string('severity', 24);
            $table->decimal('temperature_c', 5, 2)->nullable();
            $table->string('status', 24)->default('open');
            $table->uuid('top_disease_id')->nullable();
            $table->decimal('top_score', 5, 2)->nullable();
            $table->boolean('emergency')->default(false);
            $table->text('emergency_message')->nullable();
            $table->text('notes')->nullable();
            $table->uuid('created_by');
            $table->unsignedBigInteger('version')->default(1);
            $table->timestamps();
            $table->unique(['organization_id', 'case_number']);
            $table->index(['organization_id', 'farm_id', 'animal_id', 'reported_at'], 'health_cases_scope_idx');
            $table->foreign('organization_id')->references('id')->on('organizations')->cascadeOnDelete();
            $table->foreign(['farm_id', 'organization_id'])->references(['id', 'organization_id'])->on('farms')->restrictOnDelete();
            $table->foreign(['animal_id', 'organization_id'])->references(['id', 'organization_id'])->on('animals')->restrictOnDelete();
            $table->foreign('top_disease_id')->references('id')->on('health_diseases')->nullOnDelete();
            $table->foreign('created_by')->references('id')->on('users')->restrictOnDelete();
        });
        Schema::create('animal_health_case_symptoms', function (Blueprint $table): void {
            $table->uuid('health_case_id');
            $table->uuid('symptom_id');
            $table->string('presence', 16)->default('present');
            $table->string('severity', 16)->default('moderate');
            $table->primary(['health_case_id', 'symptom_id']);
            $table->foreign('health_case_id')->references('id')->on('animal_health_cases')->cascadeOnDelete();
            $table->foreign('symptom_id')->references('id')->on('health_symptoms')->restrictOnDelete();
        });
        Schema::create('animal_health_differentials', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('health_case_id');
            $table->uuid('disease_id');
            $table->decimal('score', 5, 2);
            $table->json('matched_symptoms');
            $table->json('missing_key_symptoms');
            $table->unsignedTinyInteger('rank');
            $table->timestamps();
            $table->unique(['health_case_id', 'disease_id']);
            $table->foreign('health_case_id')->references('id')->on('animal_health_cases')->cascadeOnDelete();
            $table->foreign('disease_id')->references('id')->on('health_diseases')->restrictOnDelete();
        });

        $now = now();
        foreach (['health.view', 'health.assess', 'health.manage'] as $name) {
            DB::table('permissions')->updateOrInsert(['name' => $name], ['id' => (string) Str::uuid7(), 'created_at' => $now, 'updated_at' => $now]);
        }
        $permissionIds = DB::table('permissions')->whereIn('name', ['health.view', 'health.assess', 'health.manage'])->pluck('id');
        DB::table('roles')->whereIn('slug', ['organization-owner', 'farm-manager'])->pluck('id')->each(function ($roleId) use ($permissionIds): void {
            foreach ($permissionIds as $permissionId) {
                DB::table('permission_role')->updateOrInsert(['role_id' => $roleId, 'permission_id' => $permissionId]);
            }
        });

        $this->seedKnowledge($now);
    }

    private function seedKnowledge($now): void
    {
        $symptoms = [
            ['fever', 'Fever', 'general', false], ['reduced_appetite', 'Reduced appetite', 'general', false], ['reduced_milk', 'Reduced milk production', 'production', false],
            ['mouth_blisters', 'Mouth blisters/erosions', 'oral', true], ['excess_saliva', 'Excessive salivation', 'oral', false], ['foot_lesions', 'Foot/hoof lesions', 'musculoskeletal', false],
            ['skin_nodules', 'Firm skin nodules', 'skin', false], ['swollen_lymph_nodes', 'Swollen lymph nodes', 'general', false], ['udder_swelling', 'Hot or swollen udder', 'udder', false],
            ['abnormal_milk', 'Clots/flakes/watery milk', 'udder', false], ['breathing_difficulty', 'Difficulty breathing', 'respiratory', true], ['nasal_discharge', 'Nasal discharge', 'respiratory', false],
            ['cough', 'Cough', 'respiratory', false], ['neck_swelling', 'Throat/neck swelling', 'general', true], ['sudden_collapse', 'Sudden collapse or unable to stand', 'general', true],
            ['diarrhea', 'Diarrhea', 'digestive', false], ['dehydration', 'Dehydration/sunken eyes', 'digestive', true], ['left_bloat', 'Distended left abdomen', 'digestive', true],
            ['lameness', 'Lameness', 'musculoskeletal', false], ['pale_eyelids', 'Pale eyelids/anemia', 'general', false], ['bottle_jaw', 'Swelling under jaw', 'general', false],
            ['vaginal_discharge', 'Foul vaginal discharge', 'reproductive', false], ['retained_placenta', 'Placenta retained after calving', 'reproductive', false], ['neurologic_signs', 'Circling, blindness, seizures or head pressing', 'neurologic', true],
        ];
        $symptomIds = [];
        foreach ($symptoms as [$code,$name,$system,$emergency]) {
            $id = (string) Str::uuid7();
            $symptomIds[$code] = $id;
            DB::table('health_symptoms')->insert(['id' => $id, 'code' => $code, 'name' => $name, 'body_system' => $system, 'is_emergency' => $emergency, 'emergency_message' => $emergency ? 'Urgent veterinary assessment is required.' : null, 'is_active' => true, 'created_at' => $now, 'updated_at' => $now]);
        }
        $woah = 'https://www.woah.org/en/what-we-do/animal-health-and-welfare/animal-diseases/';
        $merck = 'https://www.merckvetmanual.com/';
        $uvas = 'https://www.uvas.edu.pk/doc/advisory_services/handbook/BackgroundingManual.pdf';
        $diseases = [
            ['fmd', 'Foot-and-mouth disease', ['cattle', 'buffalo', 'goat'], 'Highly contagious vesicular disease. Isolate and contact a veterinarian/authority immediately.', 'Isolate, stop animal movement, use separate equipment, and withhold milk pending veterinary direction.', 'Clinical examination plus official laboratory confirmation is required.', 'emergency', 'UVAS Backgrounding Manual', $uvas, [['fever', 2], ['mouth_blisters', 5], ['excess_saliva', 4], ['foot_lesions', 4], ['lameness', 2], ['reduced_milk', 1]]],
            ['lsd', 'Lumpy skin disease', ['cattle', 'buffalo'], 'Viral disease characterized by fever and firm skin nodules.', 'Isolate, control biting insects, provide shade, water and soft feed; seek veterinary care.', 'Veterinary examination and laboratory confirmation where required.', 'same_day', 'WOAH disease information', $woah, [['fever', 2], ['skin_nodules', 5], ['swollen_lymph_nodes', 3], ['reduced_milk', 2], ['reduced_appetite', 1]]],
            ['mastitis', 'Mastitis', ['cattle', 'buffalo', 'goat'], 'Inflammation/infection of the udder that changes milk and may cause systemic illness.', 'Milk the affected quarter hygienically into a separate container; do not mix or sell abnormal milk.', 'Udder exam, strip-cup/CMT and milk culture before antimicrobial selection when possible.', 'same_day', 'Merck Veterinary Manual', $merck, [['udder_swelling', 5], ['abnormal_milk', 5], ['reduced_milk', 2], ['fever', 2], ['reduced_appetite', 1]]],
            ['hs', 'Hemorrhagic septicemia', ['cattle', 'buffalo'], 'Rapid severe bacterial disease, especially in cattle and buffalo during humid weather.', 'Isolate and obtain emergency veterinary care; minimize handling and heat stress.', 'Immediate veterinary examination and appropriate samples.', 'emergency', 'UVAS Backgrounding Manual', $uvas, [['fever', 3], ['neck_swelling', 5], ['breathing_difficulty', 5], ['nasal_discharge', 2], ['sudden_collapse', 4]]],
            ['pneumonia', 'Pneumonia', ['cattle', 'buffalo', 'goat'], 'Respiratory disease with several infectious and noninfectious causes.', 'Isolate, improve ventilation without chilling, provide water, and seek same-day assessment.', 'Chest examination; temperature and diagnostic sampling based on severity.', 'same_day', 'Merck Veterinary Manual', $merck, [['fever', 2], ['cough', 4], ['nasal_discharge', 3], ['breathing_difficulty', 5], ['reduced_appetite', 1]]],
            ['bloat', 'Ruminal bloat', ['cattle', 'buffalo', 'goat'], 'Gas distension of the rumen that can rapidly impair breathing.', 'Remove feed and call a veterinarian immediately; do not force liquids into a distressed animal.', 'Urgent clinical examination to distinguish frothy from free-gas bloat.', 'emergency', 'Merck Veterinary Manual', $merck, [['left_bloat', 5], ['breathing_difficulty', 4], ['reduced_appetite', 1], ['sudden_collapse', 3]]],
            ['gastroenteritis', 'Diarrhea/dehydration syndrome', ['cattle', 'buffalo', 'goat'], 'Diarrhea has infectious, parasitic, nutritional and toxic causes.', 'Isolate, offer clean water/electrolytes if safely swallowing, keep warm and clean.', 'Age-specific exam, hydration assessment and fecal testing as indicated.', 'same_day', 'Merck Veterinary Manual', $merck, [['diarrhea', 5], ['dehydration', 4], ['reduced_appetite', 2], ['fever', 1]]],
            ['foot_rot', 'Foot rot', ['cattle', 'buffalo', 'goat'], 'Painful bacterial infection of tissues between the claws.', 'Move to a clean dry area, inspect without aggressive cutting, and seek veterinary treatment.', 'Hoof examination to distinguish injury, sole disease and FMD lesions.', 'same_day', 'Merck Veterinary Manual', $merck, [['lameness', 4], ['foot_lesions', 4], ['fever', 1], ['reduced_appetite', 1]]],
            ['parasites', 'Gastrointestinal parasites', ['cattle', 'buffalo', 'goat'], 'Parasites may cause anemia, poor growth, diarrhea and production loss.', 'Provide good nutrition and clean water; avoid blind repeated deworming.', 'Fecal egg count and anemia assessment; resistance-aware treatment plan.', 'routine', 'Merck Veterinary Manual', $merck, [['pale_eyelids', 5], ['bottle_jaw', 4], ['diarrhea', 2], ['reduced_appetite', 1], ['reduced_milk', 1]]],
            ['metritis', 'Post-calving metritis', ['cattle', 'buffalo', 'goat'], 'Uterine infection after calving, commonly associated with foul discharge and illness.', 'Keep the animal clean, hydrated and separated for observation; arrange same-day veterinary care.', 'Reproductive examination and systemic assessment after calving.', 'same_day', 'Merck Veterinary Manual', $merck, [['vaginal_discharge', 5], ['retained_placenta', 3], ['fever', 2], ['reduced_appetite', 2], ['reduced_milk', 1]]],
        ];
        foreach ($diseases as [$code,$name,$species,$summary,$care,$confirm,$urgency,$source,$url,$links]) {
            $id = (string) Str::uuid7();
            DB::table('health_diseases')->insert(['id' => $id, 'code' => $code, 'name' => $name, 'species' => json_encode($species), 'summary' => $summary, 'immediate_care' => $care, 'confirmation_guidance' => $confirm, 'urgency' => $urgency, 'source_title' => $source, 'source_url' => $url, 'source_reviewed_on' => '2026-08-12', 'is_active' => true, 'created_at' => $now, 'updated_at' => $now]);
            foreach ($links as [$symptom,$weight]) {
                DB::table('health_disease_symptom')->insert(['disease_id' => $id, 'symptom_id' => $symptomIds[$symptom], 'weight' => $weight, 'is_key' => $weight >= 4]);
            }
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('animal_health_differentials');
        Schema::dropIfExists('animal_health_case_symptoms');
        Schema::dropIfExists('animal_health_cases');
        Schema::dropIfExists('health_disease_symptom');
        Schema::dropIfExists('health_diseases');
        Schema::dropIfExists('health_symptoms');
        DB::table('permissions')->whereIn('name', ['health.view', 'health.assess', 'health.manage'])->delete();
    }
};
