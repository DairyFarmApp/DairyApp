<?php

namespace App\Http\Middleware;

use App\Models\OrganizationMembership;
use App\Support\ApiResponse;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

final class RequireActiveOrganization
{
    public function handle(Request $request, Closure $next): Response
    {
        $session = $request->attributes->get('api_session');
        if (! $session?->organization_id) {
            return ApiResponse::error($request, 'ORGANIZATION_REQUIRED', 'Select an organization.', 409);
        }
        $membership = OrganizationMembership::query()->where('organization_id', $session->organization_id)->where('user_id', $request->user()->id)->where('status', 'active')->first();
        if (! $membership) {
            return ApiResponse::error($request, 'ORGANIZATION_ACCESS_DENIED', 'Organization access is unavailable.', 403);
        }
        $request->attributes->set('membership', $membership);
        $request->attributes->set('organization_id', $session->organization_id);

        return $next($request);
    }
}
