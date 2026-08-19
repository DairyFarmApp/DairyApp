<?php

namespace App\Domain\AnimalHealth\Services;

use App\Domain\AnimalHealth\Models\HealthDisease;
use App\Domain\AnimalHealth\Models\HealthSymptom;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class HealthRagService
{
    public function __construct(private readonly HealthLanguageModelService $languageModel) {}

    public function ask(string $question, string $species, array $symptomCodes, string $language, ?array $animalContext = null): array
    {
        $symptomCodes = collect([...$symptomCodes, ...$this->inferSymptomCodes($question)])
            ->unique()
            ->values()
            ->all();
        if (count($symptomCodes) <= 1 && $criticalResponse = $this->criticalDeteriorationResponse($question)) {
            return $criticalResponse;
        }
        $stopWords = ['animal', 'approved', 'buffalo', 'cattle', 'disease', 'give', 'goat', 'guidance', 'meri', 'my', 'only', 'should', 'this', 'what', 'which', 'with'];
        $tokens = collect(preg_split('/[^a-z0-9]+/', strtolower($question)))
            ->filter(fn ($token) => strlen($token) > 2 && ! in_array($token, $stopWords, true))
            ->unique();
        $scored = HealthDisease::with('symptoms')->where('is_active', true)->where('review_status', 'approved')->whereJsonContains('species', strtolower($species))->get()->map(function ($d) use ($tokens, $symptomCodes) {
            $selectedDiseaseSymptoms = $d->symptoms->whereIn('code', $symptomCodes);
            $symptomScore = $selectedDiseaseSymptoms->sum(fn ($symptom) => (int) $symptom->pivot->weight);
            $keySymptomCount = $selectedDiseaseSymptoms->filter(fn ($symptom) => (bool) $symptom->pivot->is_key)->count();
            $textScore = $tokens->filter(fn ($token) => str_contains(strtolower($d->name.' '.$d->summary.' '.$d->immediate_care), $token))->count();
            $eligible = $symptomCodes === []
                ? $textScore >= 2
                : count($symptomCodes) >= 2 || $keySymptomCount > 0;

            return [$d, $symptomScore * 10 + $textScore, $eligible, $keySymptomCount];
        })->sortByDesc(fn ($row) => $row[1])->values();
        $ranked = $scored->filter(fn ($row) => $row[2])->take(3)->values();
        if ($ranked->isEmpty()) {
            return $this->clarificationResponse($question, $symptomCodes, $scored);
        }
        if ($this->needsClarification($ranked, $symptomCodes)) {
            return $this->clarificationResponse($question, $symptomCodes, $ranked);
        }
        // Once the leading pattern is strong, do not present weak partial
        // overlaps as equally useful differentials. For example, mouth lesions,
        // salivation and hoof lesions strongly support FMD; foot rot matching
        // only the hoof sign must not be displayed beside it.
        $topScore = max(1, (int) ($ranked[0][1] ?? 1));
        $ranked = $ranked
            ->filter(fn ($row, int $index) => $index === 0 || ((int) $row[1] / $topScore) >= 0.60)
            ->values();
        $matches = $ranked->map(function ($row) {
            $d = $row[0];

            $medicines = DB::table('health_disease_medicine_evidence')
                ->where('disease_id', $d->id)
                ->where('review_status', 'approved')
                ->orderBy('active_ingredient')
                ->get(['active_ingredient', 'brand_name', 'manufacturer', 'dosage_form', 'drap_registration_number', 'drap_registry_url', 'indication', 'species_scope', 'contraindications', 'withdrawal_guidance'])
                ->map(fn ($medicine) => (array) $medicine)
                ->values()
                ->all();

            return ['code' => $d->code, 'name' => $d->name, 'name_roman_urdu' => $d->name_roman_urdu, 'urgency' => $d->urgency, 'summary' => $d->summary, 'immediate_care' => $d->immediate_care, 'immediate_care_roman_urdu' => $d->immediate_care_roman_urdu, 'do_not_do' => $d->do_not_do, 'feed_water_guidance' => $d->feed_water_guidance, 'confirmation_guidance' => $d->confirmation_guidance, 'medicines' => $medicines, 'source' => ['title' => $d->source_title, 'url' => $d->source_url, 'reviewed_on' => $d->source_reviewed_on?->toDateString()]];
        })->all();
        $hasSelectedEmergencySymptom = HealthSymptom::query()
            ->whereIn('code', $symptomCodes)
            ->where('is_emergency', true)
            ->exists();
        $emergency = ($matches[0]['urgency'] ?? null) === 'emergency' || $hasSelectedEmergencySymptom;
        $answer = $matches[0]['summary'].' '.$matches[0]['immediate_care'];
        $roman = $matches[0]['immediate_care_roman_urdu'] ?: 'Janwar ko alag rakhein, ehtiyat karein aur foran vet se rabta karein.';
        $mode = 'deterministic';
        if (config('services.health_ai.enabled')) {
            try {
                $json = $this->languageModel->generate($question, $language, $matches[0], $animalContext) + ['answer_roman_urdu' => $roman];
                if ($this->isSafeModelAnswer($json)) {
                    $answer = $json['answer_en'];
                    $roman = $json['answer_roman_urdu'];
                    $mode = config('services.health_ai.provider', 'openai_compatible') === 'gemini'
                        ? 'gemini_grounded'
                        : 'local_model_grounded';
                }
            } catch (\Throwable $exception) {
                Log::warning('Health AI language model unavailable; deterministic guidance used.', [
                    'provider' => (string) config('services.health_ai.provider', 'openai_compatible'),
                    'model' => (string) config('services.health_ai.model'),
                    'exception' => $exception::class,
                ]);
            }
        }

        return compact('mode', 'answer', 'emergency', 'matches') + ['answer_roman_urdu' => $roman, 'safety_notice' => 'Possible conditions only. A veterinarian must confirm disease and all medicine or dose decisions.', 'animal_context' => $animalContext];
    }

    /** @return list<string> */
    private function inferSymptomCodes(string $question): array
    {
        $text = strtolower(Str::ascii($question));
        $patterns = [
            'mouth_blisters' => '/\b(?:mouth|munh|mooh)\b.{0,24}\b(?:blister|blisters|chala|chalay|chale|chaalay|zakham|zakhm)\b/',
            'excess_saliva' => '/\b(?:saliva|drooling|ral|raal|thook)\b/',
            'foot_lesions' => '/\b(?:hoof|hooves|foot|feet|khur|khuron)\b.{0,24}\b(?:lesion|lesions|sore|sores|wound|wounds|zakham|zakhm)\b/',
            'udder_swelling' => '/\b(?:udder|than|thun)\b.{0,24}\b(?:swollen|swelling|sooj|suj|phool)\w*/',
            'abnormal_milk' => '/\b(?:milk|doodh)\b.{0,24}\b(?:clot|clots|flakes|watery|phatti|phata|khoon)\b/',
            'left_bloat' => '/\b(?:left|baen|bain)\b.{0,24}\b(?:belly|abdomen|pait|pet)\b.{0,24}\b(?:bloat|swollen|phool)\w*/',
            'breathing_difficulty' => '/\b(?:breath|breathing|saans)\b.{0,24}\b(?:difficult|difficulty|mushkil|takleef)\b/',
            'diarrhea' => '/\b(?:diarrhea|diarrhoea|dast|motion)\b/',
            'fever' => '/\b(?:fever|bukhar|bukhaar)\b/',
            'cough' => '/\b(?:cough|khansi|khaansi)\b/',
            'reduced_appetite' => '/\b(?:appetite|bhook)\b.{0,20}\b(?:less|reduced|kam|nahi)\b/',
            'nasal_discharge' => '/\b(?:nose|naak)\b.{0,20}\b(?:discharge|pani|fluid)\b/',
            'skin_nodules' => '/\b(?:skin|jild)\b.{0,30}\b(?:nodule|nodules|lump|lumps|gaanth|gaanthain|ganth|ganthain)\b/',
            'swollen_lymph_nodes' => '/\b(?:lymph|gland|glands|ghudood)\b.{0,24}\b(?:swollen|swelling|sooj|soojhay|suj)\w*/',
            'reduced_milk' => '/\b(?:milk|doodh)\b.{0,20}\b(?:less|reduced|drop|kam)\b/',
            'pale_eyelids' => '/\b(?:eyelid|eyelids|palkain|palkein)\b.{0,20}\b(?:pale|white|pheeki|phiki|safed)\b/',
            'bottle_jaw' => '/\b(?:jaw|jabra|jabray|jabrray)\b.{0,24}\b(?:below|under|neechay|neeche)\b.{0,20}\b(?:swollen|swelling|sooj|suj)\w*/',
            'vaginal_discharge' => '/\b(?:foul|badbudar|badbudaar)\b.{0,24}\b(?:vaginal|discharge|mada|maada)\b/',
            'retained_placenta' => '/\b(?:placenta|jer)\b.{0,24}\b(?:retained|not|nahi|nai|ni)\b|\b(?:jer)\b.{0,24}\b(?:giri|nikli)\b/',
            'lameness' => '/\b(?:lame|lameness|limping|langra|langri)\b/',
            'recent_calving' => '/\b(?:calved|calving|after birth|bacha diya|bacha dene)\b/',
            'cold_ears' => '/\b(?:cold|thanday|thande)\b.{0,16}\b(?:ears|ear|kaan)\b|\b(?:ears|ear|kaan)\b.{0,16}\b(?:cold|thanday|thande)\b/',
            'muscle_tremors' => '/\b(?:tremor|tremors|shivering|larzish|kaanp)\w*/',
            'sweet_breath' => '/\b(?:sweet|acetone|meethi)\b.{0,20}\b(?:breath|saans|boo)\b|\b(?:breath|saans)\b.{0,20}\b(?:sweet|acetone|meethi)\b/',
            'weight_loss' => '/\b(?:weight|wazan)\b.{0,16}\b(?:loss|losing|kam)\b/',
            'abortion' => '/\b(?:abortion|aborted)\b|\b(?:hamal)\b.{0,18}\b(?:loss|zaya)\b/',
            'weak_newborn' => '/\b(?:weak|kamzor|stillborn|murda)\b.{0,20}\b(?:calf|kid|newborn|bacha)\b/',
            'sudden_death' => '/\b(?:sudden|achanak)\b.{0,16}\b(?:death|dead|maut|mar)\w*/',
            'unclotted_bleeding' => '/\b(?:dark|gehra|black)\b.{0,30}\b(?:blood|bleeding|khoon)\b|\b(?:unclotted|na jamnay)\b.{0,20}\b(?:blood|khoon)\b/',
            'muscle_swelling' => '/\b(?:muscle|pathon)\b.{0,25}\b(?:swelling|swollen|soojan)\b/',
            'tick_presence' => '/\b(?:tick|ticks|cheechra|cheechray)\b/',
            'red_urine' => '/\b(?:red|coffee|laal)\b.{0,20}\b(?:urine|peshab)\b|\b(?:urine|peshab)\b.{0,20}\b(?:red|coffee|laal)\b/',
            'jaundice' => '/\b(?:yellow|peela|peeli|peelay|jaundice)\b.{0,20}\b(?:eyes|eye|gums|aankh|masoor)\w*/',
            'weakness' => '/\b(?:weak|weakness|kamzor|kamzori)\b/',
            'bloody_diarrhea' => '/\b(?:blood|bloody|khoon)\b.{0,20}\b(?:diarrhea|diarrhoea|dast)\b/',
            'straining' => '/\b(?:straining|zor)\b.{0,24}\b(?:stool|gobar|dast)\b/',
            'cloudy_eye' => '/\b(?:cloudy|dhundli|white)\b.{0,18}\b(?:eye|aankh)\b|\b(?:eye|aankh)\b.{0,18}\b(?:cloudy|dhundli)\b/',
            'tearing' => '/\b(?:eye|aankh)\b.{0,18}\b(?:tears|tearing|pani)\b/',
            'eye_pain' => '/\b(?:eye|aankh)\b.{0,20}\b(?:pain|dard|closed|band)\b/',
            'circular_hair_loss' => '/\b(?:circular|round|gol)\b.{0,20}\b(?:hair loss|bald|baal)\b/',
            'crusty_skin' => '/\b(?:crust|crusty|scaly|papri)\b.{0,16}\b(?:skin|jild)?/',
            'severe_itching' => '/\b(?:severe|intense|bohat|shadeed)\b.{0,14}\b(?:itching|itchy|kharish)\w*|\b(?:rubbing|ragar)\w*/',
            'swollen_navel' => '/\b(?:navel|naaf)\b.{0,20}\b(?:swollen|swelling|sooj)\w*/',
            'navel_discharge' => '/\b(?:navel|naaf)\b.{0,20}\b(?:discharge|pus|mada)\b/',
            'joint_swelling' => '/\b(?:joint|joints|joron)\b.{0,20}\b(?:swollen|swelling|sooj)\w*/',
            'behavior_change' => '/\b(?:behavio(?:u)?r|rawaiye)\b.{0,24}\b(?:change|abnormal|tabdeeli)\b/',
            'swallowing_difficulty' => '/\b(?:swallow|swallowing|nigal)\w*.{0,18}\b(?:difficult|difficulty|mushkil)\b/',
            'paralysis' => '/\b(?:paralysis|paralyzed|falij)\b/',
            'multiple_animals_affected' => '/\b(?:several|multiple|many|kai)\b.{0,22}\b(?:animals|cows|cattle|buffalo|goats|janwar|gai|bhains|bakri)\b.{0,24}\b(?:sick|ill|bemar|affected)\b/',
        ];

        return collect($patterns)
            ->filter(fn (string $pattern) => preg_match($pattern, $text) === 1)
            ->reject(fn (string $pattern, string $code) => $this->symptomIsNegated($text, $code))
            ->keys()
            ->values()
            ->all();
    }

    private function symptomIsNegated(string $text, string $code): bool
    {
        $terms = match ($code) {
            'mouth_blisters' => '(?:mouth|munh|mooh).{0,20}(?:blister|blisters|chala|chalay|chale|chaalay)',
            'excess_saliva' => '(?:saliva|drooling|ral|raal|thook)',
            'foot_lesions' => '(?:hoof|hooves|foot|feet|khur|khuron).{0,20}(?:lesion|lesions|sore|sores|wound|wounds|zakham|zakhm)',
            'udder_swelling' => '(?:udder|than|thun).{0,20}(?:swollen|swelling|sooj|suj|phool\w*)',
            'abnormal_milk' => '(?:milk|doodh).{0,20}(?:clot|clots|flakes|watery|phatti|phata|khoon)',
            'left_bloat' => '(?:left|baen|bain).{0,20}(?:belly|abdomen|pait|pet).{0,20}(?:bloat|swollen|phool\w*)',
            'breathing_difficulty' => '(?:breath|breathing|saans).{0,20}(?:difficult|difficulty|mushkil|takleef)',
            'diarrhea' => '(?:diarrhea|diarrhoea|dast|motion)',
            'fever' => '(?:fever|bukhar|bukhaar)',
            'cough' => '(?:cough|khansi|khaansi)',
            'reduced_appetite' => '(?:appetite|bhook).{0,20}(?:less|reduced|kam|nahi)',
            'nasal_discharge' => '(?:nose|naak).{0,20}(?:discharge|pani|fluid)',
            'skin_nodules' => '(?:skin|jild).{0,30}(?:nodule|nodules|lump|lumps|gaanth|gaanthain|ganth|ganthain)',
            'swollen_lymph_nodes' => '(?:lymph|gland|glands|ghudood).{0,24}(?:swollen|swelling|sooj|soojhay|suj\w*)',
            'reduced_milk' => '(?:milk|doodh).{0,20}(?:less|reduced|drop|kam)',
            'pale_eyelids' => '(?:eyelid|eyelids|palkain|palkein).{0,20}(?:pale|white|pheeki|phiki|safed)',
            'bottle_jaw' => '(?:jaw|jabra|jabray|jabrray).{0,24}(?:below|under|neechay|neeche).{0,20}(?:swollen|swelling|sooj|suj\w*)',
            'vaginal_discharge' => '(?:foul|badbudar|badbudaar).{0,24}(?:vaginal|discharge|mada|maada)',
            'retained_placenta' => '(?:placenta|jer).{0,24}(?:retained|not|nahi|nai|ni|giri|nikli)',
            'lameness' => '(?:lame|lameness|limping|langra|langri)',
            default => null,
        };
        if ($terms === null) {
            return false;
        }

        return preg_match('/\b(?:no|not|without)\b.{0,30}\b'.$terms.'\b|\b'.$terms.'\b.{0,20}\b(?:nahi|nai|ni)\b/', $text) === 1;
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
        if (preg_match('/[\x{0600}-\x{06FF}\x{0750}-\x{077F}\x{08A0}-\x{08FF}]/u', $romanUrdu) === 1) {
            return false;
        }
        $combined = strtolower($english.' '.$romanUrdu);

        if (preg_match('/\b(?:the animal|the patient|patient|it|janwar)\s+(?:is suffering from|is experiencing|likely has|probably has|has|hai)\b|\bdiagnosis\s+is\b/i', $combined) === 1) {
            return false;
        }

        return preg_match('/\b\d+(?:\.\d+)?\s*(?:mg|ml|g|kg|cc|iu|units?)\b|\b(?:dose|dosage|prescribe|inject|injection|antibiotic)\s*:/i', $combined) !== 1;
    }

    private function needsClarification($ranked, array $symptomCodes): bool
    {
        if (count($symptomCodes) === 2
            && in_array('fever', $symptomCodes, true)
            && in_array('cough', $symptomCodes, true)) {
            return true;
        }
        if (count($symptomCodes) > 3 || ($ranked[0][3] ?? 0) > 0) {
            return false;
        }

        $topScore = (int) ($ranked[0][1] ?? 0);
        $secondScore = (int) ($ranked[1][1] ?? 0);

        // Common signs must not become a diagnosis-like result while multiple
        // conditions remain similarly plausible.
        return count($symptomCodes) <= 2
            && $secondScore > 0
            && ($topScore - $secondScore) <= 30;
    }

    private function clarificationResponse(string $question, array $symptomCodes, $candidates = null): array
    {
        $text = strtolower(Str::ascii($question));
        if (in_array('fever', $symptomCodes, true) && in_array('tick_presence', $symptomCodes, true)) {
            $answer = 'Ticks and fever can fit several conditions. Keep the animal quiet with shade and clean water and arrange veterinary testing today. Is the urine red or coffee-coloured?';
            $roman = 'Cheechray aur bukhar kai bimariyon mein ho sakte hain. Janwar ko aram, saya aur saaf pani dein aur aaj vet se test karwayein. Kya peshab laal ya coffee rang ka hai?';
        } elseif (in_array('fever', $symptomCodes, true) && (in_array('cough', $symptomCodes, true) || in_array('nasal_discharge', $symptomCodes, true))) {
            $answer = 'Keep the animal rested, shaded and separate from the herd while monitoring breathing. Is breathing fast or difficult?';
            $roman = 'Janwar ko aram aur saye mein rewar se alag rakhein aur saans dekhein. Kya saans tez ya mushkil hai?';
        } elseif (in_array('crusty_skin', $symptomCodes, true) && ! in_array('severe_itching', $symptomCodes, true) && ! in_array('circular_hair_loss', $symptomCodes, true)) {
            $answer = 'Keep the animal separate and do not share brushes or ropes. Is there severe itching and rubbing?';
            $roman = 'Janwar ko alag rakhein aur brush ya rassi share na karein. Kya shadeed kharish aur ragarna ho raha hai?';
        } elseif (in_array('diarrhea', $symptomCodes, true) && ! in_array('bloody_diarrhea', $symptomCodes, true)) {
            $answer = 'Keep clean water available if the animal can swallow and separate it from the herd. Is there blood in the diarrhea?';
            $roman = 'Agar janwar theek se nigal sakta hai to saaf pani dein aur rewar se alag rakhein. Kya dast mein khoon hai?';
        } elseif (in_array('fever', $symptomCodes, true)) {
            if (preg_match('/\b(?:4[0-5])(?:\.\d+)?\s*(?:°?\s*c)?\b/i', $text, $temperature) === 1) {
                return [
                    'mode' => 'urgent_guidance',
                    'answer' => "A temperature of {$temperature[0]} is high. Keep the animal resting in shade with ventilation and clean water, isolate it, and contact a veterinarian promptly today. Do not give human fever medicine, antibiotics, or injections. Can the animal stand normally?",
                    'answer_roman_urdu' => "Temperature {$temperature[0]} zyada hai. Janwar ko saye aur hawadar jagah par aram dein, saaf pani dein, rewar se alag rakhein aur aaj hi foran vet se rabta karein. Insano ki bukhar ki dawa, antibiotic ya injection khud na dein. Kya janwar theek se khara ho sakta hai?",
                    'emergency' => false,
                    'matches' => [],
                    'safety_notice' => 'High temperature needs prompt veterinary assessment and continued monitoring.',
                ];
            }
            $answer = 'Keep the cow resting in a clean, shaded, well-ventilated place and provide free access to clean water. If trained, measure and record rectal temperature (a dairy cow is normally about 38.0–39.3°C). Do not use ice baths, human fever medicine, antibiotics, or injections without a veterinarian. Contact a veterinarian promptly if temperature is 40°C or higher, fever persists, or there is difficult breathing, swelling, diarrhea, mouth sores, inability to stand, or refusal to drink. What temperature did you measure and what other signs are present?';
            $roman = 'Gai ko saaf, saye wali aur hawadar jagah par aram dein aur saaf pani har waqt dein. Agar tareeqa aata hai to rectal temperature naap kar likhein; dairy gai ka aam temperature taqreeban 38.0–39.3°C hota hai. Baraf ya bohat thanday pani se na nehlayein aur vet ke baghair insano ki bukhar ki dawa, antibiotic ya injection na dein. Temperature 40°C ya zyada ho, bukhar barqarar rahe, saans mushkil ho, soojan, dast, munh mein chalay, khara na ho pana, ya pani na peena ho to foran vet se rabta karein. Temperature kitna hai aur doosri alamat kya hain?';
        } elseif (preg_match('/\b(?:hoof|hooves|foot|feet|khur|khuron)\b/', $text) === 1) {
            $answer = 'Please describe the hoof problem: is there a wound, blister, swelling, bad smell, heat, or difficulty walking? Keep the hoof clean and the animal on a dry surface.';
            $roman = 'Khur ka masla tafseel se batayein: zakhm, chala, soojan, badboo, garmi, ya chalne mein mushkil hai? Khur saaf rakhein aur janwar ko khushk jagah par rakhein.';
        } elseif ($question = $this->distinguishingQuestion($candidates, $symptomCodes)) {
            $answer = "I need one detail to separate the closest possibilities. {$question['english']} Reply yes or no, and add any other sign you noticed.";
            $roman = "Qareebi mumkin bimariyon mein farq ke liye aik baat batayein. {$question['roman']} Haan ya nahi mein jawab dein aur koi doosri alamat ho to likhein.";
        } else {
            $answer = 'Please describe more signs: when they started, temperature if measured, eating and drinking, breathing, stool, movement, and any swelling or wounds.';
            $roman = 'Mazeed alamat likhein: masla kab shuru hua, temperature, khana peena, saans, gobar, chalna, aur koi soojan ya zakhm.';
        }

        return ['mode' => 'clarification', 'answer' => $answer, 'answer_roman_urdu' => $roman, 'emergency' => false, 'matches' => [], 'safety_notice' => 'More information is needed before showing possible conditions.'];
    }

    /**
     * Choose a high-value unanswered sign that best separates the current
     * differential candidates. This produces an Akinator-style interview
     * without asking the user to repeat signs already supplied.
     */
    private function distinguishingQuestion($candidates, array $knownSymptoms): ?array
    {
        if (! $candidates || $candidates->isEmpty()) {
            return null;
        }

        $rows = $candidates->take(5);
        $candidateCount = $rows->count();
        $options = collect();
        foreach ($rows as $row) {
            foreach ($row[0]->symptoms as $symptom) {
                if (in_array($symptom->code, $knownSymptoms, true)) {
                    continue;
                }
                $current = $options->get($symptom->code, [
                    'symptom' => $symptom,
                    'present_in' => 0,
                    'weight' => 0,
                    'key' => false,
                ]);
                $current['present_in']++;
                $current['weight'] += (int) $symptom->pivot->weight;
                $current['key'] = $current['key'] || (bool) $symptom->pivot->is_key;
                $options->put($symptom->code, $current);
            }
        }

        $selected = $options
            ->filter(fn (array $option) => $option['present_in'] < $candidateCount)
            ->sortByDesc(function (array $option) use ($candidateCount): int {
                $splitQuality = min($option['present_in'], $candidateCount - $option['present_in']);

                return ($option['key'] ? 1000 : 0) + ($splitQuality * 100) + $option['weight'];
            })
            ->first();
        if (! $selected) {
            return null;
        }

        $symptom = $selected['symptom'];
        $english = rtrim($symptom->name, '.?');
        $roman = rtrim($symptom->name_roman_urdu ?: $symptom->name, '.?');

        return [
            'code' => $symptom->code,
            'english' => "Does the animal have {$english}?",
            'roman' => "Kya janwar mein {$roman} hai?",
        ];
    }

    private function criticalDeteriorationResponse(string $question): ?array
    {
        $text = strtolower(Str::ascii($question));
        $unableToStand = preg_match('/\b(?:cannot|can not|unable|not able)\s+to\s+(?:stand|get up)\b|\b(?:khari|khara|uth)\b.{0,18}\b(?:nahi|nai|ni)\b|\b(?:nahi|nai|ni)\b.{0,18}\b(?:khari|khara|uth)\b/', $text) === 1;
        if (! $unableToStand) {
            return null;
        }

        return [
            'mode' => 'emergency_guidance',
            'answer' => 'This is a serious deterioration: a cow with fever that cannot stand needs emergency veterinary help now. Keep her chest upright rather than flat on her side, provide deep dry bedding, do not drag or force her to stand, and offer water only if she can swallow normally.',
            'answer_roman_urdu' => 'Yeh halat serious hai: bukhar wali gai ka khari na ho pana emergency hai. Foran vet ko bulayein. Gai ko seene ke bal seedha rakhein, pehlu par bilkul flat na rehne dein, narm khushk bistar dein, ghaseetein ya zabardasti khara na karein, aur pani sirf tab dein jab woh theek se nigal sakay.',
            'emergency' => true,
            'matches' => [],
            'safety_notice' => 'The animal is deteriorating and needs an urgent hands-on veterinary examination.',
        ];
    }

}
