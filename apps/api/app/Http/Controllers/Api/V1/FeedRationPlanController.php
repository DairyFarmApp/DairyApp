<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Feed\Models\FeedRationPlan;
use App\Domain\Inventory\Models\InventoryItem;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\FeedRationPlanRequest;
use App\Http\Resources\Api\V1\FeedRationPlanResource;
use App\Models\Farm;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\IdempotencyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class FeedRationPlanController extends Controller
{
    public function __construct(
        private readonly AuditService $audit,
        private readonly IdempotencyService $idempotency
    ) {}

    public function index(Request $request): JsonResponse
    {
        $farmModel = $this->activeFarm($request);
        $items = FeedRationPlan::query()
            ->with('ingredients')
            ->where('organization_id', $farmModel->organization_id)
            ->where('farm_id', $farmModel->id)
            ->orderByDesc('created_at')
            ->cursorPaginate(min((int) $request->input('page.size', 50), 100));

        return ApiResponse::success($request, FeedRationPlanResource::collection($items)->resolve($request), 200, [
            'pagination' => [
                'next_cursor' => $items->nextCursor()?->encode(),
                'has_more' => $items->hasMorePages(),
                'page_size' => $items->perPage(),
            ],
        ]);
    }

    public function store(FeedRationPlanRequest $request): JsonResponse
    {
        $farmModel = $this->activeFarm($request);

        return $this->idempotency->execute($request, function () use ($request, $farmModel): JsonResponse {
            $data = $request->validated();

            $plan = null;
            DB::transaction(function () use (&$plan, $data, $farmModel, $request) {
                $plan = FeedRationPlan::create([
                    'id' => $data['id'] ?? (string) Str::uuid7(),
                    'organization_id' => $farmModel->organization_id,
                    'farm_id' => $farmModel->id,
                    'name' => $data['name'],
                    'animal_group_id' => $data['animal_group_id'] ?? null,
                    'production_stage' => $data['production_stage'] ?? null,
                    'effective_date' => $data['effective_date'],
                    'end_date' => $data['end_date'] ?? null,
                    'feeding_frequency' => $data['feeding_frequency'],
                    'created_by' => $request->user()->id,
                    'version' => 1,
                ]);

                foreach ($data['ingredients'] as $ingredient) {
                    $feed = InventoryItem::with('batches')->where('organization_id', $farmModel->organization_id)->where('farm_id', $farmModel->id)->where('kind', 'feed')->findOrFail($ingredient['inventory_item_id']);
                    $stock = $feed->batches->sum(fn ($b) => (float) $b->current_quantity);
                    $averageCost = $stock > 0 ? $feed->batches->sum(fn ($b) => (float) $b->current_quantity * (float) $b->unit_cost) / $stock : 0;
                    $plan->ingredients()->create([
                        'organization_id' => $farmModel->organization_id,
                        'farm_id' => $farmModel->id,
                        'inventory_item_id' => $ingredient['inventory_item_id'],
                        'quantity_per_animal' => $ingredient['quantity_per_animal'],
                        'unit' => $ingredient['unit'],
                        'estimated_cost' => (float) $ingredient['quantity_per_animal'] * $averageCost,
                    ]);
                }

                $plan->load('ingredients');
                $this->audit->record($request, 'feed_ration_plan.created', 'feed_ration_plan', $plan->id, null, $plan->toArray());
            });

            return ApiResponse::success($request, (new FeedRationPlanResource($plan))->resolve($request), 201);
        });
    }

    public function show(Request $request, string $planId): JsonResponse
    {
        $plan = FeedRationPlan::query()
            ->with('ingredients')
            ->where('organization_id', $request->attributes->get('organization_id'))
            ->findOrFail($planId);

        abort_unless($request->attributes->get('membership')->canAccessFarm($plan->farm_id), 404);

        return ApiResponse::success($request, (new FeedRationPlanResource($plan))->resolve($request));
    }

    private function activeFarm(Request $request): Farm
    {
        $farmId = $request->attributes->get('api_session')->farm_id;
        $farm = Farm::query()->where('organization_id', $request->attributes->get('organization_id'))->findOrFail($farmId);
        abort_unless($request->attributes->get('membership')->canAccessFarm($farm->id), 404);

        return $farm;
    }
}
