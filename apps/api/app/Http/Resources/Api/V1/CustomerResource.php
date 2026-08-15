<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CustomerResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return ['id' => $this->id, 'farm_id' => $this->farm_id, 'code' => $this->code, 'name' => $this->name, 'customer_type' => $this->customer_type, 'phone' => $this->phone, 'email' => $this->email, 'address' => $this->address, 'delivery_address' => $this->delivery_address, 'tax_information' => $this->tax_information, 'credit_limit' => $this->credit_limit, 'payment_terms_days' => $this->payment_terms_days, 'default_milk_rate' => $this->default_milk_rate, 'quality_based_pricing' => $this->quality_based_pricing, 'opening_balance' => $this->opening_balance, 'current_balance' => $this->current_balance, 'currency' => 'PKR', 'route_name' => $this->route_name, 'is_active' => $this->is_active, 'notes' => $this->notes, 'version' => $this->version];
    }
}
