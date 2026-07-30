<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\OwnerAccounts\Support\OwnerAccountService;
use App\Http\Controllers\Controller;
use App\Models\Farm;
use App\Models\FarmInviteLink;
use App\Models\OrganizationMembership;
use App\Support\ApiResponse;
use App\Support\AuditService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FamilyAccountController extends Controller
{
    public function __construct(
        private readonly OwnerAccountService $accounts,
        private readonly AuditService $audit,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $owner = $this->primaryOwner($request);
        $members = OrganizationMembership::query()
            ->with('user')
            ->where('organization_id', $owner->organization_id)
            ->where('membership_type', 'family_admin')
            ->orderByRaw("CASE WHEN status = 'active' THEN 0 ELSE 1 END")
            ->orderBy('created_at')
            ->get()
            ->map(fn (OrganizationMembership $membership) => $this->memberPayload($membership))
            ->values();

        return ApiResponse::success($request, $members);
    }

    public function invite(Request $request): JsonResponse
    {
        $owner = $this->primaryOwner($request);
        $current = $this->accounts->currentInvite($owner);

        return ApiResponse::success(
            $request,
            $current ? $this->invitePayload($current['link'], $current['token']) : null,
        );
    }

    public function rotateInvite(Request $request): JsonResponse
    {
        $owner = $this->primaryOwner($request);
        $session = $request->attributes->get('api_session');
        $farm = Farm::query()
            ->where('organization_id', $owner->organization_id)
            ->findOrFail($session->farm_id);
        $created = $this->accounts->createOrRotateInvite($owner, $farm);
        $this->audit->record(
            $request,
            'family_invite.rotated',
            'farm_invite_link',
            $created['link']->id,
            null,
            ['generation' => $created['link']->generation, 'farm_id' => $farm->id],
        );

        return ApiResponse::success(
            $request,
            $this->invitePayload($created['link'], $created['token']),
            201,
        );
    }

    public function disableInvite(Request $request): JsonResponse
    {
        $owner = $this->primaryOwner($request);
        $link = FarmInviteLink::query()
            ->where('organization_id', $owner->organization_id)
            ->firstOrFail();
        $link->forceFill(['is_enabled' => false])->save();
        $this->audit->record(
            $request,
            'family_invite.disabled',
            'farm_invite_link',
            $link->id,
        );

        return ApiResponse::success($request, ['disabled' => true]);
    }

    public function remove(Request $request, string $membership): JsonResponse
    {
        $owner = $this->primaryOwner($request);
        $family = $this->familyMembership($owner, $membership);
        try {
            $this->accounts->removeFamily($owner, $family);
        } catch (\DomainException $exception) {
            return ApiResponse::error(
                $request,
                'FAMILY_ACCOUNT_CONFLICT',
                $exception->getMessage(),
                409,
            );
        }
        $this->audit->record(
            $request,
            'family_account.removed',
            'organization_membership',
            $family->id,
            ['status' => $family->status],
            ['status' => 'removed'],
        );

        return ApiResponse::success($request, ['removed' => true]);
    }

    public function restore(Request $request, string $membership): JsonResponse
    {
        $owner = $this->primaryOwner($request);
        $family = $this->familyMembership($owner, $membership);
        try {
            $this->accounts->restoreFamily($owner, $family);
        } catch (\DomainException $exception) {
            return ApiResponse::error(
                $request,
                'FAMILY_ACCOUNT_CONFLICT',
                $exception->getMessage(),
                409,
            );
        }
        $this->audit->record(
            $request,
            'family_account.restored',
            'organization_membership',
            $family->id,
            ['status' => $family->status],
            ['status' => 'active'],
        );

        return ApiResponse::success($request, ['restored' => true]);
    }

    private function primaryOwner(Request $request): OrganizationMembership
    {
        $membership = $request->attributes->get('membership');
        abort_unless(
            $membership instanceof OrganizationMembership &&
            $membership->membership_type === 'primary_owner',
            403,
        );

        return $membership;
    }

    private function familyMembership(
        OrganizationMembership $owner,
        string $id,
    ): OrganizationMembership {
        return OrganizationMembership::query()
            ->where('organization_id', $owner->organization_id)
            ->where('membership_type', 'family_admin')
            ->findOrFail($id);
    }

    private function memberPayload(OrganizationMembership $membership): array
    {
        return [
            'id' => $membership->id,
            'name' => $membership->user->name,
            'email' => $membership->user->email,
            'phone_number' => $membership->user->phone_number,
            'has_profile_photo' => $membership->user->profile_photo_path !== null,
            'status' => $membership->status,
            'joined_at' => $membership->created_at?->toISOString(),
        ];
    }

    private function invitePayload(FarmInviteLink $link, string $token): array
    {
        return [
            'id' => $link->id,
            'farm_id' => $link->farm_id,
            'invitation_token' => $token,
            'is_enabled' => $link->is_enabled,
            'generation' => $link->generation,
            'updated_at' => $link->updated_at?->toISOString(),
        ];
    }
}
