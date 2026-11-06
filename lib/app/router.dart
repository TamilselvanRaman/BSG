import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_colors.dart';
import '../features/splash/splash_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/reports/smart_chart_screen.dart';
import '../features/billing/bills_list_screen.dart';
import '../features/more/more_menu_screen.dart';
import '../features/customers/customers_screen.dart';
import '../features/customers/customer_detail_screen.dart';
import '../features/customers/add_customer_screen.dart';
import '../features/goods_entries/goods_entry_form_screen.dart';
import '../features/goods_entries/goods_entry_detail_screen.dart';
import '../features/billing/bill_form_screen.dart';
import '../features/billing/bill_detail_screen.dart';
import '../features/payments/record_payment_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/reports/daily_summary_screen.dart';
import '../features/seller_loads/seller_loads_screen.dart';
import '../features/seller_loads/seller_history_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/more/advances_screen.dart';
import '../features/more/transporto_screen.dart';
import '../features/more/partners_screen.dart';
import '../core/widgets/mandi_bottom_navbar.dart';
import '../core/widgets/mandi_quick_action_sheet.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Splash
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    // Shell Route for Bottom Navigation Bar matching Mandi UI (Photo 1 & 2)
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        // 1. Smartboard (Dashboard)
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),

        // 2. Smart Chart (Mandi Real-time Analytics & Charts)
        GoRoute(
          path: '/smart-chart',
          builder: (context, state) => const SmartChartScreen(),
        ),

        // 3. Sell Bill Book (Seller Loads & Farmer Lots)
        GoRoute(
          path: '/seller-loads',
          builder: (context, state) => const SellerLoadsScreen(),
        ),
        GoRoute(
          path: '/goods-entries',
          builder: (context, state) => const SellerLoadsScreen(),
        ),

        // 4. Buy Bill Book (Wholesale Buyer Bills & Invoices)
        GoRoute(
          path: '/bills',
          builder: (context, state) => const BillsListScreen(),
        ),

        // 5. More (Grid Menu matching Photo 2: Seller Ledger, Buyer Ledger, Reports, Advances, Transport, Partners)
        GoRoute(
          path: '/more',
          builder: (context, state) => const MoreMenuScreen(),
        ),
      ],
    ),

    // Sub-screens (pushed on root navigator)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/customers',
      builder: (context, state) => const CustomersScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/customers/new',
      builder: (context, state) => const AddCustomerScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/customers/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return CustomerDetailScreen(customerId: id);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/seller-loads',
      builder: (context, state) => const SellerLoadsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/sellers/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return SellerHistoryScreen(sellerId: id);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/goods-entries/new',
      builder: (context, state) => const GoodsEntryFormScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/goods-entries/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return GoodsEntryDetailScreen(entryId: id);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/bills/new',
      builder: (context, state) {
        final entryId = state.uri.queryParameters['entryId'];
        final customerId = state.uri.queryParameters['customerId'];
        final lotNumber = state.uri.queryParameters['lotNumber'];
        final sellerId = state.uri.queryParameters['sellerId'];
        return BillFormScreen(
          initialEntryId: entryId,
          initialCustomerId: customerId,
          initialLotNumber: lotNumber,
          initialSellerId: sellerId,
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/bills/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return BillDetailScreen(billId: id);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/payments/new',
      builder: (context, state) {
        final billId = state.uri.queryParameters['billId'];
        final customerId = state.uri.queryParameters['customerId'];
        return RecordPaymentScreen(initialBillId: billId, initialCustomerId: customerId);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/reports',
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/reports/daily-summary',
      builder: (context, state) => const DailySummaryScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/advances',
      builder: (context, state) => const AdvancesScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/transporto',
      builder: (context, state) => const TransportoScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/partners',
      builder: (context, state) => const PartnersScreen(),
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/smart-chart')) return 1;
    if (location.startsWith('/goods-entries') || location.startsWith('/seller-loads') || location.startsWith('/sellers')) return 2;
    if (location.startsWith('/bills')) return 3;
    if (location.startsWith('/more')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/smart-chart');
        break;
      case 2:
        context.go('/seller-loads');
        break;
      case 3:
        context.go('/bills');
        break;
      case 4:
        context.go('/more');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWideScreen = width >= 768;

    if (isWideScreen) {
      final isExtended = width >= 1100;

      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (idx) => _onItemTapped(idx, context),
              backgroundColor: const Color(0xFF1B5E20),
              indicatorColor: const Color(0xFFFFEB3B),
              unselectedIconTheme: const IconThemeData(color: Color(0xFFC8E6C9)),
              selectedIconTheme: const IconThemeData(color: Color(0xFF1B5E20)),
              unselectedLabelTextStyle: const TextStyle(color: Color(0xFFC8E6C9), fontSize: 12),
              selectedLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
              extended: isExtended,
              minWidth: 74,
              minExtendedWidth: 230,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.storefront_rounded, color: Color(0xFF1B5E20), size: 22),
                    ),
                    if (isExtended) ...[
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BSG',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Agro Mandi ERP',
                            style: TextStyle(fontSize: 11, color: Color(0xFFC8E6C9), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.grid_view_rounded),
                  selectedIcon: Icon(Icons.grid_view_rounded),
                  label: Text('Smartboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.description_outlined),
                  selectedIcon: Icon(Icons.description),
                  label: Text('Smart Chart'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.menu_book_rounded),
                  selectedIcon: Icon(Icons.menu_book_rounded),
                  label: Text('Sell Bill Book'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.scale_rounded),
                  selectedIcon: Icon(Icons.scale_rounded),
                  label: Text('Buy Bill Book'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.more_horiz_rounded),
                  selectedIcon: Icon(Icons.more_horiz_rounded),
                  label: Text('More'),
                ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      // Floating Action Button matching Image 1: Green circle with '+'
      floatingActionButton: FloatingActionButton(
        heroTag: 'shell_fab',
        onPressed: () => MandiQuickActionSheet.show(context),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(side: BorderSide(color: Color(0xFF81C784), width: 1.5)),
        tooltip: 'Quick Entry',
        child: const Icon(Icons.add, size: 28),
      ),
      bottomNavigationBar: MandiBottomNavBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (idx) => _onItemTapped(idx, context),
      ),
    );
  }
}
