<?php

namespace App\Domain\Workforce\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Employee extends Model
{
    use SoftDeletes, UsesUuidV7;

    protected $fillable = [
        'organization_id',
        'farm_id',
        'shed_id',
        'employee_number',
        'name',
        'phone',
        'email',
        'designation',
        'department',
        'joining_date',
        'employment_type',
        'monthly_salary',
        'address',
        'emergency_contact',
        'notes',
        'is_active',
        'version',
        'created_by',
        'updated_by',
    ];

    protected function casts(): array
    {
        return [
            'joining_date' => 'date:Y-m-d',
            'monthly_salary' => 'decimal:2',
            'is_active' => 'boolean',
            'version' => 'integer',
        ];
    }

    public function loans(): HasMany
    {
        return $this->hasMany(EmployeeLoan::class);
    }
}
