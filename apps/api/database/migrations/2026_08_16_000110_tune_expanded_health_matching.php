<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $diseaseId = DB::table('health_diseases')->where('code', 'ketosis')->value('id');
        $symptomId = DB::table('health_symptoms')->where('code', 'recent_calving')->value('id');
        if ($diseaseId && $symptomId) {
            DB::table('health_disease_symptom')->updateOrInsert(
                ['disease_id' => $diseaseId, 'symptom_id' => $symptomId],
                ['weight' => 1, 'is_key' => false],
            );
        }
    }

    public function down(): void
    {
        $diseaseId = DB::table('health_diseases')->where('code', 'ketosis')->value('id');
        $symptomId = DB::table('health_symptoms')->where('code', 'recent_calving')->value('id');
        DB::table('health_disease_symptom')->where('disease_id', $diseaseId)->where('symptom_id', $symptomId)->delete();
    }
};
