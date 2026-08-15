<?php

namespace App\Domain\AnimalHealth\Services;

use App\Domain\AnimalHealth\Models\AnimalBreedingService;
use App\Domain\AnimalHealth\Models\AnimalCalvingEvent;
use App\Domain\AnimalHealth\Models\AnimalPregnancyCheck;
use App\Domain\AnimalHealth\Models\AnimalPreventiveCareRecord;
use App\Domain\AnimalHealth\Models\AnimalWithdrawalRestriction;
use App\Domain\AnimalHealth\Models\CalfCareProfile;
use App\Domain\AnimalHealth\Models\InAppAlert;
use App\Domain\Inventory\Models\InventoryItem;

final class HealthAlertSyncService
{
    public function sync(string $org, string $farm): void
    {
        $sources = [];
        foreach (AnimalWithdrawalRestriction::where('organization_id', $org)->where('farm_id', $farm)->where('status', 'active')->whereBetween('ends_at', [now(), now()->addDays(2)])->get() as $x) {
            $sources[] = $this->data('withdrawal_ending', 'warning', 'Medicine withdrawal ending', 'Dawa ki pabandi khatam honay wali hai', $x->type.' withdrawal ends soon.', 'Doodh ya gosht ki pabandi jald khatam hogi.', 'withdrawal', $x->id, $x->ends_at);
        }
        foreach (AnimalPreventiveCareRecord::where('organization_id', $org)->where('farm_id', $farm)->whereNotNull('next_due_date')->whereDate('next_due_date', '<=', today()->addDays(30))->get()->unique(fn ($x) => $x->animal_id.'-'.$x->type) as $x) {
            $sources[] = $this->data($x->type.'_due', $x->next_due_date->isPast() ? 'high' : 'warning', ucfirst($x->type).' due', ucfirst($x->type).' ki tareekh', $x->type.' is due for an animal.', 'Janwar ki bachao ki dawa due hai.', 'preventive_care', $x->id, $x->next_due_date);
        }
        foreach (AnimalBreedingService::where('organization_id', $org)->where('farm_id', $farm)->whereDate('pregnancy_check_due_date', '<=', today()->addDays(14))->whereDoesntHave('pregnancyChecks')->get() as $x) {
            $sources[] = $this->data('pregnancy_check_due', 'warning', 'Pregnancy check due', 'Pregnancy check ki tareekh', 'Pregnancy confirmation is due.', 'Hamal ki tasdeeq karwani hai.', 'breeding_service', $x->id, $x->pregnancy_check_due_date);
        }
        foreach (AnimalPregnancyCheck::where('organization_id', $org)->where('farm_id', $farm)->where('result', 'pregnant')->whereDate('expected_calving_date', '<=', today()->addDays(30))->get() as $x) {
            $sources[] = $this->data('expected_calving', $x->expected_calving_date->isPast() ? 'high' : 'warning', 'Expected calving', 'Bachay ki mutawaqqa paidaish', 'Prepare for expected calving.', 'Bachay ki paidaish ki tayari karein.', 'pregnancy_check', $x->id, $x->expected_calving_date);
        }
        foreach (AnimalCalvingEvent::where('organization_id', $org)->where('farm_id', $farm)->whereDate('post_calving_check_due', '<=', today()->addDays(7))->get() as $x) {
            $sources[] = $this->data('post_calving_check', 'warning', 'Post-calving check', 'Paidaish ke baad check', 'Mother requires a post-calving check.', 'Maa ka paidaish ke baad check zaroori hai.', 'calving', $x->id, $x->post_calving_check_due);
        }
        foreach (CalfCareProfile::where('organization_id', $org)->where('farm_id', $farm)->whereNull('actual_weaning_date')->whereDate('weaning_target_date', '<=', today()->addDays(14))->get() as $x) {
            $sources[] = $this->data('weaning_due', $x->weaning_target_date->isPast() ? 'high' : 'warning', 'Weaning due', 'Doodh chhuranay ki tareekh', 'Calf weaning is due.', 'Bachray ka doodh chhurana due hai.', 'calf_care', $x->id, $x->weaning_target_date);
        }
        foreach (InventoryItem::with('batches')->where('organization_id', $org)->where('farm_id', $farm)->where('is_active', true)->get() as $item) {
            $stock = $item->batches->sum(fn ($batch) => (float) $batch->current_quantity);
            if ($stock <= (float) $item->minimum_stock) {
                $sources[] = $this->data('inventory_low_stock', 'warning', 'Low stock: '.$item->name, 'Stock kam hai: '.$item->name, "Only $stock {$item->unit} remains.", "Sirf $stock {$item->unit} baqi hai.", 'inventory_item', $item->id, now());
            }
            foreach ($item->batches->filter(fn ($batch) => $batch->current_quantity > 0 && $batch->expiry_date?->lte(today()->addDays(30))) as $batch) {
                $expired = $batch->expiry_date->isPast();
                $sources[] = $this->data('inventory_expiry', $expired ? 'high' : 'warning', ($expired ? 'Expired' : 'Expiring').' stock: '.$item->name, ($expired ? 'Muddat khatam' : 'Muddat khatam honay wali').': '.$item->name, "Batch {$batch->batch_number} expires {$batch->expiry_date->toDateString()}.", "Batch {$batch->batch_number} ki muddat {$batch->expiry_date->toDateString()} hai.", 'inventory_batch', $batch->id, $batch->expiry_date);
            }
        }
        $active = [];
        foreach ($sources as $d) {
            $key = $d['type'].':'.$d['related_id'];
            $active[] = $key;
            InAppAlert::updateOrCreate(['organization_id' => $org, 'farm_id' => $farm, 'source_key' => $key], [...$d, 'status' => 'active']);
        }InAppAlert::where('organization_id', $org)->where('farm_id', $farm)->where('status', 'active')->whereNotIn('source_key', $active ?: ['none'])->update(['status' => 'resolved', 'resolved_at' => now()]);
    }

    private function data($type, $severity, $title, $roman, $description, $descriptionRoman, $related, $id, $due): array
    {
        return compact('type', 'severity', 'title', 'description') + ['title_roman_urdu' => $roman, 'description_roman_urdu' => $descriptionRoman, 'related_type' => $related, 'related_id' => $id, 'due_at' => $due];
    }
}
