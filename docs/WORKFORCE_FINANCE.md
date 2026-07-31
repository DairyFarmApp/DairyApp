# Workforce, Payroll, Employee Loans, and Finance

Status: implemented controlled Phase 7A core, 2026-07-30.

## User-facing modules

The authenticated navigation permanently includes:

- Employees
- Salary
- Loans
- Finance

On compact layouts the menu bar scrolls horizontally so every module remains
reachable. Wide layouts retain the glass navigation rail.

## Employees

Employees belong to the authenticated organization and active farm. The
implemented profile stores an employee number, name, phone, email,
designation, department, joining date, employment type, monthly PKR salary,
address, emergency contact, notes, active state, and optimistic version.

Authorized users can add and edit employees. Deactivation preserves payroll
history and is blocked while an active loan has an outstanding balance.
Employee numbers are generated transactionally from the organization sequence.

Employee records are not application login accounts. Owner/family access
continues to use organization memberships and roles.

## Employee loans

A loan records:

- employee;
- disbursement date;
- principal amount;
- monthly installment;
- first recovery month;
- reason and notes;
- recovered and outstanding amounts;
- active or paid status.

Disbursement immediately creates a balanced immutable journal:

```text
Debit  Employee Loans Receivable
Credit Farm Funds
```

There is no ordinary loan update or delete endpoint after disbursement.
Installments are created only when approved payroll is paid. A loan becomes
`paid` automatically when its outstanding balance reaches zero.

## Monthly payroll

Payroll uses one period per organization, farm, and calendar month:

```text
Draft -> Approved -> Paid
```

Generation snapshots every eligible active employee's monthly salary. Active
loans whose recovery month has arrived contribute a scheduled deduction, capped
so deductions cannot exceed salary. Only one unpaid payroll period may exist
for a farm.

Payment creates immutable installment rows, updates loan balances, and posts
one balanced journal:

```text
Debit  Salary Expense               gross salary
Credit Farm Funds                   net salary
Credit Employee Loans Receivable    recovered installments
```

The backend rejects payment until approval. Idempotency prevents repeat
approval/payment requests from posting twice.

## PKR finance

The interface contains no cash, bank, mobile-wallet, or account-setup screen.
All amounts are exact two-decimal PKR strings. The backend maintains hidden
system accounts:

- Farm Funds
- General Income
- General Expense
- Salary Expense
- Employee Loans Receivable

Income posts a debit to Farm Funds and a credit to General Income. Expense
posts a debit to General Expense and a credit to Farm Funds. Users see monthly
income, expenses, profit/loss, employee-loan balance, source records, and
journal entries without system-account configuration.

Posted income, expenses, loan disbursements, payroll payment, journals, and
installments have no ordinary edit or physical-delete endpoint.

## Permissions

- `employees.view`
- `employees.manage`
- `employee_loans.view`
- `employee_loans.manage`
- `payroll.view`
- `payroll.process`
- `finance.view`
- `finance.manage`

Organization owners/family administrators and farm managers receive these
permissions. Other seeded farm roles do not receive confidential workforce or
finance access. The permanent menu is discoverable, but Laravel permission and
tenant middleware remains the security boundary for all data and actions.

## Tenant isolation and audit

Every implemented row carries organization scope. Operational records also
carry farm scope and composite foreign keys. The active organization and farm
come from the opaque authenticated session, never from a client-selected
finance payload.

Audited actions include employee creation/update/deactivation/restoration, loan
disbursement, payroll generation/approval/payment, and income/expense posting.
Audit rows contain request and actor context and are not editable through these
modules.

## API operations

Employees:

- `GET /api/v1/employees`
- `POST /api/v1/employees`
- `PATCH /api/v1/employees/{employee}`
- `DELETE /api/v1/employees/{employee}`
- `POST /api/v1/employees/{employee}/restore`

Loans:

- `GET /api/v1/employee-loans`
- `POST /api/v1/employee-loans`

Payroll:

- `GET /api/v1/payroll`
- `POST /api/v1/payroll/generate`
- `POST /api/v1/payroll/{period}/approve`
- `POST /api/v1/payroll/{period}/pay`

Finance:

- `GET /api/v1/finance/overview`
- `GET|POST /api/v1/finance/income`
- `GET|POST /api/v1/finance/expenses`
- `GET /api/v1/finance/ledger`
- `GET /api/v1/finance/profit-loss`

All create and state-transition commands accept `Idempotency-Key`.

## Offline policy

Workforce and finance are online-only in Phase 7A. Financial commands are never
queued speculatively because salary, loan balance, approval state, and journal
balance must be revalidated against the authoritative MySQL transaction.
Offline read caching and finance-draft outbox support require a separately
approved conflict and sensitive-data policy.

## Explicit exclusions

- attendance, shifts, leave, overtime, bonuses, allowances, and arbitrary
  payroll deductions;
- employee photographs, identification numbers, bank details, documents,
  payslip PDFs, tasks, and performance notes;
- statutory tax, pension, social-security, or jurisdiction-specific payroll;
- expense approval thresholds, fiscal periods/locking, journal reversal UI,
  cost centres, receivables, payables, cash flow, and exports;
- cash/bank/wallet setup and transfers;
- offline workforce or finance mutation.
