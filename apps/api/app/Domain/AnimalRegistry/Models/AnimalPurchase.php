<?php

namespace App\Domain\AnimalRegistry\Models;

use App\Domain\Finance\Models\ExpenseRecord;
use App\Models\User;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class AnimalPurchase extends Model
{
    use HasFactory, HasUuids, SoftDeletes;

    protected $fillable = [
        'organization_id',
        'farm_id',
        'animal_id',
        'purchase_number',
        'purchase_date',
        'supplier',
        'purchase_price',
        'transportation_cost',
        'veterinary_cost',
        'total_cost',
        'reference',
        'notes',
        'expense_record_id',
        'created_by',
    ];

    protected $casts = [
        'purchase_date' => 'date',
        'purchase_price' => 'decimal:2',
        'transportation_cost' => 'decimal:2',
        'veterinary_cost' => 'decimal:2',
        'total_cost' => 'decimal:2',
    ];

    public function animal(): BelongsTo
    {
        return $this->belongsTo(Animal::class);
    }

    public function expenseRecord(): BelongsTo
    {
        return $this->belongsTo(ExpenseRecord::class);
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
