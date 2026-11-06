import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buyer_seller_goods_management/app/app.dart';
import 'package:buyer_seller_goods_management/data/app_state.dart';
import 'package:buyer_seller_goods_management/data/models/bill.dart';
import 'package:buyer_seller_goods_management/data/models/bill_item.dart';
import 'package:buyer_seller_goods_management/features/billing/bill_form_screen.dart';
import 'package:buyer_seller_goods_management/features/billing/bill_detail_screen.dart';
import 'package:buyer_seller_goods_management/features/billing/widgets/bag_weights_entry_dialog.dart';
import 'package:buyer_seller_goods_management/features/more/more_menu_screen.dart';
import 'package:buyer_seller_goods_management/features/reports/smart_chart_screen.dart';
import 'package:buyer_seller_goods_management/features/seller_loads/seller_loads_screen.dart';
import 'package:buyer_seller_goods_management/features/seller_loads/seller_history_screen.dart';

void main() {
  group('Mandi Tablet UI Integration & Flow Tests', () {
    testWidgets('Bottom Navigation Bar displays Mandi 5 tabs matching photos', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 850);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const ProviderScope(child: GoodsManagementApp()));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Mandi 5 tabs on bottom navigation bar
      expect(find.text('Smartboard'), findsOneWidget);
      expect(find.text('Smart Chart'), findsWidgets);
      expect(find.text('Sell Bill Book'), findsOneWidget);
      expect(find.text('Buy Bill Book'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);

      // FAB '+' is present
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Tapping More tab opens the 6-tile grid matching Image 2', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 850);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const ProviderScope(child: GoodsManagementApp()));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap 'More' nav item
      await tester.tap(find.text('More'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // More screen should now be visible
      expect(find.byType(MoreMenuScreen), findsOneWidget);

      // Verify the 6 tiles matching Image 2
      expect(find.text('Seller Ledger'), findsOneWidget);
      expect(find.text('Buyer Ledger'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);
      expect(find.text('Advances'), findsOneWidget);
      expect(find.text('Transporto'), findsOneWidget);
      expect(find.text('Partners'), findsOneWidget);
    });

    testWidgets('Tapping Smart Chart tab displays Arrival Auction with farmer lot cards', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 850);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const ProviderScope(child: GoodsManagementApp()));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap 'Smart Chart' nav item
      await tester.tap(find.text('Smart Chart').first, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Smart Chart screen should be loaded
      expect(find.byType(SmartChartScreen), findsOneWidget);

      // Tabs matching Photo 3
      expect(find.text('Arrival Auction'), findsOneWidget);
      expect(find.text('Sales Summary'), findsOneWidget);

      // Search bar hint matching Photo 3
      expect(find.text('Search by Seller Name'), findsOneWidget);

      // Farmers and Lots from user photos
      expect(find.text('Aditya - Aditya'), findsOneWidget);

      // Verify produce bags and Auction / Trade action button
      expect(find.text('Auction / Trade'), findsWidgets);
    });

    testWidgets('Tapping Sell Bill Book (Option 3) shows inward loads and opens seller history', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 850);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const ProviderScope(child: GoodsManagementApp()));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap 'Sell Bill Book' nav item (Option 3)
      await tester.tap(find.text('Sell Bill Book'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Seller loads screen should be visible
      expect(find.byType(SellerLoadsScreen), findsOneWidget);
      expect(find.text('Sell Bill Book (Farmer & Inward Loads)'), findsOneWidget);

      // Create Seller Load FAB
      expect(find.text('Create Seller Load'), findsOneWidget);

      // Farmer lots displayed
      expect(find.text('Aditya - Aditya'), findsOneWidget);

      // Tap History on first card to open SellerHistoryScreen
      await tester.ensureVisible(find.text('History').first);
      await tester.tap(find.text('History').first);
      await tester.pumpAndSettle();

      expect(find.byType(SellerHistoryScreen), findsOneWidget);
      expect(find.text('Aditya - Aditya'), findsWidgets);
      expect(find.text('Inward Loads (1)'), findsOneWidget);
      expect(find.text('Farmer Advances'), findsOneWidget);
      expect(find.text('Farmer Ledger'), findsOneWidget);
    });

    testWidgets('Add Bill renders 3-step workflow with Buyer list matching Photo 2', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 850);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: BillFormScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top title and Stepper
      expect(find.text('Add Bill'), findsOneWidget);
      expect(find.text('Bill To*'), findsWidgets);
      expect(find.text('Lot & Weighing'), findsOneWidget);
      expect(find.text('Settlement'), findsOneWidget);

      // Search input matching Photo 2
      expect(find.text('Search by Name / Mobile / Short Code'), findsOneWidget);

      // Buyers matching Photo 2
      expect(find.text('AAA_Sale - Bill'), findsOneWidget);
      expect(find.text('ABDUL - NA'), findsOneWidget);
      expect(find.text('ANP_NELLAI - Sabari'), findsOneWidget);

      // Tap buyer to move to Step 2
      await tester.tap(find.text('AAA_Sale - Bill'));
      await tester.pumpAndSettle();

      // Step 2 should now display Lot and Weighing fields
      expect(find.text('Billing To Selected Buyer:'), findsOneWidget);
      expect(find.text('Bags to Bill (BG) *'), findsOneWidget);
      expect(find.text('Net Weight (kg) *'), findsOneWidget);
      expect(find.text('Selling Rate (₹/kg) *'), findsOneWidget);
      expect(find.textContaining('Bag-by-Bag'), findsOneWidget);
    });

    testWidgets('BagWeightsEntryDialog allows entering individual bag weights and tare deduction', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(500, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BagWeightsEntryDialog(
              initialBags: 10,
              initialTarePerBag: 1.0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Dialog title and initial bag count
      expect(find.text('Bag-by-Bag Weighing Entry'), findsOneWidget);
      expect(find.text('10 BG'), findsOneWidget);

      // 10 bag inputs should exist
      expect(find.text('Bag #1'), findsOneWidget);
      expect(find.text('Bag #10'), findsOneWidget);

      // Quick fill presets
      expect(find.text('50 kg All'), findsOneWidget);
      expect(find.text('Tare / Bag:'), findsOneWidget);

      // Tap 50 kg All
      await tester.tap(find.text('50 kg All'));
      await tester.pumpAndSettle();

      // Check calculations: 10 bags * 50kg = 500kg gross - 10kg tare = 490kg net
      expect(find.text('500.0 kg'), findsOneWidget);
      expect(find.text('- 10.0 kg'), findsOneWidget);
      expect(find.text('490.0 kg'), findsOneWidget);
    });

    testWidgets('Invoice Detail Page displays bottom action bar matching user photo', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(500, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final testBill = Bill(
        id: 'bill-test-invoice',
        billNumber: 'BILL-2026-999',
        customerId: 'cust-aaa',
        billDate: DateTime.now(),
        items: const [
          BillItem(
            id: 'bi-1',
            description: 'Onion (A(3))',
            weight: 1000,
            quantity: 40,
            rate: 28,
            lineTotal: 28000,
          ),
        ],
        subtotal: 28000,
        labourCharge: 400,
        createdAt: DateTime.now(),
      );

      final container = ProviderContainer();
      container.read(appStateProvider.notifier).createBill(testBill);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: BillDetailScreen(billId: 'bill-test-invoice'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Invoice header and bill number
      expect(find.text('BILL-2026-999'), findsWidgets);
      expect(find.text('BSG'), findsOneWidget);

      // Bottom action bar options matching user photo
      expect(find.text('CANCEL'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Pay'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Print'), findsWidgets);
      expect(find.text('Share'), findsWidgets);
      expect(find.text('WhatsApp'), findsOneWidget);

      // Tap 'History' to open audit modal
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.text('Audit History: BILL-2026-999'), findsOneWidget);
    });
  });
}
