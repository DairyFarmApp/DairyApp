import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/auth/session_models.dart';
import 'package:dairycare_mobile/features/account/presentation/family_management_screen.dart';
import 'package:dairycare_mobile/features/account/presentation/profile_screen.dart';
import 'package:dairycare_mobile/features/authentication/presentation/login_screen.dart';
import 'package:dairycare_mobile/features/authentication/presentation/signup_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_detail_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_form_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_group_management_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_list_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_movement_form_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_status_change_form_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_weight_form_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_feed_form_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/animal_milk_form_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/breed_management_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/cattle_sales_dashboard_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/cattle_sale_form_screen.dart';
import 'package:dairycare_mobile/features/animals/presentation/cattle_purchase_form_screen.dart';
import 'package:dairycare_mobile/features/health/presentation/health_assessment_screen.dart';
import 'package:dairycare_mobile/features/health/presentation/treatment_form_screen.dart';
import 'package:dairycare_mobile/features/health/presentation/health_knowledge_screen.dart';
import 'package:dairycare_mobile/features/health/presentation/health_ai_ask_screen.dart';
import 'package:dairycare_mobile/features/health/presentation/health_ai_review_screen.dart';
import 'package:dairycare_mobile/features/health/presentation/health_medicine_evidence_screen.dart';
import 'package:dairycare_mobile/features/health/presentation/preventive_care_form_screen.dart';
import 'package:dairycare_mobile/features/health/presentation/breeding_section.dart';
import 'package:dairycare_mobile/features/health/presentation/calf_care_section.dart';
import 'package:dairycare_mobile/features/health/presentation/alerts_screen.dart';
import 'package:dairycare_mobile/features/farms/presentation/farm_selection_screen.dart';
import 'package:dairycare_mobile/features/farms/presentation/farm_list_screen.dart';
import 'package:dairycare_mobile/features/foundation_home/presentation/foundation_home_screen.dart';
import 'package:dairycare_mobile/features/foundation_home/presentation/foundation_shell.dart';
import 'package:dairycare_mobile/features/foundation_home/presentation/sync_diagnostics_screen.dart';
import 'package:dairycare_mobile/features/inventory/domain/inventory_models.dart';
import 'package:dairycare_mobile/features/inventory/presentation/inventory_dashboard_screen.dart';
import 'package:dairycare_mobile/features/inventory/presentation/inventory_item_form_screen.dart';
import 'package:dairycare_mobile/features/inventory/presentation/inventory_overview_screen.dart';
import 'package:dairycare_mobile/features/inventory/presentation/stock_usage_indents_screen.dart';
import 'package:dairycare_mobile/features/reports/presentation/daily_production_report_screen.dart';
import 'package:dairycare_mobile/features/milk/presentation/milk_production_screen.dart';
import 'package:dairycare_mobile/features/feed/presentation/daily_feed_issues_screen.dart';
import 'package:dairycare_mobile/features/feed/presentation/daily_feed_issue_form_screen.dart';
import 'package:dairycare_mobile/features/feed/presentation/feed_ration_plans_screen.dart';
import 'package:dairycare_mobile/features/feed/presentation/feed_ration_plan_form_screen.dart';
import 'package:dairycare_mobile/features/feed/presentation/feed_analysis_screen.dart';
import 'package:dairycare_mobile/features/organizations/presentation/organization_selection_screen.dart';
import 'package:dairycare_mobile/features/sheds/presentation/shed_list_screen.dart';
import 'package:dairycare_mobile/features/workforce/presentation/employee_loans_screen.dart';
import 'package:dairycare_mobile/features/workforce/presentation/employees_screen.dart';
import 'package:dairycare_mobile/features/workforce/presentation/finance_screen.dart';
import 'package:dairycare_mobile/features/workforce/presentation/payroll_screen.dart';
import 'package:dairycare_mobile/features/commerce/presentation/commercial_parties_screen.dart';
import 'package:dairycare_mobile/features/commerce/presentation/purchase_orders_screen.dart';
import 'package:dairycare_mobile/features/commerce/presentation/supplier_invoices_screen.dart';
import 'package:dairycare_mobile/features/commerce/presentation/milk_sales_screen.dart';
import 'package:dairycare_mobile/features/commerce/presentation/deliveries_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  ref.onDispose(refresh.dispose);
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: refresh,
    redirect: (context, state) => authRedirect(
      auth: ref.read(authControllerProvider),
      path: state.matchedLocation,
    ),
    routes: [
      GoRoute(path: '/loading', builder: (_, _) => const _LoadingScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (_, state) => SignupScreen(
          familyInvitationToken: state.uri.queryParameters['family_invite'],
        ),
      ),
      GoRoute(
        path: '/organizations/select',
        builder: (_, _) => const OrganizationSelectionScreen(),
      ),
      GoRoute(
        path: '/farms/select',
        builder: (_, _) => const FarmSelectionScreen(),
      ),
      ShellRoute(
        builder: (_, _, child) => FoundationShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, _) => const FoundationHomeScreen(),
          ),
          GoRoute(path: '/alerts', builder: (_, _) => const AlertsScreen()),
          GoRoute(path: '/farms', builder: (_, _) => const FarmListScreen()),
          GoRoute(path: '/sheds', builder: (_, _) => const ShedListScreen()),
          GoRoute(
            path: '/animals',
            builder: (_, _) => const AnimalListScreen(),
          ),
          GoRoute(
            path: '/animals/new',
            builder: (_, _) => const AnimalFormScreen(),
          ),
          GoRoute(
            path: '/animals/:animalId/edit',
            builder: (_, state) =>
                AnimalFormScreen(animalId: state.pathParameters['animalId']!),
          ),
          GoRoute(
            path: '/animals/:animalId/movements/new',
            builder: (_, state) => AnimalMovementFormScreen(
              animalId: state.pathParameters['animalId']!,
            ),
          ),
          GoRoute(
            path: '/animals/:animalId/weights/new',
            builder: (_, state) => AnimalWeightFormScreen(
              animalId: state.pathParameters['animalId']!,
            ),
          ),
          GoRoute(
            path: '/animals/:animalId/weights/:weightId/correct',
            builder: (_, state) => AnimalWeightFormScreen(
              animalId: state.pathParameters['animalId']!,
              weightId: state.pathParameters['weightId']!,
            ),
          ),
          GoRoute(
            path: '/animals/:animalId/status-changes/new',
            builder: (_, state) => AnimalStatusChangeFormScreen(
              animalId: state.pathParameters['animalId']!,
            ),
          ),
          GoRoute(
            path: '/animals/sales-dashboard',
            builder: (_, _) => const CattleSalesDashboardScreen(),
          ),
          GoRoute(
            path: '/animals/purchases/new',
            builder: (_, _) => const CattlePurchaseFormScreen(),
          ),
          GoRoute(
            path: '/animals/sales/new',
            builder: (_, _) => const CattleSaleFormScreen(),
          ),
          GoRoute(
            path: '/animals/:animalId',
            builder: (_, state) =>
                AnimalDetailScreen(animalId: state.pathParameters['animalId']!),
          ),
          GoRoute(
            path: '/animals/:animalId/record-feed',
            builder: (_, state) => AnimalFeedFormScreen(
              animalId: state.pathParameters['animalId']!,
            ),
          ),
          GoRoute(
            path: '/animals/:animalId/record-milk',
            builder: (_, state) => AnimalMilkFormScreen(
              animalId: state.pathParameters['animalId']!,
            ),
          ),
          GoRoute(
            path: '/animals/:animalId/health-assessment',
            builder: (_, state) => HealthAssessmentScreen(
              animalId: state.pathParameters['animalId']!,
            ),
          ),
          GoRoute(
            path: '/animals/:animalId/treatments/new',
            builder: (_, state) => TreatmentFormScreen(
              animalId: state.pathParameters['animalId']!,
            ),
          ),
          GoRoute(
            path: '/health-guide',
            builder: (_, _) => const HealthKnowledgeScreen(),
          ),
          GoRoute(
            path: '/health-guide/ask',
            builder: (_, _) => const HealthAiAskScreen(),
          ),
          GoRoute(
            path: '/health-guide/review',
            builder: (_, _) => const HealthAiReviewScreen(),
          ),
          GoRoute(
            path: '/health-guide/medicine-evidence',
            builder: (_, _) => const HealthMedicineEvidenceScreen(),
          ),
          GoRoute(
            path: '/animals/:animalId/preventive-care/new',
            builder: (_, state) => PreventiveCareFormScreen(
              animalId: state.pathParameters['animalId']!,
            ),
          ),
          GoRoute(
            path: '/animals/:animalId/breeding',
            builder: (_, state) => BreedingEventScreen(
              animalId: state.pathParameters['animalId']!,
            ),
          ),
          GoRoute(
            path: '/animals/:animalId/calf-care',
            builder: (_, state) =>
                CalfCareFormScreen(animalId: state.pathParameters['animalId']!),
          ),
          GoRoute(
            path: '/animal-breeds',
            builder: (_, _) => const BreedManagementScreen(),
          ),
          GoRoute(
            path: '/animal-groups',
            builder: (_, _) => const AnimalGroupManagementScreen(),
          ),
          GoRoute(
            path: '/sync',
            builder: (_, _) => const SyncDiagnosticsScreen(),
          ),
          GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
          GoRoute(
            path: '/family',
            builder: (_, _) => const FamilyManagementScreen(),
          ),
          GoRoute(
            path: '/inventory',
            builder: (_, _) => const InventoryDashboardScreen(),
          ),
          GoRoute(
            path: '/inventory/indents',
            builder: (_, _) => const StockUsageIndentsScreen(),
          ),
          GoRoute(
            path: '/reports/daily-production',
            builder: (_, _) => const DailyProductionReportScreen(),
          ),
          GoRoute(
            path: '/inventory/:kind',
            builder: (_, state) => InventoryOverviewScreen(
              kind: InventoryKind.fromPath(state.pathParameters['kind']!)!,
            ),
          ),
          GoRoute(
            path: '/inventory/:kind/new',
            builder: (_, state) => InventoryItemFormScreen(
              kind: InventoryKind.fromPath(state.pathParameters['kind']!)!,
            ),
          ),
          GoRoute(
            path: '/milk',
            builder: (_, _) => const MilkProductionScreen(),
          ),
          GoRoute(
            path: '/employees',
            builder: (_, _) => const EmployeesScreen(),
          ),
          GoRoute(path: '/payroll', builder: (_, _) => const PayrollScreen()),
          GoRoute(
            path: '/employee-loans',
            builder: (_, _) => const EmployeeLoansScreen(),
          ),
          GoRoute(path: '/finance', builder: (_, _) => const FinanceScreen()),
          GoRoute(
            path: '/suppliers',
            builder: (_, _) => const CommercialPartiesScreen(kind: 'suppliers'),
          ),
          GoRoute(
            path: '/customers',
            builder: (_, _) => const CommercialPartiesScreen(kind: 'customers'),
          ),
          GoRoute(
            path: '/purchases',
            builder: (_, _) => const PurchaseOrdersScreen(),
          ),
          GoRoute(
            path: '/supplier-invoices',
            builder: (_, _) => const SupplierInvoicesScreen(),
          ),
          GoRoute(
            path: '/milk-sales',
            builder: (_, _) => const MilkSalesScreen(),
          ),
          GoRoute(
            path: '/deliveries',
            builder: (_, _) => const DeliveriesScreen(),
          ),
          GoRoute(
            path: '/feed/plans',
            builder: (_, _) => const FeedRationPlansScreen(),
          ),
          GoRoute(
            path: '/feed/plans/new',
            builder: (_, _) => const FeedRationPlanFormScreen(),
          ),
          GoRoute(
            path: '/feed/issues',
            builder: (_, _) => const DailyFeedIssuesScreen(),
          ),
          GoRoute(
            path: '/feed/analysis',
            builder: (_, _) => const FeedAnalysisScreen(),
          ),
          GoRoute(
            path: '/feed/issues/new',
            builder: (_, _) => const DailyFeedIssueFormScreen(),
          ),
        ],
      ),
    ],
  );
});

String? authRedirect({
  required AsyncValue<AuthSession?> auth,
  required String path,
}) {
  final isPublicAuthPage = path == '/login' || path == '/signup';
  if (auth.isLoading) {
    return path == '/loading' || isPublicAuthPage ? null : '/loading';
  }
  final session = auth.asData?.value;
  if (session == null) return isPublicAuthPage ? null : '/login';
  if (isPublicAuthPage || path == '/loading') {
    if (session.activeOrganizationId == null) return '/organizations/select';
    if (session.activeFarmId == null) return '/farms/select';
    return '/home';
  }
  if (session.activeOrganizationId == null && path != '/organizations/select') {
    return '/organizations/select';
  }
  if (session.activeFarmId == null &&
      path != '/farms/select' &&
      path != '/organizations/select') {
    return '/farms/select';
  }
  return null;
}

final class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    _subscription = ref.listen(
      authControllerProvider,
      (_, _) => notifyListeners(),
    );
  }

  late final ProviderSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

final class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
