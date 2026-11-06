import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buyer_seller_goods_management/app/theme/app_theme.dart';
import 'package:buyer_seller_goods_management/data/models/commodity.dart';
import 'package:buyer_seller_goods_management/features/goods_entries/widgets/commodity_selector.dart';
import 'package:buyer_seller_goods_management/features/goods_entries/goods_entry_form_screen.dart';

void main() {
  group('CommoditySelector Widget & Integration Tests', () {
    testWidgets('Displays visual goods cards and Add New option', (WidgetTester tester) async {
      final ctrl = TextEditingController(text: 'Country Tomatoes');
      bool nextCalled = false;
      Commodity? selectedCommodity;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: CommoditySelector(
                  controller: ctrl,
                  onNext: () => nextCalled = true,
                  onCommodityChanged: (c) => selectedCommodity = c,
                ),
              ),
            ),
          ),
        ),
      );

      // Verify Header
      expect(find.text('Commodity / Goods Name *'), findsOneWidget);
      expect(find.text('+ Add Goods'), findsOneWidget);

      // Verify Add New Card exists
      expect(find.text('Add New'), findsOneWidget);

      // Verify Default Commodity Cards are rendered in the carousel
      expect(find.text('Country Tomatoes'), findsWidgets);
      expect(find.text('Small Onions'), findsOneWidget);
      expect(find.text('Hill Potatoes'), findsOneWidget);

      // Tap on Small Onions card
      await tester.tap(find.text('Small Onions'));
      await tester.pumpAndSettle();

      // Controller should update to Small Onions
      expect(ctrl.text, equals('Small Onions'));
      expect(selectedCommodity?.name, equals('Small Onions'));
      expect(nextCalled, isTrue);
    });

    testWidgets('Adding new goods via Add New dialog adds to catalog and selects it', (WidgetTester tester) async {
      final ctrl = TextEditingController();
      bool nextCalled = false;
      Commodity? selectedCommodity;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CommoditySelector(
                    controller: ctrl,
                    onNext: () => nextCalled = true,
                    onCommodityChanged: (c) => selectedCommodity = c,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Tap on "+ Add Goods" action
      await tester.tap(find.text('+ Add Goods'));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.text('Add New Commodity / Goods'), findsOneWidget);

      // Enter custom goods name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g. Ooty Fresh Carrots, White Garlic'),
        'Ooty Cauliflower',
      );
      await tester.pumpAndSettle();

      // Select preset icon Cauliflower
      await tester.tap(find.text('Cauliflower'));
      await tester.pumpAndSettle();

      // Scroll to and tap Save & Choose Goods
      await tester.ensureVisible(find.text('Save & Choose Goods'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save & Choose Goods'));
      await tester.pumpAndSettle();

      // Dialog should close, controller should have the new goods name, and nextCalled should be true
      expect(ctrl.text, equals('Ooty Cauliflower'));
      expect(selectedCommodity?.name, equals('Ooty Cauliflower'));
      expect(nextCalled, isTrue);
    });

    testWidgets('GoodsEntryFormScreen renders CommoditySelector and auto-focuses next on selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const GoodsEntryFormScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find CommoditySelector inside GoodsEntryFormScreen
      expect(find.text('Commodity / Goods Name *'), findsOneWidget);
      expect(find.text('Vehicle Number (Optional)'), findsOneWidget);

      // Select Hill Potatoes
      await tester.ensureVisible(find.text('Hill Potatoes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hill Potatoes'));
      await tester.pumpAndSettle();

      // First product line should be auto-updated with Hill Potatoes A-Grade
      await tester.ensureVisible(find.widgetWithText(TextFormField, 'Hill Potatoes A-Grade'));
      expect(find.widgetWithText(TextFormField, 'Hill Potatoes A-Grade'), findsOneWidget);
    });

    testWidgets('GoodsEntryFormScreen renders Corporate LiveSummaryBanner, Accordion, and QuickSaveBottomBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const GoodsEntryFormScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Live summary banner
      expect(find.text('LIVE FINANCIAL SUMMARY'), findsOneWidget);
      expect(find.text('REAL-TIME AUDIT'), findsOneWidget);

      // Accordion sections
      expect(find.text('Party & Commodity Selection'), findsOneWidget);
      expect(find.text('Lot Details & Logistics'), findsOneWidget);
      expect(find.text('Product Lines, Weights & Rates'), findsOneWidget);
      expect(find.text('Initial Advance Settlement'), findsOneWidget);

      // Quick save bar
      expect(find.text('Confirm Entry'), findsOneWidget);
      expect(find.text('Draft'), findsOneWidget);
    });
  });
}
