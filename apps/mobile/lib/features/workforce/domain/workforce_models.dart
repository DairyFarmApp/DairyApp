final class Employee {
  const Employee({
    required this.id,
    required this.employeeNumber,
    required this.name,
    required this.designation,
    required this.joiningDate,
    required this.employmentType,
    required this.monthlySalary,
    required this.isActive,
    required this.version,
    this.phone,
    this.email,
    this.department,
    this.address,
    this.emergencyContact,
    this.notes,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    id: json['id'] as String,
    employeeNumber: json['employee_number'] as String,
    name: json['name'] as String,
    phone: json['phone'] as String?,
    email: json['email'] as String?,
    designation: json['designation'] as String,
    department: json['department'] as String?,
    joiningDate: DateTime.parse(json['joining_date'] as String),
    employmentType: json['employment_type'] as String,
    monthlySalary: json['monthly_salary'].toString(),
    address: json['address'] as String?,
    emergencyContact: json['emergency_contact'] as String?,
    notes: json['notes'] as String?,
    isActive: json['is_active'] as bool? ?? true,
    version: (json['version'] as num).toInt(),
  );

  final String id;
  final String employeeNumber;
  final String name;
  final String? phone;
  final String? email;
  final String designation;
  final String? department;
  final DateTime joiningDate;
  final String employmentType;
  final String monthlySalary;
  final String? address;
  final String? emergencyContact;
  final String? notes;
  final bool isActive;
  final int version;
}

final class EmployeeOverview {
  const EmployeeOverview({
    required this.employees,
    required this.activeEmployees,
    required this.monthlySalaryTotal,
    required this.outstandingLoans,
  });

  factory EmployeeOverview.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>;
    return EmployeeOverview(
      employees: (json['employees'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(Employee.fromJson)
          .toList(growable: false),
      activeEmployees: (summary['active_employees'] as num).toInt(),
      monthlySalaryTotal: summary['monthly_salary_total'].toString(),
      outstandingLoans: summary['outstanding_loans'].toString(),
    );
  }

  final List<Employee> employees;
  final int activeEmployees;
  final String monthlySalaryTotal;
  final String outstandingLoans;
}

final class EmployeeLoan {
  const EmployeeLoan({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.loanNumber,
    required this.disbursementDate,
    required this.principalAmount,
    required this.monthlyInstallment,
    required this.recoveredAmount,
    required this.outstandingAmount,
    required this.firstRecoveryMonth,
    required this.reason,
    required this.status,
    this.notes,
  });

  factory EmployeeLoan.fromJson(Map<String, dynamic> json) => EmployeeLoan(
    id: json['id'] as String,
    employeeId: json['employee_id'] as String,
    employeeName: json['employee_name'] as String? ?? 'Employee',
    loanNumber: json['loan_number'] as String,
    disbursementDate: DateTime.parse(json['disbursement_date'] as String),
    principalAmount: json['principal_amount'].toString(),
    monthlyInstallment: json['monthly_installment'].toString(),
    recoveredAmount: json['recovered_amount'].toString(),
    outstandingAmount: json['outstanding_amount'].toString(),
    firstRecoveryMonth: json['first_recovery_month'] as String,
    reason: json['reason'] as String,
    notes: json['notes'] as String?,
    status: json['status'] as String,
  );

  final String id;
  final String employeeId;
  final String employeeName;
  final String loanNumber;
  final DateTime disbursementDate;
  final String principalAmount;
  final String monthlyInstallment;
  final String recoveredAmount;
  final String outstandingAmount;
  final String firstRecoveryMonth;
  final String reason;
  final String? notes;
  final String status;
}

final class LoanOverview {
  const LoanOverview({
    required this.loans,
    required this.activeLoans,
    required this.principalAmount,
    required this.recoveredAmount,
    required this.outstandingAmount,
  });

  factory LoanOverview.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>;
    return LoanOverview(
      loans: (json['loans'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(EmployeeLoan.fromJson)
          .toList(growable: false),
      activeLoans: (summary['active_loans'] as num).toInt(),
      principalAmount: summary['principal_amount'].toString(),
      recoveredAmount: summary['recovered_amount'].toString(),
      outstandingAmount: summary['outstanding_amount'].toString(),
    );
  }

  final List<EmployeeLoan> loans;
  final int activeLoans;
  final String principalAmount;
  final String recoveredAmount;
  final String outstandingAmount;
}

final class PayrollLine {
  const PayrollLine({
    required this.id,
    required this.employeeId,
    required this.employeeNumber,
    required this.employeeName,
    required this.basicSalary,
    required this.loanDeduction,
    required this.netSalary,
  });

  factory PayrollLine.fromJson(Map<String, dynamic> json) => PayrollLine(
    id: json['id'] as String,
    employeeId: json['employee_id'] as String,
    employeeNumber: json['employee_number'] as String? ?? '',
    employeeName: json['employee_name'] as String? ?? 'Employee',
    basicSalary: json['basic_salary'].toString(),
    loanDeduction: json['loan_deduction'].toString(),
    netSalary: json['net_salary'].toString(),
  );

  final String id;
  final String employeeId;
  final String employeeNumber;
  final String employeeName;
  final String basicSalary;
  final String loanDeduction;
  final String netSalary;
}

final class PayrollPeriod {
  const PayrollPeriod({
    required this.id,
    required this.periodMonth,
    required this.status,
    required this.totalBasicSalary,
    required this.totalLoanDeduction,
    required this.totalNetSalary,
    required this.entries,
  });

  factory PayrollPeriod.fromJson(Map<String, dynamic> json) => PayrollPeriod(
    id: json['id'] as String,
    periodMonth: json['period_month'] as String,
    status: json['status'] as String,
    totalBasicSalary: json['total_basic_salary'].toString(),
    totalLoanDeduction: json['total_loan_deduction'].toString(),
    totalNetSalary: json['total_net_salary'].toString(),
    entries: (json['entries'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(PayrollLine.fromJson)
        .toList(growable: false),
  );

  final String id;
  final String periodMonth;
  final String status;
  final String totalBasicSalary;
  final String totalLoanDeduction;
  final String totalNetSalary;
  final List<PayrollLine> entries;
}

final class FinanceOverview {
  const FinanceOverview({
    required this.month,
    required this.income,
    required this.expenses,
    required this.netProfit,
    required this.paidPayroll,
    required this.outstandingEmployeeLoans,
  });

  factory FinanceOverview.fromJson(Map<String, dynamic> json) =>
      FinanceOverview(
        month: json['month'] as String,
        income: json['income'].toString(),
        expenses: json['expenses'].toString(),
        netProfit: json['net_profit'].toString(),
        paidPayroll: json['paid_payroll'].toString(),
        outstandingEmployeeLoans: json['outstanding_employee_loans'].toString(),
      );

  final String month;
  final String income;
  final String expenses;
  final String netProfit;
  final String paidPayroll;
  final String outstandingEmployeeLoans;
}

final class FinanceRecord {
  const FinanceRecord({
    required this.id,
    required this.number,
    required this.recordedOn,
    required this.category,
    required this.amount,
    this.party,
    this.reference,
    this.description,
  });

  factory FinanceRecord.fromJson(Map<String, dynamic> json) => FinanceRecord(
    id: json['id'] as String,
    number: json['number'] as String,
    recordedOn: DateTime.parse(json['recorded_on'] as String),
    category: json['category'] as String,
    party: json['party'] as String?,
    amount: json['amount'].toString(),
    reference: json['reference'] as String?,
    description: json['description'] as String?,
  );

  final String id;
  final String number;
  final DateTime recordedOn;
  final String category;
  final String? party;
  final String amount;
  final String? reference;
  final String? description;
}

final class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.entryNumber,
    required this.occurredOn,
    required this.sourceType,
    required this.description,
    required this.status,
    required this.amount,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> json) => LedgerEntry(
    id: json['id'] as String,
    entryNumber: json['entry_number'] as String,
    occurredOn: DateTime.parse(json['occurred_on'] as String),
    sourceType: json['source_type'] as String,
    description: json['description'] as String,
    status: json['status'] as String,
    amount: json['amount'].toString(),
  );

  final String id;
  final String entryNumber;
  final DateTime occurredOn;
  final String sourceType;
  final String description;
  final String status;
  final String amount;
}

final class FinanceDashboard {
  const FinanceDashboard({
    required this.overview,
    required this.income,
    required this.expenses,
    required this.ledger,
  });

  final FinanceOverview overview;
  final List<FinanceRecord> income;
  final List<FinanceRecord> expenses;
  final List<LedgerEntry> ledger;
}
