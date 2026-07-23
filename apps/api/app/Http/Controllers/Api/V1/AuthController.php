<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\LoginRequest;
use App\Models\ApiSession;
use App\Models\Farm;
use App\Models\OrganizationMembership;
use App\Models\User;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\SessionPayload;
use App\Support\TokenService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function __construct(private readonly TokenService $tokens, private readonly SessionPayload $payload, private readonly AuditService $audit) {}

    public function login(LoginRequest $request): JsonResponse
    {
        $user = User::query()->whereRaw('LOWER(email) = ?', [strtolower($request->string('email')->toString())])->first();
        if ($user?->locked_until?->isPast()) {
            $user->forceFill(['failed_login_count' => 0, 'last_failed_login_at' => null, 'locked_until' => null])->save();
        }
        $valid = $user && Hash::check($request->string('password')->toString(), $user->password);
        if (! $valid || ! $user->is_active || ($user->locked_until && $user->locked_until->isFuture())) {
            if ($user) {
                if (! $user->locked_until?->isFuture()) {
                    $windowStart = now()->subMinutes((int) config('dairycare.auth.failure_window_minutes', 15));
                    $failures = $user->last_failed_login_at?->greaterThanOrEqualTo($windowStart)
                        ? $user->failed_login_count + 1
                        : 1;
                    $lockUntil = $failures >= (int) config('dairycare.auth.lock_threshold', 5)
                        ? now()->addMinutes((int) config('dairycare.auth.lock_minutes', 5))
                        : null;
                    $user->forceFill(['failed_login_count' => $failures, 'last_failed_login_at' => now(), 'locked_until' => $lockUntil])->save();
                }
                $request->setUserResolver(fn () => $user);
            } else {
                Hash::check($request->string('password')->toString(), '$2y$12$wHqKqQqJVR8kLXpxA9nQ7e8sXfgV1l4qG3nXr2o72V3tqHjrxYvQm');
            }
            $this->audit->record($request, 'auth.login_failed');

            return ApiResponse::error($request, 'INVALID_CREDENTIALS', 'The supplied credentials are invalid.', 401);
        }
        $user->forceFill(['failed_login_count' => 0, 'last_failed_login_at' => null, 'locked_until' => null])->save();
        $memberships = $user->memberships()->where('status', 'active')->get();
        $organizationId = $memberships->count() === 1 ? $memberships->first()->organization_id : null;
        $tokens = $this->tokens->issue($user, $request, $organizationId);
        $session = $tokens['session'];
        unset($tokens['session']);
        $request->setUserResolver(fn () => $user);
        $request->attributes->set('api_session', $session);
        $this->audit->record($request, 'auth.login_succeeded', 'api_session', $session->id);

        return ApiResponse::success($request, $this->payload->make($session->load('user'), $tokens));
    }

    public function renew(Request $request): JsonResponse
    {
        $validated = $request->validate(['renewal_credential' => ['required', 'string']]);

        return DB::transaction(function () use ($request, $validated): JsonResponse {
            $result = $this->tokens->renew($validated['renewal_credential']);
            if ($result['status'] === 'reused') {
                $session = $result['session'];
                $request->setUserResolver(fn () => $session->user);
                $request->attributes->set('api_session', $session);
                $this->audit->record($request, 'auth.renewal_reuse_detected', 'api_session', $session->id);

                return ApiResponse::error($request, 'INVALID_RENEWAL_CREDENTIAL', 'The session cannot be renewed.', 401);
            }
            if ($result['status'] !== 'rotated') {
                return ApiResponse::error($request, 'INVALID_RENEWAL_CREDENTIAL', 'The session cannot be renewed.', 401);
            }
            $tokens = $result['tokens'];
            $session = $tokens['session'];
            $request->setUserResolver(fn () => $session->user);
            $request->attributes->set('api_session', $session);
            unset($tokens['session']);
            $this->audit->record($request, 'auth.session_renewed', 'api_session', $session->id);

            return ApiResponse::success($request, $this->payload->make($session->load('user'), $tokens));
        });
    }

    public function me(Request $request): JsonResponse
    {
        return ApiResponse::success($request, $this->payload->make($request->attributes->get('api_session')->load('user')));
    }

    public function logout(Request $request): JsonResponse
    {
        $session = $request->attributes->get('api_session');
        $session->forceFill(['revoked_at' => now()])->save();
        $this->audit->record($request, 'auth.logout', 'api_session', $session->id);

        return ApiResponse::success($request, ['revoked' => true]);
    }

    public function sessions(Request $request): JsonResponse
    {
        $items = $request->user()->apiSessions()->latest()->get()->map(fn (ApiSession $session) => ['id' => $session->id, 'device_name' => $session->device_name, 'ip_address' => $session->ip_address, 'last_used_at' => $session->last_used_at?->toISOString(), 'created_at' => $session->created_at->toISOString(), 'is_current' => $session->id === $request->attributes->get('api_session')->id, 'revoked_at' => $session->revoked_at?->toISOString()]);

        return ApiResponse::success($request, $items);
    }

    public function revokeSession(Request $request, string $session): JsonResponse
    {
        $target = $request->user()->apiSessions()->findOrFail($session);
        $target->forceFill(['revoked_at' => now()])->save();
        $this->audit->record($request, 'auth.session_revoked', 'api_session', $target->id);

        return ApiResponse::success($request, ['revoked' => true]);
    }

    public function switchOrganization(Request $request): JsonResponse
    {
        $validated = $request->validate(['organization_id' => ['required', 'uuid']]);
        $membership = OrganizationMembership::query()->where('user_id', $request->user()->id)->where('organization_id', $validated['organization_id'])->where('status', 'active')->first();
        if (! $membership) {
            return ApiResponse::error($request, 'ORGANIZATION_ACCESS_DENIED', 'Organization access is unavailable.', 403);
        }
        $session = $request->attributes->get('api_session');
        $old = $session->organization_id;
        $session->forceFill(['organization_id' => $membership->organization_id, 'farm_id' => null])->save();
        $tokens = $this->tokens->rotate($session);
        $session = $tokens['session'];
        unset($tokens['session']);
        $request->attributes->set('api_session', $session);
        $this->audit->record($request, 'auth.organization_switched', 'organization', $membership->organization_id, ['organization_id' => $old], ['organization_id' => $membership->organization_id]);

        return ApiResponse::success($request, $this->payload->make($session->load('user'), $tokens));
    }

    public function switchFarm(Request $request): JsonResponse
    {
        $validated = $request->validate(['farm_id' => ['required', 'uuid']]);
        $session = $request->attributes->get('api_session');
        $membership = OrganizationMembership::query()->where('organization_id', $session->organization_id)->where('user_id', $request->user()->id)->where('status', 'active')->first();
        $farm = Farm::query()->where('organization_id', $session->organization_id)->find($validated['farm_id']);
        if (! $membership || ! $farm || ! $membership->canAccessFarm($farm->id)) {
            return ApiResponse::error($request, 'FARM_ACCESS_DENIED', 'Farm access is unavailable.', 403);
        }
        $old = $session->farm_id;
        $session->forceFill(['farm_id' => $farm->id])->save();
        $tokens = $this->tokens->rotate($session);
        $session = $tokens['session'];
        unset($tokens['session']);
        $request->attributes->set('api_session', $session);
        $this->audit->record($request, 'auth.farm_switched', 'farm', $farm->id, ['farm_id' => $old], ['farm_id' => $farm->id]);

        return ApiResponse::success($request, $this->payload->make($session->load('user'), $tokens));
    }
}
