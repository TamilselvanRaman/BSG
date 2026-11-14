import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bsg_mobile/data/repositories/app_repository.dart';
import 'package:bsg_mobile/features/reports/reports_landing_screen.dart';

void main() {
  group('Reports Module Business Logic & Calculation Verification', () {
    late AppRepository repo;

    setUp(() {
      repo = AppRepository();
    });

    test('Daily Summary calculation generates received, paid, expenses, and totals', () {
      final summary = repo.getDailySummaryReport(DateTime.now());

      expect(summary.salesAmount, greaterThanOrEqualTo(0));
      expect(summary.totalReceived, greaterThanOrEqualTo(0));
      expect(summary.totalPaid, greaterThanOrEqualTo(0));
      expect(summary.receivedItems, isNotEmpty);
      expect(summary.paidItems, isNotEmpty);
    });

    test('Gross Profit calculation verifies Sales - COGS = Gross Profit and Profit %', () {
      final gp = repo.getGrossProfitReport();

      expect(gp.totalSalesAmount, greaterThanOrEqualTo(0));
      expect(gp.totalPurchaseCost, greaterThanOrEqualTo(0));
      expect(gp.grossProfit, closeTo(gp.totalSalesAmount - gp.totalPurchaseCost, 0.001));

      if (gp.totalPurchaseCost > 0) {
        expect(gp.profitPercentage, closeTo((gp.grossProfit / gp.totalPurchaseCost) * 100, 0.01));
      }
      expect(gp.productProfits, isNotEmpty);
    });

    test('Stock Report calculation strictly satisfies Opening + Inward - Sold = Closing Stock', () {
      final stockData = repo.getStockReportData();

      for (final item in stockData.products) {
        final expectedClosing = item.openingStock + item.purchasedQuantity - item.soldQuantity;
        expect(item.closingStock, closeTo(expectedClosing, 0.001),
            reason: 'Closing stock must equal Opening + Purchased - Sold for ${item.productName}');
        expect(item.closingStock, greaterThanOrEqualTo(0));
      }
    });

    test('Sales Report aggregates bills, quantities, collections, and dues accurately', () {
      final salesData = repo.getSalesReportData();

      expect(salesData.totalBills, greaterThanOrEqualTo(0));
      expect(salesData.totalSales, greaterThanOrEqualTo(0));
      expect(salesData.totalReceived, greaterThanOrEqualTo(0));
      expect(salesData.totalOutstanding, closeTo(salesData.totalSales - salesData.totalReceived, 0.001));
      expect(salesData.byBuyer, isNotEmpty);
      expect(salesData.byCrop, isNotEmpty);
    });

    test('Purchase Reports aggregates inward arrivals, payments, and balances correctly', () {
      final purchaseData = repo.getPurchaseReportData();

      expect(purchaseData.totalLots, greaterThanOrEqualTo(0));
      expect(purchaseData.totalPurchaseAmount, greaterThanOrEqualTo(0));
      expect(purchaseData.amountPaid, greaterThanOrEqualTo(0));
      expect(purchaseData.outstandingPayable, closeTo(purchaseData.totalPurchaseAmount - purchaseData.amountPaid, 0.001));
      expect(purchaseData.bySeller, isNotEmpty);
      expect(purchaseData.byProduct, isNotEmpty);
    });

    test('RMC Reports evaluates statutory 1.0% Mandi Market Committee fee on produce turnover', () {
      final rmcData = repo.getRmcReportData();

      expect(rmcData.totalTaxableTurnover, greaterThanOrEqualTo(0));
      expect(rmcData.totalRmcFee, closeTo(rmcData.totalTaxableTurnover * 0.01, 0.01));
      expect(rmcData.transactions, isNotEmpty);
      for (final tx in rmcData.transactions) {
        expect(tx.rmcAmount, closeTo(tx.taxableAmount * 0.01, 0.01));
      }
    });
  });

  group('Reports Landing Page UI Widget Verification', () {
    testWidgets('Renders all 6 report categories with accordion design', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ReportsLandingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify all 6 category titles are rendered
      expect(find.text('Daily Summary'), findsWidgets);
      expect(find.text('Gross Profit'), findsWidgets);
      expect(find.text('Stock Report'), findsOneWidget);
      expect(find.text('Sales Report'), findsOneWidget);
      expect(find.text('Purchase Reports'), findsOneWidget);
      expect(find.text('RMC Reports'), findsOneWidget);

      // Verify Daily Summary is expanded by default with its submenu
      expect(find.text('Executive overview & transaction vouchers'), findsOneWidget);

      // Tap on 'Gross Profit' card to expand it and collapse Daily Summary
      await tester.tap(find.text('Gross Profit').first);
      await tester.pumpAndSettle();

      // Submenu for Gross Profit should now be visible
      expect(find.text('Product-wise & transaction profit margins'), findsOneWidget);
    });
  });
}
