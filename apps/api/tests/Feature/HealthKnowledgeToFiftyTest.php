<?php

namespace Tests\Feature;

use App\Domain\AnimalHealth\Models\HealthDisease;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class HealthKnowledgeToFiftyTest extends TestCase
{
    use CreatesFoundationData, RefreshDatabase;

    public function test_health_knowledge_contains_exactly_fifty_sourced_diseases(): void
    {
        $this->assertSame(50, HealthDisease::count());
        $this->assertSame(50, HealthDisease::where('review_status', 'approved')->count());
        $this->assertSame(16, HealthDisease::whereIn('code', ['bovine_tb','leptospirosis','salmonellosis','listeriosis','ibr','bvd','q_fever','contagious_agalactia','sheep_goat_pox','bluetongue','tetanus','botulism','orf','urolithiasis','hardware_disease','bovine_ephemeral_fever'])->count());
    }

    public function test_distinctive_new_signs_rank_key_emergencies(): void
    {
        $this->foundation(['health.view']);
        $headers = $this->bearer($this->loginToken());
        config(['services.health_ai.enabled' => false]);
        foreach ([
            [['circling','fever'],'goat','listeriosis'],
            [['stiff_gait','swallowing_difficulty'],'cattle','tetanus'],
            [['flaccid_paralysis','swallowing_difficulty'],'cattle','botulism'],
            [['straining_urinate','no_urine'],'goat','urolithiasis'],
            [['lip_scabs','reduced_appetite'],'goat','orf'],
            [['muzzle_edema','oral_erosions','lameness'],'goat','bluetongue'],
        ] as [$symptoms,$species,$expected]) {
            $this->postJson('/api/v1/health/ai/ask',['question'=>'Veterinary evaluation','species'=>$species,'symptom_codes'=>$symptoms,'language'=>'both'],$headers)->assertOk()->assertJsonPath('data.matches.0.code',$expected);
        }
    }
}
