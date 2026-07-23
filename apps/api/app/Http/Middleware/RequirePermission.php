<?php

namespace App\Http\Middleware;

use App\Support\ApiResponse;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

final class RequirePermission
{
    public function handle(Request $request, Closure $next, string $permission): Response
    {
        $membership = $request->attributes->get('membership');
        if (! $membership?->can($permission)) {
            return ApiResponse::error($request, 'FORBIDDEN', 'You do not have permission for this action.', 403);
        }

        return $next($request);
    }
}
