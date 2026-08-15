<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class FinancialAccountsTest extends TestCase
{
    use CreatesFoundationData, RefreshDatabase;

    public function test_accounts_opening_balances_and_transfers_use_append_only_ledgers(): void
    {
        $f=$this->foundation(['finance_accounts.view','finance_accounts.manage','finance_accounts.transfer']); $h=$this->bearer($this->loginToken());
        $cash=$this->postJson('/api/v1/finance/accounts',['name'=>'Main Cash Box','account_type'=>'cash','opening_balance'=>'50000.00','opened_on'=>'2026-08-12'],[...$h,'Idempotency-Key'=>'cash'])->assertCreated()->assertJsonPath('data.account_number','ACC-000001')->assertJsonPath('data.balance','50000.00');
        $bank=$this->postJson('/api/v1/finance/accounts',['name'=>'HBL Farm Account','account_type'=>'bank','institution'=>'HBL','external_number'=>'PK00-1234','opening_balance'=>'10000.00','opened_on'=>'2026-08-12'],[...$h,'Idempotency-Key'=>'bank'])->assertCreated()->assertJsonPath('data.account_number','ACC-000002');
        $this->postJson('/api/v1/finance/account-transfers',['from_account_id'=>$cash->json('data.id'),'to_account_id'=>$bank->json('data.id'),'amount'=>'15000.00','transferred_at'=>'2026-08-12 12:00:00'],[...$h,'Idempotency-Key'=>'transfer'])->assertCreated()->assertJsonPath('data.transfer_number','TRF-000001');
        $this->getJson('/api/v1/finance/accounts',$h)->assertOk()->assertJsonPath('data.currency','PKR')->assertJsonPath('data.accounts.0.balance','25000.00')->assertJsonPath('data.accounts.1.balance','35000.00');
        $this->assertDatabaseCount('financial_account_transactions',4); $this->assertDatabaseCount('finance_journal_entries',3); $this->assertSame('0.00',number_format((float)\DB::table('finance_journal_lines')->selectRaw('SUM(debit-credit) total')->value('total'),2,'.',''));
    }

    public function test_transfer_blocks_insufficient_balance_without_partial_writes(): void
    {
        $this->foundation(['finance_accounts.manage','finance_accounts.transfer']); $h=$this->bearer($this->loginToken());
        $a=$this->postJson('/api/v1/finance/accounts',['name'=>'Cash','account_type'=>'cash','opening_balance'=>'100','opened_on'=>'2026-08-12'],[...$h,'Idempotency-Key'=>'a'])->json('data.id');
        $b=$this->postJson('/api/v1/finance/accounts',['name'=>'Wallet','account_type'=>'mobile_wallet','opening_balance'=>'0','opened_on'=>'2026-08-12'],[...$h,'Idempotency-Key'=>'b'])->json('data.id');
        $this->postJson('/api/v1/finance/account-transfers',['from_account_id'=>$a,'to_account_id'=>$b,'amount'=>'101','transferred_at'=>'2026-08-12'],[...$h,'Idempotency-Key'=>'bad'])->assertUnprocessable()->assertJsonPath('error.code','INSUFFICIENT_ACCOUNT_BALANCE');
        $this->assertDatabaseCount('financial_account_transfers',0); $this->assertDatabaseCount('financial_account_transactions',1);
    }
}
