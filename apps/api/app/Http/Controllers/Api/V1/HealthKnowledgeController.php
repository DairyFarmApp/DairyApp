<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\AnimalHealth\Models\HealthDisease;
use App\Domain\AnimalHealth\Models\HealthKnowledgeReview;
use App\Domain\AnimalHealth\Services\HealthAiDatasetService;
use App\Domain\AnimalHealth\Services\HealthRagService;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\HealthAiAskRequest;
use App\Http\Requests\Api\V1\HealthAiEvaluationReviewRequest;
use App\Http\Requests\Api\V1\HealthKnowledgeReviewRequest;
use App\Http\Requests\Api\V1\HealthMedicineEvidenceReviewRequest;
use App\Http\Requests\Api\V1\HealthMedicineEvidenceStoreRequest;
use App\Support\ApiResponse;
use App\Support\AuditService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\Response;

class HealthKnowledgeController extends Controller
{
    public function __construct(private readonly AuditService $audit, private readonly HealthAiDatasetService $datasets, private readonly HealthRagService $rag) {}

    public function index(Request $request): JsonResponse
    {
        $query = HealthDisease::query()->with('symptoms')->where('is_active', true);
        if (! $request->attributes->get('membership')->can('health.knowledge.review')) {
            $query->where('review_status', 'approved');
        }
        if ($request->filled('species')) {
            $query->whereJsonContains('species', strtolower((string) $request->query('species')));
        }
        if ($request->filled('search')) {
            $search = '%'.strtolower((string) $request->query('search')).'%';
            $query->where(fn ($q) => $q->whereRaw('LOWER(name) LIKE ?', [$search])->orWhereRaw('LOWER(COALESCE(name_roman_urdu, ?)) LIKE ?', ['', $search]));
        }

        return ApiResponse::success($request, $query->orderBy('name')->get()->map(fn ($d) => $this->payload($d))->all());
    }

    public function review(HealthKnowledgeReviewRequest $request, string $disease): JsonResponse
    {
        $model = HealthDisease::query()->with('symptoms')->findOrFail($disease);
        $data = $request->validated();
        DB::transaction(function () use ($request, $model, $data): void {
            HealthKnowledgeReview::query()->create([...$data, 'disease_id' => $model->id, 'reviewed_by' => $request->user()->id]);
            $model->forceFill(['review_status' => $data['decision'], 'reviewed_by' => $request->user()->id, 'reviewed_at' => now(), 'knowledge_version' => $model->knowledge_version + 1])->save();
            $this->audit->record($request, 'health_knowledge.reviewed', 'health_disease', $model->id, null, ['decision' => $data['decision'], 'reviewer_registration' => $data['reviewer_registration']]);
        });

        return ApiResponse::success($request, $this->payload($model->refresh()->load('symptoms')));
    }

    public function export(Request $request): Response
    {
        $data = $this->datasets->export();
        $this->audit->record($request, 'health_ai.dataset_exported', 'health_ai_dataset', null, null, ['disease_count' => count($data['diseases']), 'evaluation_count' => count($data['evaluation_cases'])]);

        return response(json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE), 200, ['Content-Type' => 'application/json', 'Content-Disposition' => 'attachment; filename="dairycare-health-ai-dataset.json"']);
    }

    public function ask(HealthAiAskRequest $request): JsonResponse
    {
        $d = $request->validated();
        $result = $this->rag->ask($d['question'], $d['species'], $d['symptom_codes'] ?? [], $d['language'] ?? 'both');
        $this->audit->record($request, 'health_ai.question_answered', 'health_ai_query', null, null, ['species' => $d['species'], 'symptom_codes' => $d['symptom_codes'] ?? [], 'mode' => $result['mode'], 'match_codes' => collect($result['matches'])->pluck('code')->all()]);

        return ApiResponse::success($request, $result);
    }

    public function evaluationCases(Request $request): JsonResponse
    {
        $cases = DB::table('health_ai_evaluation_cases')->orderBy('case_code')->get()->map(fn ($case): array => $this->evaluationPayload($case))->all();

        return ApiResponse::success($request, $cases);
    }

    public function medicineEvidence(Request $request): JsonResponse
    {
        $rows = DB::table('health_disease_medicine_evidence as evidence')->join('health_diseases as disease', 'disease.id', '=', 'evidence.disease_id')
            ->select('evidence.*', 'disease.code as disease_code', 'disease.name as disease_name')->orderBy('disease.name')->orderBy('evidence.active_ingredient')->get();

        return ApiResponse::success($request, $rows->map(fn ($row) => $this->medicineEvidencePayload($row))->all());
    }

    public function storeMedicineEvidence(HealthMedicineEvidenceStoreRequest $request): JsonResponse
    {
        $data = $request->validated();
        $sourceBelongsToDisease = DB::table('health_knowledge_sources')->where('id', $data['source_id'])->where('disease_id', $data['disease_id'])->exists();
        if (! $sourceBelongsToDisease) {
            return ApiResponse::error($request, 'SOURCE_DISEASE_MISMATCH', 'The evidence source must belong to the selected disease.', 422);
        }
        $id = (string) Str::uuid7();
        DB::table('health_disease_medicine_evidence')->insert([...$data, 'id' => $id, 'review_status' => 'pending_review', 'created_at' => now(), 'updated_at' => now()]);
        $this->audit->record($request, 'health_medicine_evidence.created', 'health_medicine_evidence', $id, null, ['disease_id' => $data['disease_id'], 'active_ingredient' => $data['active_ingredient'], 'drap_registration_number' => $data['drap_registration_number']]);
        $row = DB::table('health_disease_medicine_evidence as evidence')->join('health_diseases as disease', 'disease.id', '=', 'evidence.disease_id')->select('evidence.*', 'disease.code as disease_code', 'disease.name as disease_name')->where('evidence.id', $id)->firstOrFail();

        return ApiResponse::success($request, $this->medicineEvidencePayload($row), 201);
    }

    public function reviewMedicineEvidence(HealthMedicineEvidenceReviewRequest $request, string $evidence): JsonResponse
    {
        $data = $request->validated();
        $before = (array) DB::table('health_disease_medicine_evidence')->where('id', $evidence)->firstOrFail();
        DB::transaction(function () use ($request, $evidence, $data): void {
            DB::table('health_medicine_evidence_reviews')->insert(['id' => (string) Str::uuid7(), 'medicine_evidence_id' => $evidence, 'decision' => $data['decision'], 'reviewer_notes' => $data['reviewer_notes'], 'reviewer_name' => $data['reviewer_name'], 'reviewer_registration' => $data['reviewer_registration'], 'reviewed_by' => $request->user()->id, 'created_at' => now(), 'updated_at' => now()]);
            DB::table('health_disease_medicine_evidence')->where('id', $evidence)->update(['review_status' => $data['decision'], 'reviewed_by' => $request->user()->id, 'reviewer_name' => $data['reviewer_name'], 'reviewer_registration' => $data['reviewer_registration'], 'review_notes' => $data['reviewer_notes'], 'reviewed_at' => now(), 'review_version' => DB::raw('review_version + 1'), 'updated_at' => now()]);
        });
        $after = (array) DB::table('health_disease_medicine_evidence')->where('id', $evidence)->firstOrFail();
        $this->audit->record($request, 'health_medicine_evidence.reviewed', 'health_medicine_evidence', $evidence, $before, $after);
        $row = DB::table('health_disease_medicine_evidence as evidence')->join('health_diseases as disease', 'disease.id', '=', 'evidence.disease_id')->select('evidence.*', 'disease.code as disease_code', 'disease.name as disease_name')->where('evidence.id', $evidence)->firstOrFail();

        return ApiResponse::success($request, $this->medicineEvidencePayload($row));
    }

    private function medicineEvidencePayload(object $row): array
    {
        return ['id' => $row->id, 'disease_id' => $row->disease_id, 'disease_code' => $row->disease_code, 'disease_name' => $row->disease_name, 'active_ingredient' => $row->active_ingredient, 'brand_name' => $row->brand_name, 'manufacturer' => $row->manufacturer, 'dosage_form' => $row->dosage_form, 'drap_registration_number' => $row->drap_registration_number, 'drap_registry_url' => $row->drap_registry_url, 'drap_verified_on' => $row->drap_verified_on, 'indication' => $row->indication, 'species_scope' => $row->species_scope, 'contraindications' => $row->contraindications, 'withdrawal_guidance' => $row->withdrawal_guidance, 'review_status' => $row->review_status, 'reviewer_name' => $row->reviewer_name, 'reviewer_registration' => $row->reviewer_registration, 'review_notes' => $row->review_notes, 'reviewed_at' => $row->reviewed_at, 'review_version' => (int) $row->review_version, 'prescribing_notice' => 'Registration and evidence do not determine the dose. A veterinarian must prescribe for the specific animal and product label.'];
    }

    public function reviewEvaluationCase(HealthAiEvaluationReviewRequest $request, string $case): JsonResponse
    {
        $data = $request->validated();
        $before = (array) DB::table('health_ai_evaluation_cases')->where('id', $case)->firstOrFail();

        DB::transaction(function () use ($request, $case, $data): void {
            DB::table('health_ai_evaluation_reviews')->insert([
                'id' => (string) Str::uuid7(),
                'evaluation_case_id' => $case,
                'decision' => $data['decision'],
                'reviewer_notes' => $data['reviewer_notes'],
                'reviewer_name' => $data['reviewer_name'],
                'reviewer_registration' => $data['reviewer_registration'],
                'reviewed_by' => $request->user()->id,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
            DB::table('health_ai_evaluation_cases')->where('id', $case)->update([
                'review_status' => $data['decision'],
                'review_notes' => $data['reviewer_notes'],
                'reviewed_by' => $request->user()->id,
                'reviewer_name' => $data['reviewer_name'],
                'reviewer_registration' => $data['reviewer_registration'],
                'reviewed_at' => now(),
                'review_version' => DB::raw('review_version + 1'),
                'updated_at' => now(),
            ]);
        });

        $after = DB::table('health_ai_evaluation_cases')->where('id', $case)->firstOrFail();
        $this->audit->record($request, 'health_ai.evaluation_case_reviewed', 'health_ai_evaluation_case', $case, $before, (array) $after);

        return ApiResponse::success($request, $this->evaluationPayload($after));
    }

    public function evaluationCaseReviews(Request $request, string $case): JsonResponse
    {
        DB::table('health_ai_evaluation_cases')->where('id', $case)->firstOrFail();
        $reviews = DB::table('health_ai_evaluation_reviews')
            ->where('evaluation_case_id', $case)
            ->orderByDesc('created_at')
            ->orderByDesc('id')
            ->get()
            ->map(fn ($review): array => [
                'id' => $review->id,
                'decision' => $review->decision,
                'reviewer_notes' => $review->reviewer_notes,
                'reviewer_name' => $review->reviewer_name,
                'reviewer_registration' => $review->reviewer_registration,
                'reviewed_at' => $review->created_at,
            ])->all();

        return ApiResponse::success($request, $reviews);
    }

    private function evaluationPayload(object $case): array
    {
        return [
            'id' => $case->id, 'case_code' => $case->case_code, 'species' => $case->species,
            'question_en' => $case->question_en, 'question_roman_urdu' => $case->question_roman_urdu,
            'symptom_codes' => json_decode($case->symptom_codes, true),
            'expected_disease_codes' => json_decode($case->expected_disease_codes, true),
            'expected_emergency' => (bool) $case->expected_emergency, 'expects_match' => (bool) $case->expects_match,
            'review_status' => $case->review_status, 'review_notes' => $case->review_notes,
            'reviewer_name' => $case->reviewer_name, 'reviewer_registration' => $case->reviewer_registration,
            'reviewed_at' => $case->reviewed_at, 'review_version' => (int) $case->review_version,
        ];
    }

    private function payload(HealthDisease $d): array
    {
        return ['id' => $d->id, 'code' => $d->code, 'name' => $d->name, 'name_roman_urdu' => $d->name_roman_urdu, 'species' => $d->species, 'summary' => $d->summary, 'summary_roman_urdu' => $d->summary_roman_urdu, 'immediate_care' => $d->immediate_care, 'immediate_care_roman_urdu' => $d->immediate_care_roman_urdu, 'confirmation_guidance' => $d->confirmation_guidance, 'confirmation_guidance_roman_urdu' => $d->confirmation_guidance_roman_urdu, 'safe_home_care' => $d->safe_home_care, 'safe_home_care_roman_urdu' => $d->safe_home_care_roman_urdu, 'urgency' => $d->urgency, 'source_title' => $d->source_title, 'source_url' => $d->source_url, 'source_reviewed_on' => $d->source_reviewed_on?->format('Y-m-d'), 'review_status' => $d->review_status, 'reviewed_at' => $d->reviewed_at?->toIso8601String(), 'knowledge_version' => $d->knowledge_version, 'symptoms' => $d->symptoms->map(fn ($s) => ['id' => $s->id, 'code' => $s->code, 'name' => $s->name, 'name_roman_urdu' => $s->name_roman_urdu])->values()];
    }
}
