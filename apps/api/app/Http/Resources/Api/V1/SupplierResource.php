<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SupplierResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return ['id' => $this->id, 'farm_id' => $this->farm_id, 'code' => $this->code, 'name' => $this->name, 'contact_person' => $this->contact_person, 'phone' => $this->phone, 'email' => $this->email, 'address' => $this->address, 'tax_information' => $this->tax_information, 'categories' => $this->categories ?? [], 'payment_terms_days' => $this->payment_terms_days, 'credit_limit' => $this->credit_limit, 'opening_balance' => $this->opening_balance, 'current_balance' => $this->current_balance, 'currency' => 'PKR', 'is_active' => $this->is_active, 'notes' => $this->notes, 'version' => $this->version];
    }
}
