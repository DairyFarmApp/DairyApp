<?php

namespace App\Support;

final class PermissionCatalog
{
    /**
     * @return list<string>
     */
    public static function all(): array
    {
        return [
            'organizations.view',
            'organizations.update',
            'farms.view',
            'farms.create',
            'farms.update',
            'farms.archive',
            'sheds.view',
            'sheds.create',
            'sheds.update',
            'sheds.archive',
            'users.view',
            'users.manage',
            'roles.view',
            'roles.manage',
            'sessions.view_own',
            'sessions.revoke_own',
            'audit_logs.view',
            'animals.view',
            'animals.create',
            'animals.update',
            'animals.archive',
            'animals.restore',
            'animals.manage_identifiers',
            'animal_breeds.view',
            'animal_breeds.manage',
            'animal_groups.view',
            'animal_groups.manage',
            'animals.move',
            'animal_movements.view',
            'animal_movements.approve',
            'animal_movements.reject',
            'animal_movements.cancel',
            'animals.record_weight',
            'animals.correct_weight',
            'animals.view_weight_history',
            'animals.change_status',
            'animals.view_status_history',
            'inventory.view',
            'inventory.manage',
            'inventory.export',
            'milk.view',
            'milk.create',
            'milk.correct',
            'employees.view',
            'employees.manage',
            'employee_loans.view',
            'employee_loans.manage',
            'payroll.view',
            'payroll.process',
            'finance.view',
            'finance.manage',
        ];
    }
}
