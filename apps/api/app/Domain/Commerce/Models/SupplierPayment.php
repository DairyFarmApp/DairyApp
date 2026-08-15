<?php

namespace App\Domain\Commerce\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SupplierPayment extends Model
{
    use UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'supplier_id', 'supplier_invoice_id', 'payment_number', 'payment_date', 'amount', 'payment_method', 'reference', 'notes', 'created_by'];

    protected function casts(): array
    {
        return ['payment_date' => 'date', 'amount' => 'decimal:2'];
    }

    public function invoice(): BelongsTo
    {
        return $this->belongsTo(SupplierInvoice::class, 'supplier_invoice_id');
    }
}
