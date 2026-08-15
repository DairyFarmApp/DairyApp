<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Finance\Models\FinancialAccount;
use App\Domain\Finance\Models\FinancialAccountTransaction;
use App\Domain\Finance\Models\FinancialAccountTransfer;
use App\Domain\Finance\Support\FinancePostingService;
use App\Domain\Finance\Support\ScopedNumberGenerator;
use App\Http\Controllers\Controller;
use App\Support\ApiResponse;
use App\Support\AuditService;
use App\Support\IdempotencyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class FinancialAccountController extends Controller
{
    public function __construct(private IdempotencyService $idempotency, private ScopedNumberGenerator $numbers, private FinancePostingService $posting, private AuditService $audit) {}

    public function index(Request $r): JsonResponse
    {
        $scope=$this->scope($r); $accounts=FinancialAccount::where($scope)->where('is_active',true)->withSum('transactions as balance','amount_change')->orderBy('name')->get();
        $transactions=FinancialAccountTransaction::where($scope)->whereIn('financial_account_id',$accounts->pluck('id'))->latest('occurred_at')->limit(300)->get();
        return ApiResponse::success($r,['currency'=>'PKR','accounts'=>$accounts->map(fn($a)=>[...$a->toArray(),'balance'=>number_format((float)$a->balance,2,'.','')]),'transactions'=>$transactions]);
    }

    public function store(Request $r): JsonResponse
    {
        $d=$r->validate(['name'=>['required','string','max:160'],'account_type'=>['required',Rule::in(['cash','bank','mobile_wallet'])],'institution'=>['nullable','string','max:160'],'external_number'=>['nullable','string','max:120'],'opening_balance'=>['required','numeric','min:0'],'opened_on'=>['required','date']]);
        return $this->idempotency->execute($r,function()use($r,$d){$scope=$this->scope($r); $account=DB::transaction(function()use($r,$d,$scope){$account=FinancialAccount::create([...$scope,...collect($d)->except(['opening_balance','opened_on'])->all(),'account_number'=>$this->numbers->next($scope['organization_id'],'financial_account','ACC-'),'created_by'=>$r->user()->id]); if((float)$d['opening_balance']>0){$journal=$this->posting->post($scope['organization_id'],$scope['farm_id'],'financial_account_opening',$account->id,$d['opened_on'],'Opening balance '.$account->name,$r->user()->id,[['account'=>'FARM_FUNDS','debit'=>(string)$d['opening_balance']],['account'=>'OPENING_EQUITY','credit'=>(string)$d['opening_balance']]]); FinancialAccountTransaction::create([...$scope,'financial_account_id'=>$account->id,'transaction_number'=>$this->numbers->next($scope['organization_id'],'financial_account_transaction','ATX-'),'occurred_at'=>$d['opened_on'],'transaction_type'=>'opening_balance','amount_change'=>$d['opening_balance'],'reference_type'=>'financial_account','reference_id'=>$account->id,'description'=>'Opening balance','journal_entry_id'=>$journal->id,'created_by'=>$r->user()->id]);} return $account;}); return ApiResponse::success($r,$this->payload($account),201);});
    }

    public function transfer(Request $r): JsonResponse
    {
        $d=$r->validate(['from_account_id'=>['required','uuid','different:to_account_id'],'to_account_id'=>['required','uuid'],'amount'=>['required','numeric','gt:0'],'transferred_at'=>['required','date'],'reference'=>['nullable','string','max:160'],'notes'=>['nullable','string','max:2000']]);
        return $this->idempotency->execute($r,function()use($r,$d){$scope=$this->scope($r);$result=DB::transaction(function()use($r,$d,$scope){$accounts=FinancialAccount::where($scope)->whereIn('id',[$d['from_account_id'],$d['to_account_id']])->lockForUpdate()->get()->keyBy('id'); abort_unless($accounts->count()===2,404);$balance=(float)FinancialAccountTransaction::where('financial_account_id',$d['from_account_id'])->sum('amount_change'); if($balance+0.001<(float)$d['amount'])return null;$transfer=FinancialAccountTransfer::create([...$scope,...$d,'transfer_number'=>$this->numbers->next($scope['organization_id'],'financial_account_transfer','TRF-'),'created_by'=>$r->user()->id]);$journal=$this->posting->post($scope['organization_id'],$scope['farm_id'],'financial_account_transfer',$transfer->id,substr($d['transferred_at'],0,10),'Transfer '.$transfer->transfer_number,$r->user()->id,[['account'=>'FARM_FUNDS','debit'=>(string)$d['amount']],['account'=>'FARM_FUNDS','credit'=>(string)$d['amount']]]);foreach([[$d['from_account_id'],-(float)$d['amount'],'transfer_out'],[$d['to_account_id'],(float)$d['amount'],'transfer_in']]as[$id,$amount,$type])FinancialAccountTransaction::create([...$scope,'financial_account_id'=>$id,'transaction_number'=>$this->numbers->next($scope['organization_id'],'financial_account_transaction','ATX-'),'occurred_at'=>$d['transferred_at'],'transaction_type'=>$type,'amount_change'=>$amount,'reference_type'=>'financial_account_transfer','reference_id'=>$transfer->id,'description'=>'Transfer '.$transfer->transfer_number,'journal_entry_id'=>$journal->id,'created_by'=>$r->user()->id]);return $transfer;});if($result===null)return ApiResponse::error($r,'INSUFFICIENT_ACCOUNT_BALANCE','The source account does not have enough funds.',422);return ApiResponse::success($r,$result,201);});
    }

    private function scope(Request $r):array{return['organization_id'=>$r->attributes->get('organization_id'),'farm_id'=>$r->attributes->get('api_session')->farm_id];}
    private function payload(FinancialAccount $a):array{return[...$a->toArray(),'balance'=>number_format((float)$a->transactions()->sum('amount_change'),2,'.',''),'currency'=>'PKR'];}
}
