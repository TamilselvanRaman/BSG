import 'dart:math';
import 'package:uuid/uuid.dart';
import 'demo_data.dart';
import 'models/customer.dart';
import 'models/goods_entry.dart';
import 'models/bill.dart';
import 'models/payment.dart';
import 'models/ledger_entry.dart';
import 'models/dashboard_metrics.dart';
import 'models/daily_summary.dart';
import 'models/commodity.dart';
import 'models/seller_load.dart';

class MockRepository {
  static final MockRepository _instance = MockRepository._internal();
  factory MockRepository() => _instance;

  final _uuid = const Uuid();

  List<Customer> _customers = [];
  List<SellerLoad> _sellerLoads = [];
  List<GoodsEntry> _goodsEntries = [];
  List<Bill> _bills = [];
  List<Payment> _payments = [];
  List<Commodity> _commodities = [];

  MockRepository._internal() {
    resetDemoData();
  }

  void resetDemoData() {
    _customers = List.from(DemoData.initialCustomers);
    _sellerLoads = List.from(DemoData.initialSellerLoads);
    _goodsEntries = List.from(DemoData.initialGoodsEntries);
    _bills = List.from(DemoData.initialBills);
    _payments = List.from(DemoData.initialPayments);
    _commodities = List.from(DemoData.initialCommodities);
  }

  // --- Seller Loads ---
  List<SellerLoad> getSellerLoads() => List.unmodifiable(_sellerLoads);

  SellerLoad? getSellerLoadById(String id) {
    try {
      return _sellerLoads.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  void addSellerLoad(SellerLoad load) {
    _sellerLoads.insert(0, load);
  }

  void updateSellerLoad(SellerLoad load) {
    final index = _sellerLoads.indexWhere((s) => s.id == load.id);
    if (index != -1) {
      _sellerLoads[index] = load;
    }
  }

  // --- Commodities Catalog ---
  List<Commodity> getCommodities() => List.unmodifiable(_commodities);

  Commodity? getCommodityById(String id) {
    try {
      return _commodities.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Commodity? getCommodityByName(String name) {
    try {
      final clean = name.trim().toLowerCase();
      return _commodities.firstWhere((c) => c.name.toLowerCase() == clean);
    } catch (_) {
      return null;
    }
  }

  void addCommodity(Commodity commodity) {
    _commodities.insert(0, commodity);
  }

  void updateCommodity(Commodity commodity) {
    final index = _commodities.indexWhere((c) => c.id == commodity.id);
    if (index != -1) {
      _commodities[index] = commodity;
    }
  }

  // --- Customers ---
  List<Customer> getCustomers() => List.unmodifiable(_customers);

  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void addCustomer(Customer customer) {
    _customers.insert(0, customer);
  }

  void updateCustomer(Customer customer) {
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      _customers[index] = customer;
    }
  }

  // --- Goods Entries ---
  List<GoodsEntry> getGoodsEntries() => List.unmodifiable(_goodsEntries);

  GoodsEntry? getGoodsEntryById(String id) {
    try {
      return _goodsEntries.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  void addGoodsEntry(GoodsEntry entry) {
    _goodsEntries.insert(0, entry);

    // If an initial payment was received with the goods entry, record it in the payment ledger
    if (entry.initialPaymentAmount > 0) {
      final payment = Payment(
        id: 'pay-${_uuid.v4().substring(0, 8)}',
        customerId: entry.customerId,
        goodsEntryId: entry.id,
        billId: null, // Will be linked when bill is created
        amount: entry.initialPaymentAmount,
        paymentDate: entry.entryDate,
        paymentMode: entry.initialPaymentMode,
        paymentType: PaymentType.initialAdvance,
        reference: entry.initialPaymentRef,
        notes: entry.initialPaymentNotes.isNotEmpty
            ? entry.initialPaymentNotes
            : 'Initial advance for Goods Entry ${entry.entryNumber}',
        createdAt: DateTime.now(),
      );
      _payments.insert(0, payment);
    }
  }

  void updateGoodsEntry(GoodsEntry entry) {
    final index = _goodsEntries.indexWhere((g) => g.id == entry.id);
    if (index != -1) {
      _goodsEntries[index] = entry;
    }
  }

  // --- Bills ---
  List<Bill> getBills() => List.unmodifiable(_bills);

  Bill? getBillById(String id) {
    try {
      return _bills.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  void createBill(Bill bill) {
    _bills.insert(0, bill);

    // Update the linked goods entry status if any
    if (bill.goodsEntryId != null) {
      final entryIndex = _goodsEntries.indexWhere((g) => g.id == bill.goodsEntryId);
      if (entryIndex != -1) {
        _goodsEntries[entryIndex] = _goodsEntries[entryIndex].copyWith(
          status: GoodsEntryStatus.billed,
        );
      }

      // Link any initial payment from this entry to the bill
      for (int i = 0; i < _payments.length; i++) {
        if (_payments[i].goodsEntryId == bill.goodsEntryId && _payments[i].billId == null) {
          _payments[i] = _payments[i].copyWith(billId: bill.id);
        }
      }
    }
  }

  void updateBill(Bill bill) {
    final index = _bills.indexWhere((b) => b.id == bill.id);
    if (index != -1) {
      _bills[index] = bill;
    }
  }

  void cancelBill(String billId, {required String reason, required String cancelledBy}) {
    final index = _bills.indexWhere((b) => b.id == billId);
    if (index != -1) {
      final old = _bills[index];
      _bills[index] = old.copyWith(
        status: BillStatus.cancelled,
        cancellationReason: reason,
        cancelledAt: DateTime.now(),
        cancelledBy: cancelledBy,
      );

      // Note: Payment records are preserved as audit ledger credit
    }
  }

  // --- Payments ---
  List<Payment> getPayments() => List.unmodifiable(_payments);

  void recordPayment(Payment payment) {
    _payments.insert(0, payment);

    // If payment is linked to a bill, update bill's otherPaymentsApplied and status
    if (payment.billId != null) {
      final billIndex = _bills.indexWhere((b) => b.id == payment.billId);
      if (billIndex != -1) {
        final bill = _bills[billIndex];
        final newOther = bill.otherPaymentsApplied + payment.amount;
        final totalPaid = bill.initialPaymentApplied + newOther;

        BillStatus newStatus = bill.status;
        if (totalPaid >= bill.amountPayable) {
          newStatus = BillStatus.paid;
        } else if (totalPaid > 0) {
          newStatus = BillStatus.partiallyPaid;
        }

        _bills[billIndex] = bill.copyWith(
          otherPaymentsApplied: newOther,
          status: newStatus,
        );
      }
    }
  }

  // --- Financial Balances & Ledger Calculations ---

  /// Authoritative Customer Outstanding Balance:
  /// Opening balance + (All active non-cancelled bills total) - (All customer payments)
  double getCustomerBalance(String customerId) {
    final customer = getCustomerById(customerId);
    final openingBalance = customer?.openingBalance ?? 0.0;

    final customerActiveBillsTotal = _bills
        .where((b) => b.customerId == customerId && b.status != BillStatus.cancelled)
        .fold(0.0, (sum, b) => sum + b.currentBillTotal);

    final customerPaymentsTotal = _payments
        .where((p) => p.customerId == customerId && p.status == PaymentStatus.completed)
        .fold(0.0, (sum, p) => sum + p.amount);

    return openingBalance + customerActiveBillsTotal - customerPaymentsTotal;
  }

  /// Get Unapplied / Advance Payments for a Customer
  double getCustomerAdvances(String customerId) {
    final balance = getCustomerBalance(customerId);
    if (balance < 0) {
      return balance.abs(); // Overpaid / credit advance
    }
    return 0.0;
  }

  /// Complete Customer Account Ledger with chronological Debit / Credit / Running Balance
  List<LedgerEntry> getCustomerLedger(String customerId) {
    final List<LedgerEntry> entries = [];
    final customer = getCustomerById(customerId);
    double running = 0.0;

    // 1. Opening balance
    if (customer != null && customer.openingBalance > 0) {
      running += customer.openingBalance;
      entries.add(LedgerEntry(
        id: 'le-open-${customer.id}',
        customerId: customerId,
        date: customer.createdAt,
        transactionReference: 'OPENING',
        description: 'Opening Balance brought forward',
        debit: customer.openingBalance,
        credit: 0.0,
        runningBalance: running,
      ));
    }

    // Collect all financial transactions for customer:
    // - Bills issued
    // - Cancelled bill reversals
    // - Initial payments & Bill payments
    final List<Map<String, dynamic>> rawEvents = [];

    for (final bill in _bills.where((b) => b.customerId == customerId)) {
      // Bill issued event (Debit)
      rawEvents.add({
        'type': 'BILL',
        'date': bill.billDate,
        'bill': bill,
      });

      // If cancelled, cancellation reversal event (Credit)
      if (bill.status == BillStatus.cancelled && bill.cancelledAt != null) {
        rawEvents.add({
          'type': 'BILL_CANCELLED',
          'date': bill.cancelledAt!,
          'bill': bill,
        });
      }
    }

    for (final pay in _payments.where((p) => p.customerId == customerId && p.status == PaymentStatus.completed)) {
      rawEvents.add({
        'type': 'PAYMENT',
        'date': pay.paymentDate,
        'payment': pay,
      });
    }

    // Sort events chronologically
    rawEvents.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    int counter = 1;
    for (final ev in rawEvents) {
      final type = ev['type'] as String;
      final date = ev['date'] as DateTime;

      if (type == 'BILL') {
        final b = ev['bill'] as Bill;
        running += b.currentBillTotal;
        entries.add(LedgerEntry(
          id: 'le-bill-${b.id}',
          customerId: customerId,
          date: date,
          transactionReference: b.billNumber,
          description: 'Bill Issued (Subtotal: ₹${b.subtotal.toStringAsFixed(0)} + Labour: ₹${b.labourCharge.toStringAsFixed(0)})',
          debit: b.currentBillTotal,
          credit: 0.0,
          runningBalance: running,
          relatedBillId: b.id,
          relatedEntryId: b.goodsEntryId,
        ));
      } else if (type == 'BILL_CANCELLED') {
        final b = ev['bill'] as Bill;
        running -= b.currentBillTotal;
        entries.add(LedgerEntry(
          id: 'le-canc-${b.id}',
          customerId: customerId,
          date: date,
          transactionReference: 'CANCEL-${b.billNumber}',
          description: 'Bill Cancelled Reversal: ${b.cancellationReason}',
          debit: 0.0,
          credit: b.currentBillTotal,
          runningBalance: running,
          relatedBillId: b.id,
        ));
      } else if (type == 'PAYMENT') {
        final p = ev['payment'] as Payment;
        running -= p.amount;
        final desc = p.paymentType == PaymentType.initialAdvance
            ? 'Initial Advance Received (${p.paymentMode}${p.reference.isNotEmpty ? ' - Ref: ${p.reference}' : ''})'
            : 'Payment Received (${p.paymentMode}${p.reference.isNotEmpty ? ' - Ref: ${p.reference}' : ''})';

        entries.add(LedgerEntry(
          id: 'le-pay-${p.id}-${counter++}',
          customerId: customerId,
          date: date,
          transactionReference: p.reference.isNotEmpty ? p.reference : 'PAY-${p.id.substring(0, 6)}',
          description: desc,
          debit: 0.0,
          credit: p.amount,
          runningBalance: running,
          relatedBillId: p.billId,
          relatedEntryId: p.goodsEntryId,
        ));
      }
    }

    return entries;
  }

  // --- Dashboard Metrics ---
  DashboardMetrics getDashboardMetrics() {
    final now = DateTime.now();
    bool isToday(DateTime dt) => dt.year == now.year && dt.month == now.month && dt.day == now.day;

    final todayActiveBills = _bills.where((b) => isToday(b.billDate) && b.status != BillStatus.cancelled);
    final todaySales = todayActiveBills.fold(0.0, (sum, b) => sum + b.currentBillTotal);

    final todayInitialPays = _payments
        .where((p) => isToday(p.paymentDate) && p.paymentType == PaymentType.initialAdvance && p.status == PaymentStatus.completed)
        .fold(0.0, (sum, p) => sum + p.amount);

    final todayOtherPays = _payments
        .where((p) => isToday(p.paymentDate) && p.paymentType != PaymentType.initialAdvance && p.status == PaymentStatus.completed)
        .fold(0.0, (sum, p) => sum + p.amount);

    final todayTotalCollections = todayInitialPays + todayOtherPays;

    // Total outstanding across all buyers
    double totalOutstanding = 0.0;
    for (final cust in _customers.where((c) => c.customerType != CustomerType.seller)) {
      final bal = getCustomerBalance(cust.id);
      if (bal > 0) {
        totalOutstanding += bal;
      }
    }

    final totalBuyers = _customers.where((c) => c.customerType != CustomerType.seller).length;
    final totalGoodsEntries = _goodsEntries.length;
    final billsGenerated = _bills.length;
    final pendingBills = _bills.where((b) => b.status == BillStatus.unpaid || b.status == BillStatus.partiallyPaid).length;
    final cancelledBills = _bills.where((b) => b.status == BillStatus.cancelled).length;

    return DashboardMetrics(
      todaySales: todaySales,
      todayInitialPayments: todayInitialPays,
      todayOtherPayments: todayOtherPays,
      todayTotalCollections: todayTotalCollections,
      outstandingBuyerBalances: totalOutstanding,
      totalBuyers: totalBuyers,
      totalGoodsEntries: totalGoodsEntries,
      billsGenerated: billsGenerated,
      pendingBills: pendingBills,
      cancelledBills: cancelledBills,
    );
  }

  // --- Daily Summary ---
  DailySummary getDailySummary(DateTime targetDate) {
    bool isSameDay(DateTime dt) =>
        dt.year == targetDate.year && dt.month == targetDate.month && dt.day == targetDate.day;

    final dayBills = _bills.where((b) => isSameDay(b.billDate)).toList();
    final dayActiveBills = dayBills.where((b) => b.status != BillStatus.cancelled).toList();
    final dayCancelledBills = dayBills.where((b) => b.status == BillStatus.cancelled).toList();

    final activeSalesTotal = dayActiveBills.fold(0.0, (sum, b) => sum + b.currentBillTotal);

    final dayPayments = _payments.where((p) => isSameDay(p.paymentDate) && p.status == PaymentStatus.completed).toList();
    final initialPays = dayPayments
        .where((p) => p.paymentType == PaymentType.initialAdvance)
        .fold(0.0, (sum, p) => sum + p.amount);
    final otherPays = dayPayments
        .where((p) => p.paymentType != PaymentType.initialAdvance)
        .fold(0.0, (sum, p) => sum + p.amount);
    final totalCollections = initialPays + otherPays;

    final dayEntries = _goodsEntries.where((g) => isSameDay(g.entryDate)).toList();

    // Outstanding total remaining for bills issued that day
    final dayOutstanding = dayActiveBills.fold(0.0, (sum, b) => sum + b.remainingBalance);

    // Build transaction list
    final List<DailyTransactionItem> txList = [];

    for (final e in dayEntries) {
      final cust = getCustomerById(e.customerId);
      txList.add(DailyTransactionItem(
        id: 'tx-ge-${e.id}',
        type: 'Goods Entry',
        customerName: cust?.name ?? 'Unknown Buyer',
        village: cust?.village ?? '',
        phone: cust?.phone ?? '',
        vehicleNumber: e.vehicleNumber.isNotEmpty ? e.vehicleNumber : null,
        referenceNumber: e.entryNumber,
        amount: e.totalAmount,
        time: e.entryDate,
        status: e.status.name.toUpperCase(),
      ));
    }

    for (final b in dayBills) {
      final cust = getCustomerById(b.customerId);
      txList.add(DailyTransactionItem(
        id: 'tx-bill-${b.id}',
        type: b.status == BillStatus.cancelled ? 'Bill Cancelled' : 'Bill Generated',
        customerName: cust?.name ?? 'Unknown Buyer',
        village: cust?.village ?? '',
        phone: cust?.phone ?? '',
        referenceNumber: b.billNumber,
        amount: b.currentBillTotal,
        time: b.billDate,
        status: b.statusLabel,
      ));
    }

    for (final p in dayPayments) {
      final cust = getCustomerById(p.customerId);
      txList.add(DailyTransactionItem(
        id: 'tx-pay-${p.id}',
        type: p.paymentType == PaymentType.initialAdvance ? 'Initial Payment' : 'Payment Received',
        customerName: cust?.name ?? 'Unknown Buyer',
        village: cust?.village ?? '',
        phone: cust?.phone ?? '',
        referenceNumber: p.reference.isNotEmpty ? p.reference : 'PAY-${p.id.substring(0, 6)}',
        amount: p.amount,
        time: p.paymentDate,
        status: '${p.paymentMode} (${p.typeLabel})',
      ));
    }

    txList.sort((a, b) => b.time.compareTo(a.time));

    return DailySummary(
      date: targetDate,
      activeSalesTotal: activeSalesTotal,
      initialPaymentsReceived: initialPays,
      otherPaymentsReceived: otherPays,
      totalCollections: totalCollections,
      outstandingBalance: dayOutstanding,
      goodsEntriesCount: dayEntries.length,
      billsCount: dayActiveBills.length,
      cancelledBillsCount: dayCancelledBills.length,
      transactions: txList,
    );
  }
}
