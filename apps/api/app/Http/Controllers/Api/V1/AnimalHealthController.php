<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\AnimalHealth\Models\AnimalHealthCase;
use App\Domain\AnimalHealth\Models\AnimalHealthDifferential;
use App\Domain\AnimalHealth\Models\HealthSymptom;
use App\Domain\AnimalHealth\Services\HealthAssessmentService;
use App\Domain\AnimalRegistry\Models\Animal;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\AnimalHealthAssessmentRequest;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\IdempotencyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AnimalHealthController extends Controller
{
    public function __construct(private readonly HealthAssessmentService $assessments, private readonly AuditService $audit, private readonly IdempotencyService $idempotency) {}

    public function symptoms(Request $request): JsonResponse
    {
        $items = HealthSymptom::query()->where('is_active', true)->orderBy('body_system')->orderBy('name')->get()->map(fn ($s) => ['id' => $s->id, 'code' => $s->code, 'name' => $s->name, 'name_roman_urdu' => $s->name_roman_urdu, 'body_system' => $s->body_system, 'is_emergency' => $s->is_emergency, 'emergency_message' => $s->emergency_message]);

        return ApiResponse::success($request, $items);
    }

    public function index(Request $request, string $animal): JsonResponse
    {
        $animalModel = $this->animal($request, $animal);
        $cases = AnimalHealthCase::query()->with(['symptoms', 'topDisease', 'differentials.disease'])->where('organization_id', $animalModel->organization_id)->where('farm_id', $animalModel->current_farm_id)->where('animal_id', $animalModel->id)->latest('reported_at')->paginate(20);

        return ApiResponse::success($request, collect($cases->items())->map(fn ($case) => $this->payload($case))->all(), 200, ['current_page' => $cases->currentPage(), 'last_page' => $cases->lastPage(), 'total' => $cases->total()]);
    }

    public function store(AnimalHealthAssessmentRequest $request, string $animal): JsonResponse
    {
        $animalModel = $this->animal($request, $animal);
        abort_if($animalModel->operational_status === 'deceased', 422, 'A deceased animal cannot receive a health assessment.');

        return $this->idempotency->execute($request, function () use ($request, $animalModel): JsonResponse {
            $data = $request->validated();
            $symptoms = HealthSymptom::query()->whereIn('id', $data['symptom_ids'])->get();
            $ranked = $this->assessments->rank(strtolower($animalModel->species->code), $data['symptom_ids']);
            $emergency = $symptoms->contains('is_emergency', true) || $data['severity'] === 'severe';
            $message = $emergency ? 'Emergency signs selected. Isolate the animal when safe and contact a veterinarian immediately.' : null;
            $case = DB::transaction(function () use ($request, $animalModel, $data, $symptoms, $ranked, $emergency, $message): AnimalHealthCase {
                $number = 'HC-'.str_pad((string) (AnimalHealthCase::query()->where('organization_id', $animalModel->organization_id)->lockForUpdate()->count() + 1), 6, '0', STR_PAD_LEFT);
                $case = AnimalHealthCase::query()->create(['organization_id' => $animalModel->organization_id, 'farm_id' => $animalModel->current_farm_id, 'animal_id' => $animalModel->id, 'case_number' => $number, 'reported_at' => $data['reported_at'] ?? now(), 'severity' => $data['severity'], 'temperature_c' => $data['temperature_c'] ?? null, 'status' => 'open', 'top_disease_id' => $ranked->first()['disease']->id ?? null, 'top_score' => $ranked->first()['score'] ?? null, 'emergency' => $emergency, 'emergency_message' => $message, 'notes' => $data['notes'] ?? null, 'created_by' => $request->user()->id]);
                $case->symptoms()->attach($symptoms->mapWithKeys(fn ($s) => [$s->id => ['presence' => 'present', 'severity' => $data['severity']]])->all());
                foreach ($ranked as $index => $result) {
                    AnimalHealthDifferential::query()->create(['health_case_id' => $case->id, 'disease_id' => $result['disease']->id, 'score' => $result['score'], 'matched_symptoms' => $result['matched'], 'missing_key_symptoms' => $result['missing_key'], 'rank' => $index + 1]);
                }
                $this->audit->record($request, 'animal_health.assessed', 'animal_health_case', $case->id, null, ['animal_id' => $animalModel->id, 'symptom_ids' => $data['symptom_ids'], 'emergency' => $emergency]);

                return $case->load(['symptoms', 'topDisease', 'differentials.disease']);
            });

            return ApiResponse::success($request, $this->payload($case), 201);
        });
    }

    private function animal(Request $request, string $id): Animal
    {
        $farmId = $request->attributes->get('api_session')->farm_id;

        return Animal::query()->with('species')->where('organization_id', $request->attributes->get('organization_id'))->where('current_farm_id', $farmId)->findOrFail($id);
    }

    private function payload(AnimalHealthCase $case): array
    {
        return ['id' => $case->id, 'case_number' => $case->case_number, 'animal_id' => $case->animal_id, 'reported_at' => $case->reported_at?->toIso8601String(), 'severity' => $case->severity, 'temperature_c' => $case->temperature_c, 'status' => $case->status, 'emergency' => $case->emergency, 'emergency_message' => $case->emergency_message, 'notes' => $case->notes, 'version' => $case->version, 'symptoms' => $case->symptoms->map(fn ($s) => ['id' => $s->id, 'name' => $s->name, 'body_system' => $s->body_system])->values(), 'differentials' => $case->differentials->map(fn ($d) => ['rank' => $d->rank, 'score' => $d->score, 'matched_symptoms' => $d->matched_symptoms, 'missing_key_symptoms' => $d->missing_key_symptoms, 'disease' => ['id' => $d->disease->id, 'code' => $d->disease->code, 'name' => $d->disease->name, 'summary' => $d->disease->summary, 'urgency' => $d->disease->urgency, 'immediate_care' => $d->disease->immediate_care, 'confirmation_guidance' => $d->disease->confirmation_guidance, 'source_title' => $d->disease->source_title, 'source_url' => $d->disease->source_url, 'source_reviewed_on' => $d->disease->source_reviewed_on?->format('Y-m-d')]])->values()];
    }
}
