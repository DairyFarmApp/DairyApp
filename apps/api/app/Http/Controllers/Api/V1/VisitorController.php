<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Visitors\Models\VisitorRecord;
use App\Http\Controllers\Controller;
use App\Support\ApiResponse;
use App\Support\AuditService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class VisitorController extends Controller
{
    public function __construct(private readonly AuditService $audit) {}

    public function index(Request $request): JsonResponse
    {
        $items = $this->scope($request)->latest('visited_at')->limit(300)->get()->map(fn (VisitorRecord $record) => $this->data($record));

        return ApiResponse::success($request, ['visitors' => $items]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'visitor_name' => ['required', 'string', 'max:160'],
            'visited_at' => ['required', 'date'],
            'purpose' => ['required', 'string', 'max:500'],
        ]);
        $record = VisitorRecord::query()->create([...$data, 'organization_id' => $request->attributes->get('organization_id'), 'farm_id' => $this->farmId($request), 'created_by' => $request->user()->id]);
        $this->audit->record($request, 'visitor.created', 'visitor_record', $record->id, null, $record->only(['visitor_name', 'visited_at', 'purpose']));

        return ApiResponse::success($request, $this->data($record), 201);
    }

    public function destroy(Request $request, string $visitor): JsonResponse
    {
        $record = $this->scope($request)->findOrFail($visitor);
        $record->delete();
        $this->audit->record($request, 'visitor.deleted', 'visitor_record', $record->id, $record->only(['visitor_name', 'visited_at', 'purpose']), null);

        return ApiResponse::success($request, ['deleted' => true]);
    }

    private function scope(Request $request)
    {
        return VisitorRecord::query()->where('organization_id', $request->attributes->get('organization_id'))->where('farm_id', $this->farmId($request));
    }

    private function farmId(Request $request): string
    {
        return (string) $request->attributes->get('api_session')->farm_id;
    }

    private function data(VisitorRecord $record): array
    {
        return ['id' => $record->id, 'visitor_name' => $record->visitor_name, 'visited_at' => $record->visited_at?->toIso8601String(), 'purpose' => $record->purpose];
    }
}
