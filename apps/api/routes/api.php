<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\FarmController;
use App\Http\Controllers\Api\V1\OrganizationController;
use App\Http\Controllers\Api\V1\ShedController;
use App\Http\Controllers\Api\V1\SyncController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function (): void {
    Route::post('auth/login', [AuthController::class, 'login'])->middleware('throttle:login');
    Route::post('auth/renew', [AuthController::class, 'renew'])->middleware('throttle:renew');

    Route::middleware('auth.opaque')->group(function (): void {
        Route::post('auth/logout', [AuthController::class, 'logout']);
        Route::get('auth/me', [AuthController::class, 'me']);
        Route::get('auth/sessions', [AuthController::class, 'sessions'])->middleware(['tenant', 'permission:sessions.view_own']);
        Route::delete('auth/sessions/{session}', [AuthController::class, 'revokeSession'])->middleware(['tenant', 'permission:sessions.revoke_own']);
        Route::post('auth/switch-organization', [AuthController::class, 'switchOrganization']);
        Route::post('auth/switch-farm', [AuthController::class, 'switchFarm']);
        Route::get('organizations', [OrganizationController::class, 'index']);

        Route::middleware('tenant')->group(function (): void {
            Route::get('organizations/{organization}', [OrganizationController::class, 'show'])->middleware('permission:organizations.view');
            Route::patch('organizations/{organization}', [OrganizationController::class, 'update'])->middleware('permission:organizations.update');
            Route::get('farms', [FarmController::class, 'index'])->middleware('permission:farms.view');
            Route::post('farms', [FarmController::class, 'store'])->middleware('permission:farms.create');
            Route::get('farms/{farm}', [FarmController::class, 'show'])->middleware('permission:farms.view');
            Route::patch('farms/{farm}', [FarmController::class, 'update'])->middleware('permission:farms.update');
            Route::delete('farms/{farm}', [FarmController::class, 'destroy'])->middleware('permission:farms.archive');
            Route::get('farms/{farm}/sheds', [ShedController::class, 'index'])->middleware('permission:sheds.view');
            Route::post('farms/{farm}/sheds', [ShedController::class, 'store'])->middleware('permission:sheds.create');
            Route::get('sheds/{shed}', [ShedController::class, 'show'])->middleware('permission:sheds.view');
            Route::patch('sheds/{shed}', [ShedController::class, 'update'])->middleware('permission:sheds.update');
            Route::delete('sheds/{shed}', [ShedController::class, 'destroy'])->middleware('permission:sheds.archive');
            Route::get('sync/bootstrap', [SyncController::class, 'bootstrap']);
            Route::get('sync/changes', [SyncController::class, 'changes']);
        });
    });
});
