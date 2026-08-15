<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\AnimalHealth\Models\InAppAlert;
use App\Domain\AnimalHealth\Services\HealthAlertSyncService;
use App\Http\Controllers\Controller;
use App\Support\ApiResponse;
use App\Support\AuditService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AlertController extends Controller
{
    public function __construct(private readonly HealthAlertSyncService $sync, private readonly AuditService $audit) {}

    public function index(Request $r): JsonResponse
    {
        $o = $r->attributes->get('organization_id');
        $f = $r->attributes->get('api_session')->farm_id;
        $this->sync->sync($o, $f);
        $q = InAppAlert::where('organization_id', $o)->where('farm_id', $f);
        if ($r->query('status', 'active') !== 'all') {
            $q->where('status', $r->query('status', 'active'));
        }

return ApiResponse::success($r, $q->orderBy('due_at')->get());
    }

    public function update(Request $r, string $alert): JsonResponse
    {
        $r->validate(['action' => 'required|in:read,unread,resolve,reopen']);
        $x = InAppAlert::where('organization_id', $r->attributes->get('organization_id'))->where('farm_id', $r->attributes->get('api_session')->farm_id)->findOrFail($alert);
        match ($r->input('action')) {
            'read' => $x->forceFill(['read_at' => now()])->save(),'unread' => $x->forceFill(['read_at' => null])->save(),'resolve' => $x->forceFill(['status' => 'resolved', 'resolved_at' => now(), 'resolved_by' => $r->user()->id])->save(),'reopen' => $x->forceFill(['status' => 'active', 'resolved_at' => null, 'resolved_by' => null])->save()
        };
        $this->audit->record($r, 'alert.'.$r->input('action'), 'in_app_alert', $x->id);

        return ApiResponse::success($r,$x);
    }
}
