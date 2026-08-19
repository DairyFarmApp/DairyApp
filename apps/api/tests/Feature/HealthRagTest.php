<?php

namespace Tests\Feature;

use App\Domain\AnimalRegistry\Models\Animal;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class HealthRagTest extends TestCase
{
    use CreatesFoundationData,RefreshDatabase;

    public function test_selected_animal_is_linked_to_the_ai_context(): void
    {
        $foundation = $this->foundation(['health.view']);
        $references = $this->animalRegistryReferences($foundation);
        $animal = Animal::query()->create([
            'organization_id' => $foundation['organization']->id,
            'animal_number' => 'DC-000123',
            'name' => 'Noor',
            'species_id' => $references['species']->id,
            'breed_id' => $references['breed']->id,
            'sex' => 'female',
            'life_stage' => 'adult',
            'current_farm_id' => $foundation['farm']->id,
            'current_shed_id' => $foundation['shed']->id,
            'origin' => 'born_on_farm',
            'operational_status' => 'active',
            'created_by' => $foundation['user']->id,
            'updated_by' => $foundation['user']->id,
        ]);
        $headers = $this->bearer($this->loginToken());
        config(['services.health_ai.enabled' => false]);

        $this->postJson('/api/v1/health/ai/ask', [
            'question' => 'Noor has fever, what should I check?',
            'species' => 'cattle',
            'animal_id' => $animal->id,
            'symptom_codes' => [],
            'language' => 'both',
        ], $headers)
            ->assertOk()
            ->assertJsonPath('data.animal_context.animal.id', $animal->id)
            ->assertJsonPath('data.animal_context.animal.number', 'DC-000123')
            ->assertJsonPath('data.animal_context.animal.name', 'Noor')
            ->assertJsonCount(0, 'data.animal_context.recent_cases')
            ->assertJsonCount(0, 'data.animal_context.recent_treatments');
    }

    public function test_deterministic_rag_is_species_scoped_cited_and_emergency_safe(): void
    {
        $this->foundation(['health.view']);
        $h = $this->bearer($this->loginToken());
        config(['services.health_ai.enabled' => false]);
        $r = $this->postJson('/api/v1/health/ai/ask', ['question' => 'Mouth blisters and too much saliva, what should I do?', 'species' => 'cattle', 'symptom_codes' => ['mouth_blisters', 'excess_saliva'], 'language' => 'both'], $h)->assertOk()->assertJsonPath('data.mode', 'deterministic')->assertJsonPath('data.emergency', true)->assertJsonPath('data.matches.0.code', 'fmd')->assertJsonStructure(['data' => ['answer', 'answer_roman_urdu', 'safety_notice', 'matches' => [['source' => ['title', 'url', 'reviewed_on']]]]]);
        $this->assertDatabaseHas('audit_logs', ['action' => 'health_ai.question_answered']);
    }

    public function test_distinctive_fmd_pattern_suppresses_weak_partial_alternatives(): void
    {
        $this->foundation(['health.view']);
        $headers = $this->bearer($this->loginToken());
        config(['services.health_ai.enabled' => false]);

        $this->postJson('/api/v1/health/ai/ask', [
            'question' => 'Meri gai ko bukhar hai, munh mein chalay hain, bohat ral aa rahi hai aur khuron par zakhm hain.',
            'species' => 'cattle',
            'symptom_codes' => [],
            'language' => 'both',
        ], $headers)
            ->assertOk()
            ->assertJsonPath('data.matches.0.code', 'fmd')
            ->assertJsonCount(1, 'data.matches');
    }

    public function test_roman_urdu_free_text_infers_approved_fmd_symptoms_without_checkboxes(): void
    {
        $this->foundation(['health.view']);
        $headers = $this->bearer($this->loginToken());
        config(['services.health_ai.enabled' => false]);

        $this->postJson('/api/v1/health/ai/ask', [
            'question' => 'Meri gai ke munh mein chalay hain, bohat ral aa rahi hai aur khuron par zakhm hain. Kya karun?',
            'species' => 'cattle',
            'symptom_codes' => [],
            'language' => 'both',
        ], $headers)
            ->assertOk()
            ->assertJsonPath('data.matches.0.code', 'fmd')
            ->assertJsonPath('data.emergency', true);
    }

    public function test_single_general_symptom_requests_details_instead_of_claiming_emergency_disease(): void
    {
        $this->foundation(['health.view']);
        $headers = $this->bearer($this->loginToken());
        config(['services.health_ai.enabled' => true]);

        $this->postJson('/api/v1/health/ai/ask', [
            'question' => 'meri gai ko bukhar ha',
            'species' => 'cattle',
            'symptom_codes' => [],
            'language' => 'both',
        ], $headers)
            ->assertOk()
            ->assertJsonPath('data.mode', 'clarification')
            ->assertJsonPath('data.emergency', false)
            ->assertJsonCount(0, 'data.matches')
            ->assertJsonPath('data.answer', fn (string $answer): bool => str_contains($answer, 'provide free access to clean water') && str_contains($answer, 'Do not use ice baths') && str_contains($answer, '40°C or higher'))
            ->assertJsonPath('data.answer_roman_urdu', fn (string $answer): bool => str_contains($answer, 'saaf pani har waqt dein') && str_contains($answer, 'insano ki bukhar ki dawa') && str_contains($answer, '40°C ya zyada'));
    }

    public function test_follow_up_temperature_keeps_the_earlier_fever_context(): void
    {
        $this->foundation(['health.view']);
        $headers = $this->bearer($this->loginToken());
        config(['services.health_ai.enabled' => false]);

        $this->postJson('/api/v1/health/ai/ask', [
            'question' => "Earlier message: meri gai ko bukhar ha\nCurrent message: temperature 40.5 hai",
            'species' => 'cattle',
            'symptom_codes' => [],
            'language' => 'both',
        ], $headers)
            ->assertOk()
            ->assertJsonPath('data.mode', 'urgent_guidance')
            ->assertJsonPath('data.answer', fn (string $answer): bool => str_contains($answer, 'temperature of 40.5') && str_contains($answer, 'contact a veterinarian promptly today'))
            ->assertJsonPath('data.answer_roman_urdu', fn (string $answer): bool => str_contains($answer, 'Temperature 40.5') && str_contains($answer, 'aaj hi foran vet se rabta karein'));
    }

    public function test_follow_up_unable_to_stand_escalates_instead_of_repeating_fever_advice(): void
    {
        $this->foundation(['health.view']);
        $headers = $this->bearer($this->loginToken());
        config(['services.health_ai.enabled' => false]);

        $this->postJson('/api/v1/health/ai/ask', [
            'question' => "Earlier message: meri gai ko bukhar ha\nEarlier message: temp 40 ha\nCurrent message: khari nai ho parhi",
            'species' => 'cattle',
            'symptom_codes' => [],
            'language' => 'both',
        ], $headers)
            ->assertOk()
            ->assertJsonPath('data.mode', 'emergency_guidance')
            ->assertJsonPath('data.emergency', true)
            ->assertJsonPath('data.answer', fn (string $answer): bool => str_contains($answer, 'cannot stand') && str_contains($answer, 'emergency veterinary help now'))
            ->assertJsonPath('data.answer_roman_urdu', fn (string $answer): bool => str_contains($answer, 'khari na ho pana emergency hai') && str_contains($answer, 'zabardasti khara na karein'));
    }

    public function test_vague_hoof_problem_asks_targeted_follow_up_question(): void
    {
        $this->foundation(['health.view']);
        $headers = $this->bearer($this->loginToken());
        config(['services.health_ai.enabled' => false]);

        $this->postJson('/api/v1/health/ai/ask', [
            'question' => 'bhains k khur mei masla ha',
            'species' => 'buffalo',
            'symptom_codes' => [],
            'language' => 'both',
        ], $headers)
            ->assertOk()
            ->assertJsonPath('data.mode', 'clarification')
            ->assertJsonPath('data.emergency', false)
            ->assertJsonCount(0, 'data.matches')
            ->assertJsonFragment(['answer_roman_urdu' => 'Khur ka masla tafseel se batayein: zakhm, chala, soojan, badboo, garmi, ya chalne mein mushkil hai? Khur saaf rakhein aur janwar ko khushk jagah par rakhein.']);
    }

    public function test_overlapping_tick_and_fever_signs_ask_one_discriminating_question(): void
    {
        $this->foundation(['health.view']);
        $headers = $this->bearer($this->loginToken());
        config(['services.health_ai.enabled' => false]);

        $this->postJson('/api/v1/health/ai/ask', [
            'question' => 'Meri gai par cheechray hain aur bukhar hai.',
            'species' => 'cattle',
            'symptom_codes' => [],
            'language' => 'both',
        ], $headers)
            ->assertOk()
            ->assertJsonPath('data.mode', 'clarification')
            ->assertJsonCount(0, 'data.matches')
            ->assertJsonPath('data.answer', fn (string $answer): bool => str_contains($answer, 'several conditions') && str_contains($answer, 'Is the urine red or coffee-coloured?'))
            ->assertJsonPath('data.answer_roman_urdu', fn (string $answer): bool => str_contains($answer, 'Kya peshab laal ya coffee rang ka hai?'));
    }

    public function test_follow_up_answer_resolves_tick_fever_overlap_from_chat_context(): void
    {
        $this->foundation(['health.view']);
        $headers = $this->bearer($this->loginToken());
        config(['services.health_ai.enabled' => false]);

        $this->postJson('/api/v1/health/ai/ask', [
            'question' => "Earlier message: Meri gai par cheechray hain aur bukhar hai.\nCurrent message: peshab laal hai",
            'species' => 'cattle',
            'symptom_codes' => [],
            'language' => 'both',
        ], $headers)
            ->assertOk()
            ->assertJsonPath('data.mode', 'deterministic')
            ->assertJsonPath('data.matches.0.code', 'babesiosis');
    }

    public function test_overlapping_fever_and_cough_asks_about_breathing_before_matching(): void
    {
        $this->foundation(['health.view']);
        $headers = $this->bearer($this->loginToken());
        config(['services.health_ai.enabled' => false]);

        $this->postJson('/api/v1/health/ai/ask', [
            'question' => 'Meri bhains ko bukhar aur khansi hai.',
            'species' => 'buffalo',
            'symptom_codes' => [],
            'language' => 'both',
        ], $headers)
            ->assertOk()
            ->assertJsonPath('data.mode', 'clarification')
            ->assertJsonCount(0, 'data.matches')
            ->assertJsonPath('data.answer', fn (string $answer): bool => str_ends_with($answer, 'Is breathing fast or difficult?'));
    }

    public function test_negated_mouth_signs_do_not_turn_foot_rot_into_fmd(): void
    {
        $this->foundation(['health.view']);
        $headers = $this->bearer($this->loginToken());
        config(['services.health_ai.enabled' => false]);

        foreach ([
            'My goat is lame with a hoof lesion but has no mouth blisters or saliva.',
            'Meri bakri langra rahi hai aur khur par zakhm hai lekin munh mein chalay ya ral nahi hai.',
        ] as $question) {
            $this->postJson('/api/v1/health/ai/ask', [
                'question' => $question,
                'species' => 'goat',
                'symptom_codes' => ['lameness', 'foot_lesions'],
                'language' => 'both',
            ], $headers)
                ->assertOk()
                ->assertJsonPath('data.matches.0.code', 'foot_rot')
                ->assertJsonPath('data.emergency', false);
        }
    }

    public function test_optionless_roman_urdu_prompts_cover_the_validated_disease_set(): void
    {
        $this->foundation(['health.view']);
        $headers = $this->bearer($this->loginToken());
        config(['services.health_ai.enabled' => false]);

        $cases = [
            ['Meri gai ki jild par sakht gaanthain hain, ghudood soojhay aur doodh kam hai', 'cattle', 'lsd'],
            ['Meri bakri ki palkain pheeki hain, jabray ke neechay soojan aur dast hain', 'goat', 'parasites'],
            ['Bacha dene ke baad meri bhains se badbudar mada aa raha hai, jer nahi giri aur bukhar hai', 'buffalo', 'metritis'],
            ['Meri bakri langra rahi hai aur khur par zakhm hai lekin munh mein chalay ya ral nahi', 'goat', 'foot_rot'],
            ['Meri bakri ko khansi hai, naak se pani aur bhook kam hai', 'goat', 'pneumonia'],
        ];

        foreach ($cases as [$question, $species, $expected]) {
            $this->postJson('/api/v1/health/ai/ask', [
                'question' => $question,
                'species' => $species,
                'symptom_codes' => [],
                'language' => 'both',
            ], $headers)
                ->assertOk()
                ->assertJsonPath('data.matches.0.code', $expected);
        }
    }

    public function test_local_model_can_only_phrase_grounded_context_and_outage_falls_back(): void
    {
        $this->foundation(['health.view']);
        $h = $this->bearer($this->loginToken());
        config(['services.health_ai.enabled' => true, 'services.health_ai.url' => 'http://model.test/v1']);
        Http::fake(['model.test/*' => Http::response(['choices' => [['message' => ['content' => "```json\n".json_encode(['answer_en' => 'Approved guidance says isolate and contact a veterinarian.'])."\n```"]]]], 200)]);
        $this->postJson('/api/v1/health/ai/ask', ['question' => 'Udder is swollen and milk has clots', 'species' => 'buffalo', 'symptom_codes' => ['udder_swelling', 'abnormal_milk']], $h)->assertOk()->assertJsonPath('data.mode', 'local_model_grounded')->assertJsonPath('data.matches.0.code', 'mastitis');
        Http::assertSent(function ($request): bool {
            $prompt = $request->data()['messages'][1]['content'] ?? '';

            return str_contains($prompt, 'PRIMARY_CONTEXT:')
                && str_contains($prompt, '"code":"mastitis"')
                && ! str_contains($prompt, '"code":"foot_rot"');
        });
        Http::fake(fn () => throw new \RuntimeException('offline'));
        $this->postJson('/api/v1/health/ai/ask', ['question' => 'Left side belly is swollen', 'species' => 'goat', 'symptom_codes' => ['left_bloat']], $h)->assertOk()->assertJsonPath('data.mode', 'deterministic')->assertJsonPath('data.matches.0.code', 'bloat');
    }

    public function test_unsafe_roman_urdu_or_oversized_model_output_is_rejected(): void
    {
        $this->foundation(['health.view']);
        $h = $this->bearer($this->loginToken());
        config(['services.health_ai.enabled' => true, 'services.health_ai.url' => 'http://model.test/v1']);
        foreach ([['Safe English', 'Dose: 5 ml injection dein.'], ['Safe English', 'جانور کو الگ رکھیں۔'], ['The animal likely has metritis.', 'Mehfooz jawab'], [str_repeat('A', 801), 'Mehfooz jawab']] as [$en,$ur]) {
            Http::fake(['model.test/*' => Http::response(['choices' => [['message' => ['content' => json_encode(['answer_en' => $en, 'answer_roman_urdu' => $ur])]]]], 200)]);
            $this->postJson('/api/v1/health/ai/ask', ['question' => 'Udder swollen with clots', 'species' => 'buffalo', 'symptom_codes' => ['udder_swelling', 'abnormal_milk']], $h)->assertOk()->assertJsonPath('data.mode', 'deterministic');
        }
    }

    public function test_model_failure_log_excludes_farmer_question(): void
    {
        $this->foundation(['health.view']);
        $h = $this->bearer($this->loginToken());
        config(['services.health_ai.enabled' => true, 'services.health_ai.url' => 'http://model.test/v1']);
        Http::fake(fn () => throw new \RuntimeException('offline'));
        Log::spy();
        $secret = 'PRIVATE FARMER OBSERVATION';
        $this->postJson('/api/v1/health/ai/ask', ['question' => $secret, 'species' => 'goat', 'symptom_codes' => ['left_bloat']], $h)->assertOk();
        Log::shouldHaveReceived('warning')->once()->withArgs(fn ($message, $context) => ! str_contains(json_encode([$message, $context]), $secret) && isset($context['model'],$context['exception']));
    }

    public function test_health_ai_questions_are_rate_limited_per_user(): void
    {
        $this->foundation(['health.view']);
        $h = $this->bearer($this->loginToken());
        config(['services.health_ai.enabled' => false]);
        $payload = ['question' => 'Mouth blisters and saliva', 'species' => 'cattle', 'symptom_codes' => ['mouth_blisters']];
        for ($i = 0; $i < 12; $i++) {
            $this->postJson('/api/v1/health/ai/ask', $payload, $h)->assertOk();
        }$this->postJson('/api/v1/health/ai/ask', $payload, $h)->assertStatus(429)->assertJsonPath('error.code', 'RATE_LIMITED');
    }
}
