<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

return new class extends Migration
{
    public function up(): void
    {
        $now = now();
        $symptoms = [
            ['recent_calving', 'Recently calved', 'Haal hi mein bacha diya', 'reproductive', false],
            ['cold_ears', 'Cold ears or limbs', 'Thanday kaan ya tangain', 'general', false],
            ['muscle_tremors', 'Muscle tremors', 'Pathon mein larzish', 'neurologic', false],
            ['sweet_breath', 'Sweet or acetone-like breath', 'Saans mein meethi boo', 'metabolic', false],
            ['weight_loss', 'Weight or body-condition loss', 'Wazan kam hona', 'general', false],
            ['abortion', 'Abortion or reproductive loss', 'Hamal zaya hona', 'reproductive', true],
            ['weak_newborn', 'Weak or stillborn newborn', 'Kamzor ya murda bacha', 'reproductive', false],
            ['sudden_death', 'Sudden unexplained death', 'Achanak maut', 'general', true],
            ['unclotted_bleeding', 'Dark unclotted bleeding from openings', 'Surakhon se gehra na jamnay wala khoon', 'general', true],
            ['muscle_swelling', 'Painful gas-like muscle swelling', 'Pathon ki dardnaak hawa wali soojan', 'musculoskeletal', true],
            ['tick_presence', 'Ticks present', 'Cheechray mojood', 'skin', false],
            ['red_urine', 'Red or coffee-coloured urine', 'Laal ya coffee rang peshab', 'urinary', true],
            ['jaundice', 'Yellow eyes or gums', 'Aankhon ya masooron ka peela hona', 'general', false],
            ['weakness', 'Marked weakness', 'Bohat kamzori', 'general', false],
            ['bloody_diarrhea', 'Bloody diarrhea', 'Khoon walay dast', 'digestive', true],
            ['straining', 'Straining to pass stool', 'Gobar ke liye zor lagana', 'digestive', false],
            ['cloudy_eye', 'Cloudy or ulcerated eye', 'Aankh dhundli ya zakhmi', 'eye', false],
            ['tearing', 'Excessive tearing', 'Aankh se zyada pani', 'eye', false],
            ['eye_pain', 'Eye held closed or painful', 'Dard se aankh band rakhna', 'eye', false],
            ['circular_hair_loss', 'Circular hair-loss patches', 'Gol baal jharne ke daagh', 'skin', false],
            ['crusty_skin', 'Scaly or crusty skin', 'Papri wali jild', 'skin', false],
            ['severe_itching', 'Severe itching or rubbing', 'Bohat kharish ya ragarna', 'skin', false],
            ['swollen_navel', 'Swollen painful navel', 'Sooji hui dardnaak naaf', 'neonatal', false],
            ['navel_discharge', 'Discharge from navel', 'Naaf se mada', 'neonatal', false],
            ['joint_swelling', 'Swollen painful joints', 'Joron ki dardnaak soojan', 'musculoskeletal', false],
            ['behavior_change', 'Sudden abnormal behaviour', 'Achanak rawaiye ki tabdeeli', 'neurologic', true],
            ['swallowing_difficulty', 'Difficulty swallowing', 'Nigalne mein mushkil', 'neurologic', true],
            ['paralysis', 'Progressive paralysis', 'Barhti hui falij', 'neurologic', true],
            ['multiple_animals_affected', 'Several animals affected together', 'Kai janwar aik sath bemar', 'general', true],
        ];
        $symptomIds = [];
        foreach ($symptoms as [$code, $name, $roman, $system, $emergency]) {
            $id = (string) Str::uuid7();
            DB::table('health_symptoms')->insert([
                'id' => $id, 'code' => $code, 'name' => $name, 'name_roman_urdu' => $roman,
                'body_system' => $system, 'is_emergency' => $emergency,
                'emergency_message' => $emergency ? 'Urgent veterinary assessment is required.' : null,
                'is_active' => true, 'created_at' => $now, 'updated_at' => $now,
            ]);
            $symptomIds[$code] = $id;
        }

        $merck = 'Merck Veterinary Manual';
        $woah = 'World Organisation for Animal Health (WOAH)';
        $commonDoNot = 'Do not give human medicine, antibiotics, injections, or force liquids without veterinary direction.';
        $commonDoNotRu = 'Vet ke mashware ke baghair insano ki dawa, antibiotic, injection ya zabardasti liquid na dein.';
        $diseases = [
            ['milk_fever', 'Milk fever (hypocalcemia)', 'Doodh ka bukhar / calcium ki kami', ['cattle', 'buffalo'], 'Low blood calcium around calving can cause tremors, cold ears, weakness and inability to stand.', 'Recent calving ke qareeb calcium ki kami larzish, thanday kaan, kamzori aur khara na honay ka sabab ban sakti hai.', 'Keep the animal chest-up on deep dry bedding and call a veterinarian urgently; recumbent animals need prompt treatment.', 'Janwar ko seene ke bal narm khushk bistar par rakhein aur foran vet bulayein.', 'emergency', $merck, 'https://www.merckvetmanual.com/metabolic-disorders/parturient-paresis-in-ruminants/parturient-paresis-in-cows', [['recent_calving', 4], ['cold_ears', 4], ['muscle_tremors', 3], ['sudden_collapse', 5]]],
            ['ketosis', 'Ketosis', 'Ketosis / energy ki kami', ['cattle', 'buffalo'], 'Early-lactation energy imbalance may reduce appetite and milk and cause weight loss or acetone-like breath.', 'Doodh shuru honay ke baad energy ki kami se bhook aur doodh kam, wazan kam aur saans mein meethi boo ho sakti hai.', 'Offer the normal palatable ration and clean water; arrange same-day veterinary assessment and metabolic testing.', 'Mamool ka acha chara aur saaf pani dein aur aaj hi vet se metabolic check karwayein.', 'same_day', $merck, 'https://www.merckvetmanual.com/metabolic-disorders/ketosis-in-cattle/ketosis-in-cattle', [['recent_calving', 1], ['reduced_appetite', 3], ['reduced_milk', 3], ['sweet_breath', 5], ['weight_loss', 3]]],
            ['brucellosis', 'Brucellosis', 'Brucellosis / hamal zaya honay wali zoonotic bimari', ['cattle', 'buffalo', 'goat'], 'A contagious zoonotic disease associated with abortion, retained placenta and weak offspring.', 'Insanon ko lag sakne wali mutaddi bimari jo hamal zaya, jer na girne aur kamzor bachay se judi hai.', 'Isolate the animal and abortion materials, restrict raw milk, avoid bare-hand contact and notify a veterinarian/authority.', 'Janwar aur zaya shuda hamal ka samaan alag karein, kacha doodh band karein, nangi haath na lagayein aur vet/authority ko batayein.', 'emergency', $woah, 'https://www.woah.org/en/disease/brucellosis/', [['abortion', 5], ['retained_placenta', 3], ['weak_newborn', 3]]],
            ['anthrax', 'Anthrax suspicion', 'Anthrax ka shuba', ['cattle', 'buffalo', 'goat'], 'A rapidly fatal zoonotic disease; sudden death with dark unclotted bleeding is a critical warning pattern.', 'Tezi se jaan leva aur insanon ko lagne wali bimari; achanak maut aur gehra na jamnay wala khoon khatarnak alamat hain.', 'Do not touch, cut, skin or open the carcass. Keep people and animals away and contact veterinary authorities immediately.', 'Lash ko na chhuain, na kaatain, na khaal utarein aur na kholein. Logon aur janwaron ko door rakh kar foran authority/vet ko batayein.', 'emergency', $woah, 'https://www.woah.org/en/disease/anthrax/', [['sudden_death', 5], ['unclotted_bleeding', 5]]],
            ['blackleg', 'Blackleg', 'Black quarter / pathon ki jaan leva soojan', ['cattle', 'goat'], 'An acute clostridial disease causing severe lameness, fever and painful gas-filled muscle swelling, sometimes sudden death.', 'Tez clostridial bimari jo shadeed langrahat, bukhar, hawa wali dardnaak pathon ki soojan aur achanak maut kar sakti hai.', 'Isolate and obtain emergency veterinary help; do not cut or massage the swelling.', 'Janwar alag karein aur emergency vet bulayein; soojan ko na kaatain aur na malish karein.', 'emergency', $merck, 'https://www.merckvetmanual.com/infectious-diseases/clostridial-diseases/blackleg-in-animals', [['muscle_swelling', 5], ['lameness', 3], ['fever', 2], ['sudden_death', 4]]],
            ['theileriosis', 'Theileriosis', 'Theileriosis / cheechron ki bimari', ['cattle', 'buffalo', 'goat'], 'A tick-borne disease that may cause fever, enlarged lymph nodes, poor appetite, anemia and breathing difficulty.', 'Cheechron se phailne wali bimari jo bukhar, ghudood ki soojan, bhook ki kami, khoon ki kami aur saans ka masla kar sakti hai.', 'Keep the animal quiet with water and shade, check the herd for ticks, and seek same-day veterinary testing.', 'Janwar ko aram, saaf pani aur saya dein, rewar mein cheechray check karein aur aaj hi vet test karwayein.', 'same_day', $woah, 'https://www.woah.org/en/disease/theileriosis/', [['tick_presence', 3], ['fever', 3], ['swollen_lymph_nodes', 5], ['pale_eyelids', 2]]],
            ['babesiosis', 'Bovine babesiosis', 'Babesiosis / laal peshab wali tick bimari', ['cattle', 'buffalo'], 'A tick-borne blood parasite disease associated with fever, anemia, weakness and red or coffee-coloured urine.', 'Cheechron ki khoon wali bimari jo bukhar, khoon ki kami, kamzori aur laal/coffee rang peshab kar sakti hai.', 'Keep the animal quiet, shaded and watered and obtain urgent veterinary blood testing.', 'Janwar ko aram, saya aur pani dein aur foran vet se khoon ka test karwayein.', 'emergency', $woah, 'https://www.woah.org/en/disease/bovine-babesiosis/', [['tick_presence', 3], ['fever', 3], ['red_urine', 5], ['pale_eyelids', 3], ['weakness', 2]]],
            ['anaplasmosis', 'Bovine anaplasmosis', 'Anaplasmosis / khoon ki tick bimari', ['cattle', 'buffalo'], 'A blood-borne infection causing progressive anemia, fever, weakness and sometimes jaundice.', 'Khoon ki infection jo barhti khoon ki kami, bukhar, kamzori aur kabhi peela pan kar sakti hai.', 'Minimize movement and stress, provide water and shade, and seek urgent veterinary blood testing.', 'Chalna aur stress kam karein, pani aur saya dein aur foran vet se khoon test karwayein.', 'same_day', $merck, 'https://www.merckvetmanual.com/circulatory-system/blood-parasites/anaplasmosis-in-ruminants', [['tick_presence', 2], ['fever', 2], ['pale_eyelids', 5], ['jaundice', 4], ['weakness', 3]]],
            ['coccidiosis', 'Coccidiosis', 'Coccidiosis / khoon walay dast', ['cattle', 'buffalo', 'goat'], 'An intestinal parasite disease, especially in young animals, causing straining, diarrhea and sometimes blood and dehydration.', 'Aanton ki parasitic bimari, khas tor par bachon mein, jo zor lagana, dast, khoon aur pani ki kami kar sakti hai.', 'Separate the animal, keep bedding and water clean, offer water if swallowing normally, and seek same-day care.', 'Janwar alag karein, bistar aur pani saaf rakhein, nigal sakay to pani dein aur aaj hi vet bulayein.', 'same_day', $merck, 'https://www.merckvetmanual.com/digestive-system/coccidiosis/coccidiosis-of-cattle', [['bloody_diarrhea', 5], ['diarrhea', 3], ['straining', 4], ['dehydration', 3], ['weight_loss', 2]]],
            ['pinkeye', 'Infectious keratoconjunctivitis (pinkeye)', 'Pinkeye / aankh ki infection', ['cattle', 'buffalo', 'goat'], 'A painful contagious eye condition causing tearing, eye closure and corneal cloudiness or ulceration.', 'Dardnaak mutaddi aankh ki bimari jo pani, aankh band rakhna aur dhundlapan/zakhm kar sakti hai.', 'Move to shade, reduce dust and flies, isolate affected animals and arrange prompt eye examination.', 'Saye mein rakhein, dhool aur makhiyan kam karein, janwar alag karein aur jaldi aankh check karwayein.', 'same_day', $merck, 'https://www.merckvetmanual.com/eye-diseases-and-disorders/infectious-keratoconjunctivitis/infectious-keratoconjunctivitis-in-cattle-and-small-ruminants', [['cloudy_eye', 5], ['tearing', 3], ['eye_pain', 4]]],
            ['ringworm', 'Ringworm (dermatophytosis)', 'Daad / fungal jild ki bimari', ['cattle', 'buffalo', 'goat'], 'A contagious fungal skin disease causing circular hair loss, scales and gray-white crusts; it can infect people.', 'Mutaddi fungal jild ki bimari jo gol baal jharne, chilkon aur safed papri ka sabab banti hai aur insan ko lag sakti hai.', 'Use gloves, isolate shared grooming equipment, improve hygiene and obtain veterinary confirmation.', 'Dastanay pehnein, brush/samaan alag karein, safai behtar karein aur vet se tasdeeq karwayein.', 'routine', $merck, 'https://www.merckvetmanual.com/integumentary-system/dermatophytosis/dermatophytosis-in-cattle', [['circular_hair_loss', 5], ['crusty_skin', 4]]],
            ['mange', 'Mange', 'Kharish / mange', ['cattle', 'buffalo', 'goat'], 'Mite infestation can cause severe itching, rubbing, hair loss and crusted skin and may spread through contact.', 'Mites ki wajah se shadeed kharish, ragarna, baal jharna aur papri hoti hai aur rabtay se phail sakti hai.', 'Separate affected animals and equipment, use gloves, and seek veterinary skin examination before treatment.', 'Mutasir janwar aur samaan alag karein, dastanay pehnein aur ilaaj se pehle vet se jild check karwayein.', 'routine', $merck, 'https://www.merckvetmanual.com/integumentary-system/mange/mange-in-cattle', [['severe_itching', 5], ['circular_hair_loss', 2], ['crusty_skin', 4]]],
            ['navel_ill', 'Navel ill (omphalitis)', 'Naaf ki infection', ['cattle', 'buffalo', 'goat'], 'Newborn navel infection can cause swelling, discharge, fever, weakness and spread to joints or internal organs.', 'Naye bachay ki naaf ki infection soojan, mada, bukhar, kamzori aur joron/andarooni aza tak phail sakti hai.', 'Keep the calf warm and dry, do not squeeze or cut the navel, and obtain same-day veterinary care.', 'Bachay ko garam aur khushk rakhein, naaf ko na nichorein ya kaatain aur aaj hi vet bulayein.', 'same_day', $merck, 'https://www.merckvetmanual.com/generalized-conditions/neonatal-infection/neonatal-infection-in-large-animals', [['swollen_navel', 5], ['navel_discharge', 5], ['fever', 2], ['joint_swelling', 3], ['weakness', 2]]],
            ['rabies', 'Rabies suspicion', 'Rabies ka shuba', ['cattle', 'buffalo', 'goat'], 'A fatal zoonotic neurologic disease that can cause behaviour change, salivation, swallowing difficulty and paralysis.', 'Jaan leva aur insano ko lagne wali asabi bimari jo rawaiye ki tabdeeli, ral, nigalne mein mushkil aur falij kar sakti hai.', 'Do not approach the mouth or handle saliva. Secure the area from a safe distance and contact veterinary/public-health authorities immediately.', 'Munh ke qareeb na jayein aur ral ko na chhuain. Mehfooz faslay se jagah band karein aur foran veterinary/public-health authority ko batayein.', 'emergency', $woah, 'https://www.woah.org/en/disease/rabies/', [['behavior_change', 5], ['excess_saliva', 2], ['swallowing_difficulty', 5], ['paralysis', 4]]],
            ['poisoning', 'Suspected poisoning', 'Zeher ka shuba', ['cattle', 'buffalo', 'goat'], 'Sudden illness in several animals, collapse, salivation, breathing or neurologic signs may indicate toxic exposure.', 'Kai janwaron ka achanak bemar hona, girna, ral, saans ya asabi alamat zeher ka shuba ho sakti hain.', 'Remove access to suspected feed/water without entering a hazardous area, save labels/samples safely, and call a veterinarian immediately.', 'Mashkook chara/pani band karein magar khatarnak jagah mein na jayein, label/sample mehfooz rakhein aur foran vet bulayein.', 'emergency', $merck, 'https://www.merckvetmanual.com/toxicology/overview-of-toxicology/overview-of-veterinary-toxicology', [['multiple_animals_affected', 5], ['sudden_collapse', 3], ['excess_saliva', 2], ['neurologic_signs', 4], ['breathing_difficulty', 3]]],
        ];

        foreach ($diseases as [$code, $name, $nameRu, $species, $summary, $summaryRu, $care, $careRu, $urgency, $sourceTitle, $sourceUrl, $links]) {
            $id = (string) Str::uuid7();
            DB::table('health_diseases')->insert([
                'id' => $id, 'code' => $code, 'name' => $name, 'name_roman_urdu' => $nameRu,
                'species' => json_encode($species), 'summary' => $summary, 'summary_roman_urdu' => $summaryRu,
                'immediate_care' => $care, 'immediate_care_roman_urdu' => $careRu,
                'confirmation_guidance' => 'A veterinarian must examine the animal and select appropriate laboratory or field tests.',
                'confirmation_guidance_roman_urdu' => 'Vet janwar ka muaina karke munasib laboratory ya field test select karega.',
                'safe_home_care' => $care, 'safe_home_care_roman_urdu' => $careRu,
                'do_not_do' => $commonDoNot, 'do_not_do_roman_urdu' => $commonDoNotRu,
                'feed_water_guidance' => 'Keep clean water available only when the animal can swallow safely; avoid sudden ration changes.',
                'feed_water_guidance_roman_urdu' => 'Sirf theek se nigal sakne par saaf pani dein aur achanak chara tabdeel na karein.',
                'urgency' => $urgency, 'source_title' => $sourceTitle, 'source_url' => $sourceUrl,
                'source_reviewed_on' => '2026-08-16', 'review_status' => 'approved', 'reviewed_at' => $now,
                'knowledge_version' => 1, 'is_active' => true, 'created_at' => $now, 'updated_at' => $now,
            ]);
            DB::table('health_knowledge_sources')->insert([
                'id' => (string) Str::uuid7(), 'disease_id' => $id, 'title' => $sourceTitle,
                'url' => $sourceUrl, 'url_hash' => hash('sha256', $sourceUrl), 'publisher' => $sourceTitle,
                'source_type' => 'authoritative_veterinary_reference', 'accessed_on' => '2026-08-16',
                'evidence_scope' => 'Disease summary, clinical signs, urgency, immediate management and confirmation.',
                'is_primary' => true, 'created_at' => $now, 'updated_at' => $now,
            ]);
            foreach ($links as [$symptom, $weight]) {
                DB::table('health_disease_symptom')->insert([
                    'disease_id' => $id, 'symptom_id' => $symptomIds[$symptom] ?? DB::table('health_symptoms')->where('code', $symptom)->value('id'),
                    'weight' => $weight, 'is_key' => $weight >= 4,
                ]);
            }
        }

        $evaluations = [
            ['MILK-FEVER', 'cattle', 'My cow calved yesterday, has cold ears and tremors, and cannot stand.', 'Meri gai ne kal bacha diya, kaan thanday aur larzish hai aur khari nahi ho sakti.', ['recent_calving', 'cold_ears', 'muscle_tremors', 'sudden_collapse'], 'milk_fever', true],
            ['KETOSIS', 'cattle', 'After calving my cow is eating less, losing milk and weight, and her breath smells sweet.', 'Bacha dene ke baad gai ki bhook, doodh aur wazan kam hai aur saans mein meethi boo hai.', ['recent_calving', 'reduced_appetite', 'reduced_milk', 'weight_loss', 'sweet_breath'], 'ketosis', false],
            ['BRUCELLOSIS', 'goat', 'My goat aborted and retained the placenta; the newborn was weak.', 'Meri bakri ka hamal zaya hua, jer nahi giri aur bacha kamzor tha.', ['abortion', 'retained_placenta', 'weak_newborn'], 'brucellosis', true],
            ['ANTHRAX', 'cattle', 'A cow died suddenly and dark blood that does not clot is coming from an opening.', 'Gai achanak mar gai aur surakh se gehra khoon aa raha hai jo jamta nahi.', ['sudden_death', 'unclotted_bleeding'], 'anthrax', true],
            ['BLACKLEG', 'cattle', 'My young cow has fever, severe lameness and painful swelling in a large muscle.', 'Jawan gai ko bukhar, shadeed langrahat aur pathon mein dardnaak soojan hai.', ['fever', 'lameness', 'muscle_swelling'], 'blackleg', true],
            ['THEILERIOSIS', 'buffalo', 'My buffalo has ticks, fever, swollen lymph nodes and pale eyelids.', 'Meri bhains par cheechray, bukhar, ghudood ki soojan aur pheeki palkain hain.', ['tick_presence', 'fever', 'swollen_lymph_nodes', 'pale_eyelids'], 'theileriosis', false],
            ['BABESIOSIS', 'cattle', 'My cow has ticks, fever, weakness and red urine.', 'Meri gai par cheechray hain, bukhar, kamzori aur laal peshab hai.', ['tick_presence', 'fever', 'weakness', 'red_urine'], 'babesiosis', true],
            ['ANAPLASMOSIS', 'cattle', 'My cow has ticks, pale eyelids, yellow gums and progressive weakness.', 'Meri gai par cheechray, pheeki palkain, peelay masooray aur barhti kamzori hai.', ['tick_presence', 'pale_eyelids', 'jaundice', 'weakness'], 'anaplasmosis', false],
            ['COCCIDIOSIS', 'goat', 'My young goat strains and has bloody diarrhea and dehydration.', 'Meri choti bakri zor lagati hai aur khoon walay dast aur pani ki kami hai.', ['straining', 'bloody_diarrhea', 'dehydration'], 'coccidiosis', true],
            ['PINKEYE', 'cattle', 'My cow keeps a painful eye closed; it is tearing and cloudy.', 'Meri gai dard wali aankh band rakhti hai, pani aa raha aur aankh dhundli hai.', ['eye_pain', 'tearing', 'cloudy_eye'], 'pinkeye', false],
            ['RINGWORM', 'cattle', 'My calf has round patches of hair loss with gray crusts and little itching.', 'Meray bachray ke baal gol daaghon mein jharay aur safed papri hai, kharish kam hai.', ['circular_hair_loss', 'crusty_skin'], 'ringworm', false],
            ['MANGE', 'goat', 'My goat has severe itching, rubbing, hair loss and crusty skin.', 'Meri bakri ko shadeed kharish, ragarna, baal jharna aur papri wali jild hai.', ['severe_itching', 'circular_hair_loss', 'crusty_skin'], 'mange', false],
            ['NAVEL-ILL', 'cattle', 'My newborn calf has a swollen navel with discharge, fever and a swollen joint.', 'Naye bachray ki naaf sooji hai aur mada aa raha hai, bukhar aur jor soojha hai.', ['swollen_navel', 'navel_discharge', 'fever', 'joint_swelling'], 'navel_ill', false],
            ['RABIES', 'goat', 'My goat suddenly behaves abnormally, drools, cannot swallow and is becoming paralyzed.', 'Meri bakri ka rawaiya achanak badla, ral aa rahi, nigal nahi sakti aur falij barh raha hai.', ['behavior_change', 'excess_saliva', 'swallowing_difficulty', 'paralysis'], 'rabies', true],
            ['POISONING', 'buffalo', 'Several buffalo became sick together with salivation, breathing difficulty and collapse.', 'Kai bhains aik sath bemar hain, ral, saans mein mushkil aur girna shuru hua.', ['multiple_animals_affected', 'excess_saliva', 'breathing_difficulty', 'sudden_collapse'], 'poisoning', true],
        ];
        foreach ($evaluations as [$suffix, $species, $english, $roman, $signs, $expected, $emergency]) {
            DB::table('health_ai_evaluation_cases')->insert([
                'id' => (string) Str::uuid7(), 'case_code' => 'EVAL-'.$suffix.'-01', 'species' => $species,
                'question_en' => $english, 'question_roman_urdu' => $roman,
                'symptom_codes' => json_encode($signs), 'expected_disease_codes' => json_encode([$expected]),
                'expected_emergency' => $emergency, 'expects_match' => true, 'review_status' => 'approved',
                'review_notes' => 'Source-grounded expansion benchmark; no medicine or dose recommendation.',
                'created_at' => $now, 'updated_at' => $now,
            ]);
        }
    }

    public function down(): void
    {
        $codes = ['milk_fever', 'ketosis', 'brucellosis', 'anthrax', 'blackleg', 'theileriosis', 'babesiosis', 'anaplasmosis', 'coccidiosis', 'pinkeye', 'ringworm', 'mange', 'navel_ill', 'rabies', 'poisoning'];
        DB::table('health_ai_evaluation_cases')->whereIn('case_code', ['EVAL-MILK-FEVER-01', 'EVAL-KETOSIS-01', 'EVAL-BRUCELLOSIS-01', 'EVAL-ANTHRAX-01', 'EVAL-BLACKLEG-01', 'EVAL-THEILERIOSIS-01', 'EVAL-BABESIOSIS-01', 'EVAL-ANAPLASMOSIS-01', 'EVAL-COCCIDIOSIS-01', 'EVAL-PINKEYE-01', 'EVAL-RINGWORM-01', 'EVAL-MANGE-01', 'EVAL-NAVEL-ILL-01', 'EVAL-RABIES-01', 'EVAL-POISONING-01'])->delete();
        DB::table('health_diseases')->whereIn('code', $codes)->delete();
        DB::table('health_symptoms')->whereIn('code', ['recent_calving', 'cold_ears', 'muscle_tremors', 'sweet_breath', 'weight_loss', 'abortion', 'weak_newborn', 'sudden_death', 'unclotted_bleeding', 'muscle_swelling', 'tick_presence', 'red_urine', 'jaundice', 'weakness', 'bloody_diarrhea', 'straining', 'cloudy_eye', 'tearing', 'eye_pain', 'circular_hair_loss', 'crusty_skin', 'severe_itching', 'swollen_navel', 'navel_discharge', 'joint_swelling', 'behavior_change', 'swallowing_difficulty', 'paralysis', 'multiple_animals_affected'])->delete();
    }
};
