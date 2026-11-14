import 'package:flutter_test/flutter_test.dart';
import 'package:bsg_mobile/main.dart';
import 'package:bsg_mobile/data/repositories/app_repository.dart';
import 'package:bsg_mobile/data/models/bill_model.dart';
import 'package:bsg_mobile/data/models/payment_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('BSG App Core Business Logic Tests', () {
    late AppRepository repo;

    setUp(() {
      repo = AppRepository();
    });

    test('Initial Seed Data Loaded with Supplier and Customer terminology', () {
      final suppliers = repo.getSuppliers();
      final customers = repo.getCustomers();
      final lots = repo.getLots();

      expect(suppliers.isNotEmpty, true);
      expect(customers.isNotEmpty, true);
      expect(lots.isNotEmpty, true);
    });

    test('Creating a Lot sets initial stock correctly', () async {
      final supplier = repo.getSuppliers().first;
      final lot = await repo.createLot(
        supplierId: supplier.id,
        supplierName: supplier.name,
        date: DateTime.now(),
        productName: 'Shimla Apples',
        goodsCount: 20,
        quantity: 500,
        weight: 500,
        costRate: 80,
        labourCharge: 200,
      );

      expect(lot.lotNumber.startsWith('LOT-2026-'), true);
      expect(lot.remainingQuantity, 500);
      expect(lot.isAvailable, true);
      expect(lot.totalInitialCost, (500 * 80) + 200);
    });

    test('Cash Bill deducts lot stock and creates bill', () async {
      final lots = repo.getLots().where((l) => l.isAvailable).toList();
      final lot = lots.first;
      final prevRemaining = lot.remainingQuantity;

      final bill = await repo.createCashBill(
        lotId: lot.id,
        customerName: 'Counter Cash Buyer',
        date: DateTime.now(),
        quantity: 50,
        weight: 50,
        sellRate: 40,
        amountReceived: 2000,
      );

      expect(bill.type, BillType.cash);
      expect(bill.grossAmount, 2000);
      expect(bill.status, BillStatus.paid);

      // Verify stock was deducted
      final updatedLot = repo.getLot(lot.id);
      expect(updatedLot!.remainingQuantity, prevRemaining - 50);
    });

    test('Credit Bill posts balance due to Customer ledger and updates outstanding', () async {
      final customer = repo.getCustomers().first;
      final initialOutstanding = customer.currentOutstanding;
      final lot = repo.getLots().firstWhere((l) => l.isAvailable);

      final bill = await repo.createCreditBill(
        customerId: customer.id,
        lotId: lot.id,
        date: DateTime.now(),
        quantity: 100,
        weight: 100,
        sellRate: 45,
        labourCharge: 100,
        amountReceived: 0,
      );

      expect(bill.type, BillType.credit);
      expect(bill.totalAmount, (100 * 45) + 100);
      expect(bill.balanceDue, (100 * 45) + 100);

      // Verify customer outstanding increased
      final updatedCustomer = repo.getCustomer(customer.id);
      expect(updatedCustomer!.currentOutstanding, initialOutstanding + bill.balanceDue);
    });

    test('Cancelling a bill restores lot stock and reverses customer ledger', () async {
      final customer = repo.getCustomers().first;
      final lot = repo.getLots().firstWhere((l) => l.isAvailable);
      final lotInitialStock = lot.remainingQuantity;

      final bill = await repo.createCreditBill(
        customerId: customer.id,
        lotId: lot.id,
        date: DateTime.now(),
        quantity: 60,
        weight: 60,
        sellRate: 30,
        amountReceived: 0,
      );

      final customerBalanceAfterBill = repo.getCustomer(customer.id)!.currentOutstanding;
      expect(repo.getLot(lot.id)!.remainingQuantity, lotInitialStock - 60);

      // Cancel the bill
      await repo.cancelBill(bill.id, 'Entry error by billing clerk');

      // Verify bill status is cancelled
      final cancelledBill = repo.getBill(bill.id);
      expect(cancelledBill!.isCancelled, true);
      expect(cancelledBill.cancellationReason, 'Entry error by billing clerk');

      // Verify stock restored
      expect(repo.getLot(lot.id)!.remainingQuantity, lotInitialStock);

      // Verify customer ledger reversed
      expect(repo.getCustomer(customer.id)!.currentOutstanding, customerBalanceAfterBill - bill.balanceDue);
    });

    test('Recording a payment reduces customer outstanding and allocates to bills', () async {
      final customer = repo.getCustomers().first;
      final currentDue = customer.currentOutstanding;

      final payment = await repo.recordPayment(
        customerId: customer.id,
        date: DateTime.now(),
        amount: 2000,
        method: PaymentMethod.upi,
        referenceNumber: 'UPI98234123',
      );

      expect(payment.receiptNumber.startsWith('RCP-2026-'), true);
      final updatedCustomer = repo.getCustomer(customer.id);
      expect(updatedCustomer!.currentOutstanding, currentDue - 2000);
    });

    test('Customer Ledger accurately generates chronological entries and running balance', () {
      final customer = repo.getCustomers().first;
      final ledger = repo.getCustomerLedger(customer.id);

      expect(ledger.isNotEmpty, true);
      expect(ledger.first.description, 'Opening Balance');
      expect(ledger.last.runningBalance, customer.currentOutstanding);
    });

    test('Supplier Ledger accurately calculates running balance', () {
      final supplier = repo.getSuppliers().first;
      final ledger = repo.getSupplierLedger(supplier.id);

      expect(ledger.isNotEmpty, true);
      expect(ledger.first.description, 'Opening Balance');
      expect(ledger.first.credit, supplier.openingBalance);
    });

    test('Stock Summary calculates aggregated product stock correctly', () {
      final summary = repo.getStockSummary();
      expect(summary.isNotEmpty, true);

      final tomatoStock = summary.firstWhere((s) => s.productName.contains('Tomatoes'));
      expect(tomatoStock.totalInwardQuantity, 1250);
      expect(tomatoStock.remainingQuantity, 650);
      expect(tomatoStock.soldQuantity, 600);
    });
  });

  group('BSG App Widget Tests', () {
    testWidgets('App renders Home Dashboard, search button, and bottom navigation destinations', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: BSGApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify bottom navigation tabs exist
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Bills'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Users'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);

      // Verify 6 Big Box Action shortcuts exist
      expect(find.text('Create Cash Bill'), findsOneWidget);
      expect(find.text('Create Credit Bill'), findsOneWidget);
      expect(find.text('Received Amount'), findsNWidgets(2)); // Big box action + KPI overview card
      expect(find.text('Create Lot'), findsOneWidget);
      expect(find.text('Users Directory'), findsOneWidget);
      expect(find.text('Add Expense'), findsOneWidget);
    });
  });
}
