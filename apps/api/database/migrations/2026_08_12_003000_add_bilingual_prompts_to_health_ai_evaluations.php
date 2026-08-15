<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('health_ai_evaluation_cases', function (Blueprint $table): void {
            $table->text('question_en')->nullable()->after('species');
            $table->text('question_roman_urdu')->nullable()->after('question_en');
        });

        $questions = [
            'EVAL-FMD-01' => [
                'My cow has mouth blisters, excessive saliva and sores around the feet. What should I do?',
                'Meri gai ke munh mein chalay hain, bohat ral aa rahi hai aur khuron par zakhm hain. Kya karun?',
            ],
            'EVAL-BLOAT-01' => [
                'My goat has a swollen left belly and is struggling to breathe. What should I do?',
                'Meri bakri ka baen pait phoola hua hai aur saans lene mein mushkil hai. Kya karun?',
            ],
            'EVAL-MASTITIS-01' => [
                'My buffalo has a swollen udder and abnormal milk with clots. What should I do?',
                'Meri bhains ka than soojha hua hai aur doodh mein phattiyan hain. Kya karun?',
            ],
        ];

        foreach ($questions as $caseCode => [$english, $romanUrdu]) {
            DB::table('health_ai_evaluation_cases')->where('case_code', $caseCode)->update([
                'question_en' => $english,
                'question_roman_urdu' => $romanUrdu,
                'updated_at' => now(),
            ]);
        }
    }

    public function down(): void
    {
        Schema::table('health_ai_evaluation_cases', function (Blueprint $table): void {
            $table->dropColumn(['question_en', 'question_roman_urdu']);
        });
    }
};
