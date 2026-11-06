class DailyTransactionItem {
  final String id;
  final String type; // 'Goods Entry', 'Bill Generated', 'Initial Payment', 'Payment Received', 'Bill Cancelled'
  final String customerName;
  final String village;
  final String phone;
  final String? vehicleNumber;
  final String referenceNumber;
  final double amount;
  final DateTime time;
  final String status;

  const DailyTransactionItem({
    required this.id,
    required this.type,
    required this.customerName,
    required this.village,
    required this.phone,
    this.vehicleNumber,
    required this.referenceNumber,
    required this.amount,
    required this.time,
    required this.status,
  });
}

class DailySummary {
  final DateTime date;
  final double activeSalesTotal;
  final double initialPaymentsReceived;
  final double otherPaymentsReceived;
  final double totalCollections;
  final double outstandingBalance;
  final int goodsEntriesCount;
  final int billsCount;
  final int cancelledBillsCount;
  final List<DailyTransactionItem> transactions;

  const DailySummary({
    required this.date,
    required this.activeSalesTotal,
    required this.initialPaymentsReceived,
    required this.otherPaymentsReceived,
    required this.totalCollections,
    required this.outstandingBalance,
    required this.goodsEntriesCount,
    required this.billsCount,
    required this.cancelledBillsCount,
    required this.transactions,
  });
}
