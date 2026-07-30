<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\MilkProduction\Models\MilkEntry;
use App\Domain\MilkProduction\Models\MilkProductionSlot;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\MilkBulkStoreRequest;
use App\Http\Requests\Api\V1\MilkCorrectionRequest;
use App\Http\Requests\Api\V1\MilkDailyRequest;
use App\Http\Resources\Api\V1\MilkEntryResource;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\IdempotencyService;
use Carbon\CarbonImmutable;
use Illuminate\Database\QueryException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class MilkProductionController extends Controller
{
    public function __construct(
        private readonly IdempotencyService $idempotency,
        private readonly AuditService $audit,
    ) {}

    public function daily(MilkDailyRequest $request): JsonResponse
    {
        $organizationId = (string) $request->attributes->get('organization_id');
        $farmId = $this->activeFarmId($request);
        $date = $request->validated('date');
        $session = $request->validated('session');
        $entries = $this->currentEntries($organizationId, $farmId)
            ->whereHas('slot', function ($query) use ($date, $session): void {
                $query->whereDate('production_date', $date);
                if ($session) {
                    $query->where('session', $session);
                }
            })
            ->orderBy(
                MilkProductionSlot::query()
                    ->select('production_date')
                    ->whereColumn('milk_production_slots.id', 'milk_entries.milk_production_slot_id'),
            )
            ->get();

        $animals = Animal::query()
            ->with(['currentShed'])
            ->where('organization_id', $organizationId)
            ->where('current_farm_id', $farmId)
            ->where('sex', 'female')
            ->where('life_stage', 'adult')
            ->where('operational_status', 'active')
            ->orderBy('animal_number')
            ->get()
            ->map(fn (Animal $animal): array => [
                'id' => $animal->id,
                'animal_number' => $animal->animal_number,
                'name' => $animal->name,
                'shed_id' => $animal->current_shed_id,
                'shed_name' => $animal->currentShed?->name,
            ]);

        return ApiResponse::success($request, [
            'date' => $date,
            'session' => $session,
            'summary' => $this->summary($organizationId, $farmId, $date, $session),
            'eligible_animals' => $animals,
            'entries' => MilkEntryResource::collection($entries)->resolve($request),
        ]);
    }

    public function storeBulk(MilkBulkStoreRequest $request): JsonResponse
    {
        $organizationId = (string) $request->attributes->get('organization_id');
        $farmId = $this->activeFarmId($request);
        $data = $request->validated();
        $animalIds = collect($data['entries'])->pluck('animal_id')->values();
        $animals = Animal::query()
            ->where('organization_id', $organizationId)
            ->where('current_farm_id', $farmId)
            ->whereIn('id', $animalIds)
            ->where('sex', 'female')
            ->where('life_stage', 'adult')
            ->where('operational_status', 'active')
            ->get()
            ->keyBy('id');
        if ($animals->count() !== $animalIds->count()) {
            return ApiResponse::error(
                $request,
                'MILK_ANIMAL_NOT_ELIGIBLE',
                'One or more animals are unavailable or not eligible for milk production.',
                422,
            );
        }

        try {
            return $this->idempotency->execute($request, function () use (
                $request,
                $organizationId,
                $farmId,
                $data,
                $animals,
            ): JsonResponse {
                $entries = DB::transaction(function () use (
                    $request,
                    $organizationId,
                    $farmId,
                    $data,
                    $animals,
                ): Collection {
                    $created = collect();
                    foreach ($data['entries'] as $payload) {
                        $animal = $animals[$payload['animal_id']];
                        $slot = MilkProductionSlot::query()->create([
                            'id' => $payload['slot_id'],
                            'organization_id' => $organizationId,
                            'farm_id' => $farmId,
                            'shed_id' => $animal->current_shed_id,
                            'animal_id' => $animal->id,
                            'production_date' => $data['production_date'],
                            'session' => $data['session'],
                            'version' => 1,
                            'created_by' => $request->user()->id,
                        ]);
                        $created->push(MilkEntry::query()->create([
                            'id' => $payload['id'],
                            'organization_id' => $organizationId,
                            'farm_id' => $farmId,
                            'milk_production_slot_id' => $slot->id,
                            'animal_id' => $animal->id,
                            'revision' => 1,
                            'quantity_litres' => $payload['quantity_litres'],
                            'rejected_quantity_litres' => $payload['rejected_quantity_litres'] ?? '0.000',
                            'rejection_reason' => $payload['rejection_reason'] ?? null,
                            'notes' => $payload['notes'] ?? null,
                            'entry_source' => $payload['entry_source'] ?? 'manual',
                            'is_current' => true,
                            'recorded_by' => $request->user()->id,
                        ]));
                    }
                    $this->audit->record(
                        $request,
                        'milk.entries_recorded',
                        'milk_production_slot',
                        $created->first()?->milk_production_slot_id,
                        null,
                        [
                            'farm_id' => $farmId,
                            'production_date' => $data['production_date'],
                            'session' => $data['session'],
                            'entry_count' => $created->count(),
                            'quantity_litres' => $this->decimal(
                                $created->sum(fn (MilkEntry $entry) => (float) $entry->quantity_litres),
                            ),
                        ],
                    );

                    return $created;
                });
                $entries->each->load(['slot.shed', 'animal', 'recorder']);

                return ApiResponse::success(
                    $request,
                    MilkEntryResource::collection($entries)->resolve($request),
                    201,
                );
            });
        } catch (QueryException $exception) {
            if ($this->isConstraintViolation($exception)) {
                return ApiResponse::error(
                    $request,
                    'DUPLICATE_MILK_ENTRY',
                    'Milk is already recorded for one of these animals, this date, and this session.',
                    409,
                );
            }

            throw $exception;
        }
    }

    public function correct(
        MilkCorrectionRequest $request,
        string $entry,
    ): JsonResponse {
        $organizationId = (string) $request->attributes->get('organization_id');
        $farmId = $this->activeFarmId($request);
        $current = $this->currentEntries($organizationId, $farmId)
            ->whereKey($entry)
            ->first();
        if (! $current) {
            return ApiResponse::error($request, 'NOT_FOUND', 'The requested resource was not found.', 404);
        }

        return $this->idempotency->execute($request, function () use (
            $request,
            $current,
        ): JsonResponse {
            $data = $request->validated();
            $result = DB::transaction(function () use ($request, $current, $data): ?MilkEntry {
                $slot = MilkProductionSlot::query()->lockForUpdate()->findOrFail(
                    $current->milk_production_slot_id,
                );
                $old = MilkEntry::query()->lockForUpdate()->findOrFail($current->id);
                if (! $old->is_current) {
                    return null;
                }
                $replacement = MilkEntry::query()->create([
                    'id' => $data['id'],
                    'organization_id' => $old->organization_id,
                    'farm_id' => $old->farm_id,
                    'milk_production_slot_id' => $old->milk_production_slot_id,
                    'animal_id' => $old->animal_id,
                    'revision' => $old->revision + 1,
                    'quantity_litres' => $data['quantity_litres'],
                    'rejected_quantity_litres' => $data['rejected_quantity_litres'] ?? '0.000',
                    'rejection_reason' => $data['rejection_reason'] ?? null,
                    'notes' => $data['notes'] ?? null,
                    'entry_source' => $data['entry_source'] ?? 'manual',
                    'is_current' => true,
                    'supersedes_entry_id' => $old->id,
                    'correction_reason' => trim($data['correction_reason']),
                    'recorded_by' => $request->user()->id,
                ]);
                $old->forceFill([
                    'is_current' => false,
                    'superseded_by_entry_id' => $replacement->id,
                ])->save();
                $slot->forceFill(['version' => $slot->version + 1])->touch();
                $this->audit->record(
                    $request,
                    'milk.entry_corrected',
                    'milk_entry',
                    $replacement->id,
                    [
                        'entry_id' => $old->id,
                        'quantity_litres' => $old->quantity_litres,
                        'rejected_quantity_litres' => $old->rejected_quantity_litres,
                    ],
                    [
                        'entry_id' => $replacement->id,
                        'quantity_litres' => $replacement->quantity_litres,
                        'rejected_quantity_litres' => $replacement->rejected_quantity_litres,
                        'correction_reason' => $replacement->correction_reason,
                    ],
                );

                return $replacement;
            });
            if (! $result) {
                return ApiResponse::error(
                    $request,
                    'MILK_ENTRY_ALREADY_CORRECTED',
                    'This milk entry was already corrected. Refresh and try again.',
                    409,
                );
            }

            return ApiResponse::success(
                $request,
                (new MilkEntryResource(
                    $result->load(['slot.shed', 'animal', 'recorder']),
                ))->resolve($request),
                201,
            );
        });
    }

    private function currentEntries(string $organizationId, string $farmId)
    {
        return MilkEntry::query()
            ->with(['slot.shed', 'animal', 'recorder'])
            ->where('organization_id', $organizationId)
            ->where('farm_id', $farmId)
            ->where('is_current', true);
    }

    private function summary(
        string $organizationId,
        string $farmId,
        string $date,
        ?string $session,
    ): array {
        $daily = $this->aggregate($organizationId, $farmId, $date, $date, $session);
        $selectedDate = CarbonImmutable::parse($date);
        $yesterday = $selectedDate->subDay()->toDateString();
        $sevenDayStart = $selectedDate->subDays(6)->toDateString();
        $previous = $this->aggregate($organizationId, $farmId, $yesterday, $yesterday, $session);
        $sevenDays = $this->aggregate($organizationId, $farmId, $sevenDayStart, $date, $session);

        return [
            ...$daily,
            'yesterday_sellable_litres' => $previous['sellable_litres'],
            'seven_day_daily_average_litres' => $this->decimal(
                (float) $sevenDays['sellable_litres'] / 7,
            ),
        ];
    }

    private function aggregate(
        string $organizationId,
        string $farmId,
        string $from,
        string $to,
        ?string $session,
    ): array {
        $query = DB::table('milk_entries')
            ->join(
                'milk_production_slots',
                'milk_production_slots.id',
                '=',
                'milk_entries.milk_production_slot_id',
            )
            ->where('milk_entries.organization_id', $organizationId)
            ->where('milk_entries.farm_id', $farmId)
            ->where('milk_entries.is_current', true)
            ->whereBetween('milk_production_slots.production_date', [$from, $to]);
        if ($session) {
            $query->where('milk_production_slots.session', $session);
        }
        $row = $query->selectRaw(
            'COALESCE(SUM(milk_entries.quantity_litres), 0) as total, '.
            'COALESCE(SUM(milk_entries.rejected_quantity_litres), 0) as rejected, '.
            'COUNT(*) as entries, COUNT(DISTINCT milk_entries.animal_id) as animals',
        )->first();
        $total = (float) $row->total;
        $rejected = (float) $row->rejected;

        return [
            'total_litres' => $this->decimal($total),
            'rejected_litres' => $this->decimal($rejected),
            'sellable_litres' => $this->decimal($total - $rejected),
            'entry_count' => (int) $row->entries,
            'animals_recorded' => (int) $row->animals,
        ];
    }

    private function activeFarmId(Request $request): string
    {
        $farmId = $request->attributes->get('api_session')?->farm_id;
        abort_unless(is_string($farmId) && $farmId !== '', 409, 'An active farm is required.');

        return $farmId;
    }

    private function decimal(float $value): string
    {
        return number_format($value, 3, '.', '');
    }

    private function isConstraintViolation(QueryException $exception): bool
    {
        return in_array((string) $exception->getCode(), ['23000', '23505'], true);
    }
}
