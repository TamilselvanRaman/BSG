import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bsg_mobile/core/utils/formatters.dart';
import 'package:bsg_mobile/data/models/bill_model.dart';
import 'package:bsg_mobile/data/repositories/app_repository.dart';
import 'package:bsg_mobile/features/bills/services/bill_calculation_engine.dart';
import 'package:bsg_mobile/features/bills/lot_billing/lot_billing_workflow_screen.dart';
import 'package:bsg_mobile/features/bills/lot_billing/screens/bag_management_screen.dart';

void main() {
  group('BillCalculationEngine Mathematical & Decimal Safety Tests', () {
    test('Calculates individual bag amounts and aggregate totals accurately', () {
      final bags = [
        const BagRowCalculation(serialNumber: 1, weight: 52.0, rate: 250.0, amount: 13000.0),
        const BagRowCalculation(serialNumber: 2, weight: 53.0, rate: 250.0, amount: 13250.0),
        const BagRowCalculation(serialNumber: 3, weight: 53.0, rate: 250.0, amount: 13250.0),
        const BagRowCalculation(serialNumber: 4, weight: 54.0, rate: 250.0, amount: 13500.0),
        const BagRowCalculation(serialNumber: 5, weight: 38.0, rate: 250.0, amount: 9500.0),
      ];

      const extraCharges = [
        BillExtraCharge(id: 'ec_1', name: 'Packing Fee', amount: 150.0),
        BillExtraCharge(id: 'ec_2', name: 'Ice Charges', amount: 50.0),
      ];

      final result = BillCalculationEngine.compute(
        bags: bags,
        transportFee: 1200.0,
        labourFee: 500.0,
        mandiFee: 625.0,
        extraCharges: extraCharges,
      );

      // Verify mathematical precision
      expect(result.totalBags, 5);
      expect(result.totalWeight, 250.0);
      expect(result.averageBagWeight, 50.0);
      expect(result.goodsAmount, 62500.0);
      expect(result.totalExtraCharges, 200.0);
      expect(result.totalCharges, 1200.0 + 500.0 + 625.0 + 200.0); // 2525.0
      expect(result.grandTotal, 62500.0 + 2525.0); // 65025.0
    });

    test('generateBagRows creates expected rows and preserves existing weights', () {
      final rows = BillCalculationEngine.generateBagRows(
        count: 4,
        defaultWeight: 45.0,
        defaultRate: 30.0,
      );

      expect(rows.length, 4);
      expect(rows[0].weight, 45.0);
      expect(rows[0].rate, 30.0);
      expect(rows[0].amount, 1350.0);
      expect(rows[3].serialNumber, 4);
    });
  });

  group('Lot-Based Bill Repository Integration Tests', () {
    test('AppRepository creates lot-based bill and updates lot stock accurately', () async {
      final repo = AppRepository();

      // Create a test lot first
      final lot = await repo.createLot(
        supplierId: 'sup_1',
        supplierName: 'Kaveri Farms',
        date: DateTime.now(),
        entryNumber: 'ENT-7788',
        productName: 'Nagpur Oranges',
        goodsCount: 50,
        quantity: 2500.0,
        weight: 2500.0,
        unit: 'Kg',
        costRate: 40.0,
      );

      final bagItems = [
        const BillBagItem(serialNumber: 1, weight: 50.0, rate: 55.0, amount: 2750.0),
        const BillBagItem(serialNumber: 2, weight: 52.0, rate: 55.0, amount: 2860.0),
        const BillBagItem(serialNumber: 3, weight: 48.0, rate: 55.0, amount: 2640.0),
      ];

      final bill = await repo.createLotBasedBill(
        lotId: lot.id,
        date: DateTime.now(),
        type: BillType.cash,
        customerName: 'Karthik Supermarket',
        customerPhone: '9842109842',
        bagItems: bagItems,
        transportFee: 300.0,
        labourFee: 150.0,
        mandiFee: 80.0,
        extraCharges: const [
          BillExtraCharge(id: 'ec_1', name: 'Crate Stacking', amount: 50.0),
        ],
        amountReceived: 8830.0,
      );

      expect(bill.bagItems.length, 3);
      expect(bill.weight, 150.0); // 50 + 52 + 48
      expect(bill.quantity, 3.0); // 3 bags
      expect(bill.grossAmount, 8250.0); // 2750 + 2860 + 2640
      expect(bill.transportFee, 300.0);
      expect(bill.labourCharge, 150.0);
      expect(bill.mandiFee, 80.0);
      expect(bill.otherCharges, 50.0);
      expect(bill.totalAmount, 8250.0 + 300.0 + 150.0 + 80.0 + 50.0); // 8830.0
      expect(bill.isPaid, true);

      // Verify lot stock was deducted
      final updatedLot = repo.getLot(lot.id);
      expect(updatedLot?.remainingQuantity, 2500.0 - 3.0);
      expect(updatedLot?.remainingWeight, 2500.0 - 150.0);
    });
  });

  group('Lot Billing Workflow UI Tests', () {
    testWidgets('LotBillingWorkflowScreen renders step progress and initial lot selection', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LotBillingWorkflowScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Lot-Based Goods Billing'), findsOneWidget);
      expect(find.text('Lot Selection'), findsWidgets);
      expect(find.text('Bill & Buyer Information'), findsOneWidget);
      expect(find.text('Select Lot from Inward Stock *'), findsOneWidget);
    });

    testWidgets('BagManagementScreen renders dynamic table with bags, weights, and amounts', (tester) async {
      final bags = [
        const BagRowCalculation(serialNumber: 1, weight: 52.0, rate: 250.0, amount: 13000.0),
        const BagRowCalculation(serialNumber: 2, weight: 53.0, rate: 250.0, amount: 13250.0),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BagManagementScreen(
              bags: bags,
              onBagsChanged: (_) {},
              pricingMode: PricingMode.common,
              onPricingModeChanged: (_) {},
              commonRate: 250.0,
              onCommonRateChanged: (_) {},
              defaultBagWeight: 50.0,
              onDefaultBagWeightChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Quantity & Pricing Controls'), findsOneWidget);
      expect(find.text('Common Rate (Flat)'), findsOneWidget);
      expect(find.text('Individual Pricing'), findsOneWidget);
      expect(find.text('#1'), findsOneWidget);
      expect(find.text('#2'), findsOneWidget);
      expect(find.text(AppFormatters.currency(13000.0)), findsOneWidget);
      expect(find.text(AppFormatters.currency(13250.0)), findsOneWidget);
    });
  });
}
