import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/shell/app_shell.dart';
import '../features/auth/login_screen.dart';
import '../features/home/home_screen.dart';
import '../features/users/users_landing_screen.dart';
import '../features/users/customer_ledger_screen.dart';
import '../features/users/supplier_ledger_screen.dart';
import '../features/lots/create_lot_screen.dart';
import '../features/lots/lots_list_screen.dart';
import '../features/lots/lot_details_screen.dart';
import '../features/lots/stock_summary_screen.dart';
import '../features/lots/lot_configuration_screen.dart';
import '../features/bills/create_cash_bill_screen.dart';
import '../features/bills/create_credit_bill_screen.dart';
import '../features/bills/lot_billing/lot_billing_workflow_screen.dart';
import '../features/bills/bills_list_screen.dart';
import '../features/bills/bill_details_screen.dart';
import '../features/payments/received_amount_screen.dart';
import '../features/expenses/expenses_screen.dart';
import '../features/reports/reports_landing_screen.dart';
import '../features/reports/screens/daily_summary_screen.dart';
import '../features/reports/screens/gross_profit_screen.dart';
import '../features/reports/screens/stock_report_screen.dart';
import '../features/reports/screens/sales_report_screen.dart';
import '../features/reports/screens/purchase_report_screen.dart';
import '../features/reports/screens/rmc_report_screen.dart';
import '../features/reports/daily_tally/screens/daily_tally_dashboard_screen.dart';
import '../features/reports/daily_tally/screens/create_daily_tally_screen.dart';
import '../features/reports/daily_tally/screens/daily_tally_details_screen.dart';
import '../features/reports/daily_tally/screens/daily_tally_history_screen.dart';
import '../features/reports/daily_tally/screens/daily_cash_reconciliation_screen.dart';
import '../features/catalogue/screens/admin_product_management_screen.dart';
import '../features/settings/screens/appearance_screen.dart';
import '../features/search/global_search_screen.dart';
import '../data/repositories/app_repository.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNav');

final appRouterProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(currentUserProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: user != null ? '/home' : '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Tab 1: Bills
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bills',
                builder: (context, state) => const BillsListScreen(),
              ),
            ],
          ),
          // Tab 2: Expenses
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/expenses',
                builder: (context, state) => const ExpensesScreen(),
              ),
            ],
          ),
          // Tab 3: Users
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/users',
                builder: (context, state) => const UsersLandingScreen(),
              ),
            ],
          ),
          // Tab 4: Reports
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => const ReportsLandingScreen(),
              ),
            ],
          ),
        ],
      ),
      // Deep workflow routes
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/daily-tally',
        builder: (context, state) => const DailyTallyDashboardScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/search',
        builder: (context, state) => const GlobalSearchScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/lots',
        builder: (context, state) => const LotsListScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/lots/create',
        builder: (context, state) {
          final supplierId = state.uri.queryParameters['supplierId'];
          return CreateLotScreen(initialSupplierId: supplierId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/lots/stock-summary',
        builder: (context, state) => const StockSummaryScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/lots/configuration',
        builder: (context, state) => const LotConfigurationScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/lots/:id',
        builder: (context, state) {
          final lotId = state.pathParameters['id'] ?? '';
          return LotDetailsScreen(lotId: lotId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/bills/create-cash',
        builder: (context, state) {
          final lotId = state.uri.queryParameters['lotId'];
          return CreateCashBillScreen(initialLotId: lotId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/bills/lot-billing',
        builder: (context, state) {
          final lotId = state.uri.queryParameters['lotId'];
          final customerId = state.uri.queryParameters['customerId'];
          return LotBillingWorkflowScreen(
            initialLotId: lotId,
            initialCustomerId: customerId,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/bills/create-credit',
        builder: (context, state) {
          final customerId = state.uri.queryParameters['customerId'];
          final lotId = state.uri.queryParameters['lotId'];
          return CreateCreditBillScreen(
            initialCustomerId: customerId,
            initialLotId: lotId,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/bills/:id',
        builder: (context, state) {
          final billId = state.pathParameters['id'] ?? '';
          return BillDetailsScreen(billId: billId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/payments/received-amount',
        builder: (context, state) {
          final customerId = state.uri.queryParameters['customerId'];
          return ReceivedAmountScreen(initialCustomerId: customerId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/reports/daily-summary',
        builder: (context, state) => const DailySummaryScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/reports/gross-profit',
        builder: (context, state) => const GrossProfitScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/reports/stock',
        builder: (context, state) {
          final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
          return StockReportScreen(initialTabIndex: tab);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/reports/sales',
        builder: (context, state) {
          final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
          final buyerId = state.uri.queryParameters['buyerId'];
          final crop = state.uri.queryParameters['crop'];
          return SalesReportScreen(
            initialTabIndex: tab,
            initialBuyerId: buyerId,
            initialCropName: crop != null ? Uri.decodeComponent(crop) : null,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/reports/purchase',
        builder: (context, state) {
          final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
          return PurchaseReportScreen(initialTabIndex: tab);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/reports/rmc',
        builder: (context, state) {
          final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
          return RmcReportScreen(initialTabIndex: tab);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/reports/daily-tally',
        builder: (context, state) => const DailyTallyDashboardScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/daily-tally/create',
        builder: (context, state) => const CreateDailyTallyScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/daily-tally/history',
        builder: (context, state) => const DailyTallyHistoryScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/daily-tally/reconciliation',
        builder: (context, state) => const DailyCashReconciliationScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/daily-tally/:id',
        builder: (context, state) {
          final tallyId = state.pathParameters['id'] ?? '';
          return DailyTallyDetailsScreen(id: tallyId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/reports/daily-tally/create',
        builder: (context, state) => const CreateDailyTallyScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/reports/daily-tally/history',
        builder: (context, state) => const DailyTallyHistoryScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/reports/daily-tally/reconciliation',
        builder: (context, state) => const DailyCashReconciliationScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/reports/daily-tally/:id',
        builder: (context, state) {
          final tallyId = state.pathParameters['id'] ?? '';
          return DailyTallyDetailsScreen(id: tallyId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/users/customer-ledger/:id',
        builder: (context, state) {
          final customerId = state.pathParameters['id'] ?? '';
          return CustomerLedgerScreen(customerId: customerId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/users/supplier-ledger/:id',
        builder: (context, state) {
          final supplierId = state.pathParameters['id'] ?? '';
          return SupplierLedgerScreen(supplierId: supplierId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/admin/products',
        builder: (context, state) => const AdminProductManagementScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/appearance',
        builder: (context, state) => const AppearanceScreen(),
      ),
    ],
  );
});
