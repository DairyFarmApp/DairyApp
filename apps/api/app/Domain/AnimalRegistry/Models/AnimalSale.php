<?php

namespace App\Domain\AnimalRegistry\Models;

use App\Domain\Finance\Models\IncomeRecord;
use App\Models\User;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class AnimalSale extends Model
{
    use HasFactory, HasUuids, SoftDeletes;

    protected $fillable = [
        'organization_id',
        'farm_id',
        'animal_id',
        'sale_number',
        'sale_date',
        'buyer',
        'sale_price',
        'commission',
        'transportation_cost',
        'net_revenue',
        'reason',
        'reference',
        'notes',
        'income_record_id',
        'created_by',
    ];

    protected $casts = [
        'sale_date' => 'date',
        'sale_price' => 'decimal:2',
        'commission' => 'decimal:2',
        'transportation_cost' => 'decimal:2',
        'net_revenue' => 'decimal:2',
    ];

    public function animal(): BelongsTo
    {
        return $this->belongsTo(Animal::class);
    }

    public function incomeRecord(): BelongsTo
    {
        return $this->belongsTo(IncomeRecord::class);
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
