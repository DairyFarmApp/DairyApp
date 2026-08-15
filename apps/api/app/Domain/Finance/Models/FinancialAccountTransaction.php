<?php
namespace App\Domain\Finance\Models;
use App\Models\Concerns\UsesUuidV7; use Illuminate\Database\Eloquent\Model;
class FinancialAccountTransaction extends Model { use UsesUuidV7; protected $fillable=['organization_id','farm_id','financial_account_id','transaction_number','occurred_at','transaction_type','amount_change','reference_type','reference_id','description','journal_entry_id','created_by']; protected function casts():array{return['occurred_at'=>'datetime','amount_change'=>'decimal:2'];} }
