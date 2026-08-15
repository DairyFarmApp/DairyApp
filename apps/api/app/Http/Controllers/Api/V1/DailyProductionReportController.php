<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Http\Controllers\Controller;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DailyProductionReportController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $organizationId = $request->attributes->get('organization_id');
        $farmId = $request->attributes->get('api_session')?->farm_id;

        $request->validate([
            'date' => 'required|date_format:Y-m-d',
        ]);

        $date = $request->query('date');

        $animals = Animal::query()
            ->where('organization_id', $organizationId)
            ->where('current_farm_id', $farmId)
            ->withSum(['feedConsumptions as total_feed_kg' => function ($query) use ($date) {
                $query->whereDate('date', $date);
            }], 'quantity')
            ->withSum(['milkEntries as total_milk_litres' => function ($query) use ($date) {
                $query->join('milk_production_slots', 'milk_entries.milk_production_slot_id', '=', 'milk_production_slots.id')
                    ->whereDate('milk_production_slots.production_date', $date)
                    ->where('milk_entries.is_current', true);
            }], 'quantity_litres')
            ->get();

        $data = $animals->map(function (Animal $animal) use ($date) {
            return [
                'animal_id' => $animal->id,
                'animal_number' => $animal->animal_number,
                'animal_name' => $animal->name,
                'date' => $date,
                'total_feed_kg' => (float) ($animal->total_feed_kg ?? 0),
                'total_milk_litres' => (float) ($animal->total_milk_litres ?? 0),
            ];
        });

        return ApiResponse::success($request, $data);
    }
}
