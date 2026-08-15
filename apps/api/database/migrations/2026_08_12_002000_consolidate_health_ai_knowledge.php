<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

return new class extends Migration {
    public function up(): void {
        Schema::table('health_diseases', function(Blueprint $t):void {
            $t->text('do_not_do')->nullable()->after('safe_home_care_roman_urdu');
            $t->text('do_not_do_roman_urdu')->nullable()->after('do_not_do');
            $t->text('feed_water_guidance')->nullable()->after('do_not_do_roman_urdu');
            $t->text('feed_water_guidance_roman_urdu')->nullable()->after('feed_water_guidance');
        });
        Schema::create('health_knowledge_sources', function(Blueprint $t):void {
            $t->uuid('id')->primary(); $t->uuid('disease_id'); $t->string('title',255); $t->string('url',1000); $t->char('url_hash',64);
            $t->string('publisher',160)->nullable(); $t->string('source_type',40); $t->date('accessed_on');
            $t->string('evidence_scope',500); $t->boolean('is_primary')->default(false); $t->timestamps();
            $t->unique(['disease_id','url_hash'],'health_source_disease_url_unique'); $t->foreign('disease_id')->references('id')->on('health_diseases')->cascadeOnDelete();
        });
        Schema::create('health_disease_medicine_evidence', function(Blueprint $t):void {
            $t->uuid('id')->primary(); $t->uuid('disease_id'); $t->string('active_ingredient',180);
            $t->string('indication',500); $t->text('contraindications')->nullable(); $t->text('withdrawal_guidance')->nullable();
            $t->uuid('source_id'); $t->string('review_status',24)->default('pending_review'); $t->uuid('reviewed_by')->nullable(); $t->dateTime('reviewed_at')->nullable(); $t->timestamps();
            $t->foreign('disease_id')->references('id')->on('health_diseases')->cascadeOnDelete(); $t->foreign('source_id')->references('id')->on('health_knowledge_sources')->restrictOnDelete();
        });
        Schema::create('health_ai_evaluation_cases', function(Blueprint $t):void {
            $t->uuid('id')->primary(); $t->string('case_code',80)->unique(); $t->string('species',30); $t->json('symptom_codes');
            $t->json('expected_disease_codes'); $t->boolean('expected_emergency'); $t->string('review_status',24)->default('pending_review');
            $t->text('review_notes')->nullable(); $t->timestamps();
        });
        foreach(DB::table('health_diseases')->get() as $d) DB::table('health_knowledge_sources')->insert(['id'=>(string)Str::uuid7(),'disease_id'=>$d->id,'title'=>$d->source_title,'url'=>$d->source_url,'url_hash'=>hash('sha256',$d->source_url),'source_type'=>'veterinary_reference','accessed_on'=>$d->source_reviewed_on,'evidence_scope'=>'Disease summary, signs, urgency, immediate care and confirmation guidance.','is_primary'=>true,'created_at'=>now(),'updated_at'=>now()]);
        DB::table('health_diseases')->update(['do_not_do'=>'Do not give prescription medicine, force liquids, or sell abnormal/restricted milk without veterinary direction.','do_not_do_roman_urdu'=>'Vet ke mashware ke baghair prescription dawa na dein, zabardasti pani na pilayen, aur ghair mamooli ya restricted doodh na bechein.','feed_water_guidance'=>'Keep clean water available when the animal can swallow safely. Do not make sudden feed changes; follow disease-specific immediate care and veterinary advice.','feed_water_guidance_roman_urdu'=>'Agar janwar theek se nigal sakta ho to saaf pani dein. Achanak chara tabdeel na karein; bimari ki foran dekh bhaal aur vet ke mashware par amal karein.']);
        foreach([['EVAL-FMD-01','cattle',['mouth_blisters','excess_saliva','foot_lesions'],['fmd'],true],['EVAL-BLOAT-01','goat',['left_bloat','breathing_difficulty'],['bloat'],true],['EVAL-MASTITIS-01','buffalo',['udder_swelling','abnormal_milk'],['mastitis'],false]] as [$code,$species,$symptoms,$expected,$emergency]) DB::table('health_ai_evaluation_cases')->insert(['id'=>(string)Str::uuid7(),'case_code'=>$code,'species'=>$species,'symptom_codes'=>json_encode($symptoms),'expected_disease_codes'=>json_encode($expected),'expected_emergency'=>$emergency,'review_status'=>'approved','review_notes'=>'Seeded from the approved deterministic knowledge base; requires periodic veterinary re-review.','created_at'=>now(),'updated_at'=>now()]);
        DB::table('permissions')->updateOrInsert(['name'=>'health.ai.export'],['id'=>(string)Str::uuid7(),'created_at'=>now(),'updated_at'=>now()]);
    }
    public function down():void { Schema::dropIfExists('health_ai_evaluation_cases'); Schema::dropIfExists('health_disease_medicine_evidence'); Schema::dropIfExists('health_knowledge_sources'); Schema::table('health_diseases',fn(Blueprint $t)=>$t->dropColumn(['do_not_do','do_not_do_roman_urdu','feed_water_guidance','feed_water_guidance_roman_urdu'])); DB::table('permissions')->where('name','health.ai.export')->delete(); }
};
