<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\OwnerAccounts\Support\OwnerAccountService;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\FamilySignupRequest;
use App\Http\Requests\Api\V1\OwnerSignupRequest;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\SessionPayload;
use App\Support\TokenService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OwnerAccountController extends Controller
{
    public function __construct(
        private readonly OwnerAccountService $accounts,
        private readonly TokenService $tokens,
        private readonly SessionPayload $payload,
        private readonly AuditService $audit,
    ) {}

    public function signup(OwnerSignupRequest $request): JsonResponse
    {
        $created = $this->accounts->registerPrimaryOwner($request->validated());

        return $this->completeSignup(
            request: $request,
            user: $created['user'],
            organizationId: $created['organization']->id,
            farmId: $created['farm']->id,
            action: 'auth.primary_owner_registered',
            membershipId: $created['membership']->id,
        );
    }

    public function inspectFamilyInvite(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'invitation_token' => ['required', 'string', 'max:250'],
        ]);
        $link = $this->accounts->inspectInvite($validated['invitation_token']);
        if (! $link) {
            return ApiResponse::error(
                $request,
                'INVALID_FARM_INVITATION',
                'The farm invitation is invalid or has been disabled.',
                404,
            );
        }

        return ApiResponse::success($request, [
            'farm' => [
                'id' => $link->farm->id,
                'name' => $link->farm->name,
            ],
            'organization' => [
                'id' => $link->organization->id,
                'name' => $link->organization->name,
            ],
        ]);
    }

    public function familySignup(FamilySignupRequest $request): JsonResponse
    {
        try {
            $created = $this->accounts->registerFamilyOwner(
                $request->string('invitation_token')->toString(),
                $request->validated(),
            );
        } catch (\DomainException $exception) {
            return ApiResponse::error(
                $request,
                'FAMILY_SIGNUP_UNAVAILABLE',
                $exception->getMessage(),
                409,
            );
        }

        return $this->completeSignup(
            request: $request,
            user: $created['user'],
            organizationId: $created['organization']->id,
            farmId: $created['farm']->id,
            action: 'auth.family_account_registered',
            membershipId: $created['membership']->id,
        );
    }

    private function completeSignup(
        Request $request,
        mixed $user,
        string $organizationId,
        string $farmId,
        string $action,
        string $membershipId,
    ): JsonResponse {
        $tokens = $this->tokens->issue(
            $user,
            $request,
            $organizationId,
            $farmId,
        );
        $session = $tokens['session'];
        unset($tokens['session']);
        $request->setUserResolver(fn () => $user);
        $request->attributes->set('api_session', $session);
        $this->audit->record(
            $request,
            $action,
            'organization_membership',
            $membershipId,
        );

        return ApiResponse::success(
            $request,
            $this->payload->make($session->load('user'), $tokens),
            201,
        );
    }
}
