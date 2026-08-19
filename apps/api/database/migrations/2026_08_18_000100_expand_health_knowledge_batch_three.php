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
            ['oral_erosions', 'Painful mouth erosions', 'Munh mein dardnaak chalay', 'oral', true],
            ['profuse_diarrhea', 'Profuse watery diarrhea', 'Bohat zyada pani walay dast', 'digestive', true],
            ['chest_pain', 'Painful breathing or chest pain', 'Saans par dard ya seene ka dard', 'respiratory', true],
            ['abdominal_pain', 'Abdominal pain or kicking at belly', 'Pait ka dard ya pait ko laat marna', 'digestive', false],
            ['convulsions', 'Convulsions or paddling', 'Doray ya tangain chalana', 'neurologic', true],
            ['edema', 'Body or dependent swelling', 'Jism ya neechay hissay mein soojan', 'general', false],
            ['chronic_diarrhea', 'Persistent chronic diarrhea', 'Purane musalsal dast', 'digestive', false],
            ['normal_appetite_weight_loss', 'Weight loss despite eating', 'Khanay ke bawajood wazan kam', 'general', false],
            ['recent_grain_change', 'Recent grain overload or sudden ration change', 'Haal hi mein zyada dana ya achanak ration tabdeeli', 'nutrition', false],
            ['loose_sour_stool', 'Loose sour-smelling gray stool', 'Patla khatta badbudar surmai gobar', 'digestive', false],
            ['swollen_hard_tongue', 'Hard swollen protruding tongue', 'Sakht sooji bahar nikli zaban', 'oral', true],
            ['post_calving_red_urine', 'Red-brown urine after calving', 'Bacha dene ke baad laal bhoora peshab', 'urinary', true],
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

        $commonDoNot = 'Do not give human medicines, start antibiotics, inject products, force liquids, or use an unverified dose.';
        $commonDoNotRu = 'Insano ki dawa, antibiotic, injection, zabardasti liquid ya ghair tasdeeq shuda dose na dein.';
        $diseases = [
            ['ppr', 'Peste des petits ruminants (PPR)', 'PPR / bakri bher ki plague', ['goat'], 'A highly contagious viral disease causing fever, mouth erosions, eye/nose discharge, diarrhea and pneumonia.', 'Tezi se phailne wali viral bimari jo bukhar, munh ke chalay, aankh/naak ka mada, dast aur pneumonia karti hai.', 'Isolate immediately, stop movement and shared equipment, keep warm and dry, and offer clean water/soft feed only if swallowing safely.', 'Foran alag karein, amad-o-raft aur mushtarka samaan band karein, garam khushk rakhein aur nigal sakay to pani/narm chara dein.', 'Supportive fluids and secondary-infection treatment are selected by a veterinarian; there is no antiviral cure. Prevention is vaccination and biosecurity.', 'Vet supportive fluids aur secondary infection ka ilaaj select karta hai; viral cure nahi. Bachao vaccination aur biosecurity hai.', 'emergency', 'Merck Veterinary Manual', 'https://www.merckvetmanual.com/generalized-conditions/peste-des-petits-ruminants/peste-des-petits-ruminants', [['fever',3],['oral_erosions',5],['nasal_discharge',3],['profuse_diarrhea',4],['cough',2],['breathing_difficulty',3]]],
            ['ccpp', 'Contagious caprine pleuropneumonia', 'CCPP / bakri ka mutaddi phephron ka infection', ['goat'], 'A severe contagious goat respiratory disease causing high fever, painful difficult breathing, cough and nasal discharge.', 'Bakriyon ki shadeed mutaddi saans ki bimari jo tez bukhar, dardnaak mushkil saans, khansi aur naak ka mada karti hai.', 'Isolate, stop goat movement, improve ventilation without chilling, minimize handling and provide water if swallowing.', 'Alag karein, bakriyon ki amad-o-raft band karein, thand lagaye baghair hawa behtar karein, handling kam aur nigal sakay to pani dein.', 'Veterinary antimicrobial selection and supportive care should follow examination and sampling; vaccination supports prevention where available.', 'Vet muaina aur sample ke baad antibiotic aur supportive care select kare; dastiyab ho to vaccine bachao mein madad karti hai.', 'emergency', 'World Organisation for Animal Health (WOAH)', 'https://www.woah.org/en/disease/contagious-caprine-pleuropneumonia/', [['fever',3],['cough',3],['nasal_discharge',2],['breathing_difficulty',5],['chest_pain',5]]],
            ['enterotoxemia', 'Enterotoxemia', 'Enterotoxemia / dana khanay wali clostridial bimari', ['goat'], 'Clostridial toxin disease often associated with rich feed or sudden diet change; it may cause abdominal pain, diarrhea, neurologic signs or sudden death.', 'Clostridial zehar ki bimari jo ameer charay ya achanak ration tabdeeli ke baad pait dard, dast, asabi alamat ya achanak maut kar sakti hai.', 'Remove concentrate feed, isolate, keep quiet and obtain emergency help; do not drench a weak, bloated or convulsing animal.', 'Dana hata dein, alag aur pur-sukoon rakhein; kamzor, phoolay ya doray walay janwar ko zabardasti drench na karein.', 'A veterinarian may use antitoxin early plus fluids and other supportive treatment. Routine prevention uses appropriate clostridial vaccination and gradual feed changes.', 'Vet jaldi antitoxin, fluids aur supportive ilaaj use kar sakta hai. Bachao clostridial vaccine aur ahista feed tabdeeli se hota hai.', 'emergency', 'Merck Veterinary Manual', 'https://www.merckvetmanual.com/infectious-diseases/clostridial-diseases/enterotoxemias-in-animals', [['recent_grain_change',4],['abdominal_pain',4],['diarrhea',2],['convulsions',5],['sudden_death',5]]],
            ['surra', 'Trypanosoma evansi infection (surra)', 'Surra / trypanosomiasis', ['cattle','buffalo','goat'], 'A blood parasite spread mainly by biting flies, causing intermittent fever, anemia, weakness, weight loss and sometimes edema or neurologic disease.', 'Khoon ka parasite jo kaatne wali makhiyon se phail kar aata jata bukhar, khoon ki kami, kamzori, wazan ki kami aur soojan/asabi masla karta hai.', 'Rest in shade, reduce fly exposure, provide water and arrange blood testing; severe weakness or neurologic signs are urgent.', 'Saye mein aram, makhiyon se bachao, pani aur khoon ka test karwayein; shadeed kamzori ya asabi alamat urgent hain.', 'Veterinary treatment uses a locally effective trypanocidal medicine selected for species, resistance risk and label restrictions; vector control is essential.', 'Vet species, resistance aur label dekh kar trypanocidal dawa select karta hai; makhi control zaroori hai.', 'same_day', 'WOAH Technical Disease Card', 'https://rr-middleeast.woah.org/en/technical-disease-cards/', [['fever',2],['pale_eyelids',4],['weakness',3],['weight_loss',3],['edema',3],['neurologic_signs',2]]],
            ['fasciolosis', 'Fasciolosis (liver fluke)', 'Jigar ka keera / fasciolosis', ['cattle','buffalo','goat'], 'Liver fluke disease can cause anemia, weight loss, bottle jaw, reduced production and sometimes severe weakness.', 'Jigar ke keeray se khoon ki kami, wazan aur paidawar kam, jabray ke neechay soojan aur kamzori hoti hai.', 'Provide clean water and adequate nutrition, avoid wet snail-infested grazing and arrange fecal/blood testing rather than blind deworming.', 'Saaf pani aur munasib ghiza dein, geeli snail wali charagah se bachayein aur andha deworming ke bajaye test karwayein.', 'A veterinarian selects a flukicide effective for the parasite stage and local resistance pattern and verifies milk/meat withdrawal.', 'Vet parasite ke stage aur local resistance ke mutabiq flukicide aur doodh/gosht withdrawal check karta hai.', 'same_day', 'Merck Veterinary Manual', 'https://www.merckvetmanual.com/digestive-system/fluke-infections-in-ruminants/fasciola-hepatica-in-ruminants', [['pale_eyelids',4],['bottle_jaw',4],['weight_loss',3],['weakness',2],['reduced_milk',2]]],
            ['johnes', "Paratuberculosis (Johne's disease)", 'Johne ki bimari / purane dast aur wazan ki kami', ['cattle','buffalo','goat'], 'A chronic contagious intestinal infection causing progressive weight loss and, especially in cattle, persistent diarrhea.', 'Purani mutaddi aant ki infection jo musalsal wazan kam aur khas tor par gai mein purane dast karti hai.', 'Separate the animal, prevent manure contamination of calf areas, do not feed contaminated colostrum/milk, and arrange herd testing.', 'Janwar alag karein, bachon ki jagah ko gobar se bachayein, alooda colostrum/doodh na pilayein aur herd testing karwayein.', 'PCR/culture and herd-level interpretation are required. There is no satisfactory curative treatment; control depends on testing and hygiene.', 'PCR/culture aur herd level tashreeh chahiye. Mukammal shifa ka moassar ilaaj nahi; control testing aur safai se hai.', 'routine', 'Merck Veterinary Manual', 'https://www.merckvetmanual.com/digestive-system/intestinal-diseases-in-ruminants/paratuberculosis-in-ruminants', [['chronic_diarrhea',5],['normal_appetite_weight_loss',5],['weight_loss',4],['reduced_milk',2]]],
            ['ruminal_acidosis', 'Ruminal acidosis / grain overload', 'Rumen acidosis / zyada dana', ['cattle','buffalo','goat'], 'Excess rapidly fermentable feed or abrupt ration change can cause appetite loss, lethargy, loose sour stool, dehydration, bloat and collapse.', 'Zyada jaldi hazam honay wala dana ya achanak ration tabdeeli bhook band, susti, khatta patla gobar, pani ki kami, bloat aur girna kar sakti hai.', 'Remove grain, offer good hay and water only if swallowing normally, keep quiet and seek urgent help for bloat, dehydration or inability to stand.', 'Dana hata kar acha hay dein, nigal sakay to pani, pur-sukoon rakhein; bloat, pani ki kami ya khara na ho sakay to urgent madad lein.', 'Treatment depends on rumen pH and severity and may require rumen emptying, fluids, alkalinizing therapy and transfaunation by a veterinarian.', 'Ilaaj rumen pH aur shiddat par hai; vet ko rumen khali, fluids, alkalinizing therapy ya transfaunation karni par sakti hai.', 'emergency', 'Merck Veterinary Manual', 'https://www.merckvetmanual.com/digestive-system/diseases-of-the-ruminant-forestomach/grain-overload-in-ruminants', [['recent_grain_change',5],['reduced_appetite',2],['loose_sour_stool',4],['dehydration',3],['left_bloat',2],['sudden_collapse',3]]],
            ['wooden_tongue', 'Actinobacillosis (wooden tongue)', 'Wooden tongue / sakht sooji zaban', ['cattle','buffalo'], 'Bacterial soft-tissue disease most characteristically causing a hard swollen painful tongue, drooling and inability to eat or swallow.', 'Bacterial soft tissue bimari jo khas tor par sakht sooji dardnaak zaban, ral aur khanay/nigalne ki mushkil karti hai.', 'Offer soft feed and water only if swallowing safely, remove coarse traumatic feed and seek same-day treatment.', 'Nigal sakay to narm chara aur pani dein, sakht chubhne wala chara hata dein aur aaj hi ilaaj karwayein.', 'Veterinary treatment commonly uses iodide therapy and an appropriate antimicrobial after examination; response is best when treated early.', 'Vet muaina ke baad aam tor par iodide therapy aur munasib antimicrobial use karta hai; jaldi ilaaj behtar hai.', 'same_day', 'Merck Veterinary Manual', 'https://www.merckvetmanual.com/infectious-diseases/actinobacillosis/actinobacillosis-in-cattle-and-other-animals', [['swollen_hard_tongue',5],['excess_saliva',3],['swallowing_difficulty',4],['reduced_appetite',2]]],
            ['postparturient_hemoglobinuria', 'Post-parturient hemoglobinuria', 'Bacha dene ke baad laal peshab / phosphorus ki kami', ['cattle','buffalo'], 'A severe red-cell breakdown syndrome around early lactation, often associated with low phosphorus, causing red-brown urine, anemia and weakness.', 'Doodh shuru honay ke qareeb khoon ke cells tootne ki shadeed halat, aksar phosphorus kami se, jo laal bhoora peshab, khoon ki kami aur kamzori karti hai.', 'Keep the animal quiet, shaded and watered, avoid walking, record calving date and obtain urgent blood and urine assessment.', 'Janwar ko aram, saya aur pani dein, chalayein nahi, bacha dene ki tareekh likhein aur foran khoon/peshab check karwayein.', 'A veterinarian confirms hemolysis and phosphorus status; treatment can require phosphorus correction, supportive fluids and transfusion in severe anemia.', 'Vet hemolysis aur phosphorus check karta hai; ilaaj mein phosphorus correction, fluids aur shadeed anemia mein khoon lag sakta hai.', 'emergency', 'Merck Veterinary Manual', 'https://www.merckvetmanual.com/metabolic-disorders/disorders-of-phosphorus-metabolism/postparturient-hemoglobinuria-in-dairy-cows', [['recent_calving',3],['post_calving_red_urine',5],['pale_eyelids',4],['weakness',3],['reduced_milk',2]]],
        ];

        $codes = [];
        foreach ($diseases as [$code,$name,$roman,$species,$summary,$summaryRu,$care,$careRu,$treatment,$treatmentRu,$urgency,$source,$url,$links]) {
            $codes[] = $code;
            $id = (string) Str::uuid7();
            DB::table('health_diseases')->insert([
                'id'=>$id,'code'=>$code,'name'=>$name,'name_roman_urdu'=>$roman,'species'=>json_encode($species),
                'summary'=>$summary,'summary_roman_urdu'=>$summaryRu,'immediate_care'=>$care,'immediate_care_roman_urdu'=>$careRu,
                'confirmation_guidance'=>$treatment,'confirmation_guidance_roman_urdu'=>$treatmentRu,
                'safe_home_care'=>$care,'safe_home_care_roman_urdu'=>$careRu,'do_not_do'=>$commonDoNot,'do_not_do_roman_urdu'=>$commonDoNotRu,
                'feed_water_guidance'=>'Provide clean water only if swallowing is safe and follow the disease-specific feeding precautions above.',
                'feed_water_guidance_roman_urdu'=>'Sirf mehfooz nigal sakne par saaf pani dein aur upar wali bimari ki feed ehtiyat par amal karein.',
                'urgency'=>$urgency,'source_title'=>$source,'source_url'=>$url,'source_reviewed_on'=>'2026-08-18',
                'review_status'=>'approved','reviewed_at'=>$now,'knowledge_version'=>1,'is_active'=>true,'created_at'=>$now,'updated_at'=>$now,
            ]);
            DB::table('health_knowledge_sources')->insert([
                'id'=>(string)Str::uuid7(),'disease_id'=>$id,'title'=>$source,'url'=>$url,'url_hash'=>hash('sha256',$url),
                'publisher'=>$source,'source_type'=>'authoritative_veterinary_reference','accessed_on'=>'2026-08-18',
                'evidence_scope'=>'Disease identity, signs, first aid, treatment approach, prevention and confirmation.',
                'is_primary'=>true,'created_at'=>$now,'updated_at'=>$now,
            ]);
            foreach ($links as [$symptom,$weight]) {
                $symptomId = $symptomIds[$symptom] ?? DB::table('health_symptoms')->where('code',$symptom)->value('id');
                DB::table('health_disease_symptom')->insert(['disease_id'=>$id,'symptom_id'=>$symptomId,'weight'=>$weight,'is_key'=>$weight>=4]);
            }
        }
    }

    public function down(): void
    {
        $codes = ['ppr','ccpp','enterotoxemia','surra','fasciolosis','johnes','ruminal_acidosis','wooden_tongue','postparturient_hemoglobinuria'];
        DB::table('health_diseases')->whereIn('code',$codes)->delete();
        DB::table('health_symptoms')->whereIn('code',['oral_erosions','profuse_diarrhea','chest_pain','abdominal_pain','convulsions','edema','chronic_diarrhea','normal_appetite_weight_loss','recent_grain_change','loose_sour_stool','swollen_hard_tongue','post_calving_red_urine'])->delete();
    }
};
