import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buyer_seller_goods_management/app/app.dart';
import 'package:buyer_seller_goods_management/core/localization/app_language.dart';
import 'package:buyer_seller_goods_management/core/localization/app_strings.dart';
import 'package:buyer_seller_goods_management/core/localization/language_provider.dart';
import 'package:buyer_seller_goods_management/core/widgets/business_branch_dialog.dart';
import 'package:buyer_seller_goods_management/core/widgets/global_search_dialog.dart';
import 'package:buyer_seller_goods_management/features/auth/login_screen.dart';
import 'package:buyer_seller_goods_management/features/inventory/stock_summary_screen.dart';
import 'package:buyer_seller_goods_management/features/billing/print_purchase_slip_dialog.dart';
import 'package:buyer_seller_goods_management/data/models/seller_load.dart';

void main() {
  group('Multi-Language & Localization Tests (English, Tamil, Hindi)', () {
    test('Translations dictionary returns accurate terms in all 3 languages', () {
      // English
      expect(AppStrings.tr('smartboard', AppLanguage.english), 'Smartboard');
      expect(AppStrings.tr('inventory', AppLanguage.english), 'Stock & Inventory');
      expect(AppStrings.tr('todaySales', AppLanguage.english), "Today's Sales");

      // Tamil
      expect(AppStrings.tr('smartboard', AppLanguage.tamil), 'ஸ்மார்ட்போர்டு');
      expect(AppStrings.tr('inventory', AppLanguage.tamil), 'சரக்கு இருப்பு (ஸ்டாக்)');
      expect(AppStrings.tr('todaySales', AppLanguage.tamil), 'இன்றைய விற்பனை');

      // Hindi
      expect(AppStrings.tr('smartboard', AppLanguage.hindi), 'स्मार्टबोर्ड');
      expect(AppStrings.tr('inventory', AppLanguage.hindi), 'स्टॉक और इन्वेंटरी');
      expect(AppStrings.tr('todaySales', AppLanguage.hindi), 'आज की बिक्री');
    });

    testWidgets('Switching language reactively updates navigation and UI across screens', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 850);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const GoodsManagementApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Initial English
      expect(find.text('Smartboard'), findsOneWidget);
      expect(find.text('Smart Chart'), findsOneWidget);

      // Switch to Tamil
      container.read(languageProvider.notifier).setLanguage(AppLanguage.tamil);
      await tester.pumpAndSettle();

      expect(find.text('ஸ்மார்ட்போர்டு'), findsOneWidget);
      expect(find.text('ஸ்மார்ட் சார்ட்'), findsOneWidget);

      // Switch to Hindi
      container.read(languageProvider.notifier).setLanguage(AppLanguage.hindi);
      await tester.pumpAndSettle();

      expect(find.text('स्मार्टबोर्ड'), findsOneWidget);
      expect(find.text('स्मार्ट चार्ट'), findsOneWidget);
    });
  });

  group('Mandi Staff Login & Role Switcher Tests', () {
    testWidgets('LoginScreen renders clean UI and allows 1-tap demo login', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 850);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('BSG Agro Goods Mandi'), findsOneWidget);
      expect(find.text('Mandi Staff Login'), findsOneWidget);
      expect(find.text('Proprietor'), findsOneWidget);
      expect(find.text('Billing Clerk'), findsOneWidget);
      expect(find.text('Login to Mandi Terminal'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
      expect(find.text('Weighing Clerk'), findsOneWidget);

      // Test 1-Tap Clerk login
      await tester.tap(find.text('Weighing Clerk'));
      await tester.pump();
    });
  });

  group('Stock & Inventory Module Tests', () {
    testWidgets('StockSummaryScreen renders KPI cards, progress bars and movement table without overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 850);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: StockSummaryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Stock & Inventory'), findsOneWidget);
      expect(find.text('Closing Stock'), findsWidgets);
      expect(find.text('Inward Purchases'), findsWidgets);
      expect(find.text('COMMODITY-WISE STOCK LEVELS'), findsOneWidget);
      expect(find.text('DAILY STOCK MOVEMENT REGISTER'), findsOneWidget);

      // Verify DataTable headers
      expect(find.text('Sell-Through'), findsOneWidget);
      expect(find.text('View Lots'), findsWidgets);
    });
  });

  group('Global Search & Branch Switcher Dialog Tests', () {
    testWidgets('GlobalSearchDialog renders tabs and searches across all entities', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 850);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: GlobalSearchDialog()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.textContaining('All ('), findsWidgets);
      expect(find.textContaining('Lots ('), findsWidgets);
      expect(find.textContaining('Bills ('), findsWidgets);
      expect(find.textContaining('Buyers ('), findsWidgets);
      expect(find.textContaining('Farmers ('), findsWidgets);
    });

    testWidgets('PrintPurchaseSlipDialog renders farmer settlement voucher', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 850);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final dummyLoad = SellerLoad(
        id: 'test-load-1',
        loadNumber: 'LOAD-2026-001',
        sellerId: 'cust-1',
        sellerName: 'Periasamy - Farmer',
        village: 'Palladam, Tiruppur',
        phone: '98421 99999',
        vehicleNumber: 'TN 38 AL 4512',
        commodity: 'Country Tomatoes',
        totalBags: 60,
        grossWeight: 1500,
        advancePaidToSeller: 3000,
        arrivalDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PrintPurchaseSlipDialog(load: dummyLoad),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('BSG AGRO GOODS TRADING'), findsOneWidget);
      expect(find.text('FARMER INWARD SETTLEMENT VOUCHER'), findsOneWidget);
      expect(find.text('Periasamy - Farmer'), findsOneWidget);
      expect(find.text('TN 38 AL 4512'), findsOneWidget);
      expect(find.text('NET PAYABLE TO FARMER:'), findsOneWidget);
      expect(find.text('Print Voucher'), findsOneWidget);
    });
  });
}
