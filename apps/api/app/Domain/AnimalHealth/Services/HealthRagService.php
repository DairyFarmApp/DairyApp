<?php

namespace App\Domain\AnimalHealth\Services;

use App\Domain\AnimalHealth\Models\HealthDisease;
use App\Domain\AnimalHealth\Models\HealthSymptom;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class HealthRagService
{
    public function ask(string $question, string $species, array $symptomCodes, string $language): array
    {
        $stopWords = ['animal', 'approved', 'buffalo', 'cattle', 'disease', 'give', 'goat', 'guidance', 'meri', 'my', 'only', 'should', 'this', 'what', 'which', 'with'];
        $tokens = collect(preg_split('/[^a-z0-9]+/', strtolower($question)))
            ->filter(fn ($token) => strlen($token) > 2 && ! in_array($token, $stopWords, true))
            ->unique();
        $ranked = HealthDisease::with('symptoms')->where('is_active', true)->where('review_status', 'approved')->whereJsonContains('species', strtolower($species))->get()->map(function ($d) use ($tokens, $symptomCodes) {
            $symptomScore = $d->symptoms
                ->whereIn('code', $symptomCodes)
                ->sum(fn ($symptom) => (int) $symptom->pivot->weight);
            $textScore = $tokens->filter(fn ($token) => str_contains(strtolower($d->name.' '.$d->summary.' '.$d->immediate_care), $token))->count();
            $eligible = $symptomCodes === [] ? $textScore >= 2 : $symptomScore > 0;

            return [$d, $symptomScore * 10 + $textScore, $eligible];
        })->filter(fn ($row) => $row[2])->sortByDesc(fn ($row) => $row[1])->take(3)->values();
        if ($ranked->isEmpty()) {
            return ['mode' => 'deterministic', 'answer' => 'No approved matching guidance was found. Contact a veterinarian, especially if the animal is getting worse.', 'answer_roman_urdu' => 'Approved guide mein match nahi mila. Janwar ki halat kharab ho rahi ho to foran vet se rabta karein.', 'emergency' => false, 'matches' => [], 'safety_notice' => 'This is decision support, not a diagnosis or prescription.'];
        }
        $matches = $ranked->map(function ($row) {
            $d = $row[0];

            return ['code' => $d->code, 'name' => $d->name, 'name_roman_urdu' => $d->name_roman_urdu, 'urgency' => $d->urgency, 'summary' => $d->summary, 'immediate_care' => $d->immediate_care, 'immediate_care_roman_urdu' => $d->immediate_care_roman_urdu, 'do_not_do' => $d->do_not_do, 'feed_water_guidance' => $d->feed_water_guidance, 'confirmation_guidance' => $d->confirmation_guidance, 'source' => ['title' => $d->source_title, 'url' => $d->source_url, 'reviewed_on' => $d->source_reviewed_on?->toDateString()]];
        })->all();
        $hasSelectedEmergencySymptom = HealthSymptom::query()
            ->whereIn('code', $symptomCodes)
            ->where('is_emergency', true)
            ->exists();
        $emergency = ($matches[0]['urgency'] ?? null) === 'emergency' || $hasSelectedEmergencySymptom;
        $answer = $matches[0]['summary'].' '.$matches[0]['immediate_care'];
        $roman = $matches[0]['immediate_care_roman_urdu'] ?: 'Foran vet se rabta karein aur approved guide par amal karein.';
        $mode = 'deterministic';
        if (config('services.health_ai.enabled')) {
            try {
                $payload = ['model' => config('services.health_ai.model'), 'temperature' => 0, 'response_format' => ['type' => 'json_object'], 'messages' => [
                    ['role' => 'system', 'content' => 'Use only CONTEXT. Never diagnose, prescribe, name a new medicine, or invent a dose. Return JSON with answer_en and answer_roman_urdu, each under 90 words.'],
                    ['role' => 'user', 'content' => "QUESTION: $question\nLANGUAGE: $language\nCONTEXT: ".json_encode($matches, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES)],
                ]];
                $content = Http::timeout((int) config('services.health_ai.timeout', 15))->post(rtrim(config('services.health_ai.url'), '/').'/chat/completions', $payload)->throw()->json('choices.0.message.content');
                $json = json_decode($content, true, flags: JSON_THROW_ON_ERROR);
                if ($this->isSafeModelAnswer($json)) {
                    $answer = $json['answer_en'];
                    $roman = $json['answer_roman_urdu'];
                    $mode = 'local_model_grounded';
                }
            } catch (\Throwable $exception) {
                Log::warning('Health AI local model unavailable; deterministic guidance used.', [
                    'model' => (string) config('services.health_ai.model'),
                    'exception' => $exception::class,
                ]);
            }
        }

        return compact('mode', 'answer', 'emergency', 'matches') + ['answer_roman_urdu' => $roman, 'safety_notice' => 'Possible conditions only. A veterinarian must confirm disease and all medicine or dose decisions.'];
    }

    private function isSafeModelAnswer(array $json): bool
    {
        $english = $json['answer_en'] ?? null;
        $romanUrdu = $json['answer_roman_urdu'] ?? null;
        if (! is_string($english) || ! is_string($romanUrdu) || trim($english) === '' || trim($romanUrdu) === '') {
            return false;
        }
        if (Str::length($english) > 800 || Str::length($romanUrdu) > 800) {
            return false;
        }
        $combined = strtolower($english.' '.$romanUrdu);

        return preg_match('/\b\d+(?:\.\d+)?\s*(?:mg|ml|g|kg|cc|iu|units?)\b|\b(?:dose|dosage|prescribe|inject|injection|antibiotic)\s*:/i', $combined) !== 1;
    }
}
