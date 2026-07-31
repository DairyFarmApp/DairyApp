<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('system_accounts', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->string('code', 60);
            $table->string('name', 120);
            $table->enum('type', ['asset', 'liability', 'equity', 'income', 'expense']);
            $table->boolean('is_hidden')->default(true);
            $table->timestamps();

            $table->unique(['organization_id', 'code']);
            $table->unique(['id', 'organization_id']);
            $table->foreign('organization_id')->references('id')->on('organizations')->cascadeOnDelete();
        });

        Schema::create('finance_journal_entries', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->string('entry_number', 60);
            $table->date('occurred_on');
            $table->string('source_type', 60);
            $table->uuid('source_id');
            $table->string('description', 500);
            $table->enum('status', ['posted', 'reversed'])->default('posted');
            $table->uuid('reversal_of_id')->nullable();
            $table->uuid('posted_by');
            $table->timestamps();

            $table->unique(['organization_id', 'farm_id', 'entry_number'], 'journal_farm_number_unique');
            $table->unique(['organization_id', 'source_type', 'source_id'], 'journal_source_unique');
            $table->unique(['id', 'organization_id', 'farm_id'], 'journal_scope_unique');
            $table->index(['organization_id', 'farm_id', 'occurred_on'], 'journal_farm_date_index');
            $table->foreign(['farm_id', 'organization_id'], 'journal_farm_scope_fk')
                ->references(['id', 'organization_id'])->on('farms')->restrictOnDelete();
            $table->foreign(['reversal_of_id', 'organization_id', 'farm_id'], 'journal_reversal_scope_fk')
                ->references(['id', 'organization_id', 'farm_id'])->on('finance_journal_entries')->restrictOnDelete();
            $table->foreign('posted_by')->references('id')->on('users')->restrictOnDelete();
        });

        Schema::create('finance_journal_lines', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->uuid('journal_entry_id');
            $table->uuid('system_account_id');
            $table->decimal('debit', 18, 2)->default(0);
            $table->decimal('credit', 18, 2)->default(0);
            $table->string('memo', 500)->nullable();
            $table->timestamps();

            $table->index(['organization_id', 'farm_id', 'system_account_id'], 'journal_lines_account_index');
            $table->foreign(
                ['journal_entry_id', 'organization_id', 'farm_id'],
                'journal_lines_entry_scope_fk',
            )->references(['id', 'organization_id', 'farm_id'])
                ->on('finance_journal_entries')->restrictOnDelete();
            $table->foreign(['system_account_id', 'organization_id'], 'journal_lines_account_scope_fk')
                ->references(['id', 'organization_id'])->on('system_accounts')->restrictOnDelete();
        });

        Schema::create('income_records', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->string('income_number', 60);
            $table->date('recorded_on');
            $table->string('category', 100);
            $table->string('payer', 180)->nullable();
            $table->decimal('amount', 18, 2);
            $table->string('reference', 160)->nullable();
            $table->text('description')->nullable();
            $table->uuid('journal_entry_id');
            $table->uuid('created_by');
            $table->timestamps();

            $table->unique(['organization_id', 'farm_id', 'income_number'], 'income_farm_number_unique');
            $table->index(['organization_id', 'farm_id', 'recorded_on'], 'income_farm_date_index');
            $table->foreign(['farm_id', 'organization_id'], 'income_farm_scope_fk')
                ->references(['id', 'organization_id'])->on('farms')->restrictOnDelete();
            $table->foreign(
                ['journal_entry_id', 'organization_id', 'farm_id'],
                'income_journal_scope_fk',
            )->references(['id', 'organization_id', 'farm_id'])
                ->on('finance_journal_entries')->restrictOnDelete();
            $table->foreign('created_by')->references('id')->on('users')->restrictOnDelete();
        });

        Schema::create('expense_records', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->string('expense_number', 60);
            $table->date('recorded_on');
            $table->string('category', 100);
            $table->string('payee', 180)->nullable();
            $table->decimal('amount', 18, 2);
            $table->string('reference', 160)->nullable();
            $table->text('description')->nullable();
            $table->uuid('journal_entry_id');
            $table->uuid('created_by');
            $table->timestamps();

            $table->unique(['organization_id', 'farm_id', 'expense_number'], 'expense_farm_number_unique');
            $table->index(['organization_id', 'farm_id', 'recorded_on'], 'expense_farm_date_index');
            $table->foreign(['farm_id', 'organization_id'], 'expense_farm_scope_fk')
                ->references(['id', 'organization_id'])->on('farms')->restrictOnDelete();
            $table->foreign(
                ['journal_entry_id', 'organization_id', 'farm_id'],
                'expense_journal_scope_fk',
            )->references(['id', 'organization_id', 'farm_id'])
                ->on('finance_journal_entries')->restrictOnDelete();
            $table->foreign('created_by')->references('id')->on('users')->restrictOnDelete();
        });

        Schema::create('employees', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->uuid('shed_id')->nullable();
            $table->string('employee_number', 60);
            $table->string('name', 180);
            $table->string('phone', 40)->nullable();
            $table->string('email', 254)->nullable();
            $table->string('designation', 120);
            $table->string('department', 120)->nullable();
            $table->date('joining_date');
            $table->enum('employment_type', ['full_time', 'part_time', 'contract', 'casual']);
            $table->decimal('monthly_salary', 18, 2);
            $table->text('address')->nullable();
            $table->string('emergency_contact', 180)->nullable();
            $table->text('notes')->nullable();
            $table->boolean('is_active')->default(true);
            $table->unsignedBigInteger('version')->default(1);
            $table->uuid('created_by');
            $table->uuid('updated_by');
            $table->timestamps();
            $table->softDeletes();

            $table->unique(['organization_id', 'farm_id', 'employee_number'], 'employees_farm_number_unique');
            $table->unique(['id', 'organization_id', 'farm_id'], 'employees_scope_unique');
            $table->index(['organization_id', 'farm_id', 'is_active', 'name'], 'employees_farm_active_index');
            $table->foreign(['farm_id', 'organization_id'], 'employees_farm_scope_fk')
                ->references(['id', 'organization_id'])->on('farms')->restrictOnDelete();
            $table->foreign(['shed_id', 'organization_id', 'farm_id'], 'employees_shed_scope_fk')
                ->references(['id', 'organization_id', 'farm_id'])->on('sheds')->restrictOnDelete();
            $table->foreign('created_by')->references('id')->on('users')->restrictOnDelete();
            $table->foreign('updated_by')->references('id')->on('users')->restrictOnDelete();
        });

        Schema::create('employee_loans', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->uuid('employee_id');
            $table->string('loan_number', 60);
            $table->date('disbursement_date');
            $table->decimal('principal_amount', 18, 2);
            $table->decimal('monthly_installment', 18, 2);
            $table->decimal('recovered_amount', 18, 2)->default(0);
            $table->decimal('outstanding_amount', 18, 2);
            $table->date('first_recovery_month');
            $table->string('reason', 500);
            $table->text('notes')->nullable();
            $table->enum('status', ['active', 'paid'])->default('active');
            $table->uuid('journal_entry_id');
            $table->uuid('created_by');
            $table->timestamps();

            $table->unique(['organization_id', 'farm_id', 'loan_number'], 'loans_farm_number_unique');
            $table->unique(['id', 'organization_id', 'farm_id'], 'loans_scope_unique');
            $table->index(['organization_id', 'farm_id', 'employee_id', 'status'], 'loans_employee_status_index');
            $table->foreign(
                ['employee_id', 'organization_id', 'farm_id'],
                'loans_employee_scope_fk',
            )->references(['id', 'organization_id', 'farm_id'])->on('employees')->restrictOnDelete();
            $table->foreign(
                ['journal_entry_id', 'organization_id', 'farm_id'],
                'loans_journal_scope_fk',
            )->references(['id', 'organization_id', 'farm_id'])
                ->on('finance_journal_entries')->restrictOnDelete();
            $table->foreign('created_by')->references('id')->on('users')->restrictOnDelete();
        });

        Schema::create('payroll_periods', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->date('period_month');
            $table->enum('status', ['draft', 'approved', 'paid'])->default('draft');
            $table->decimal('total_basic_salary', 18, 2)->default(0);
            $table->decimal('total_loan_deduction', 18, 2)->default(0);
            $table->decimal('total_net_salary', 18, 2)->default(0);
            $table->uuid('generated_by');
            $table->uuid('approved_by')->nullable();
            $table->uuid('paid_by')->nullable();
            $table->timestamp('approved_at')->nullable();
            $table->timestamp('paid_at')->nullable();
            $table->uuid('journal_entry_id')->nullable();
            $table->timestamps();

            $table->unique(['organization_id', 'farm_id', 'period_month'], 'payroll_farm_month_unique');
            $table->unique(['id', 'organization_id', 'farm_id'], 'payroll_scope_unique');
            $table->index(['organization_id', 'farm_id', 'status'], 'payroll_farm_status_index');
            $table->foreign(['farm_id', 'organization_id'], 'payroll_farm_scope_fk')
                ->references(['id', 'organization_id'])->on('farms')->restrictOnDelete();
            $table->foreign(
                ['journal_entry_id', 'organization_id', 'farm_id'],
                'payroll_journal_scope_fk',
            )->references(['id', 'organization_id', 'farm_id'])
                ->on('finance_journal_entries')->restrictOnDelete();
            $table->foreign('generated_by')->references('id')->on('users')->restrictOnDelete();
            $table->foreign('approved_by')->references('id')->on('users')->restrictOnDelete();
            $table->foreign('paid_by')->references('id')->on('users')->restrictOnDelete();
        });

        Schema::create('payroll_entries', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->uuid('payroll_period_id');
            $table->uuid('employee_id');
            $table->decimal('basic_salary', 18, 2);
            $table->decimal('loan_deduction', 18, 2)->default(0);
            $table->decimal('bonus', 18, 2)->default(0);
            $table->decimal('other_deduction', 18, 2)->default(0);
            $table->decimal('net_salary', 18, 2);
            $table->timestamps();

            $table->unique(['payroll_period_id', 'employee_id'], 'payroll_entries_period_employee_unique');
            $table->unique(['id', 'organization_id', 'farm_id'], 'payroll_entries_scope_unique');
            $table->foreign(
                ['payroll_period_id', 'organization_id', 'farm_id'],
                'payroll_entries_period_scope_fk',
            )->references(['id', 'organization_id', 'farm_id'])->on('payroll_periods')->restrictOnDelete();
            $table->foreign(
                ['employee_id', 'organization_id', 'farm_id'],
                'payroll_entries_employee_scope_fk',
            )->references(['id', 'organization_id', 'farm_id'])->on('employees')->restrictOnDelete();
        });

        Schema::create('employee_loan_installments', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->uuid('employee_loan_id');
            $table->uuid('payroll_entry_id');
            $table->decimal('amount', 18, 2);
            $table->date('recovered_on');
            $table->timestamps();

            $table->unique(['employee_loan_id', 'payroll_entry_id'], 'loan_installment_payroll_unique');
            $table->index(['organization_id', 'farm_id', 'recovered_on'], 'loan_installments_date_index');
            $table->foreign(
                ['employee_loan_id', 'organization_id', 'farm_id'],
                'loan_installments_loan_scope_fk',
            )->references(['id', 'organization_id', 'farm_id'])->on('employee_loans')->restrictOnDelete();
            $table->foreign(
                ['payroll_entry_id', 'organization_id', 'farm_id'],
                'loan_installments_payroll_scope_fk',
            )->references(['id', 'organization_id', 'farm_id'])->on('payroll_entries')->restrictOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('employee_loan_installments');
        Schema::dropIfExists('payroll_entries');
        Schema::dropIfExists('payroll_periods');
        Schema::dropIfExists('employee_loans');
        Schema::dropIfExists('employees');
        Schema::dropIfExists('expense_records');
        Schema::dropIfExists('income_records');
        Schema::dropIfExists('finance_journal_lines');
        Schema::dropIfExists('finance_journal_entries');
        Schema::dropIfExists('system_accounts');
    }
};
