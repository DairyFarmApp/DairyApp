<?php
namespace App\Domain\Finance\Models;
use App\Models\Concerns\UsesUuidV7; use Illuminate\Database\Eloquent\Model;
class FinancialAccountTransfer extends Model { use UsesUuidV7; protected $fillable=['organization_id','farm_id','transfer_number','from_account_id','to_account_id','transferred_at','amount','reference','notes','created_by']; protected function casts():array{return['transferred_at'=>'datetime','amount'=>'decimal:2'];} }
