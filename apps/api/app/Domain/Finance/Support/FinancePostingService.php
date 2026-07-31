<?php

namespace App\Domain\Finance\Support;

use App\Domain\Finance\Models\JournalEntry;
use App\Domain\Finance\Models\SystemAccount;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

final class FinancePostingService
{
    private const ACCOUNTS = [
        'FARM_FUNDS' => ['Farm Funds', 'asset'],
        'GENERAL_INCOME' => ['General Income', 'income'],
        'GENERAL_EXPENSE' => ['General Expense', 'expense'],
        'SALARY_EXPENSE' => ['Salary Expense', 'expense'],
        'EMPLOYEE_LOANS' => ['Employee Loans Receivable', 'asset'],
    ];

    public function __construct(private readonly ScopedNumberGenerator $numbers) {}

    /**
     * @param  list<array{account: string, debit?: string, credit?: string, memo?: string|null}>  $lines
     */
    public function post(
        string $organizationId,
        string $farmId,
        string $sourceType,
        string $sourceId,
        string $occurredOn,
        string $description,
        string $postedBy,
        array $lines,
    ): JournalEntry {
        $accounts = $this->accounts($organizationId);
        $debits = 0;
        $credits = 0;

        foreach ($lines as $line) {
            if (! $accounts->has($line['account'])) {
                throw new \InvalidArgumentException('Unknown system account.');
            }
            $debit = $this->toCents($line['debit'] ?? '0.00');
            $credit = $this->toCents($line['credit'] ?? '0.00');
            if (($debit === 0) === ($credit === 0)) {
                throw new \InvalidArgumentException('A journal line must contain exactly one positive side.');
            }
            $debits += $debit;
            $credits += $credit;
        }

        if ($debits <= 0 || $debits !== $credits) {
            throw new \InvalidArgumentException('Journal debits and credits must balance.');
        }

        $journal = JournalEntry::query()->create([
            'organization_id' => $organizationId,
            'farm_id' => $farmId,
            'entry_number' => $this->numbers->next($organizationId, 'finance_journal', 'JE-'),
            'occurred_on' => $occurredOn,
            'source_type' => $sourceType,
            'source_id' => $sourceId,
            'description' => $description,
            'status' => 'posted',
            'posted_by' => $postedBy,
        ]);

        foreach ($lines as $line) {
            $journal->lines()->create([
                'organization_id' => $organizationId,
                'farm_id' => $farmId,
                'system_account_id' => $accounts[$line['account']]->id,
                'debit' => $this->formatCents($this->toCents($line['debit'] ?? '0.00')),
                'credit' => $this->formatCents($this->toCents($line['credit'] ?? '0.00')),
                'memo' => $line['memo'] ?? null,
            ]);
        }

        return $journal->load('lines.account');
    }

    /**
     * @return Collection<string, SystemAccount>
     */
    public function accounts(string $organizationId): Collection
    {
        return collect(self::ACCOUNTS)->mapWithKeys(
            function (array $definition, string $code) use ($organizationId): array {
                DB::table('system_accounts')->insertOrIgnore([
                    'id' => (string) Str::uuid7(),
                    'organization_id' => $organizationId,
                    'code' => $code,
                    'name' => $definition[0],
                    'type' => $definition[1],
                    'is_hidden' => true,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
                $account = SystemAccount::query()
                    ->where('organization_id', $organizationId)
                    ->where('code', $code)
                    ->firstOrFail();

                return [$code => $account];
            },
        );
    }

    public function toCents(string $amount): int
    {
        if (! preg_match('/^\d{1,16}(?:\.\d{1,2})?$/', $amount)) {
            throw new \InvalidArgumentException('Money must be a positive decimal string with at most two decimals.');
        }
        [$whole, $fraction] = array_pad(explode('.', $amount, 2), 2, '');

        return ((int) $whole * 100) + (int) str_pad($fraction, 2, '0');
    }

    public function formatCents(int $cents): string
    {
        return sprintf('%d.%02d', intdiv($cents, 100), $cents % 100);
    }
}
