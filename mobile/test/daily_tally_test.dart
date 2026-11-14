import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bsg_mobile/core/theme/app_theme.dart';
import 'package:bsg_mobile/core/theme/theme_extension.dart';
import 'package:bsg_mobile/data/repositories/app_repository.dart';
import 'package:bsg_mobile/features/reports/daily_tally/models/daily_tally_model.dart';
import 'package:bsg_mobile/features/reports/reports_landing_screen.dart';

void main() {
  group('Daily Tally Financial Calculations', () {
    test('Calculates available cash, expected closing cash, and balanced status correctly', () {
      final tally = DailyTally(
        id: 'test_1',
        tallyNumber: 'DT-TEST-001',
        date: DateTime.now(),
        openingCash: 15000.0,
        cashSales: 7200.0,
        outstandingReceived: 5000.0,
        otherCashReceived: 0.0,
        otherCashInflow: 0.0,
        gpay1Received: 3500.0,
        gpay2Received: 1200.0,
        labourExpense: 850.0,
        transportExpense: 0.0,
        rentExpense: 0.0,
        utilitiesExpense: 0.0,
        teaRefreshmentsExpense: 220.0,
        otherExpense: 0.0,
        partyPayments: const [
          TallyPartyPayment(
            id: 'p1',
            partyName: 'Kaveri Farms',
            amount: 4500.0,
            mode: TallyPaymentMode.cash,
          ),
          TallyPartyPayment(
            id: 'p2',
            partyName: 'Bank Transferred Farmer',
            amount: 2000.0,
            mode: TallyPaymentMode.bankTransfer, // Non-cash, shouldn't deduct physical cash
          ),
        ],
        bankDeposit: 8000.0,
        otherCashOutflow: 0.0,
        actualCashCounted: 13630.0,
        createdAt: DateTime.now(),
      );

      // Available cash = 15000 + 7200 + 5000 = 27,200
      expect(tally.totalAvailableCash, 27200.0);

      // Total Cash Expenses = 850 + 220 = 1,070
      expect(tally.totalCashExpenses, 1070.0);

      // Total Cash Party Payments = 4,500 (2,000 is bank transfer)
      expect(tally.totalCashPartyPayments, 4500.0);
      expect(tally.totalDigitalPartyPayments, 2000.0);

      // Expected Closing Cash = 27,200 - 1,070 - 4,500 - 8,000 = 13,630
      expect(tally.expectedClosingCash, 13630.0);

      // Actual cash counted = 13,630 -> Difference = 0.0 -> Balanced
      expect(tally.cashDifference, 0.0);
      expect(tally.isBalanced, true);
      expect(tally.isSurplus, false);
      expect(tally.isShortage, false);

      // Digital collections distinct from physical cash
      expect(tally.totalDigitalReceived, 4700.0);
    });

    test('Detects cash surplus and cash shortage correctly', () {
      final surplusTally = DailyTally(
        id: 'test_2',
        tallyNumber: 'DT-TEST-002',
        date: DateTime.now(),
        openingCash: 10000.0,
        cashSales: 5000.0,
        labourExpense: 1000.0,
        actualCashCounted: 14500.0, // Expected: 10000+5000-1000 = 14000
        createdAt: DateTime.now(),
      );

      expect(surplusTally.expectedClosingCash, 14000.0);
      expect(surplusTally.cashDifference, 500.0);
      expect(surplusTally.isSurplus, true);
      expect(surplusTally.isBalanced, false);

      final shortageTally = DailyTally(
        id: 'test_3',
        tallyNumber: 'DT-TEST-003',
        date: DateTime.now(),
        openingCash: 10000.0,
        cashSales: 5000.0,
        labourExpense: 1000.0,
        actualCashCounted: 13500.0, // Expected: 14000 -> Difference: -500
        createdAt: DateTime.now(),
      );

      expect(shortageTally.cashDifference, -500.0);
      expect(shortageTally.isShortage, true);
      expect(shortageTally.isBalanced, false);
    });
  });

  group('AppRepository Daily Tally Operations', () {
    test('Creates and queries daily tallies successfully', () {
      final repo = AppRepository();
      final initialCount = repo.getDailyTallies().length;

      final created = repo.createDailyTally(
        date: DateTime(2026, 11, 20),
        openingCash: 20000.0,
        cashSales: 10000.0,
        actualCashCounted: 30000.0,
        notes: 'Automated test tally',
      );

      expect(created.tallyNumber.startsWith('DT-2026-'), true);
      expect(repo.getDailyTallies().length, initialCount + 1);

      final retrieved = repo.getDailyTally(created.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.openingCash, 20000.0);

      repo.deleteDailyTally(created.id);
      expect(repo.getDailyTally(created.id), isNull);
    });
  });

  group('Reports Landing Page UI Integration', () {
    testWidgets('Displays all 7 report categories including new Daily Tally card', (tester) async {
      tester.view.physicalSize = const Size(1080, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.fromTheme(AppThemeColors.classic),
            home: const ReportsLandingScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all 7 report categories are present
      expect(find.text('Daily Summary'), findsWidgets);
      expect(find.text('Gross Profit'), findsOneWidget);
      expect(find.text('Stock Report'), findsOneWidget);
      expect(find.text('Sales Report'), findsOneWidget);
      expect(find.text('Purchase Reports'), findsOneWidget);
      expect(find.text('RMC Reports'), findsOneWidget);

      // Verify the new 7th Daily Tally card is rendered
      expect(find.text('Daily Tally'), findsOneWidget);
      expect(
        find.text('Daily cash register, opening balance, receipts, expenses & cash reconciliation.'),
        findsOneWidget,
      );
    });
  });
}
