<?php
namespace App\Domain\Finance\Models;
use App\Models\Concerns\UsesUuidV7; use Illuminate\Database\Eloquent\Model; use Illuminate\Database\Eloquent\SoftDeletes; use Illuminate\Database\Eloquent\Relations\HasMany;
class FinancialAccount extends Model { use UsesUuidV7,SoftDeletes; protected $fillable=['organization_id','farm_id','account_number','name','account_type','institution','external_number','is_active','created_by']; protected function casts():array{return['is_active'=>'boolean'];} public function transactions():HasMany{return $this->hasMany(FinancialAccountTransaction::class);} }
