import 'package:flutter_test/flutter_test.dart';
import 'package:buyer_seller_goods_management/data/mock_repository.dart';
import 'package:buyer_seller_goods_management/data/models/bill.dart';
import 'package:buyer_seller_goods_management/data/models/bill_item.dart';
import 'package:buyer_seller_goods_management/data/models/goods_entry.dart';
import 'package:buyer_seller_goods_management/data/models/goods_entry_item.dart';
import 'package:buyer_seller_goods_management/data/models/payment.dart';

void main() {
  group('Billing Calculation Engine Tests', () {
    test('Calculates correct subtotal, labour, payable, and remaining balance', () {
      final bill = Bill(
        id: 'test-bill-1',
        billNumber: 'BILL-TEST-001',
        customerId: 'cust-1',
        billDate: DateTime.now(),
        items: const [
          BillItem(id: 'i1', description: 'Item A', quantity: 10, weight: 200, rate: 30, lineTotal: 6000),
          BillItem(id: 'i2', description: 'Item B', quantity: 15, weight: 300, rate: 20, lineTotal: 6000),
        ],
        subtotal: 12000.0,
        labourCharge: 500.0,
        previousBalanceSnapshot: 3000.0,
        initialPaymentApplied: 5000.0,
        otherPaymentsApplied: 2000.0,
        createdAt: DateTime.now(),
      );

      // Current Bill Total = 12000 + 500 = 12500
      expect(bill.currentBillTotal, equals(12500.0));

      // Gross Amount Payable = 12500 + 3000 = 15500
      expect(bill.amountPayable, equals(15500.0));

      // Payments applied = 5000 + 2000 = 7000
      expect(bill.totalPaymentsApplied, equals(7000.0));

      // Remaining due = 15500 - 7000 = 8500
      expect(bill.remainingBalance, equals(8500.0));
      expect(bill.excessCredit, equals(0.0));
    });

    test('Handles excess advance correctly as customer credit', () {
      final bill = Bill(
        id: 'test-bill-2',
        billNumber: 'BILL-TEST-002',
        customerId: 'cust-4',
        billDate: DateTime.now(),
        items: const [
          BillItem(id: 'i1', description: 'Chilli', quantity: 10, weight: 100, rate: 50, lineTotal: 5000),
        ],
        subtotal: 5000.0,
        labourCharge: 200.0,
        previousBalanceSnapshot: 0.0,
        initialPaymentApplied: 8000.0, // Advance exceeds total!
        otherPaymentsApplied: 0.0,
        createdAt: DateTime.now(),
      );

      expect(bill.currentBillTotal, equals(5200.0));
      expect(bill.amountPayable, equals(5200.0));
      expect(bill.remainingBalance, equals(0.0)); // No remaining due
      expect(bill.excessCredit, equals(2800.0)); // 8000 - 5200 = 2800 credit
    });
  });

  group('Mock Repository & Financial Accounting Reconciliation Tests', () {
    late MockRepository repo;

    setUp(() {
      repo = MockRepository();
      repo.resetDemoData();
    });

    test('Customer account ledger running balance matches customer balance', () {
      final customers = repo.getCustomers();

      for (final customer in customers) {
        final balance = repo.getCustomerBalance(customer.id);
        final ledger = repo.getCustomerLedger(customer.id);

        if (ledger.isNotEmpty) {
          final lastRunningBalance = ledger.last.runningBalance;
          expect(
            (lastRunningBalance - balance).abs(),
            lessThan(0.01),
            reason: 'Ledger final balance must equal customer calculated balance for ${customer.name}',
          );
        } else {
          expect(balance, equals(0.0));
        }
      }
    });

    test('Adding a goods entry with initial payment creates a payment transaction', () {
      final initialPaymentCount = repo.getPayments().length;

      final entry = GoodsEntry(
        id: 'test-ge-1',
        entryNumber: 'GE-TEST-999',
        customerId: 'cust-1',
        entryDate: DateTime.now(),
        lotNumber: 'LOT-TEST-99',
        goodsCount: 20,
        items: const [
          GoodsEntryItem(
            id: 'item-1',
            productName: 'Tomatoes',
            goodsName: 'Tomatoes',
            quantity: 20,
            weight: 500,
            costRate: 20,
            sellRate: 25,
          ),
        ],
        initialPaymentAmount: 4000.0,
        initialPaymentMode: 'UPI',
        initialPaymentRef: 'UPI-TEST-123',
        createdAt: DateTime.now(),
      );

      repo.addGoodsEntry(entry);

      expect(repo.getPayments().length, equals(initialPaymentCount + 1));
      final recordedPayment = repo.getPayments().first;
      expect(recordedPayment.amount, equals(4000.0));
      expect(recordedPayment.paymentType, equals(PaymentType.initialAdvance));
      expect(recordedPayment.customerId, equals('cust-1'));
    });

    test('Cancelling a bill excludes it from sales and adjusts ledger', () {
      final bills = repo.getBills().where((b) => b.status != BillStatus.cancelled).toList();
      final billToCancel = bills.first;

      final prevSales = repo.getDashboardMetrics().todaySales;
      final prevBalance = repo.getCustomerBalance(billToCancel.customerId);

      repo.cancelBill(
        billToCancel.id,
        reason: 'Client request for cancellation test',
        cancelledBy: 'Test Admin',
      );

      final updatedBill = repo.getBillById(billToCancel.id);
      expect(updatedBill?.status, equals(BillStatus.cancelled));
      expect(updatedBill?.cancellationReason, equals('Client request for cancellation test'));

      // If the cancelled bill was dated today, verify sales were reduced
      final isToday = billToCancel.billDate.day == DateTime.now().day;
      if (isToday) {
        final newSales = repo.getDashboardMetrics().todaySales;
        expect(newSales, equals(prevSales - billToCancel.currentBillTotal));
      }

      // Cancelled bill amount is deducted from customer balance
      final newBalance = repo.getCustomerBalance(billToCancel.customerId);
      expect(newBalance, equals(prevBalance - billToCancel.currentBillTotal));
    });

    test('Daily summary accurately reports sales vs collections', () {
      final summary = repo.getDailySummary(DateTime.now());

      expect(summary.activeSalesTotal, isNonNegative);
      expect(summary.totalCollections, isNonNegative);
      expect(summary.initialPaymentsReceived, isNonNegative);
      expect(summary.otherPaymentsReceived, isNonNegative);
      expect(summary.totalCollections, equals(summary.initialPaymentsReceived + summary.otherPaymentsReceived));
    });
  });
}
