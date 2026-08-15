<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Feed\Models\DailyFeedIssue;
use App\Domain\Feed\Models\FeedRationPlan;
use App\Domain\MilkProduction\Models\MilkEntry;
use App\Http\Controllers\Controller;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FeedAnalysisController extends Controller
{
    public function show(Request $r): JsonResponse
    {
        $o = $r->attributes->get('organization_id');
        $f = $r->attributes->get('api_session')->farm_id;
        $from = $r->date('from') ?? today()->subDays(6);
        $to = $r->date('to') ?? today();
        $issues = DailyFeedIssue::with('inventoryItem.batches')->where('organization_id', $o)->where('farm_id', $f)->whereBetween('date', [$from, $to])->get();
        $planned = $issues->sum(fn ($x) => (float) $x->planned_quantity);
        $issued = $issues->sum(fn ($x) => (float) $x->issued_quantity);
        $consumed = $issues->sum(fn ($x) => (float) $x->consumed_quantity);
        $wasted = $issues->sum(fn ($x) => (float) $x->wasted_quantity);
        $cost = $issues->sum(function ($x) {
            $stock = $x->inventoryItem->batches->sum(fn ($b) => (float) $b->current_quantity);
            $avg = $stock > 0 ? $x->inventoryItem->batches->sum(fn ($b) => (float) $b->current_quantity * (float) $b->unit_cost) / $stock : 0;

            return (float) $x->consumed_quantity * $avg;
        });
        $milk = MilkEntry::query()
            ->join('milk_production_slots', 'milk_production_slots.id', '=', 'milk_entries.milk_production_slot_id')
            ->where('milk_entries.organization_id', $o)
            ->where('milk_entries.farm_id', $f)
            ->where('milk_entries.is_current', true)
            ->whereBetween('milk_production_slots.production_date', [$from, $to])
            ->sum('milk_entries.quantity_litres');
        $plans = FeedRationPlan::with('ingredients.inventoryItem')->where('organization_id', $o)->where('farm_id', $f)->whereDate('effective_date', '<=', $to)->where(fn ($q) => $q->whereNull('end_date')->orWhereDate('end_date', '>=', $from))->get();
        $nutrition = $plans->flatMap->ingredients->reduce(function ($c, $i) {
            $q = (float) $i->quantity_per_animal;
            $item = $i->inventoryItem;
            $c['dry_matter_kg'] += $q * (float) $item->dry_matter_percent / 100;
            $c['crude_protein_kg'] += $q * (float) $item->crude_protein_percent / 100;
            $c['energy_mj'] += $q * (float) $item->metabolizable_energy_mj_per_kg;

            return $c;
        }, ['dry_matter_kg' => 0, 'crude_protein_kg' => 0, 'energy_mj' => 0]);

        return ApiResponse::success($r, ['period' => ['from' => $from->toDateString(), 'to' => $to->toDateString()], 'planned_quantity' => $planned, 'issued_quantity' => $issued, 'consumed_quantity' => $consumed, 'wasted_quantity' => $wasted, 'variance_quantity' => $issued - $planned, 'wastage_percent' => $issued > 0 ? round($wasted / $issued * 100, 2) : 0, 'estimated_feed_cost_pkr' => round($cost, 2), 'milk_litres' => (float) $milk, 'feed_cost_per_litre_pkr' => $milk > 0 ? round($cost / $milk, 2) : null, 'feed_kg_per_litre' => $milk > 0 ? round($consumed / $milk, 3) : null, 'ration_nutrition_per_animal' => $nutrition, 'active_plan_count' => $plans->count()]);
    }
}
