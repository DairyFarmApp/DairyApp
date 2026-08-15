<?php

namespace App\Domain\Commerce\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class SupplierInvoice extends Model
{
    use UsesUuidV7;

    protected $fillable = ['organization_id', 'farm_id', 'supplier_id', 'purchase_order_id', 'invoice_number', 'supplier_invoice_number', 'invoice_date', 'due_date', 'total_amount', 'paid_amount', 'balance_amount', 'payment_status', 'notes', 'created_by'];

    protected function casts(): array
    {
        return ['invoice_date' => 'date', 'due_date' => 'date', 'total_amount' => 'decimal:2', 'paid_amount' => 'decimal:2', 'balance_amount' => 'decimal:2'];
    }

    public function supplier(): BelongsTo
    {
        return $this->belongsTo(Supplier::class);
    }

    public function purchaseOrder(): BelongsTo
    {
        return $this->belongsTo(PurchaseOrder::class);
    }

    public function payments(): HasMany
    {
        return $this->hasMany(SupplierPayment::class);
    }
}
