<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\AnimalRegistry\Models\AnimalSpecies;
use App\Http\Controllers\Controller;
use App\Http\Resources\Api\V1\AnimalSpeciesResource;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AnimalSpeciesController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $species = AnimalSpecies::query()->orderBy('name')->get();

        return ApiResponse::success($request, AnimalSpeciesResource::collection($species)->resolve($request));
    }
}
