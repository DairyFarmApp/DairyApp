<?php

use App\Domain\AnimalMovements\Exceptions\AnimalMovementConflict;
use App\Domain\AnimalMovements\Exceptions\StaleAnimalMovementVersion;
use App\Domain\AnimalRegistry\Exceptions\StaleAnimalRegistryVersion;
use App\Domain\AnimalStatuses\Exceptions\AnimalStatusConflict;
use App\Domain\AnimalWeights\Exceptions\AnimalWeightConflict;
use App\Http\Middleware\AssignRequestId;
use App\Http\Middleware\AuthenticateOpaqueSession;
use App\Http\Middleware\RequireActiveOrganization;
use App\Http\Middleware\RequirePermission;
use App\Support\ApiResponse;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->append(AssignRequestId::class);
        $middleware->alias([
            'auth.opaque' => AuthenticateOpaqueSession::class,
            'tenant' => RequireActiveOrganization::class,
            'permission' => RequirePermission::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*'),
        );
        $exceptions->render(fn (ValidationException $e, Request $request) => $request->is('api/*')
            ? ApiResponse::error($request, 'VALIDATION_FAILED', 'The request could not be processed.', 422, collect($e->errors())->map(fn ($messages) => collect($messages)->map(fn ($message) => ['code' => 'invalid', 'message' => $message])->all())->all())
            : null);
        $exceptions->render(fn (ModelNotFoundException $e, Request $request) => $request->is('api/*') ? ApiResponse::error($request, 'NOT_FOUND', 'The requested resource was not found.', 404) : null);
        $exceptions->render(fn (AuthorizationException $e, Request $request) => $request->is('api/*') ? ApiResponse::error($request, 'FORBIDDEN', 'You do not have permission for this action.', 403) : null);
        $exceptions->render(fn (StaleAnimalRegistryVersion $e, Request $request) => $request->is('api/*')
            ? ApiResponse::error($request, 'STALE_VERSION', 'The record was changed by another request.', 412, details: ['current_version' => $e->currentVersion])
            : null);
        $exceptions->render(fn (StaleAnimalMovementVersion $e, Request $request) => $request->is('api/*')
            ? ApiResponse::error($request, 'STALE_VERSION', 'The animal movement was changed by another request.', 412, details: ['current_version' => $e->currentVersion])
            : null);
        $exceptions->render(fn (AnimalMovementConflict $e, Request $request) => $request->is('api/*')
            ? ApiResponse::error($request, $e->errorCode, $e->getMessage(), 409, details: $e->details)
            : null);
        $exceptions->render(fn (AnimalWeightConflict $e, Request $request) => $request->is('api/*')
            ? ApiResponse::error($request, $e->errorCode, $e->getMessage(), 409, details: $e->details)
            : null);
        $exceptions->render(fn (AnimalStatusConflict $e, Request $request) => $request->is('api/*')
            ? ApiResponse::error($request, $e->errorCode, $e->getMessage(), 409, details: $e->details)
            : null);
        $exceptions->render(function (HttpExceptionInterface $e, Request $request) {
            if (! $request->is('api/*')) {
                return null;
            }
            $status = $e->getStatusCode();
            $code = match ($status) {
                401 => 'UNAUTHENTICATED',
                403 => 'FORBIDDEN',
                404 => 'NOT_FOUND',
                409 => 'CONFLICT',
                429 => 'RATE_LIMITED',
                default => 'HTTP_ERROR',
            };
            $message = match ($status) {
                401 => 'Authentication is required.',
                403 => 'You do not have permission for this action.',
                404 => 'The requested resource was not found.',
                429 => 'Too many requests. Please try again later.',
                default => 'The request could not be completed.',
            };

            return ApiResponse::error($request, $code, $message, $status);
        });
    })->create();
