<?php

use App\Http\Controllers\Api\V1\AnimalBreedController;
use App\Http\Controllers\Api\V1\AnimalController;
use App\Http\Controllers\Api\V1\AnimalGroupController;
use App\Http\Controllers\Api\V1\AnimalMovementController;
use App\Http\Controllers\Api\V1\AnimalSpeciesController;
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
            Route::get('animal-species', [AnimalSpeciesController::class, 'index'])->middleware('permission:animals.view');
            Route::get('animal-breeds', [AnimalBreedController::class, 'index'])->middleware('permission:animal_breeds.view');
            Route::post('animal-breeds', [AnimalBreedController::class, 'store'])->middleware('permission:animal_breeds.manage');
            Route::get('animal-breeds/{breed}', [AnimalBreedController::class, 'show'])->middleware('permission:animal_breeds.view');
            Route::patch('animal-breeds/{breed}', [AnimalBreedController::class, 'update'])->middleware('permission:animal_breeds.manage');
            Route::delete('animal-breeds/{breed}', [AnimalBreedController::class, 'destroy'])->middleware('permission:animal_breeds.manage');
            Route::get('animal-groups', [AnimalGroupController::class, 'index'])->middleware('permission:animal_groups.view');
            Route::post('animal-groups', [AnimalGroupController::class, 'store'])->middleware('permission:animal_groups.manage');
            Route::get('animal-groups/{group}', [AnimalGroupController::class, 'show'])->middleware('permission:animal_groups.view');
            Route::patch('animal-groups/{group}', [AnimalGroupController::class, 'update'])->middleware('permission:animal_groups.manage');
            Route::delete('animal-groups/{group}', [AnimalGroupController::class, 'destroy'])->middleware('permission:animal_groups.manage');
            Route::get('animals', [AnimalController::class, 'index'])->middleware('permission:animals.view');
            Route::post('animals', [AnimalController::class, 'store'])->middleware('permission:animals.create');
            Route::get('animals/{animal}/movements', [AnimalMovementController::class, 'index'])->middleware('permission:animal_movements.view');
            Route::post('animals/{animal}/movements', [AnimalMovementController::class, 'store'])->middleware('permission:animals.move');
            Route::get('animals/{animal}', [AnimalController::class, 'show'])->middleware('permission:animals.view');
            Route::patch('animals/{animal}', [AnimalController::class, 'update'])->middleware('permission:animals.update');
            Route::delete('animals/{animal}', [AnimalController::class, 'destroy'])->middleware('permission:animals.archive');
            Route::post('animals/{animal}/restore', [AnimalController::class, 'restore'])->middleware('permission:animals.restore');
            Route::get('animal-movements/{movement}', [AnimalMovementController::class, 'show'])->middleware('permission:animal_movements.view');
            Route::post('animal-movements/{movement}/approve', [AnimalMovementController::class, 'approve'])->middleware('permission:animal_movements.approve');
            Route::post('animal-movements/{movement}/reject', [AnimalMovementController::class, 'reject'])->middleware('permission:animal_movements.reject');
            Route::post('animal-movements/{movement}/cancel', [AnimalMovementController::class, 'cancel'])->middleware('permission:animal_movements.cancel');
            Route::get('sync/bootstrap', [SyncController::class, 'bootstrap']);
            Route::get('sync/changes', [SyncController::class, 'changes']);
        });
    });
});
