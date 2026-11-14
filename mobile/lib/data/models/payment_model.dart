enum PaymentMethod { cash, bank, upi, cheque }

extension PaymentMethodExt on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Hand Cash';
      case PaymentMethod.upi:
        return 'UPI / GPay';
      case PaymentMethod.bank:
        return 'Bank Transfer';
      case PaymentMethod.cheque:
        return 'Cheque';
    }
  }
}

class PaymentAllocation {
  final String billId;
  final String billNumber;
  final double allocatedAmount;

  const PaymentAllocation({
    required this.billId,
    required this.billNumber,
    required this.allocatedAmount,
  });
}

class Payment {
  final String id;
  final String receiptNumber;
  final String customerId;
  final String customerName;
  final DateTime date;
  final double amount;
  final PaymentMethod method;
  final String? referenceNumber;
  final String? notes;
  final List<PaymentAllocation> allocations;
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.receiptNumber,
    required this.customerId,
    required this.customerName,
    required this.date,
    required this.amount,
    required this.method,
    this.referenceNumber,
    this.notes,
    this.allocations = const [],
    required this.createdAt,
  });
}

