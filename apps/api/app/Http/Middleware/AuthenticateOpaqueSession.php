<?php

namespace App\Http\Middleware;

use App\Support\ApiResponse;
use App\Support\TokenService;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

final class AuthenticateOpaqueSession
{
    public function __construct(private readonly TokenService $tokens) {}

    public function handle(Request $request, Closure $next): Response
    {
        $raw = $request->bearerToken();
        $session = is_string($raw) ? $this->tokens->find($raw) : null;
        if (! $session || ! $session->user->is_active) {
            return ApiResponse::error($request, 'UNAUTHENTICATED', 'Authentication is required.', 401);
        }
        $session->forceFill(['last_used_at' => now(), 'ip_address' => $request->ip()])->save();
        Auth::setUser($session->user);
        $request->setUserResolver(fn () => $session->user);
        $request->attributes->set('api_session', $session);

        return $next($request);
    }
}
